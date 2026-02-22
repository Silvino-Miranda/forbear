//! forbear — Scroll Showcase
//! ==========================
//! Este exemplo demonstra todas as funcionalidades de scrolling
//! implementadas na Story 1.2:
//!
//!   · overflow: .scroll   — contentor scrollável com spring physics
//!   · overflow: .hidden   — clipping sem scroll (clipRect propagation)
//!   · useScroll()         — valor reactivo de scroll em píxeis
//!   · Dois scroll containers independentes — per-element routing
//!
//! Para executar: zig build run (dentro de examples/scroll-showcase/)

const std = @import("std");
const forbear = @import("forbear");

// ── Tipo auxiliar ──────────────────────────────────────────────
const Vec4 = @Vector(4, f32);

// ── Paleta de cores ────────────────────────────────────────────
const bg: Vec4 = .{ 0.08, 0.09, 0.12, 1.0 }; // fundo da janela
const surface: Vec4 = .{ 0.13, 0.15, 0.19, 1.0 }; // superfície dos cards
const inner: Vec4 = .{ 0.10, 0.11, 0.14, 1.0 }; // sub-superfície
const accent: Vec4 = .{ 1.00, 0.42, 0.20, 1.0 }; // laranja (brand)
const cyan: Vec4 = .{ 0.20, 0.85, 0.78, 1.0 }; // ciano
const violet: Vec4 = .{ 0.56, 0.35, 0.95, 1.0 }; // violeta
const text: Vec4 = .{ 0.95, 0.95, 0.97, 1.0 }; // texto principal
const subtle: Vec4 = .{ 0.55, 0.58, 0.65, 1.0 }; // texto secundário
const border: Vec4 = .{ 0.20, 0.22, 0.28, 1.0 }; // bordas

// ── Estilo partilhado de card ──────────────────────────────────
const cardStyle = forbear.IncompleteStyle{
    .direction = .topToBottom,
    .width = .grow,
    .background = .{ .color = surface },
    .borderRadius = 10,
    .borderColor = border,
    .borderWidth = .all(1),
    .padding = forbear.Padding.all(16),
    .margin = forbear.Margin.block(0).withBottom(16),
};

// ══════════════════════════════════════════════════════════════
// COMPONENTE: FeaturesList
// Painel esquerdo (250px) com overflow: .scroll independente.
// Lista as features da Story 1.2 — as implementadas têm badge verde.
// Cada item usa overflow: .hidden para cortar texto longo.
// ══════════════════════════════════════════════════════════════
fn FeaturesList() !void {
    const arena = try forbear.useArena();

    const features = [_][]const u8{
        "overflow: .scroll",
        "overflow: .hidden",
        "overflow: .visible",
        "useScroll() hook",
        "Spring physics scroll",
        "Per-element routing",
        "clipRect propagation",
        "Scissor stack (Vulkan)",
        "Horizontal scroll",
        "ScrollConfig.direction",
        "ElementScrollState",
        "Animated offset (px)",
        "forbear.useArena()",
        "forbear.useState()",
        "forbear.useTransition()",
        "useSpringTransition()",
        "forbear.component()",
        "forbear.element()",
        "forbear.layout()",
        "forbear.drawFrame()",
    };

    const numImplemented: usize = 8; // features da Story 1.2

    // Scroll container: 250px fixo, cresce em altura — overflow independente
    (try forbear.element(arena, .{
        .width = .{ .fixed = 250 },
        .height = .grow,
        .direction = .topToBottom,
        .overflow = .scroll, // ← scroll independente do painel direito
        .background = .{ .color = surface },
        .borderColor = border,
        .borderWidth = forbear.BorderWidth.right(1),
    }))({
        // Cabeçalho da lista
        (try forbear.element(arena, .{
            .width = .grow,
            .padding = forbear.Padding.block(14).withInLine(16),
            .borderColor = border,
            .borderWidth = forbear.BorderWidth.bottom(1),
        }))({
            (try forbear.element(arena, .{
                .fontWeight = 700,
                .fontSize = 11,
                .color = accent,
            }))({
                try forbear.text(arena, "API FEATURES — Story 1.2");
            });
        });

        // 20 items — cada um usa overflow: .hidden
        var i: usize = 0;
        while (i < features.len) : (i += 1) {
            const isChecked = i < numImplemented;
            const isEven = i % 2 == 0;

            (try forbear.element(arena, .{
                .width = .grow,
                .direction = .leftToRight,
                .alignment = .centerLeft,
                .overflow = .hidden, // ← corta texto que exceda os 250px
                .padding = forbear.Padding.block(9).withInLine(14),
                .background = .{ .color = if (isEven) inner else surface },
            }))({
                // Badge: verde (implementado) ou cinza (planeado)
                (try forbear.element(arena, .{
                    .width = .{ .fixed = 18 },
                    .height = .{ .fixed = 18 },
                    .background = .{ .color = if (isChecked)
                        @as(Vec4, .{ 0.08, 0.20, 0.12, 1.0 })
                    else
                        @as(Vec4, .{ 0.14, 0.16, 0.20, 1.0 }) },
                    .borderRadius = 9,
                    .borderColor = if (isChecked)
                        @as(Vec4, .{ 0.20, 0.70, 0.40, 1.0 })
                    else
                        border,
                    .borderWidth = .all(1),
                    .alignment = .center,
                    .margin = forbear.Margin.inLine(0).withRight(10),
                }))({
                    (try forbear.element(arena, .{
                        .fontSize = 9,
                        .fontWeight = 700,
                        .color = if (isChecked)
                            @as(Vec4, .{ 0.30, 0.90, 0.50, 1.0 })
                        else
                            subtle,
                    }))({
                        try forbear.text(arena, if (isChecked) "v" else "o");
                    });
                });

                // Nome da feature — clippado por overflow: .hidden se longo
                (try forbear.element(arena, .{
                    .fontSize = 11,
                    .color = if (isChecked) text else subtle,
                    .textWrapping = .none,
                }))({
                    try forbear.text(arena, features[i]);
                });
            });
        }
    });
}

// ══════════════════════════════════════════════════════════════
// COMPONENTE: ScrollableContent
// Painel direito com overflow: .scroll — demonstra as features
// de scrolling com 5 secções temáticas + cards adicionais.
//
// useScroll() é chamado aqui para ler o offset animado do scroll
// container raiz deste componente.
// ══════════════════════════════════════════════════════════════
fn ScrollableContent() !void {
    const arena = try forbear.useArena();

    // useScroll() retorna o offset animado (spring-interpolado) em px
    // para o scroll container raiz deste componente.
    // Retorna 0 no primeiro frame, actualiza nos frames seguintes.
    const scrollY = try forbear.useScroll(.{ .direction = .vertical });

    (try forbear.element(arena, .{
        .width = .grow,
        .height = .grow,
        .direction = .topToBottom,
        .overflow = .scroll, // ← este elemento é o scroll container
        .padding = forbear.Padding.block(20).withInLine(24),
    }))({
        // ── Secção 1: overflow: .scroll ───────────────────────────
        (try forbear.element(arena, cardStyle))({
            (try forbear.element(arena, .{
                .fontWeight = 700,
                .fontSize = 14,
                .color = accent,
                .margin = forbear.Margin.block(0).withBottom(8),
            }))({
                try forbear.text(arena, "overflow: .scroll");
            });

            (try forbear.element(arena, .{
                .fontSize = 12,
                .color = subtle,
                .textWrapping = .word,
                .lineHeight = 1.5,
                .margin = forbear.Margin.block(0).withBottom(14),
            }))({
                try forbear.text(arena, "Qualquer elemento pode receber overflow: .scroll para se tornar um contentor scrollavel independente. O scroll usa spring physics para decelerar naturalmente e e roteado por elemento — o cursor determina qual painel recebe os eventos de scroll.");
            });

            // Snippet de codigo
            (try forbear.element(arena, .{
                .width = .grow,
                .background = .{ .color = inner },
                .borderRadius = 6,
                .borderColor = border,
                .borderWidth = .all(1),
                .padding = forbear.Padding.all(12),
            }))({
                (try forbear.element(arena, .{
                    .fontSize = 11,
                    .color = cyan,
                    .lineHeight = 1.6,
                    .textWrapping = .none,
                }))({
                    try forbear.text(arena,
                        \\.overflow = .scroll,  // activa scroll neste elemento
                    );
                });
            });
        });

        // ── Secção 2: overflow: .hidden ───────────────────────────
        (try forbear.element(arena, cardStyle))({
            (try forbear.element(arena, .{
                .fontWeight = 700,
                .fontSize = 14,
                .color = violet,
                .margin = forbear.Margin.block(0).withBottom(8),
            }))({
                try forbear.text(arena, "overflow: .hidden");
            });

            (try forbear.element(arena, .{
                .fontSize = 12,
                .color = subtle,
                .textWrapping = .word,
                .lineHeight = 1.5,
                .margin = forbear.Margin.block(0).withBottom(14),
            }))({
                try forbear.text(arena, "Com overflow: .hidden, o conteudo e cortado pelo clipRect do elemento. O texto abaixo e mais longo que a caixa de 320px mas e clippado na borda direita:");
            });

            // Demo: contentor de largura fixa com overflow: .hidden
            (try forbear.element(arena, .{
                .width = .{ .fixed = 320 },
                .height = .{ .fixed = 34 },
                .overflow = .hidden, // ← clipRect em accao
                .background = .{ .color = inner },
                .borderRadius = 6,
                .borderColor = violet,
                .borderWidth = .all(1),
                .padding = forbear.Padding.block(8).withInLine(12),
            }))({
                (try forbear.element(arena, .{
                    .fontSize = 12,
                    .color = text,
                    .textWrapping = .none,
                }))({
                    try forbear.text(arena, "Este texto ultrapassa os 320px mas e cortado pela clipRect — overflow: .hidden funciona correctamente");
                });
            });
        });

        // ── Secção 3: useScroll() — valor live ────────────────────
        (try forbear.element(arena, cardStyle))({
            (try forbear.element(arena, .{
                .fontWeight = 700,
                .fontSize = 14,
                .color = cyan,
                .margin = forbear.Margin.block(0).withBottom(8),
            }))({
                try forbear.text(arena, "useScroll() — offset reactivo");
            });

            (try forbear.element(arena, .{
                .fontSize = 12,
                .color = subtle,
                .textWrapping = .word,
                .lineHeight = 1.5,
                .margin = forbear.Margin.block(0).withBottom(14),
            }))({
                try forbear.text(arena, "O hook useScroll() retorna o offset animado em pixeis (spring-interpolado). O valor e actualizado a cada frame enquanto o scroll esta em movimento — faz scroll neste painel para ver o numero mudar:");
            });

            // Display do scrollY em tempo real
            (try forbear.element(arena, .{
                .width = .grow,
                .direction = .leftToRight,
                .alignment = .centerLeft,
                .background = .{ .color = inner },
                .borderRadius = 8,
                .borderColor = cyan,
                .borderWidth = .all(1),
                .padding = forbear.Padding.block(16).withInLine(20),
            }))({
                (try forbear.element(arena, .{
                    .fontSize = 12,
                    .color = subtle,
                    .margin = forbear.Margin.inLine(0).withRight(10),
                }))({
                    try forbear.text(arena, "ScrollY:");
                });

                // Valor actualizado a cada frame
                const scrollText = try std.fmt.allocPrint(arena, "{d:.0}px", .{scrollY});
                (try forbear.element(arena, .{
                    .fontSize = 22,
                    .fontWeight = 700,
                    .color = cyan,
                }))({
                    try forbear.text(arena, scrollText);
                });

                // Spacer
                (try forbear.element(arena, .{ .width = .grow }))({});

                (try forbear.element(arena, .{
                    .fontSize = 10,
                    .color = .{ 0.20, 0.70, 0.65, 1.0 },
                    .fontWeight = 600,
                    .textWrapping = .none,
                }))({
                    try forbear.text(arena, "live!");
                });
            });
        });

        // ── Secção 4: Spring Physics ──────────────────────────────
        (try forbear.element(arena, cardStyle))({
            (try forbear.element(arena, .{
                .fontWeight = 700,
                .fontSize = 14,
                .color = accent,
                .margin = forbear.Margin.block(0).withBottom(8),
            }))({
                try forbear.text(arena, "Spring Physics");
            });

            (try forbear.element(arena, .{
                .fontSize = 12,
                .color = subtle,
                .textWrapping = .word,
                .lineHeight = 1.5,
                .margin = forbear.Margin.block(0).withBottom(14),
            }))({
                try forbear.text(arena, "O scroll usa uma simulacao de mola massa-mola-amortecedor (Runge-Kutta). O conteudo desacelera naturalmente ao parar, com possibilidade de overshoot suave nos parametros abaixo:");
            });

            (try forbear.element(arena, .{
                .width = .grow,
                .background = .{ .color = inner },
                .borderRadius = 6,
                .borderColor = border,
                .borderWidth = .all(1),
                .padding = forbear.Padding.all(12),
            }))({
                (try forbear.element(arena, .{
                    .fontSize = 11,
                    .color = accent,
                    .lineHeight = 1.6,
                    .textWrapping = .none,
                }))({
                    try forbear.text(arena,
                        \\SpringConfig{
                        \\  .stiffness = 300,  // rigidez (mais alto = mais rapido)
                        \\  .damping   = 35,   // amortecimento (menos = mais bounce)
                        \\  .mass      = 1.0,  // massa do conteudo
                        \\}
                    );
                });
            });
        });

        // ── Secção 5: Scroll Routing ──────────────────────────────
        (try forbear.element(arena, cardStyle))({
            (try forbear.element(arena, .{
                .fontWeight = 700,
                .fontSize = 14,
                .color = violet,
                .margin = forbear.Margin.block(0).withBottom(8),
            }))({
                try forbear.text(arena, "Scroll Routing — Dois Paineis Independentes");
            });

            (try forbear.element(arena, .{
                .fontSize = 12,
                .color = subtle,
                .textWrapping = .word,
                .lineHeight = 1.5,
            }))({
                try forbear.text(arena, "O painel esquerdo e este painel tem scroll completamente independente. O evento de scroll e entregue apenas ao elemento scrollavel sob o cursor, sem propagacao para outros contentores.\n\nExperimente: faz scroll com o cursor no painel esquerdo, depois move para este painel e faz scroll novamente.");
            });
        });

        // ── Secções 6-10: conteudo adicional (forca overflow) ─────
        var sec: usize = 6;
        while (sec <= 10) : (sec += 1) {
            const label = try std.fmt.allocPrint(
                arena,
                "Seccao {d} — conteudo adicional",
                .{sec},
            );

            (try forbear.element(arena, cardStyle))({
                (try forbear.element(arena, .{
                    .fontWeight = 600,
                    .fontSize = 13,
                    .color = subtle,
                    .margin = forbear.Margin.block(0).withBottom(8),
                }))({
                    try forbear.text(arena, label);
                });

                (try forbear.element(arena, .{
                    .fontSize = 12,
                    .color = .{ 0.38, 0.40, 0.48, 1.0 },
                    .textWrapping = .word,
                    .lineHeight = 1.5,
                }))({
                    try forbear.text(arena, "Este card garante que o conteudo total excede a altura do viewport, activando o scroll neste painel. Continua a fazer scroll para baixo e observa o useScroll() a actualizar na Seccao 3.");
                });
            });
        }
    });
}

// ══════════════════════════════════════════════════════════════
// COMPONENTE RAIZ: App()
// Header bar + body row (painel esquerdo + painel direito).
// ══════════════════════════════════════════════════════════════
fn App() !void {
    const arena = try forbear.useArena();

    (try forbear.element(arena, .{
        .width = .grow,
        .height = .grow,
        .direction = .topToBottom,
        .background = .{ .color = bg },
    }))({
        // ── Header bar ────────────────────────────────────────────
        (try forbear.element(arena, .{
            .width = .grow,
            .direction = .leftToRight,
            .alignment = .center,
            .background = .{ .color = surface },
            .borderColor = border,
            .borderWidth = forbear.BorderWidth.bottom(1),
            .padding = forbear.Padding.block(11).withInLine(24),
        }))({
            // "forbear" em bold
            (try forbear.element(arena, .{
                .fontWeight = 700,
                .fontSize = 13,
                .color = text,
                .margin = forbear.Margin.inLine(0).withRight(6),
            }))({
                try forbear.text(arena, "forbear");
            });

            // Titulo da showcase
            (try forbear.element(arena, .{
                .fontSize = 13,
                .color = accent,
            }))({
                try forbear.text(arena, "scroll showcase");
            });

            // Spacer — empurra elementos seguintes para a direita
            (try forbear.element(arena, .{ .width = .grow }))({});

            // Badge "STORY 1.2"
            (try forbear.element(arena, .{
                .background = .{ .color = .{ 0.08, 0.18, 0.12, 1.0 } },
                .borderRadius = 4,
                .borderColor = .{ 0.15, 0.55, 0.35, 1.0 },
                .borderWidth = .all(1),
                .padding = forbear.Padding.block(3).withInLine(8),
                .margin = forbear.Margin.inLine(0).withRight(12),
                .alignment = .center,
            }))({
                (try forbear.element(arena, .{
                    .fontSize = 9,
                    .fontWeight = 700,
                    .color = .{ 0.25, 0.85, 0.50, 1.0 },
                }))({
                    try forbear.text(arena, "STORY 1.2");
                });
            });

            try forbear.component(arena, forbear.FpsCounter, null);
        });

        // ── Body row: painel esquerdo + painel direito ────────────
        // height = .grow faz o body preencher o espaco restante apos o header.
        // Os dois paineis filhos tambem usam height = .grow para se esticarem
        // ate ao fundo — isso e necessario para o scroll funcionar corretamente.
        (try forbear.element(arena, .{
            .width = .grow,
            .height = .grow,
            .direction = .leftToRight,
        }))({
            try forbear.component(arena, FeaturesList, null);
            try forbear.component(arena, ScrollableContent, null);
        });
    });
}

// ══════════════════════════════════════════════════════════════
// RENDERING LOOP
// Thread dedicada separada do loop de eventos da janela.
// ══════════════════════════════════════════════════════════════
fn renderingMain(
    allocator: std.mem.Allocator,
    renderer: *forbear.Graphics.Renderer,
    window: *const forbear.Window,
) !void {
    var arenaAllocator = std.heap.ArenaAllocator.init(allocator);
    defer arenaAllocator.deinit();

    const arena = arenaAllocator.allocator();

    // Carrega a fonte Inter partilhada com o feature-showcase.
    // @embedFile compila o .ttf directamente no binario — zero deps em runtime.
    try forbear.registerFont("Inter", @embedFile("Inter.ttf"));

    while (window.running) {
        defer _ = arenaAllocator.reset(.retain_capacity);

        try forbear.component(arena, App, null);

        const viewportSize = renderer.viewportSize();

        const layoutBoxes = try forbear.layout(
            arena,
            .{
                .font = try forbear.useFont("Inter"),
                .color = text,
                .fontSize = 13,
                .fontWeight = 400,
                .lineHeight = 1.2,
                .textWrapping = .none,
                .blendMode = .normal,
            },
            viewportSize,
            .{
                @floatFromInt(window.dpi[0]),
                @floatFromInt(window.dpi[1]),
            },
        );

        try renderer.drawFrame(
            arena,
            layoutBoxes,
            bg,
            window.dpi,
            window.targetFrameTimeNs(),
        );

        try forbear.update(arena, layoutBoxes, viewportSize);

        forbear.resetNodeTree();
    }

    try renderer.waitIdle();
}

// ══════════════════════════════════════════════════════════════
// ENTRY POINT
// ══════════════════════════════════════════════════════════════
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        if (gpa.deinit() == .leak) {
            std.log.err("Memory leak detectado!", .{});
        }
    }
    const allocator = gpa.allocator();

    var graphics = try forbear.Graphics.init(allocator, "forbear scroll-showcase");
    defer graphics.deinit();

    const window = try forbear.Window.init(
        allocator,
        960,
        680,
        "forbear — Scroll Showcase",
        "forbear.scroll",
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
        .{ allocator, &renderer, window },
    );
    defer renderingThread.join();

    try window.handleEvents();
}
