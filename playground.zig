//! forbear Playground — Feature Showcase
//! Demonstrates Story 1.1 (Percentage Sizing), Story 1.2 (Scrolling), Story 1.3 (Slotting), and Story 1.5 (Underlined Text)

const std = @import("std");
const forbear = @import("forbear");

/// Card component — receives arbitrary content via componentChildrenSlot().
fn Card(props: struct { title: []const u8 }) !void {
    const arena = try forbear.useArena();
    (try forbear.element(arena, .{
        .width = .grow,
        .direction = .topToBottom,
        .background = .{ .color = .{ 0.10, 0.11, 0.15, 1.0 } },
        .padding = forbear.Padding.all(16),
        .borderRadius = 8,
        .margin = forbear.Margin.block(0).withBottom(8),
    }))({
        // Card title
        (try forbear.element(arena, .{
            .fontSize = 14,
            .fontWeight = 700,
            .color = .{ 1.0, 0.42, 0.20, 1.0 },
            .margin = forbear.Margin.block(0).withBottom(10),
        }))({
            try forbear.text(arena, props.title);
        });
        // Slot insertion point — caller's children are rendered here
        try forbear.componentChildrenSlot(arena);
    });
}

fn App() !void {
    const arena = try forbear.useArena();

    (try forbear.element(arena, .{
        .width = .grow,
        .direction = .topToBottom,
        .background = .{ .color = .{ 0.08, 0.09, 0.12, 1.0 } },
    }))({
        // Header
        (try forbear.element(arena, .{
            .width = .grow,
            .direction = .leftToRight,
            .background = .{ .color = .{ 0.13, 0.15, 0.19, 1.0 } },
            .alignment = .center,
            .padding = forbear.Padding.block(16).withInLine(24),
        }))({
            (try forbear.element(arena, .{
                .fontWeight = 700,
                .fontSize = 16,
                .color = .{ 0.95, 0.95, 0.97, 1.0 },
                .margin = forbear.Margin.inLine(0).withRight(6),
            }))({
                try forbear.text(arena, "forbear");
            });
            (try forbear.element(arena, .{
                .fontSize = 16,
                .color = .{ 1.0, 0.42, 0.20, 1.0 },
            }))({
                try forbear.text(arena, "— Feature Showcase");
            });
        });

        // Content area
        (try forbear.element(arena, .{
            .width = .grow,
            .direction = .topToBottom,
            .padding = forbear.Padding.all(24),
        }))({
            // STORY 1.1: Percentage Sizing
            (try forbear.element(arena, .{
                .width = .grow,
                .direction = .topToBottom,
                .background = .{ .color = .{ 0.13, 0.15, 0.19, 1.0 } },
                .padding = forbear.Padding.all(16),
                .borderRadius = 8,
                .margin = forbear.Margin.block(0).withBottom(20),
            }))({
                // Title with underline (STORY 1.5)
                (try forbear.element(arena, .{
                    .fontSize = 14,
                    .fontWeight = 700,
                    .color = .{ 1.0, 0.42, 0.20, 1.0 },
                    .textDecoration = .underline,
                    .margin = forbear.Margin.block(0).withBottom(8),
                }))({
                    try forbear.text(arena, "STORY 1.1: Percentage-Based Sizing");
                });

                // Demo: 50% + 50%
                (try forbear.element(arena, .{
                    .fontSize = 11,
                    .color = .{ 0.55, 0.58, 0.65, 1.0 },
                    .margin = forbear.Margin.block(0).withBottom(8),
                }))({
                    try forbear.text(arena, "50% + 50% layout:");
                });

                (try forbear.element(arena, .{
                    .direction = .leftToRight,
                    .width = .grow,
                    .height = .{ .fixed = 60 },
                    .margin = forbear.Margin.block(0).withBottom(16),
                }))({
                    // 50% block - orange
                    (try forbear.element(arena, .{
                        .width = .{ .percentage = 50 },
                        .height = .grow,
                        .background = .{ .color = .{ 1.0, 0.42, 0.20, 1.0 } },
                        .alignment = .center,
                        .borderRadius = 6,
                        .margin = forbear.Margin.inLine(0).withRight(4),
                    }))({
                        (try forbear.element(arena, .{
                            .fontWeight = 700,
                            .fontSize = 14,
                            .color = .{ 0.04, 0.04, 0.04, 1.0 },
                        }))({
                            try forbear.text(arena, "50%");
                        });
                    });

                    // 50% block - cyan
                    (try forbear.element(arena, .{
                        .width = .{ .percentage = 50 },
                        .height = .grow,
                        .background = .{ .color = .{ 0.20, 0.85, 0.78, 1.0 } },
                        .alignment = .center,
                        .borderRadius = 6,
                    }))({
                        (try forbear.element(arena, .{
                            .fontWeight = 700,
                            .fontSize = 14,
                            .color = .{ 0.04, 0.14, 0.12, 1.0 },
                        }))({
                            try forbear.text(arena, "50%");
                        });
                    });
                });

                // Demo: 25% + 50% + 25%
                (try forbear.element(arena, .{
                    .fontSize = 11,
                    .color = .{ 0.55, 0.58, 0.65, 1.0 },
                    .margin = forbear.Margin.block(0).withBottom(8),
                }))({
                    try forbear.text(arena, "25% + 50% + 25% (asymmetric):");
                });

                (try forbear.element(arena, .{
                    .direction = .leftToRight,
                    .width = .grow,
                    .height = .{ .fixed = 50 },
                }))({
                    // 25% - violet
                    (try forbear.element(arena, .{
                        .width = .{ .percentage = 25 },
                        .height = .grow,
                        .background = .{ .color = .{ 0.56, 0.35, 0.95, 1.0 } },
                        .alignment = .center,
                        .borderRadius = 6,
                        .margin = forbear.Margin.inLine(0).withRight(4),
                    }))({
                        (try forbear.element(arena, .{
                            .fontWeight = 700,
                            .fontSize = 12,
                            .color = .{ 0.95, 0.95, 0.97, 1.0 },
                        }))({
                            try forbear.text(arena, "25%");
                        });
                    });

                    // 50% - surface
                    (try forbear.element(arena, .{
                        .width = .{ .percentage = 50 },
                        .height = .grow,
                        .background = .{ .color = .{ 0.18, 0.20, 0.26, 1.0 } },
                        .alignment = .center,
                        .borderRadius = 6,
                        .margin = forbear.Margin.inLine(0).withRight(4),
                    }))({
                        (try forbear.element(arena, .{
                            .fontWeight = 600,
                            .fontSize = 12,
                            .color = .{ 0.55, 0.58, 0.65, 1.0 },
                        }))({
                            try forbear.text(arena, "50%");
                        });
                    });

                    // 25% - violet
                    (try forbear.element(arena, .{
                        .width = .{ .percentage = 25 },
                        .height = .grow,
                        .background = .{ .color = .{ 0.56, 0.35, 0.95, 1.0 } },
                        .alignment = .center,
                        .borderRadius = 6,
                    }))({
                        (try forbear.element(arena, .{
                            .fontWeight = 700,
                            .fontSize = 12,
                            .color = .{ 0.95, 0.95, 0.97, 1.0 },
                        }))({
                            try forbear.text(arena, "25%");
                        });
                    });
                });
            });

            // STORY 1.2: Scrollable List
            (try forbear.element(arena, .{
                .width = .grow,
                .direction = .topToBottom,
                .background = .{ .color = .{ 0.13, 0.15, 0.19, 1.0 } },
                .padding = forbear.Padding.all(16),
                .borderRadius = 8,
                .margin = forbear.Margin.block(0).withBottom(20),
            }))({
                (try forbear.element(arena, .{
                    .fontSize = 14,
                    .fontWeight = 700,
                    .color = .{ 1.0, 0.42, 0.20, 1.0 },
                    .textDecoration = .underline,
                    .margin = forbear.Margin.block(0).withBottom(8),
                }))({
                    try forbear.text(arena, "STORY 1.2: Scrollable List");
                });

                (try forbear.element(arena, .{
                    .fontSize = 11,
                    .color = .{ 0.55, 0.58, 0.65, 1.0 },
                    .margin = forbear.Margin.block(0).withBottom(12),
                }))({
                    try forbear.text(arena, "Mouse-wheel to scroll inside the list:");
                });

                // Scrollable container: 200px tall with 20 items (~1000px of content)
                (try forbear.element(arena, .{
                    .width = .grow,
                    .height = .{ .fixed = 200 },
                    .direction = .topToBottom,
                    .overflow = .scroll,
                    .background = .{ .color = .{ 0.08, 0.09, 0.12, 1.0 } },
                    .borderRadius = 6,
                    .borderWidth = forbear.BorderWidth.all(1),
                    .borderColor = .{ 0.20, 0.22, 0.28, 1.0 },
                }))({
                    var itemIndex: usize = 1;
                    while (itemIndex <= 20) : (itemIndex += 1) {
                        const itemText = try std.fmt.allocPrint(arena, "Item {d:0>2} — scroll to see more items below", .{itemIndex});
                        const isEven = itemIndex % 2 == 0;
                        (try forbear.element(arena, .{
                            .width = .grow,
                            .direction = .leftToRight,
                            .padding = forbear.Padding.block(10).withInLine(14),
                            .background = .{ .color = if (isEven)
                                @as(@Vector(4, f32), .{ 0.10, 0.11, 0.14, 1.0 })
                            else
                                @as(@Vector(4, f32), .{ 0.08, 0.09, 0.12, 1.0 }) },
                        }))({
                            (try forbear.element(arena, .{
                                .fontSize = 12,
                                .color = .{ 0.72, 0.75, 0.82, 1.0 },
                            }))({
                                try forbear.text(arena, itemText);
                            });
                        });
                    }
                });
            });

            // STORY 1.5: Underlined Text
            (try forbear.element(arena, .{
                .width = .grow,
                .direction = .topToBottom,
                .background = .{ .color = .{ 0.13, 0.15, 0.19, 1.0 } },
                .padding = forbear.Padding.all(16),
                .borderRadius = 8,
            }))({
                (try forbear.element(arena, .{
                    .fontSize = 14,
                    .fontWeight = 700,
                    .color = .{ 1.0, 0.42, 0.20, 1.0 },
                    .textDecoration = .underline,
                    .margin = forbear.Margin.block(0).withBottom(8),
                }))({
                    try forbear.text(arena, "STORY 1.5: Underlined Text");
                });

                (try forbear.element(arena, .{
                    .fontSize = 11,
                    .color = .{ 0.95, 0.95, 0.97, 1.0 },
                    .textDecoration = .underline,
                }))({
                    try forbear.text(arena, "This text demonstrates underline rendering");
                });

                (try forbear.element(arena, .{
                    .fontSize = 13,
                    .fontWeight = 600,
                    .color = .{ 0.20, 0.85, 0.78, 1.0 },
                    .textDecoration = .underline,
                    .margin = forbear.Margin.block(8).withTop(8),
                }))({
                    try forbear.text(arena, "Multiple font sizes supported");
                });
            });

            // STORY 1.3: Component Children Slotting
            // --- Card with a "button" and text passed as slot children ---
            try forbear.slotBegin(arena);
            // Simulated button element
            (try forbear.element(arena, .{
                .direction = .leftToRight,
                .background = .{ .color = .{ 0.56, 0.35, 0.95, 1.0 } },
                .padding = forbear.Padding.block(8).withInLine(16),
                .borderRadius = 6,
                .margin = forbear.Margin.block(0).withBottom(8),
                .alignment = .center,
            }))({
                (try forbear.element(arena, .{
                    .fontSize = 12,
                    .fontWeight = 600,
                    .color = .{ 0.95, 0.95, 0.97, 1.0 },
                }))({
                    try forbear.text(arena, "Slot Button");
                });
            });
            // Descriptive text passed as slot content
            (try forbear.element(arena, .{
                .fontSize = 12,
                .color = .{ 0.55, 0.58, 0.65, 1.0 },
            }))({
                try forbear.text(arena, "This content was passed into Card via componentChildrenSlot().");
            });
            forbear.slotEnd();
            try forbear.component(arena, Card, .{ .title = "STORY 1.3: Component Children Slotting" });
        });
    });
}

fn renderingMain(
    allocator: std.mem.Allocator,
    renderer: *forbear.Graphics.Renderer,
    window: *const forbear.Window,
) !void {
    var arenaAllocator = std.heap.ArenaAllocator.init(allocator);
    defer arenaAllocator.deinit();

    const arena = arenaAllocator.allocator();

    try forbear.registerFont("Inter", @embedFile("Inter.ttf"));

    while (window.running) {
        defer _ = arenaAllocator.reset(.retain_capacity);

        try forbear.component(arena, App, null);

        const viewportSize = renderer.viewportSize();
        const layoutBoxes = try forbear.layout(
            arena,
            .{
                .blendMode = .normal,
                .font = try forbear.useFont("Inter"),
                .color = .{ 1.0, 1.0, 1.0, 1.0 },
                .textWrapping = .word,
                .fontSize = 14,
                .fontWeight = 400,
                .lineHeight = 1.5,
            },
            viewportSize,
            .{ @floatFromInt(window.dpi[0]), @floatFromInt(window.dpi[1]) },
        );
        try renderer.drawFrame(
            arena,
            layoutBoxes,
            .{ 0.08, 0.09, 0.12, 1.0 },
            window.dpi,
            window.targetFrameTimeNs(),
        );

        try forbear.update(arena, layoutBoxes, viewportSize);

        forbear.resetNodeTree();
    }
    try renderer.waitIdle();
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        if (gpa.deinit() == .leak) {
            std.log.err("Memory was leaked", .{});
        }
    }

    const allocator = gpa.allocator();

    var graphics = try forbear.Graphics.init(
        allocator,
        "forbear — Feature Showcase",
    );
    defer graphics.deinit();

    const window = try forbear.Window.init(
        allocator,
        880,
        700,
        "forbear — Feature Showcase",
        "forbear.showcase",
    );
    defer window.deinit();

    var renderer = try graphics.initRenderer(window);
    defer renderer.deinit();

    try forbear.init(allocator, &renderer);
    defer forbear.deinit();
    forbear.setWindowHandlers(window);

    const renderingThread = try std.Thread.spawn(
        .{ .allocator = allocator },
        renderingMain,
        .{
            allocator,
            &renderer,
            window,
        },
    );
    defer renderingThread.join();

    try window.handleEvents();
}
