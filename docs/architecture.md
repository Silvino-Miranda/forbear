# Forbear Framework — Architecture Document

> **Version:** 1.0 | **Date:** 2026-02-21 | **Status:** Draft
> **Author:** Aria (architect) | **Input:** docs/prd.md

---

## Scope

This document covers the technical architecture for the 5 critical missing features identified in the PRD. It is intended as input for @dev implementation and @sm story creation.

**Source files analyzed:** `src/root.zig`, `src/node.zig`, `src/layouting.zig`, `src/graphics.zig`

---

## 1. Story 3.2 — Reducing `try` in the Public API

**Risk:** HIGH | **Impact:** Public API breaking change potential

### Root Cause

Every call to `element()`, `text()`, and `component()` returns `anyerror!T` due to arena allocation. Zig mandates explicit error propagation — `try` cannot be elided without changing the function signatures.

Current pattern:
```zig
(try element(arena, .{}))({
    (try element(arena, .{}))({
        try text(arena, "Hello");
    });
});
```

### Recommended Architecture: Error Context Pattern

Introduce an `ElementContext` that wraps the arena allocator and captures errors internally, exposing a single error check at the frame boundary.

```zig
// Proposed — try only at context initialization
const ctx = try forbear.frameContext(arena);

ctx.element(.{}, .{
    ctx.element(.{}, .{
        ctx.text("Hello"),
    }),
    ctx.text("World"),
});

// Single try at frame end — checks accumulated errors
try ctx.flush();
```

**Mechanism:** `ElementContext` holds `error_slot: ?anyerror = null`. All `ctx.*` functions are `fn(...) void`. On internal failure, error is stored in slot. `flush()` returns the accumulated error.

**Key decisions:**
- Additive API — existing `try element(arena, ...)` pattern remains valid
- Two API styles coexist during migration period
- Errors detected at flush, not at point of failure (acceptable trade-off)

**Required spike:** Prototype `ElementContext` with 3 real components before full implementation. Validate arena OOM propagation behavior.

**Discarded alternatives:**
- `@panic` on error — converts recoverable errors to crashes
- comptime error elision — Zig does not support suppressing `!T` in comptime cleanly

---

## 2. Scrolling — Clipping + Spring Physics Architecture

**Risk:** MEDIUM | **Impact:** New feature, no breaking changes

### Existing Infrastructure

```zig
// Already in Context (root.zig):
scrollPosition: Vec2,           // spring-eased value
effectiveScrollPosition: Vec2,  // snap position
```

`useSpringTransition()` already implements spring physics. Scrolling reuses it.

### Layer Architecture

**Layer 1 — Style** (`node.zig`):
```zig
pub const Overflow = enum { visible, scroll, hidden };

// Add to IncompleteStyle and Style:
overflow: Overflow = .visible,
```

**Layer 2 — Layout** (`layouting.zig`):
- `LayoutBox` gains `clipRect: ?Rect = null`
- During `layout()`, if `style.overflow == .scroll`, node propagates its `size` as `clipRect` to children
- Children receive their real absolute positions (not clipped in layout — only in rendering)

**Layer 3 — Rendering** (`graphics.zig`):
- Before rendering each `LayoutBox`, check if active `clipRect` is in stack
- Use `vkCmdSetScissor` to define clipping viewport per scrollable element
- Scissor stack: `scissorStack: [8]Rect` — supports up to 8 levels of nested scroll

**Layer 4 — Input** (`root.zig` + window platform):
- Mouse wheel hit-test: innermost element in `hoveredElementKeys` with `overflow == .scroll` receives event
- `useScroll()` hook returns `scrollOffset: Vec2` with spring physics

```zig
// Developer-facing API
const scrollY = try forbear.useScroll(.{ .direction = .vertical });

(try element(arena, .{ .overflow = .scroll, .height = .{ .fixed = 400 } }))({
    // Long content rendered here
    // scrollY drives translate offset
});
```

**Spring integration:** `useScroll()` internally calls `useSpringTransition()` — no new animation system required.

---

## 3. Type-Safe Resources — Comptime Handle Pattern

**Risk:** LOW-MEDIUM | **Impact:** Optional breaking change (gradual migration possible)

### Current Problem

```zig
// Runtime error if typo — not caught at compile time
try forbear.registerFont("inter", @embedFile("inter.ttf"));
const font = try forbear.useFont("inter");
```

### Proposed Architecture: Comptime Token

```zig
pub fn FontHandle(comptime id: []const u8) type {
    return struct {
        pub const identifier = id;
        pub fn get() !*Font { return useFont(id); }
    };
}

// registerFont returns handle directly
pub fn registerFont(comptime id: []const u8, comptime contents: []const u8) !FontHandle(id) {
    // registration logic...
    return FontHandle(id){};
}
```

**Usage:**
```zig
// Typo in "Inter" = compile error (type mismatch)
const Inter = try forbear.registerFont("inter", @embedFile("inter.ttf"));
const font = try Inter.get();
```

**Properties:**
- Zero runtime overhead — pure comptime types
- No breaking change — `useFont(string)` continues to work
- Typo in `.get()` call is a compile error (distinct types per ID)
- Duplicate ID registration handled by existing HashMap deduplication

**Same pattern applies to:** `ImageHandle`, `SvgHandle`

---

## 4. Image Async Loading — Deferred Thread Pattern

**Risk:** MEDIUM | **Impact:** Performance fix, no API changes

### Root Cause

`registerImage()` calls `stb_image` decode synchronously, blocking the render thread. Images > 1MB decompress in > 16ms, causing visible frame drops.

### Architecture: Atomic State + Worker Thread

```
┌──────────────────────────────────────────────┐
│  Main Thread (rendering loop)                 │
│  registerImage() → creates Image{.loading}   │
│  spawns worker thread                         │
│                                               │
│  Per frame:                                   │
│    useImage() → image.state.load(.acquire)    │
│      .loading → render placeholder color      │
│      .ready   → render real GPU texture       │
│      .failed  → render error placeholder      │
└──────────────────────────────────────────────┘
         │ std.atomic.Value
         ▼
┌──────────────────────────────────────────────┐
│  Worker Thread (std.Thread.spawn)             │
│  stb_image decode → RGBA pixels               │
│  Vulkan staging buffer upload                 │
│  image.state.store(.ready, .release)          │
└──────────────────────────────────────────────┘
```

**Image struct extension:**
```zig
pub const Image = struct {
    pub const State = enum { loading, ready, failed };

    state: std.atomic.Value(State),
    texture: ?GpuTexture,       // null while loading
    placeholder: Vec4,          // fallback color (default: transparent)
    aspectRatio: ?f32,          // available before decode (from PNG/JPEG header)
};
```

**API unchanged:** `registerImage()` and `useImage()` signatures stay identical. The loading behavior is transparent.

**MVP simplification:** `std.Thread.spawn` per image (no thread pool). For 10 showcase examples, image count is low. Thread pool is a future optimization.

---

## 5. SVG Support — nanosvg C Binding

**Risk:** MEDIUM | **Impact:** New feature, new C dependency

### Library Decision: nanosvg

| Option | Pro | Con |
|---|---|---|
| **nanosvg** (C, header-only) | Minimal, Zig-friendly, ~2500 LOC | Limited SVG subset (no SVG text/filters) |
| **resvg** (Rust) | Complete, high quality | Rust dependency, linking complexity |
| **Pure Zig** | Zero dependencies | Months of work, out of MVP scope |
| **lunasvg** (C++) | Complete | C++ FFI complexity in Zig |

**Decision: nanosvg** — sufficient for icons and simple illustrations (primary use case). Header-only C integrates cleanly as `dependencies/nanosvg/` (matches existing local dependency pattern with freetype, stb_image).

### Integration Pipeline

```
SVG file (comptime embedded)
       │
       ▼ nanosvg_parse()
NSVGimage (C structs)
       │
       ▼ nanosvgrastr_rasterize(width, height)
RGBA pixel buffer
       │
       ▼ existing stb_image upload pathway
GpuTexture → Texture Atlas
```

**Public API:**
```zig
pub fn registerSvg(
    comptime id: []const u8,
    comptime contents: []const u8,
    rasterSize: Vec2,     // rasterization resolution
) !SvgHandle(id)
```

**Known limitation (document in API):** nanosvg does not support SVG with embedded text, complex filters, or animation. Adequate for icons and static illustrations.

---

## Implementation Sequence

Recommended order balancing risk and value delivery:

| Order | Feature | Rationale |
|---|---|---|
| 1 | **Scrolling** | Lowest risk, highest value, reuses existing spring infrastructure |
| 2 | **Image async** | Immediately fixes frame drops in existing uhoh.com example |
| 3 | **SVG** | Isolated external dependency, test in isolation |
| 4 | **Type-safe resources** | Gradual refactor, no functional urgency |
| 5 | **try reduction** | Spike first, implement last — highest architectural risk |

---

## New Dependencies Summary

| Feature | New Files | External Dependencies | Breaking Change |
|---|---|---|---|
| try reduction | `ElementContext` in root.zig | None | No (additive) |
| Scrolling | overflow in node.zig, clipRect in layouting.zig, scissorStack in graphics.zig | None | No |
| Type-safe resources | `FontHandle`/`ImageHandle` in root.zig | None | No (additive) |
| Image async | atomic state + thread in graphics.zig | None (std.Thread) | No (same API) |
| SVG | c.zig bindings + nanosvg | nanosvg (header-only C) | No |

---

## Open Questions for @dev

1. **try reduction spike:** Is `ElementContext.flush()` semantics compatible with immediate-mode frame loop? What happens if flush is never called?
2. **Vulkan thread safety:** Does the existing Vulkan renderer support texture upload from a non-render thread? Requires `vkQueueSubmit` from worker thread or transfer queue.
3. **nanosvg raster size:** Should rasterization resolution be fixed at register time or per-use? Fixed at register is simpler but less flexible.
4. **Scroll event priority:** If two nested scrollable elements receive a wheel event, which wins? Proposed: innermost element in hover stack.

---

## Handoff to @sm

Stories to create from this document (in implementation order):

1. **Story — Scrolling:** overflow style + clipRect in LayoutBox + vkCmdSetScissor + useScroll() hook
2. **Story — Image async:** Atomic Image.state + std.Thread.spawn in registerImage + placeholder rendering
3. **Story — SVG:** nanosvg dependency + registerSvg() + rasterization pipeline
4. **Story — Type-safe resources:** FontHandle/ImageHandle comptime pattern + migration of uhoh.com example
5. **Story — try reduction SPIKE:** Prototype ElementContext, validate arena semantics, produce implementation plan
6. **Story — try reduction IMPL:** Implement ElementContext based on spike findings

— Aria, arquitetando o futuro 🏗️
