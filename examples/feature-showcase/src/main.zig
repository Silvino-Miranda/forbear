//! forbear — Feature Showcase
//! ===========================
//! Este exemplo demonstra todas as funcionalidades implementadas no
//! framework forbear, incluindo:
//!
//!   LAYOUT:
//!     · Percentage-based sizing (Story 1.1):  .width = .{ .percentage = 50 }
//!     · Grow sizing:                          .width = .grow
//!     · Fixed sizing:                         .width = .{ .fixed = 120 }
//!     · Mixed siblings no mesmo container:    fixed + grow + percentage
//!     · Direções de layout:                   .direction = .topToBottom / .leftToRight
//!     · Alinhamento:                          .alignment = .center / .topCenter / ...
//!     · Padding e margin:                     forbear.Padding.block(12).withInLine(24)
//!     · maxWidth / minWidth:                  .maxWidth = 800
//!
//!   TIPOGRAFIA:
//!     · Text decoration — underline (1.5):    .textDecoration = .underline
//!     · Font weight variável:                 .fontWeight = 400..700
//!     · Tamanhos de fonte:                    .fontSize = 11..28
//!     · Line height:                          .lineHeight = 1.4
//!     · Text wrapping:                        .textWrapping = .word / .character / .none
//!
//!   VISUAL:
//!     · Cores sólidas:                        .background = .{ .color = .{r,g,b,a} }
//!     · Box shadow:                           .shadow = .{ .blurRadius = 12, ... }
//!     · Border radius:                        .borderRadius = 10
//!     · Border color e width:                 .borderColor, .borderWidth = .all(1)
//!     · Blend mode:                           .blendMode = .normal / .multiply
//!
//!   INTERAÇÃO:
//!     · Estado reativo:                       useState(T, initialValue)
//!     · Transição animada com easing:         useTransition(value, duration, easing)
//!     · Animação com física de mola:          useSpringTransition(target, SpringConfig{})
//!     · Eventos de mouse:                     useNextEvent() → .mouseOver / .mouseOut
//!     · Componentes com props:                forbear.component(arena, Fn, Props{})
//!
//! Para executar: zig build run (dentro de examples/feature-showcase/)

const std = @import("std");
const forbear = @import("forbear");

// ============================================================
// TIPO AUXILIAR
// Vec4 = @Vector(4, f32) — usado para cores e posições 2D/4D
// ============================================================
const Vec4 = @Vector(4, f32);

// ============================================================
// PALETA DE CORES
// Todas as cores estão no espaço sRGB, valores 0.0–1.0.
// O renderer converte para linear internamente via srgbToLinearColor().
// ============================================================
const bg: Vec4 = .{ 0.08, 0.09, 0.12, 1.0 }; // Fundo da janela — azul escuro
const surface: Vec4 = .{ 0.13, 0.15, 0.19, 1.0 }; // Superfície dos cards
const inner: Vec4 = .{ 0.18, 0.20, 0.26, 1.0 }; // Sub-superfície (cards internos)
const accent: Vec4 = .{ 1.00, 0.42, 0.20, 1.0 }; // Laranja — cor de destaque primária
const cyan: Vec4 = .{ 0.20, 0.85, 0.78, 1.0 }; // Ciano — cor de destaque secundária
const violet: Vec4 = .{ 0.56, 0.35, 0.95, 1.0 }; // Violeta — cor de destaque terciária
const text: Vec4 = .{ 0.95, 0.95, 0.97, 1.0 }; // Texto principal (branco suave)
const subtle: Vec4 = .{ 0.55, 0.58, 0.65, 1.0 }; // Texto secundário (cinza médio)
const frame: Vec4 = .{ 0.22, 0.24, 0.30, 1.0 }; // Bordas de cards (cinza escuro)
const dark: Vec4 = .{ 0.06, 0.07, 0.09, 1.0 }; // Para textos sobre cor clara

// ============================================================
// COMPONENTE: SectionHeader
// Renderiza o cabeçalho de cada seção: linha decorativa + título + subtítulo.
//
// Props:
//   title       — nome da seção
//   subtitle    — descrição curta
//   lineColor   — cor da linha decorativa (padrão = accent laranja)
// ============================================================
const SectionHeaderProps = struct {
    title: []const u8,
    subtitle: []const u8,
    lineColor: Vec4 = accent, // default value: cor laranja
};

fn SectionHeader(props: SectionHeaderProps) !void {
    // useArena() retorna o allocator desta frame.
    // Todos os elementos criados neste componente usam esta arena.
    const arena = try forbear.useArena();

    // Container vertical — empilha linha + título + subtítulo
    (try forbear.element(arena, .{
        .direction = .topToBottom,
        .margin = forbear.Margin.block(0).withBottom(16),
    }))({
        // Linha horizontal colorida — cresce para preencher o container pai
        // .width = .grow é o sizing "flex: 1" do forbear
        (try forbear.element(arena, .{
            .width = .grow,
            .height = .{ .fixed = 2 }, // espessura fixa em pixels
            .background = .{ .color = props.lineColor },
            .borderRadius = 1,
            .margin = forbear.Margin.block(0).withBottom(10),
        }))({});

        // Título da seção: bold, tamanho grande
        (try forbear.element(arena, .{
            .fontWeight = 700,
            .fontSize = 16,
            .color = text,
            .margin = forbear.Margin.block(0).withBottom(3),
        }))({
            try forbear.text(arena, props.title);
        });

        // Subtítulo: peso normal, cor muted
        (try forbear.element(arena, .{
            .fontSize = 11,
            .color = subtle,
        }))({
            try forbear.text(arena, props.subtitle);
        });
    });
}

// ============================================================
// COMPONENTE: HoverButton
// Demonstra: useState + useTransition + eventos de mouse.
//
// A cor de fundo anima suavemente entre baseColor e hoverColor
// ao mover o cursor sobre o botão. A sombra também anima.
//
// Props:
//   label       — texto exibido no botão
//   baseColor   — cor quando não há hover
//   hoverColor  — cor no hover (mais saturada/brilhante)
// ============================================================
const HoverButtonProps = struct {
    label: []const u8,
    baseColor: Vec4,
    hoverColor: Vec4,
};

fn HoverButton(props: HoverButtonProps) !void {
    const arena = try forbear.useArena();

    // useState(T, initialValue):
    //   · Mantém um valor reativo que persiste entre frames enquanto o
    //     componente estiver montado.
    //   · Retorna *T — ponteiro para o valor atual.
    //   · Alterar o valor via ponteiro causa re-render no próximo frame.
    const isHovering = try forbear.useState(bool, false);

    // useTransition(target, duration, easingFn):
    //   · Anima suavemente de um valor anterior até `target`.
    //   · `duration` em segundos — aqui 0.18s (rápido, sensação responsiva).
    //   · `forbear.ease` = CSS "ease" (cubic bezier 0.25, 0.1, 0.25, 1.0).
    //   · Retorna o valor ATUAL da animação (interpolado).
    const t = try forbear.useTransition(
        if (isHovering.*) 1.0 else 0.0,
        0.18,
        forbear.ease,
    );

    // Interpolação linear manual entre as duas cores usando `t` (0.0 → 1.0)
    // Quando t=0: baseColor. Quando t=1: hoverColor. Entre: interpolado.
    const r = props.baseColor[0] + (props.hoverColor[0] - props.baseColor[0]) * t;
    const g = props.baseColor[1] + (props.hoverColor[1] - props.baseColor[1]) * t;
    const b = props.baseColor[2] + (props.hoverColor[2] - props.baseColor[2]) * t;

    (try forbear.element(arena, .{
        .background = .{ .color = .{ r, g, b, 1.0 } },
        .borderRadius = 8,
        .padding = forbear.Padding.block(10).withInLine(20),
        .alignment = .center,
        .margin = forbear.Margin.inLine(0).withRight(10),
        // A sombra também anima: blur e spread crescem no hover.
        // Isso cria um efeito "glow" suave ao passar o mouse.
        .shadow = .{
            .offset = forbear.Offset.all(0), // sem offset — sombra centrada
            .blurRadius = 6 + t * 14, // 6px → 20px
            .spread = t * 3, // 0 → 3px
            .color = .{
                props.hoverColor[0],
                props.hoverColor[1],
                props.hoverColor[2],
                0.2 + t * 0.3, // 20% → 50% de opacidade
            },
        },
    }))({
        // Texto do botão
        (try forbear.element(arena, .{
            .fontWeight = 600,
            .fontSize = 13,
            .color = text,
        }))({
            try forbear.text(arena, props.label);
        });

        // Loop de eventos de mouse.
        // useNextEvent() retorna o próximo evento pendente para este elemento,
        // ou null se não houver mais eventos neste frame.
        // Os eventos são associados ao elemento pelo seu contexto de posição na árvore.
        while (forbear.useNextEvent()) |event| {
            switch (event) {
                .mouseOver => isHovering.* = true, // cursor entrou
                .mouseOut => isHovering.* = false, // cursor saiu
            }
        }
    });
}

// ============================================================
// COMPONENTE: SpringBar
// Demonstra useSpringTransition: largura animada com física de mola.
//
// Ao fazer hover, a barra expande com um efeito elástico natural —
// ultrapassa levemente o alvo (overshoot) e oscila até estabilizar.
// ============================================================
fn SpringBar() !void {
    const arena = try forbear.useArena();

    const isHovering = try forbear.useState(bool, false);

    // useSpringTransition(target, SpringConfig):
    //   · Simula uma mola massa-mola-amortecedor.
    //   · stiffness: rigidez da mola (quanto mais alto, mais rápido)
    //   · damping:   amortecimento (quanto mais baixo, mais oscilação)
    //   · mass:      massa do objeto (quanto mais pesado, mais lento e mais overshoot)
    const barWidth = try forbear.useSpringTransition(
        if (isHovering.*) 240.0 else 60.0, // target: 60px → 240px no hover
        forbear.SpringConfig{
            .stiffness = 260, // mola moderadamente rígida
            .damping = 18, // pouco amortecimento → some bounce
            .mass = 1.0,
        },
    );

    // Container horizontal: barra animada + label explicativo
    (try forbear.element(arena, .{
        .direction = .leftToRight,
        .alignment = .centerLeft,
        .height = .{ .fixed = 48 },
    }))({
        // Barra cuja largura é controlada pela mola
        (try forbear.element(arena, .{
            .width = .{ .fixed = barWidth }, // largura vem da simulação da mola
            .height = .{ .fixed = 36 },
            .background = .{ .color = violet },
            .borderRadius = 6,
            .alignment = .center,
            .margin = forbear.Margin.inLine(0).withRight(16),
        }))({
            // Captura os eventos de hover nesta barra
            while (forbear.useNextEvent()) |event| {
                switch (event) {
                    .mouseOver => isHovering.* = true,
                    .mouseOut => isHovering.* = false,
                }
            }
        });

        // Label de instrução — muda de texto quando há hover
        (try forbear.element(arena, .{
            .fontSize = 11,
            .color = subtle,
            .textWrapping = .none,
        }))({
            try forbear.text(
                arena,
                if (isHovering.*) "solte para ver o spring" else "← passe o mouse na barra",
            );
        });
    });
}

// ============================================================
// HELPER: Card
// Wrapper visual reutilizado por cada demo. Retorna a borda/sombra
// padrão de card para manter consistência visual.
//
// NOTA: Como slotting de filhos (Story 1.3) ainda não está implementado,
// não é possível passar children como props de componente.
// Por isso, as seções de conteúdo ficam inline em App().
// Este helper apenas documenta o padrão visual via comentário.
// ============================================================

// Estilo padrão de card — reutilizado inline com `.{...} + overrides`
// para cada demo abaixo.
const cardStyle = forbear.IncompleteStyle{
    .direction = .topToBottom,
    .width = .grow,
    .background = .{ .color = surface },
    .borderRadius = 10,
    .borderColor = frame,
    .borderWidth = .all(1),
    .padding = forbear.Padding.all(16),
    .margin = forbear.Margin.block(0).withBottom(14),
};

// ============================================================
// COMPONENTE RAIZ: App()
// Chamado a cada frame. Reconstrói toda a árvore de elementos.
// O forbear é immediate-mode: cada frame descreve o estado atual da UI.
// ============================================================
fn App() !void {
    const arena = try forbear.useArena();

    // Container raiz: preenche a viewport, layout vertical
    (try forbear.element(arena, .{
        .width = .grow,
        .direction = .topToBottom,
        .background = .{ .color = bg },
    }))({
        // ════════════════════════════════════════════════════
        // HEADER BAR — barra superior fixa
        // ════════════════════════════════════════════════════
        (try forbear.element(arena, .{
            .width = .grow,
            .direction = .leftToRight,
            .alignment = .center,
            .background = .{ .color = surface },
            // Apenas a borda inferior: cria separador visual sem visual noise
            .borderColor = frame,
            .borderWidth = forbear.BorderWidth.bottom(1),
            .padding = forbear.Padding.block(11).withInLine(24),
        }))({
            // Marca "forbear" em bold
            (try forbear.element(arena, .{
                .fontWeight = 700,
                .fontSize = 13,
                .color = text,
                .margin = forbear.Margin.inLine(0).withRight(6),
            }))({
                try forbear.text(arena, "forbear");
            });

            // Subtítulo em accent color
            (try forbear.element(arena, .{
                .fontSize = 13,
                .color = accent,
            }))({
                try forbear.text(arena, "feature showcase");
            });

            // Spacer: .width = .grow empurra o FPS counter para a direita.
            // É o padrão "space-between" em flex layout — elemento vazio que cresce.
            (try forbear.element(arena, .{ .width = .grow }))({});

            // FpsCounter é um componente built-in do forbear.
            // Exibe "Xfps" no canto, útil para medir performance.
            try forbear.component(arena, forbear.FpsCounter, null);
        });

        // ════════════════════════════════════════════════════
        // ÁREA DE CONTEÚDO — com padding em todos os lados
        // ════════════════════════════════════════════════════
        (try forbear.element(arena, .{
            .width = .grow,
            .direction = .topToBottom,
            // maxWidth centraliza o conteúdo em telas largas
            .maxWidth = 820,
            .padding = forbear.Padding.all(24),
        }))({
            // ────────────────────────────────────────────────
            // SEÇÃO 1: LAYOUT SYSTEM
            // ────────────────────────────────────────────────
            try forbear.component(arena, SectionHeader, SectionHeaderProps{
                .title = "Layout System",
                .subtitle = "Percentage sizing · grow · fixed · siblings mistos num flex container",
                .lineColor = accent,
            });

            // ── DEMO: Percentage Sizing (Story 1.1) ──────────
            // Dois filhos de 50% cada — dividem o espaço igualmente.
            // .percentage é relativo ao inner size do container pai.
            (try forbear.element(arena, cardStyle))({
                // Label com underline (Story 1.5 — demonstramos já aqui)
                (try forbear.element(arena, .{
                    .fontSize = 10,
                    .fontWeight = 700,
                    .color = accent,
                    .textDecoration = .underline, // STORY 1.5
                    .margin = forbear.Margin.block(0).withBottom(10),
                }))({
                    try forbear.text(arena, "PERCENTAGE SIZING — .width = .{ .percentage = N }");
                });

                // Descrição do sizing
                (try forbear.element(arena, .{
                    .fontSize = 10,
                    .color = subtle,
                    .margin = forbear.Margin.block(0).withBottom(8),
                }))({
                    try forbear.text(arena, "50% + 50% = container completo");
                });

                // Row com dois blocos de 50%
                (try forbear.element(arena, .{
                    .direction = .leftToRight,
                    .width = .grow,
                    .height = .{ .fixed = 44 },
                    .margin = forbear.Margin.block(0).withBottom(14),
                }))({
                    // PRIMEIRO BLOCO: 50% do pai
                    (try forbear.element(arena, .{
                        .width = .{ .percentage = 50 }, // STORY 1.1
                        .height = .grow,
                        .background = .{ .color = accent },
                        .borderRadius = 6,
                        .alignment = .center,
                        .margin = forbear.Margin.inLine(0).withRight(4),
                    }))({
                        (try forbear.element(arena, .{
                            .fontWeight = 700,
                            .fontSize = 13,
                            .color = dark,
                        }))({
                            try forbear.text(arena, "50%");
                        });
                    });

                    // SEGUNDO BLOCO: outros 50%
                    (try forbear.element(arena, .{
                        .width = .{ .percentage = 50 }, // STORY 1.1
                        .height = .grow,
                        .background = .{ .color = cyan },
                        .borderRadius = 6,
                        .alignment = .center,
                    }))({
                        (try forbear.element(arena, .{
                            .fontWeight = 700,
                            .fontSize = 13,
                            .color = .{ 0.04, 0.14, 0.12, 1.0 },
                        }))({
                            try forbear.text(arena, "50%");
                        });
                    });
                });

                // Divisão assimétrica: 25% / 50% / 25%
                (try forbear.element(arena, .{
                    .fontSize = 10,
                    .color = subtle,
                    .margin = forbear.Margin.block(0).withBottom(8),
                }))({
                    try forbear.text(arena, "25% + 50% + 25% — proporções assimétricas");
                });

                (try forbear.element(arena, .{
                    .direction = .leftToRight,
                    .width = .grow,
                    .height = .{ .fixed = 36 },
                }))({
                    // 25% — violeta
                    (try forbear.element(arena, .{
                        .width = .{ .percentage = 25 },
                        .height = .grow,
                        .background = .{ .color = violet },
                        .borderRadius = 6,
                        .alignment = .center,
                        .margin = forbear.Margin.inLine(0).withRight(4),
                    }))({
                        (try forbear.element(arena, .{
                            .fontWeight = 700,
                            .fontSize = 11,
                            .color = text,
                        }))({
                            try forbear.text(arena, "25%");
                        });
                    });

                    // 50% — superfície interna com borda
                    (try forbear.element(arena, .{
                        .width = .{ .percentage = 50 },
                        .height = .grow,
                        .background = .{ .color = inner },
                        .borderColor = frame,
                        .borderWidth = .all(1),
                        .borderRadius = 6,
                        .alignment = .center,
                        .margin = forbear.Margin.inLine(0).withRight(4),
                    }))({
                        (try forbear.element(arena, .{
                            .fontWeight = 600,
                            .fontSize = 11,
                            .color = subtle,
                        }))({
                            try forbear.text(arena, "50%");
                        });
                    });

                    // 25% — violeta (espelhado)
                    (try forbear.element(arena, .{
                        .width = .{ .percentage = 25 },
                        .height = .grow,
                        .background = .{ .color = violet },
                        .borderRadius = 6,
                        .alignment = .center,
                    }))({
                        (try forbear.element(arena, .{
                            .fontWeight = 700,
                            .fontSize = 11,
                            .color = text,
                        }))({
                            try forbear.text(arena, "25%");
                        });
                    });
                });
            });

            // ── DEMO: Mixed Sizing (fixed + grow + percentage) ──
            // Demonstra como os três tipos de sizing coexistem num row.
            // O .grow recebe o espaço que sobrou após fixos e percentagens.
            (try forbear.element(arena, cardStyle))({
                (try forbear.element(arena, .{
                    .fontSize = 10,
                    .fontWeight = 700,
                    .color = cyan,
                    .textDecoration = .underline, // STORY 1.5
                    .margin = forbear.Margin.block(0).withBottom(10),
                }))({
                    try forbear.text(arena, "MIXED SIZING — fixed + grow + percentage no mesmo container");
                });

                (try forbear.element(arena, .{
                    .fontSize = 10,
                    .color = subtle,
                    .margin = forbear.Margin.block(0).withBottom(10),
                }))({
                    try forbear.text(arena, "fixed=80px | grow (resto disponível) | percentage=30%");
                });

                // Row com os três tipos de sizing
                (try forbear.element(arena, .{
                    .direction = .leftToRight,
                    .width = .grow,
                    .height = .{ .fixed = 48 },
                }))({
                    // FIXED — sempre 80px, não importa o tamanho do pai
                    (try forbear.element(arena, .{
                        .width = .{ .fixed = 80 },
                        .height = .grow,
                        .background = .{ .color = accent },
                        .borderRadius = 6,
                        .alignment = .center,
                        .margin = forbear.Margin.inLine(0).withRight(4),
                    }))({
                        (try forbear.element(arena, .{
                            .fontWeight = 700,
                            .fontSize = 10,
                            .color = dark,
                            .textWrapping = .none,
                        }))({
                            try forbear.text(arena, "fixed\n80px");
                        });
                    });

                    // GROW — ocupa todo o espaço restante após fixed e percentage
                    (try forbear.element(arena, .{
                        .width = .grow,
                        .height = .grow,
                        .background = .{ .color = inner },
                        .borderColor = frame,
                        .borderWidth = .all(1),
                        .borderRadius = 6,
                        .alignment = .center,
                        .margin = forbear.Margin.inLine(0).withRight(4),
                    }))({
                        (try forbear.element(arena, .{
                            .fontWeight = 700,
                            .fontSize = 11,
                            .color = text,
                        }))({
                            try forbear.text(arena, "grow");
                        });
                    });

                    // PERCENTAGE — 30% do container pai
                    (try forbear.element(arena, .{
                        .width = .{ .percentage = 30 }, // STORY 1.1
                        .height = .grow,
                        .background = .{ .color = cyan },
                        .borderRadius = 6,
                        .alignment = .center,
                    }))({
                        (try forbear.element(arena, .{
                            .fontWeight = 700,
                            .fontSize = 11,
                            .color = .{ 0.04, 0.14, 0.12, 1.0 },
                        }))({
                            try forbear.text(arena, "30%");
                        });
                    });
                });
            });

            // ────────────────────────────────────────────────
            // SEÇÃO 2: TYPOGRAPHY
            // ────────────────────────────────────────────────
            try forbear.component(arena, SectionHeader, SectionHeaderProps{
                .title = "Typography",
                .subtitle = "Font weights · text decoration (underline) · text wrapping · line height",
                .lineColor = cyan,
            });

            // ── DEMO: Font Weights ───────────────────────────
            (try forbear.element(arena, cardStyle))({
                (try forbear.element(arena, .{
                    .fontSize = 10,
                    .fontWeight = 700,
                    .color = cyan,
                    .textDecoration = .underline, // STORY 1.5
                    .margin = forbear.Margin.block(0).withBottom(12),
                }))({
                    try forbear.text(arena, "FONT WEIGHTS & TAMANHOS");
                });

                // A Inter é uma variable font — .fontWeight aceita 100–900
                const weights = [_]struct { w: u32, label: []const u8, sz: f32 }{
                    .{ .w = 400, .label = "Regular (400) — peso padrão para corpo de texto", .sz = 13 },
                    .{ .w = 500, .label = "Medium (500) — levemente mais pesado", .sz = 13 },
                    .{ .w = 600, .label = "SemiBold (600) — para subtítulos e labels", .sz = 13 },
                    .{ .w = 700, .label = "Bold (700) — títulos principais e destaques", .sz = 14 },
                };

                // inline for: usado para iterar arrays de struct no forbear
                inline for (weights) |item| {
                    (try forbear.element(arena, .{
                        .fontWeight = item.w,
                        .fontSize = item.sz,
                        .color = text,
                        .margin = forbear.Margin.block(0).withBottom(6),
                    }))({
                        try forbear.text(arena, item.label);
                    });
                }
            });

            // ── DEMO: Text Decoration — underline (Story 1.5) ──
            // Demonstra o textDecoration em diferentes tamanhos e cores.
            // A espessura do underline é proporcional ao fontSize (fontSize / 14).
            (try forbear.element(arena, cardStyle))({
                (try forbear.element(arena, .{
                    .fontSize = 10,
                    .fontWeight = 700,
                    .color = violet,
                    .textDecoration = .underline, // STORY 1.5 — o label demonstra a si mesmo
                    .margin = forbear.Margin.block(0).withBottom(12),
                }))({
                    try forbear.text(arena, "TEXT DECORATION — .textDecoration = .underline (Story 1.5)");
                });

                // Explicação do recurso
                (try forbear.element(arena, .{
                    .fontSize = 11,
                    .color = subtle,
                    .margin = forbear.Margin.block(0).withBottom(12),
                }))({
                    try forbear.text(arena, "A espessura do underline é fontSize / 14.0 — escala proporcionalmente ao tamanho.");
                });

                // Exemplos com diferentes tamanhos — observe como a espessura varia
                const underline_demos = [_]struct {
                    label: []const u8,
                    size: f32,
                    color: Vec4,
                    weight: u32,
                }{
                    .{ .label = "Texto pequeno, 11px — underline fino", .size = 11, .color = subtle, .weight = 400 },
                    .{ .label = "Corpo padrão, 13px — espessura normal", .size = 13, .color = text, .weight = 400 },
                    .{ .label = "Link laranja, 14px, SemiBold", .size = 14, .color = accent, .weight = 600 },
                    .{ .label = "Link ciano, 16px", .size = 16, .color = cyan, .weight = 500 },
                    .{ .label = "Título grande, 24px — underline espesso", .size = 24, .color = violet, .weight = 700 },
                };

                inline for (underline_demos) |item| {
                    (try forbear.element(arena, .{
                        .fontWeight = item.weight,
                        .fontSize = item.size,
                        .color = item.color,
                        .textDecoration = .underline, // STORY 1.5
                        .margin = forbear.Margin.block(0).withBottom(8),
                    }))({
                        try forbear.text(arena, item.label);
                    });
                }
            });

            // ── DEMO: Text Wrapping ──────────────────────────
            (try forbear.element(arena, cardStyle))({
                (try forbear.element(arena, .{
                    .fontSize = 10,
                    .fontWeight = 700,
                    .color = subtle,
                    .margin = forbear.Margin.block(0).withBottom(12),
                }))({
                    try forbear.text(arena, "TEXT WRAPPING & LINE HEIGHT");
                });

                // .word — quebra nas fronteiras de palavras (espaços)
                (try forbear.element(arena, .{
                    .fontSize = 10,
                    .color = subtle,
                    .margin = forbear.Margin.block(0).withBottom(4),
                }))({
                    try forbear.text(arena, ".textWrapping = .word — quebra em espaços:");
                });
                (try forbear.element(arena, .{
                    .width = .grow,
                    .fontSize = 13,
                    .color = text,
                    .textWrapping = .word, // quebra nas fronteiras das palavras
                    .lineHeight = 1.5, // espaçamento entre linhas = 1.5x o fontSize
                    .margin = forbear.Margin.block(0).withBottom(14),
                }))({
                    try forbear.text(arena, "Este parágrafo usa .word wrapping. Ele vai quebrar nas fronteiras das palavras quando atingir a largura máxima do seu container pai. lineHeight = 1.5 adiciona espaçamento generoso entre linhas.");
                });

                // .character — quebra em qualquer caractere (mais compacto)
                (try forbear.element(arena, .{
                    .fontSize = 10,
                    .color = subtle,
                    .margin = forbear.Margin.block(0).withBottom(4),
                }))({
                    try forbear.text(arena, ".textWrapping = .character — quebra em qualquer ponto:");
                });
                (try forbear.element(arena, .{
                    .width = .grow,
                    .fontSize = 13,
                    .color = text,
                    .textWrapping = .character, // quebra em qualquer caractere
                    .lineHeight = 1.3,
                }))({
                    try forbear.text(arena, "Este parágrafo usa .character wrapping e pode quebrar em qualquer posição, mesmo no meio de uma palavra.");
                });
            });

            // ────────────────────────────────────────────────
            // SEÇÃO 3: VISUAL EFFECTS
            // ────────────────────────────────────────────────
            try forbear.component(arena, SectionHeader, SectionHeaderProps{
                .title = "Visual Effects",
                .subtitle = "Box shadows · border radius · border styles · blend modes",
                .lineColor = violet,
            });

            // ── DEMO: Box Shadows ────────────────────────────
            // O forbear suporta sombras com blur, spread, offset e cor custom.
            (try forbear.element(arena, cardStyle))({
                (try forbear.element(arena, .{
                    .fontSize = 10,
                    .fontWeight = 700,
                    .color = violet,
                    .margin = forbear.Margin.block(0).withBottom(14),
                }))({
                    try forbear.text(arena, "BOX SHADOWS — blur radius crescente, colored shadows");
                });

                // Row de boxes com sombras coloridas de intensidade crescente
                (try forbear.element(arena, .{
                    .direction = .leftToRight,
                    .alignment = .centerLeft,
                    .width = .grow,
                    .padding = forbear.Padding.block(10),
                }))({
                    const shadow_demos = [_]struct {
                        blur: f32,
                        color: Vec4,
                        label: []const u8,
                    }{
                        .{ .blur = 4, .color = accent, .label = "blur 4px" },
                        .{ .blur = 12, .color = cyan, .label = "blur 12px" },
                        .{ .blur = 24, .color = violet, .label = "blur 24px" },
                        .{ .blur = 0, .color = accent, .label = "sem blur\nspread 3px" },
                    };

                    inline for (shadow_demos) |item| {
                        (try forbear.element(arena, .{
                            .direction = .topToBottom,
                            .alignment = .topCenter,
                            .margin = forbear.Margin.inLine(0).withRight(22),
                        }))({
                            (try forbear.element(arena, .{
                                .width = .{ .fixed = 58 },
                                .height = .{ .fixed = 58 },
                                .background = .{ .color = inner },
                                .borderRadius = 10,
                                .borderColor = item.color,
                                .borderWidth = .all(1),
                                // O campo .shadow aceita offset, blurRadius, spread e color
                                .shadow = .{
                                    .offset = forbear.Offset.all(0), // sombra centrada
                                    .blurRadius = item.blur,
                                    .spread = if (item.blur == 0) 3.0 else 0.0, // só spread no último
                                    .color = .{
                                        item.color[0],
                                        item.color[1],
                                        item.color[2],
                                        0.55,
                                    },
                                },
                                .margin = forbear.Margin.block(0).withBottom(8),
                            }))({});

                            // Label abaixo do box
                            (try forbear.element(arena, .{
                                .fontSize = 9,
                                .color = subtle,
                                .alignment = .topCenter,
                                .textWrapping = .none,
                            }))({
                                try forbear.text(arena, item.label);
                            });
                        });
                    }
                });
            });

            // ── DEMO: Border Radius & Border Styles ──────────
            (try forbear.element(arena, cardStyle))({
                (try forbear.element(arena, .{
                    .fontSize = 10,
                    .fontWeight = 700,
                    .color = subtle,
                    .margin = forbear.Margin.block(0).withBottom(14),
                }))({
                    try forbear.text(arena, "BORDER RADIUS & BORDER STYLES");
                });

                // Row de boxes demonstrando diferentes border radius e estilos
                (try forbear.element(arena, .{
                    .direction = .leftToRight,
                    .alignment = .centerLeft,
                    .width = .grow,
                }))({
                    // Sem border radius
                    (try forbear.element(arena, .{
                        .direction = .topToBottom,
                        .alignment = .topCenter,
                        .margin = forbear.Margin.inLine(0).withRight(16),
                    }))({
                        (try forbear.element(arena, .{
                            .width = .{ .fixed = 60 },
                            .height = .{ .fixed = 60 },
                            .background = .{ .color = inner },
                            .borderRadius = 0, // sem arredondamento
                            .borderColor = accent,
                            .borderWidth = .all(2),
                            .margin = forbear.Margin.block(0).withBottom(6),
                        }))({});
                        (try forbear.element(arena, .{
                            .fontSize = 9,
                            .color = subtle,
                        }))({
                            try forbear.text(arena, "radius 0");
                        });
                    });

                    // border radius = 8px
                    (try forbear.element(arena, .{
                        .direction = .topToBottom,
                        .alignment = .topCenter,
                        .margin = forbear.Margin.inLine(0).withRight(16),
                    }))({
                        (try forbear.element(arena, .{
                            .width = .{ .fixed = 60 },
                            .height = .{ .fixed = 60 },
                            .background = .{ .color = inner },
                            .borderRadius = 8,
                            .borderColor = cyan,
                            .borderWidth = .all(2),
                            .margin = forbear.Margin.block(0).withBottom(6),
                        }))({});
                        (try forbear.element(arena, .{
                            .fontSize = 9,
                            .color = subtle,
                        }))({
                            try forbear.text(arena, "radius 8");
                        });
                    });

                    // border radius = 30 (círculo para 60x60)
                    (try forbear.element(arena, .{
                        .direction = .topToBottom,
                        .alignment = .topCenter,
                        .margin = forbear.Margin.inLine(0).withRight(16),
                    }))({
                        (try forbear.element(arena, .{
                            .width = .{ .fixed = 60 },
                            .height = .{ .fixed = 60 },
                            .background = .{ .color = inner },
                            .borderRadius = 30, // metade do lado = círculo perfeito
                            .borderColor = violet,
                            .borderWidth = .all(2),
                            .margin = forbear.Margin.block(0).withBottom(6),
                        }))({});
                        (try forbear.element(arena, .{
                            .fontSize = 9,
                            .color = subtle,
                        }))({
                            try forbear.text(arena, "radius 30\n(círculo)");
                        });
                    });

                    // Borda só na parte inferior — usando BorderWidth direcional
                    (try forbear.element(arena, .{
                        .direction = .topToBottom,
                        .alignment = .topCenter,
                        .margin = forbear.Margin.inLine(0).withRight(16),
                    }))({
                        (try forbear.element(arena, .{
                            .width = .{ .fixed = 60 },
                            .height = .{ .fixed = 60 },
                            .background = .{ .color = inner },
                            .borderRadius = 6,
                            .borderColor = accent,
                            // BorderWidth herda de Padding — suporta valores por lado
                            .borderWidth = forbear.BorderWidth.bottom(3),
                            .margin = forbear.Margin.block(0).withBottom(6),
                        }))({});
                        (try forbear.element(arena, .{
                            .fontSize = 9,
                            .color = subtle,
                        }))({
                            try forbear.text(arena, "só bottom\nborder");
                        });
                    });

                    // Borda grossa com cor diferente — "pill" shape
                    (try forbear.element(arena, .{
                        .direction = .topToBottom,
                        .alignment = .topCenter,
                    }))({
                        (try forbear.element(arena, .{
                            .width = .{ .fixed = 90 },
                            .height = .{ .fixed = 60 },
                            .background = .{ .color = inner },
                            .borderRadius = 30, // pill: radius = height/2
                            .borderColor = cyan,
                            .borderWidth = .all(3),
                            .margin = forbear.Margin.block(0).withBottom(6),
                        }))({});
                        (try forbear.element(arena, .{
                            .fontSize = 9,
                            .color = subtle,
                        }))({
                            try forbear.text(arena, "pill shape\nborder 3px");
                        });
                    });
                });
            });

            // ────────────────────────────────────────────────
            // SEÇÃO 4: INTERACTIONS & ANIMATION
            // ────────────────────────────────────────────────
            try forbear.component(arena, SectionHeader, SectionHeaderProps{
                .title = "Interactions & Animation",
                .subtitle = "useState · useTransition · useSpringTransition · eventos de mouse",
                .lineColor = accent,
            });

            // ── DEMO: Hover Buttons com useTransition ─────────
            (try forbear.element(arena, cardStyle))({
                (try forbear.element(arena, .{
                    .fontSize = 10,
                    .fontWeight = 700,
                    .color = accent,
                    .textDecoration = .underline, // STORY 1.5
                    .margin = forbear.Margin.block(0).withBottom(6),
                }))({
                    try forbear.text(arena, "HOVER BUTTONS — useState + useTransition (0.18s ease)");
                });

                (try forbear.element(arena, .{
                    .fontSize = 11,
                    .color = subtle,
                    .margin = forbear.Margin.block(0).withBottom(14),
                }))({
                    try forbear.text(arena, "Passe o mouse sobre cada botão para ver a animação de cor e glow:");
                });

                // Row de botões animados — cada um com cores diferentes
                (try forbear.element(arena, .{
                    .direction = .leftToRight,
                    .alignment = .centerLeft,
                }))({
                    // Botão laranja
                    try forbear.component(arena, HoverButton, HoverButtonProps{
                        .label = "Hover aqui",
                        .baseColor = .{ 0.22, 0.12, 0.06, 1.0 }, // laranja escuro
                        .hoverColor = accent,
                    });

                    // Botão violeta
                    try forbear.component(arena, HoverButton, HoverButtonProps{
                        .label = "Animado",
                        .baseColor = .{ 0.14, 0.09, 0.20, 1.0 }, // violeta escuro
                        .hoverColor = violet,
                    });

                    // Botão ciano
                    try forbear.component(arena, HoverButton, HoverButtonProps{
                        .label = "Com glow",
                        .baseColor = .{ 0.06, 0.18, 0.16, 1.0 }, // ciano escuro
                        .hoverColor = cyan,
                    });
                });
            });

            // ── DEMO: Spring Animation ────────────────────────
            // useSpringTransition simula física real: a barra ultrapassa
            // o alvo (overshoot) e oscila antes de estabilizar.
            (try forbear.element(arena, cardStyle))({
                (try forbear.element(arena, .{
                    .fontSize = 10,
                    .fontWeight = 700,
                    .color = violet,
                    .textDecoration = .underline, // STORY 1.5
                    .margin = forbear.Margin.block(0).withBottom(6),
                }))({
                    try forbear.text(arena, "SPRING ANIMATION — useSpringTransition com física de mola");
                });

                (try forbear.element(arena, .{
                    .fontSize = 11,
                    .color = subtle,
                    .margin = forbear.Margin.block(0).withBottom(14),
                }))({
                    try forbear.text(arena, "Passe o mouse na barra violeta — ela expande com efeito elástico (overshoot):");
                });

                // O componente SpringBar gerencia seu próprio estado e animação
                try forbear.component(arena, SpringBar, null);

                // Código de referência como texto (comentário didático)
                (try forbear.element(arena, .{
                    .direction = .topToBottom,
                    .background = .{ .color = inner },
                    .borderRadius = 6,
                    .borderColor = frame,
                    .borderWidth = .all(1),
                    .padding = forbear.Padding.all(10),
                    .margin = forbear.Margin.block(12).withBottom(0),
                }))({
                    (try forbear.element(arena, .{
                        .fontSize = 10,
                        .color = subtle,
                        .lineHeight = 1.5,
                    }))({
                        try forbear.text(arena,
                            \\useSpringTransition(target, SpringConfig{
                            \\  .stiffness = 260,  // rigidez: mais alto = mais rápido
                            \\  .damping   = 18,   // amortecimento: menos = mais bounce
                            \\  .mass      = 1.0,  // massa: mais = mais lento
                            \\})
                        );
                    });
                });
            });

            // ════════════════════════════════════════════════════
            // FOOTER
            // ════════════════════════════════════════════════════
            (try forbear.element(arena, .{
                .width = .grow,
                .direction = .topToBottom,
                .alignment = .topCenter,
                .borderColor = frame,
                .borderWidth = forbear.BorderWidth.top(1), // separador superior
                .padding = forbear.Padding.block(20).withInLine(0),
                .margin = forbear.Margin.block(8).withBottom(0),
            }))({
                (try forbear.element(arena, .{
                    .fontSize = 11,
                    .color = subtle,
                    .margin = forbear.Margin.block(0).withBottom(4),
                }))({
                    try forbear.text(arena, "forbear — UI framework nativo em Zig com renderização Vulkan");
                });

                // Links com underline (STORY 1.5) — demonstração contextual
                (try forbear.element(arena, .{
                    .direction = .leftToRight,
                    .alignment = .center,
                }))({
                    (try forbear.element(arena, .{
                        .fontSize = 11,
                        .color = accent,
                        .textDecoration = .underline, // STORY 1.5
                        .margin = forbear.Margin.inLine(0).withRight(16),
                    }))({
                        try forbear.text(arena, "github.com/gabriel/forbear");
                    });

                    (try forbear.element(arena, .{
                        .fontSize = 11,
                        .color = subtle,
                        .textDecoration = .underline, // STORY 1.5
                    }))({
                        try forbear.text(arena, "docs/stories/");
                    });
                });
            });
        }); // fim da área de conteúdo
    }); // fim do container raiz
}

// ============================================================
// RENDERING LOOP
// Roda em uma thread dedicada, separada do loop de eventos da janela.
// Essa separação garante que eventos de janela (resize, input) não
// bloqueiem o rendering e vice-versa.
// ============================================================
fn renderingMain(
    allocator: std.mem.Allocator,
    renderer: *forbear.Graphics.Renderer,
    window: *const forbear.Window,
) !void {
    // ArenaAllocator: reutiliza a mesma memória a cada frame.
    // Isso evita fragmentation e mantém alocações O(1) por frame.
    var arenaAllocator = std.heap.ArenaAllocator.init(allocator);
    defer arenaAllocator.deinit();

    const arena = arenaAllocator.allocator();

    // registerFont: carrega e registra a fonte TrueType no contexto global.
    // @embedFile compila o .ttf diretamente no binário — zero dependências em runtime.
    // "Inter" é uma variable font: .fontWeight aceita 100–900 continuamente.
    try forbear.registerFont("Inter", @embedFile("Inter.ttf"));

    while (window.running) {
        // Ao fim de cada frame: libera a memória da arena mas mantém
        // o buffer alocado para o próximo frame (retain_capacity = O(1)).
        defer _ = arenaAllocator.reset(.retain_capacity);

        // Renderiza o componente raiz — reconstrói a árvore de nós desta frame.
        // O forbear é immediate-mode: App() é chamado a cada frame.
        try forbear.component(arena, App, null);

        const viewportSize = renderer.viewportSize();

        // layout(): resolve a árvore de nós em LayoutBoxes com posições absolutas.
        // A BaseStyle define os valores padrão herdados por todos os elementos
        // que não especificam explicitamente cada propriedade.
        const layoutBoxes = try forbear.layout(
            arena,
            .{
                .font = try forbear.useFont("Inter"),
                .color = text, // cor padrão de texto
                .fontSize = 13, // tamanho padrão
                .fontWeight = 400, // peso padrão
                .lineHeight = 1.2, // espaçamento entre linhas padrão
                .textWrapping = .none, // sem wrap por padrão (cada elemento pode override)
                .blendMode = .normal, // alpha blending padrão
            },
            viewportSize,
            .{
                @floatFromInt(window.dpi[0]),
                @floatFromInt(window.dpi[1]),
            },
        );

        // drawFrame(): envia os LayoutBoxes para a GPU via Vulkan.
        // `bg` é a cor de clear (cor de fundo da janela antes de qualquer elemento).
        try renderer.drawFrame(
            arena,
            layoutBoxes,
            bg,
            window.dpi,
            window.targetFrameTimeNs(),
        );

        // update(): processa eventos de mouse usando os LayoutBoxes já calculados.
        // Determina qual elemento está sob o cursor e gera eventos mouseOver/mouseOut.
        try forbear.update(arena, layoutBoxes, viewportSize);

        // resetNodeTree(): limpa a árvore de nós para o próximo frame.
        // Necessário pois a construção da árvore é acumulativa dentro de um frame.
        forbear.resetNodeTree();
    }

    // Aguarda todas as operações GPU terminarem antes de desalocar recursos.
    // Sem isso, o VkDevice pode ser destruído com comandos ainda em execução.
    try renderer.waitIdle();
}

// ============================================================
// ENTRY POINT
// ============================================================
pub fn main() !void {
    // GeneralPurposeAllocator: detecta memory leaks e double-frees em debug mode.
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        if (gpa.deinit() == .leak) {
            std.log.err("Memory leak detectado! Verifique os deinit().", .{});
        }
    }
    const allocator = gpa.allocator();

    // Graphics.init: inicializa o backend Vulkan.
    // Cria a instância VkInstance, seleciona o physical device (GPU),
    // cria o VkDevice lógico e configura as queues de rendering.
    var graphics = try forbear.Graphics.init(allocator, "forbear showcase");
    defer graphics.deinit();

    // Window.init: cria a janela nativa da plataforma.
    //   · Windows: Win32 HWND
    //   · Linux:   Wayland surface
    //   · macOS:   NSWindow + CAMetalLayer
    const window = try forbear.Window.init(
        allocator,
        880, // largura inicial em pixels lógicos
        660, // altura inicial em pixels lógicos
        "forbear — Feature Showcase",
        "forbear.feature-showcase", // app_id (usado pelo WM no Linux)
    );
    defer window.deinit();

    // initRenderer: cria o swapchain Vulkan vinculado à superfície da janela.
    // O swapchain gerencia os framebuffers e a apresentação de frames.
    var renderer = try graphics.initRenderer(window);
    defer renderer.deinit();

    // forbear.init: inicializa o contexto global do framework.
    // Aqui são alocados os hashmaps de estado, eventos e recursos.
    try forbear.init(allocator, &renderer);
    defer forbear.deinit();

    // setWindowHandlers: conecta callbacks da janela ao contexto do forbear.
    // Isso permite que eventos de resize e mouse sejam processados corretamente.
    forbear.setWindowHandlers(window);

    // Spawn da thread de rendering — separada da thread de eventos.
    // Isso evita que operações lentas de GPU bloqueiem a responsividade da janela.
    const renderingThread = try std.Thread.spawn(
        .{ .allocator = allocator },
        renderingMain,
        .{ allocator, &renderer, window },
    );
    defer renderingThread.join(); // aguarda a thread terminar ao sair

    // handleEvents(): loop de eventos da plataforma — roda na thread principal.
    // Bloqueante: processa resize, mouse move, mouse click, keyboard, etc.
    // Retorna quando a janela é fechada.
    try window.handleEvents();
}
