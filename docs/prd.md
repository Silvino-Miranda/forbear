# Forbear Framework — Product Requirements Document (PRD)

> **Version:** 1.0 | **Date:** 2026-02-21 | **Status:** Draft
> **Author:** Orion (aios-master) | **Project:** Forbear

---

## Change Log

| Date | Version | Description | Author |
|---|---|---|---|
| 2026-02-21 | 1.0 | Initial PRD created from codebase analysis | Orion (aios-master) |

---

## 1. Goals and Background Context

### Goals

- Prover um framework de UI desktop nativo de alta performance para Zig, eliminando o overhead do Electron
- Completar 10 exemplos completos de UI do mundo real como prova de conceito e showcase do framework
- Prover API declarativa no estilo React (hooks: `useState`, `useTransition`, `useSpringTransition`) com renderização Vulkan nativa
- Suportar as três principais plataformas desktop: Linux (Wayland), macOS (Metal), Windows (Win32)
- Demonstrar viabilidade de licensing comercial (gratuito para indivíduos, pago para empresas)

### Background Context

O desenvolvimento de apps desktop moderno enfrenta um trade-off histórico: desempenho nativo (Qt, Win32, GTK) vem ao custo de DX verbosa e propensa a erros; boa DX (Electron) vem ao custo de 150MB+ de bundle e alto consumo de recursos. O Forbear é uma resposta a esse dilema — um framework escrito em Zig que combina renderização Vulkan nativa com uma API inspirada em React, permitindo que desenvolvedores construam UIs complexas com animações, tipografia avançada e layouts flexíveis atingindo 165fps+ sem comprometer a experiência de desenvolvimento.

O projeto partiu de uma insatisfação real com as opções disponíveis: ou performance sem DX, ou DX sem performance. O Forbear aposta que é possível ter os três — *beautiful, performant, great DX* — e os 10 exemplos de UI do mundo real são o veículo para provar essa tese.

---

## 1.1 Out of Scope (MVP)

Os seguintes itens estão **explicitamente fora do escopo** do MVP (10 exemplos funcionando):

- **Plataformas mobile** (iOS, Android) — Forbear é desktop-only
- **WebView / Electron hybrid** — contradiz a proposta de valor do projeto
- **SVG animado** — apenas SVG estático está no escopo (Story 2.4)
- **Suporte a múltiplas janelas** — questão em aberto no `notes/open-questions.md`
- **Camada de acessibilidade** (AT-SPI, MSAA, NSAccessibility) — não planejado no roadmap atual
- **Scripting / linguagens adicionais** — API Zig only no MVP; suporte a outras linguagens é Roadmap item 3
- **Input de teclado / texto editável** — fora do escopo atual (sem widget de text input)
- **Rede / HTTP client** — framework de UI pura, sem camada de dados
- **Sistema de plugins** — não documentado no roadmap
- **Temas dinâmicos em runtime** — sem sistema de theming global no escopo

---

## 2. Requirements

### Functional Requirements

- **FR1:** O framework deve suportar criação de elementos de UI via API de funções Zig com styling declarativo (width, height, padding, margin, background, color, fontSize, borderRadius, shadow)
- **FR2:** O layout engine deve suportar direção flexível (topToBottom, leftToRight), alinhamento (center, start, end), e modo grow/fit/fixed/percentage para dimensionamento
- **FR3:** O framework deve prover hooks de estado persistente: `useState<T>`, `useAnimation`, `useTransition`, `useSpringTransition`
- **FR4:** O framework deve suportar carregamento e renderização de fontes TrueType/OpenType com shaping complexo (ligatures, RTL)
- **FR5:** O framework deve suportar carregamento de imagens (JPEG, PNG) com lazy decompression e integração com o pipeline de renderização
- **FR6:** O framework deve prover window management nativo nas 3 plataformas (Linux/Wayland, macOS/Metal, Windows/Win32)
- **FR7:** O framework deve suportar o sistema de eventos (mouseOver, mouseOut, scroll) com API de consumo por hook (`useNextEvent`)
- **FR8:** O framework deve renderizar shadows com blur, spread e offset configuráveis
- **FR9:** O framework deve suportar blend modes (normal, multiply) para composição de elementos
- **FR10:** Deve ser possível registrar e utilizar múltiplas fontes e imagens por nome via `useFont` / `useImage`
- **FR11:** Deve existir um componente `forbear.image` dedicado com sizing baseado em aspect ratio
- **FR12:** O framework deve suportar scrolling de listas e páginas longas
- **FR13:** Deve existir mecanismo de "component children slotting" para composição de componentes (`forbear.componentChildrenSlot()`)
- **FR14:** O framework deve suportar gradients (linear e radial) como backgrounds
- **FR15:** Deve ser possível sublinhar texto (text-decoration: underline)
- **FR16:** O framework deve suportar SVG como formato de imagem
- **FR17:** 10 exemplos completos de UI do mundo real devem ser implementados e funcionais
- **FR18:** O framework deve suportar texto dinâmico (não apenas `comptime fmt`)

### Non-Functional Requirements

- **NFR1:** O framework deve manter 165fps em layouts complexos com animações em hardware moderno (GPU dedicada ou integrada recente)
- **NFR2:** O bundle size do app final não deve depender de runtime pesado — sem Chromium, sem V8
- **NFR3:** Startup deve ser perceptivelmente instantâneo (< 200ms para primeira frame renderizada)
- **NFR4:** O framework deve ser compilável com Zig 0.15.2+
- **NFR5:** A API deve minimizar o número de `try` statements visíveis ao usuário final do framework
- **NFR6:** Nomes de propriedades de estilo devem ser concisos e legíveis (shorthands para padding, margin, alignment)
- **NFR7:** O registro de recursos (fontes, imagens) deve ser type-safe (sem identificação por string pura)
- **NFR8:** O framework deve ter suite de testes automatizados cobrindo layout, animações e eventos

---

## 3. User Interface Design Goals

### Overall UX Vision

O Forbear deve ser percebido como um framework onde "o que você vê no código é o que você vê na tela" — sem magia negra, sem transformações implícitas. A composição de UI deve ser tão legível quanto JSX, mas com a segurança de tipos de Zig. O desenvolvedor deve conseguir construir uma UI polida e animada com poucas linhas, sem ter que lidar com o Vulkan diretamente.

### Key Interaction Paradigms

- **Immediate-mode com estado persistente** via hooks (análogo ao React hooks, sem VDOM)
- **Event-driven com consumo explícito** via `useNextEvent()` — sem callbacks escondidos
- **Composição por funções** — componentes são funções Zig comuns, sem classes ou macros especiais
- **Animações declarativas** — `useTransition` e `useSpringTransition` sem gerenciar timers manualmente

### Core Screens and Views

Os exemplos de showcase servem como as "telas" que validam o framework:

- `uhoh.com` — Landing page com hero, navegação, imagens, tipografia variável, hover states
- `wayland-book.com` — Documentação técnica com scroll longo, sidebar, código formatado
- *(8 exemplos adicionais a definir conforme o desenvolvimento avança)*

### Accessibility

None *(framework de sistema desktop, sem camada de acessibilidade definida no escopo atual)*

### Branding

Sem branding formal definido. O framework em si é "invisível" — o showcase deve demonstrar que é possível replicar fidelmente UIs reais de sites/apps conhecidos. A qualidade visual dos exemplos é o branding.

### Target Device and Platforms

Desktop Only — Linux (Wayland), macOS (Cocoa/Metal), Windows (Win32/Vulkan)

---

## 4. Technical Assumptions

### Repository Structure

**Monorepo** — Tudo em um único repositório: `src/` (core), `examples/` (showcases), `dependencies/` (libs locais), `shaders/` (GLSL/SPIR-V), `docs/`. Padrão confirmado pelo `build.zig.zon` com paths locais para freetype, kb_text_shape e stb_image.

### Service Architecture

O Forbear é uma **biblioteca estática**, não um serviço. Consumidores adicionam via `build.zig.zon`. Não há backend, servidor ou microserviços — é puro sistema de UI desktop. Arquitetura: `src/root.zig` expõe a API pública; `examples/` são executáveis independentes que linkam a lib.

### Testing Requirements

- **Unit tests:** layout engine, spring physics, state management, event dispatching
- **Integration tests:** pipeline completo (atualmente via `test_runner.zig`)
- **Manual visual tests:** via `playground.zig` e exemplos reais
- Sem E2E automatizado formal (visual regression requer display server)

### Additional Technical Assumptions

| Decisão | Escolha | Rationale |
|---|---|---|
| **Linguagem** | Zig 0.15.2+ | Sistema de tipos forte, zero overhead, sem GC |
| **Graphics API** | Vulkan 1.4.335 | Cross-platform, máxima performance, controle total do pipeline |
| **Shaders** | GLSL → SPIR-V | Compilado em build time via `glslangValidator + spirv-opt` |
| **Font rendering** | FreeType (local) | TrueType/OpenType, variable fonts |
| **Text shaping** | kb_text_shape (local) | HarfBuzz-like, ligatures, RTL |
| **Image decoding** | stb_image (local) | JPEG, PNG, lightweight |
| **Math** | zmath (git) | SIMD-optimized vetores/matrizes |
| **Window (Linux)** | Wayland | Protocolo moderno, sem X11 legado |
| **Window (macOS)** | Cocoa + Metal | API nativa Apple |
| **Window (Windows)** | Win32 + Vulkan | API nativa Microsoft |
| **Build system** | Zig build (build.zig) | Integrado ao toolchain, sem CMake/Make |
| **Licensing** | Free individuals / Paid companies | Modelo source-available |

---

## 5. Epic List

| # | Epic | Objetivo |
|---|---|---|
| **1** | Core Feature Completions | Implementar as features faltantes que bloqueiam os exemplos: percentage sizing, scrolling, component slotting, `forbear.image` element e underlined text |
| **2** | Visual Rendering Completions | Adicionar suporte a SVG, gradients (linear/radial), filter effects (grayscale) e corrigir frame drops com imagens grandes |
| **3** | Developer Experience Improvements | Reduzir `try` statements na API, implementar shorthands de style, tornar registro de recursos type-safe |
| **4** | UI Showcase — Batch 1 (5 exemplos) | Implementar e refinar 5 exemplos completos: `uhoh.com` (finalizar), `wayland-book.com` + 3 a definir |
| **5** | UI Showcase — Batch 2 (5 exemplos) | Implementar os 5 exemplos restantes para atingir o milestone de 10 UIs completas |

---

## 6. Epic Details

### Epic 1: Core Feature Completions

**Objetivo:** Implementar as funcionalidades de layout e composição que estão faltando e que bloqueiam diretamente a implementação fiel dos exemplos de UI do mundo real. Ao término deste epic, o framework deve suportar sizing percentual, scrolling, composição de componentes via slotting, um elemento `image` dedicado e sublinhado de texto — features confirmadas como necessárias pelo TODO.md após a tentativa de replicar `uhoh.com`.

---

#### Story 1.1 — Percentage-Based Sizing

> As a Zig UI developer,
> I want to define element widths and heights as a percentage of their parent,
> so that I can build responsive layouts without hardcoding pixel values.

**Acceptance Criteria:**
1. `Style.width = .{ .percentage = 50 }` e `.height = .{ .percentage = 100 }` são tipos válidos compiláveis
2. `resolvePercentageSizing()` calcula corretamente o tamanho absoluto antes do layout final
3. Percentagem é relativa ao tamanho do pai imediato (não da janela)
4. Funciona combinado com `.grow`, `.fit` e `.fixed` em siblings do mesmo container
5. Testes unitários cobrem: 50% de pai 200px = 100px, 100% = tamanho total, percentagem aninhada
6. `zig build test` passa sem erros

*(Nota: em progresso na branch `feature/add-aios` — story pode estar parcialmente completa)*

---

#### Story 1.2 — Page and List Scrolling

> As a Zig UI developer,
> I want to make any container element scrollable when its content overflows,
> so that I can build pages with long content and scrollable lists.

**Acceptance Criteria:**
1. Elemento pode ser marcado como scrollable via prop de style (ex: `overflow: .scroll`)
2. Scroll vertical funciona com mouse wheel em Linux (Wayland), macOS e Windows
3. Scroll usa spring physics consistente com `useSpringTransition` já implementado
4. Conteúdo fora dos bounds do container não é renderizado (clipping correto)
5. O `playground.zig` possui uma demo funcional de scroll com mais de 2x a altura da janela
6. `zig build test` passa sem erros

---

#### Story 1.3 — Component Children Slotting

> As a Zig UI developer,
> I want to pass child elements to custom components,
> so that I can build reusable container components like cards, modals and layouts.

**Acceptance Criteria:**
1. `forbear.componentChildrenSlot()` marca o ponto de inserção dos filhos dentro de um componente
2. Componente pai pode receber um bloco de filhos via a API de composição
3. Filhos são renderizados no ponto correto do layout do componente pai
4. Funciona com aninhamento (componente dentro de componente com slots)
5. Exemplo no `playground.zig` demonstra um `Card` component com slot para conteúdo
6. `zig build test` passa sem erros

---

#### Story 1.4 — Dedicated Image Element

> As a Zig UI developer,
> I want a `forbear.image()` element that automatically sizes based on aspect ratio,
> so that I can display images naturally without manually calculating dimensions.

**Acceptance Criteria:**
1. `forbear.image(arena, imageId, style)` existe como função pública na API
2. Se apenas `width` ou apenas `height` for definido, a outra dimensão é calculada pelo aspect ratio da imagem
3. Imagem não causa frame drops — decompressão é feita de forma assíncrona ou pré-carregada
4. Suporta `fit`, `fixed` e `percentage` sizing para width/height independentemente
5. `backgroundImage` no style continua funcionando (sem breaking change)
6. Exemplo no `playground.zig` demonstra uma galeria de imagens com aspect ratio preservado
7. `zig build test` passa sem erros

---

#### Story 1.5 — Underlined Text

> As a Zig UI developer,
> I want to apply text-decoration underline to text elements,
> so that I can build links and highlighted text in my UIs.

**Acceptance Criteria:**
1. `Style.textDecoration = .underline` é uma propriedade válida
2. O underline é renderizado corretamente abaixo do baseline do texto
3. Cor do underline segue a `Style.color` do elemento por padrão
4. Funciona com fontes variáveis e diferentes tamanhos de fonte
5. `zig build test` passa sem erros

---

### Epic 2: Visual Rendering Completions

**Objetivo:** Adicionar as primitivas visuais que completam o vocabulário de renderização do Forbear — gradients, SVG, efeitos de filtro e correção de performance com imagens grandes. Ao término deste epic, o framework deve ser capaz de reproduzir fielmente qualquer UI moderna que use esses recursos visuais, eliminando os últimos gaps identificados no TODO.md após a análise do `uhoh.com`.

---

#### Story 2.1 — Linear Gradient Backgrounds

> As a Zig UI developer,
> I want to set a linear gradient as an element's background,
> so that I can create visually rich UIs with smooth color transitions.

**Acceptance Criteria:**
1. `Style.background = .{ .linearGradient = .{ .from = color1, .to = color2, .angle = 90 } }` é válido
2. O gradient é renderizado corretamente no shader GLSL do elemento
3. Suporta ângulos arbitrários (0°-360°)
4. Funciona combinado com `borderRadius` (gradient respeita os cantos arredondados)
5. Exemplo no `playground.zig` demonstra um botão com gradient horizontal e um container com gradient vertical
6. `zig build test` passa sem erros

---

#### Story 2.2 — Radial Gradient Backgrounds

> As a Zig UI developer,
> I want to set a radial gradient as an element's background,
> so that I can create circular/spotlight visual effects in my UIs.

**Acceptance Criteria:**
1. `Style.background = .{ .radialGradient = .{ .center = Vec2, .inner = color1, .outer = color2 } }` é válido
2. O gradient radial é renderizado corretamente no shader GLSL do elemento
3. Centro do gradient é configurável (default: centro do elemento)
4. Funciona combinado com `borderRadius`
5. Exemplo no `playground.zig` demonstra um card com radial gradient de destaque
6. `zig build test` passa sem erros

---

#### Story 2.3 — Filter Effects (Grayscale)

> As a Zig UI developer,
> I want to apply a grayscale filter to any element or image,
> so that I can create disabled states, hover effects and artistic UI treatments.

**Acceptance Criteria:**
1. `Style.filter = .{ .grayscale = 1.0 }` aplica conversão total para escala de cinza (0.0 = colorido, 1.0 = cinza total)
2. Filtro é aplicado via shader no pipeline de rendering (sem custo de CPU)
3. Funciona em qualquer elemento (container, texto, imagem)
4. Funciona com valores intermediários (ex: `0.5` para semi-grayscale)
5. Exemplo no `playground.zig` demonstra uma imagem com toggle entre colorida e grayscale via hover
6. `zig build test` passa sem erros

---

#### Story 2.4 — SVG Support

> As a Zig UI developer,
> I want to load and render SVG files as images,
> so that I can use scalable vector graphics for icons and illustrations without quality loss.

**Acceptance Criteria:**
1. `forbear.registerSvg(name, path)` carrega um arquivo SVG e o rasteriza em uma textura
2. SVG registrado pode ser usado via `forbear.image()` ou como `Style.backgroundImage`
3. SVG é rasterizado na resolução correta baseada no tamanho renderizado (sem pixelação)
4. Suporta SVGs estáticos (sem animação SVG)
5. Erro claro se o arquivo SVG não for encontrado ou for inválido
6. Exemplo no `playground.zig` demonstra ícones SVG em diferentes tamanhos sem pixelação
7. `zig build test` passa sem erros

*(Nota: a escolha da biblioteca SVG é decisão de implementação do @dev/@architect)*

---

#### Story 2.5 — Large Image Performance Fix

> As a Zig UI developer,
> I want images to load without causing frame drops,
> so that my UI remains smooth even when displaying high-resolution images.

**Acceptance Criteria:**
1. Imagens grandes (> 1MB descomprimidas) não causam frame drops visíveis (queda > 20fps por mais de 1 frame)
2. Decompressão de imagem ocorre fora do thread de rendering (async ou pré-load no startup)
3. Enquanto a imagem não está disponível, um placeholder transparente ou de cor sólida é exibido
4. A API `forbear.registerImage` permanece a mesma (sem breaking change para o usuário)
5. Medição: FPS counter (`FpsCounter` component) permanece >= 60fps durante carregamento de imagem 4K
6. `zig build test` passa sem erros

---

### Epic 3: Developer Experience Improvements

**Objetivo:** Resolver os problemas de ergonomia da API identificados durante o desenvolvimento do `uhoh.com` e documentados no TODO.md. Ao término deste epic, escrever UI com Forbear deve ser visivelmente mais limpo e legível — sem `try` em cada linha, com nomes de propriedades concisos e com segurança de tipos no acesso a recursos.

---

#### Story 3.1 — Style Property Shorthands

> As a Zig UI developer,
> I want concise, readable style property names and helper functions,
> so that my UI code is scannable and less verbose to write.

**Acceptance Criteria:**
1. Funções helper existem para padding e margin: `.all(n)`, `.inline(n)`, `.block(n)`, `.top(n)`, `.bottom(n)`, `.left(n)`, `.right(n)`
2. `paddingBlock` e `paddingInline` continuam funcionando (sem breaking change) mas podem ser expressos via helpers
3. `horizontalAlignment` e `verticalAlignment` têm aliases mais curtos (ex: `.alignX`, `.alignY` ou equivalente)
4. O exemplo `uhoh.com` é atualizado para usar os novos shorthands e fica visivelmente mais legível
5. Documentação inline (doc comments Zig) explica cada shorthand com exemplo de uso
6. `zig build test` e `zig build check` passam sem erros

---

#### Story 3.2 — Reduced `try` in Component API

> As a Zig UI developer,
> I want to write component trees without `try` before every element call,
> so that my UI code is readable and the structure of the UI is visually clear.

**Acceptance Criteria:**
1. Uma abordagem alternativa de composição de elementos é proposta e implementada que elimina ou reduz o `try` explícito por elemento
2. O `playground.zig` e o exemplo `uhoh.com` são reescritos usando a nova API
3. Um componente típico de 10 elementos tem no máximo 2 `try` statements visíveis
4. Breaking changes na API pública são documentados com guia de migração em `docs/migration.md`
5. `zig build test`, `zig build check` e `zig build run` passam sem erros

*(Nota: story de maior complexidade arquitetural do epic — pode requerer spike de @architect antes da implementação)*

---

#### Story 3.3 — Type-Safe Resource Registration

> As a Zig UI developer,
> I want font and image resources to be accessed with compile-time type safety,
> so that typos in resource names are caught at build time, not at runtime.

**Acceptance Criteria:**
1. `useFont` e `useImage` não aceitam mais strings arbitrárias como identificadores
2. Uma alternativa type-safe é implementada (ex: enum gerado em comptime, handle tipado, ou similar)
3. Tentativa de usar um recurso não registrado gera erro de compilação (não erro de runtime)
4. A API de `registerFont` / `registerImage` produz os identificadores type-safe correspondentes
5. O exemplo `uhoh.com` é atualizado para usar a nova API type-safe
6. Documentação inline explica o novo padrão de registro e uso
7. `zig build test` e `zig build check` passam sem erros

---

### Epic 4: UI Showcase — Batch 1 (5 exemplos)

**Objetivo:** Implementar os primeiros 5 exemplos completos de UI do mundo real usando o Forbear após as melhorias dos Epics 1-3. Cada exemplo deve ser uma réplica fiel o suficiente para demonstrar que o framework é capaz de reproduzir UIs modernas profissionais. Ao término deste epic, existe material concreto de showcase para validar o modelo de licensing e atrair early adopters.

---

#### Story 4.1 — uhoh.com (Completo)

> As a framework showcase viewer,
> I want to see a complete, pixel-faithful replica of uhoh.com built with Forbear,
> so that I can evaluate the framework's capability to render real-world landing pages.

**Acceptance Criteria:**
1. Navigation bar com logo, links e botões renderizada corretamente com hover states
2. Hero section com tipografia variável grande, imagens e layout correto
3. Todas as seções da página visíveis com scroll (page scrolling funcional)
4. Blend mode `multiply` aplicado corretamente nas imagens que o utilizam
5. Gradients de background reproduzidos onde existem no original
6. FPS permanece >= 60fps durante scroll suave na página completa
7. `zig build check` compila o exemplo sem warnings

---

#### Story 4.2 — wayland-book.com

> As a framework showcase viewer,
> I want to see a replica of wayland-book.com built with Forbear,
> so that I can evaluate the framework's capability to render documentation sites with long content.

**Acceptance Criteria:**
1. Layout com sidebar de navegação e área de conteúdo principal
2. Tipografia técnica com blocos de código (monospace font) renderizados corretamente
3. Scroll longo funcional (documento técnico com muitas páginas)
4. Links de navegação interna com destaque de seção ativa
5. FPS permanece >= 60fps durante scroll de conteúdo longo
6. `zig build check` compila o exemplo sem warnings

---

#### Stories 4.3, 4.4, 4.5 — Exemplos a Definir

Os 3 exemplos restantes do Batch 1 serão selecionados pelo autor dentre as seguintes opções (cada uma exercita capacidades diferentes do framework):

| Opção | UI Inspiração | Capacidades Demonstradas |
|---|---|---|
| A | Player de música (Spotify-like) | Animações contínuas, progress bars, listas virtuais, estados complexos |
| B | Dashboard de analytics (Linear/Vercel-like) | Layouts de grid, dados dinâmicos, componentes de card, navegação lateral |
| C | App de chat minimalista | Scroll de lista, input de texto, timestamps, avatares/imagens |
| D | File manager nativo | Tree view, seleção múltipla, context areas, ícones SVG |
| E | Terminal emulator visual | Monospace rendering, scroll de output, cursor piscando, input |

*Stories 4.3-4.5 serão criadas formalmente após seleção dos exemplos pelo autor.*

---

### Epic 5: UI Showcase — Batch 2 (5 exemplos)

**Objetivo:** Implementar os 5 exemplos finais que completam o milestone de 10 UIs do mundo real, atingindo a primeira grande meta do roadmap do Forbear. Os exemplos do Batch 2 devem exercitar capacidades do framework não cobertas no Batch 1, demonstrando a versatilidade do Forbear e servindo como material definitivo de showcase para o lançamento público.

---

#### Stories 5.1 — 5.5 — Exemplos a Definir

Os 5 exemplos do Batch 2 serão selecionados após conclusão do Batch 1, com base nas capacidades do framework e nas lições aprendidas. Sugestões por capacidade não coberta nos primeiros 5 exemplos:

| Story | Sugestão | Capacidade Nova |
|---|---|---|
| 5.1 | App de notas / editor simples (Notion-like) | Rich text, múltiplos tipos de bloco, edição inline |
| 5.2 | Galeria de imagens / portfolio | Grid masonry, lightbox, transições entre views |
| 5.3 | Settings / Preferences panel | Forms, toggles, sliders, inputs, grupos de configuração |
| 5.4 | Onboarding / Wizard multi-step | Transitions entre telas, progress indicator, estados de formulário |
| 5.5 | App nativo próprio do autor | TBD — showcase definitivo do que o Forbear foi construído para fazer |

*Stories 5.1-5.5 serão criadas formalmente pelo @sm após conclusão do Epic 4.*

**Critério de conclusão do Epic 5 (e do MVP):**
- 10 exemplos funcionando, compilando e com FPS estável
- Todos os exemplos disponíveis no diretório `examples/` do repositório
- README de cada exemplo documenta o que demonstra e como rodar

---

## 7. Checklist Results Report

*(Gerado após validação pelo pm-checklist — ver seção abaixo)*

---

## 8. Next Steps

### UX Expert Prompt

> Use this PRD to design the visual identity and UX patterns for the Forbear framework's 10 showcase examples. Focus on the interaction paradigms (immediate-mode hooks, declarative style), the target developer audience (Zig devs, Electron migrants), and the platform constraints (desktop-only, Vulkan rendering). Start with `@ux-design-expert *create-frontend-spec` referencing this document.

### Architect Prompt

> Use this PRD to design the technical architecture for the missing features: percentage sizing (in-progress), scrolling, component slotting, SVG support, gradients, filter effects, and the DX improvements (try reduction, shorthands, type-safe resources). Assess the risk of the `try` reduction (Story 3.2) and propose the implementation approach. Start with `@architect` referencing this document and `src/root.zig`, `src/layouting.zig`, `src/node.zig`, and `src/graphics.zig`.
