pragma Singleton
import QtQuick
import QtCore
import Quickshell
import Quickshell.Io

// Wintermute Shell · Armitage
// Fonte de valores: docs/design/tokens/tokens.json (aprovado 14/11/2026) +
// medidas de layout e de movimento herdadas do código de partida +
// refinamentos de grade do design no Figma.
//
// Este é o único arquivo de tema da shell: toda cor, medida e tempo sai daqui.
// Nunca invente um valor que não esteja aqui ou nas fichas de
// docs/design/pecas/. Se faltar, pergunte — não chute.
//
// O bloco "Compatibilidade com o código de partida", no fim, não é tema: é o
// que mantém o código antigo abrindo até cada peça ser redesenhada.
//
// Cores com alpha neste arquivo usam Qt.rgba / Qt.alpha (canais 0–1).
// tokens.json guarda alpha no formato CSS #RRGGBBAA; use fromCss() para converter.
// Qt Quick usa #AARRGGBB se você montar uma string de 8 dígitos na mão.

Singleton {
  id: root

  // ---------------------------------------------------------------------------
  // Variação selecionável: "chiba" | "freeside" | "sprawl"
  // Padrão: chiba. Persistência: ver themeFile abaixo.
  // ---------------------------------------------------------------------------
  property string name: "chiba"

  readonly property var schemeNames: ["chiba", "freeside", "sprawl"]

  readonly property var schemes: ({
    chiba: chibaScheme,
    freeside: freesideScheme,
    sprawl: sprawlScheme
  })

  readonly property var current: schemes[name] || chibaScheme

  readonly property string displayName: current.displayName

  // ---- acentos (só isto muda entre as 3 variações) ----
  readonly property color accent: current.accent
  readonly property color accentHover: current.accentHover
  readonly property color accentPressed: current.accentPressed
  readonly property color accentSubtle: current.accentSubtle      // acento 18%, fundo de seleção
  readonly property color accentRing: current.accentRing          // acento 50%, anel
  readonly property color accentGlow: current.accentGlow          // acento ~8%, brilho do vidro
  readonly property color accentText: current.accentText          // texto/ícone colorido (legível)
  // No tokens.json e nas fichas este token se chama onAccent. Em QML um nome que
  // começa com "on" seguido de maiúscula é lido como tratador de sinal e o
  // arquivo não carrega, então aqui ele é textOnAccent.
  readonly property color textOnAccent: current.textOnAccent      // sempre #0D0E11

  // ---- neutros (iguais nas 3) ----
  readonly property color background: "#0D0E11"
  readonly property color secondary: "#16171A"
  readonly property color raised: "#1F2023"
  readonly property color text: "#F2F3F5"
  readonly property color muted: "#C2C4C7"            // NÃO usar #B4B6BA do tema Armitage original
  readonly property color placeholder: "#86888B"      // só decorativo; nunca texto que informa
  // Cor do logo da marca (P-58): um meio termo entre text (#F2F3F5) e muted (#C2C4C7), que não têm token
  // entre eles. É a média canal a canal: (242+194)/2 = 218, (243+196)/2 = 219,5 → 220, (245+199)/2 = 222.
  readonly property color brandMark: "#DADCDE"
  readonly property color danger: "#EF6663"
  readonly property color dangerText: "#F7B2B1"       // texto/ícone de perigo (legível no vidro)
  readonly property color success: "#5AC576"
  readonly property color successText: "#88D59C"
  readonly property color warning: "#F2C44A"          // yellow do Armitage (anotação, indicador)
  readonly property color attention: "#F68B43"        // orange do Armitage
  readonly property color attentionText: "#F9B587"
  readonly property color border: Qt.rgba(1, 1, 1, 0.10)          // #FFFFFF1A
  readonly property color borderStrong: Qt.rgba(1, 1, 1, 0.15)    // #FFFFFF26  (~25% pedido no escopo cai aqui e em borderMuted)
  readonly property color borderMuted: Qt.rgba(1, 1, 1, 0.25)     // #FFFFFF40  tokens.json base.border_25
  readonly property color hover: Qt.rgba(1, 1, 1, 0.06)           // #FFFFFF0F  botões e linhas
  readonly property color pressed: Qt.rgba(1, 1, 1, 0.10)         // #FFFFFF1A
  readonly property color control: Qt.rgba(1, 1, 1, 0.05)         // #FFFFFF0D
  readonly property color track: Qt.rgba(1, 1, 1, 0.12)           // #FFFFFF1F
  readonly property color cardHover: Qt.rgba(1, 1, 1, 0.04)       // #FFFFFF0A  hover do VIDRO (cartão), não confundir com hover
  readonly property color scrim: Qt.rgba(13 / 255, 14 / 255, 17 / 255, 0.80)  // #0D0E11CC
  readonly property color dot: Qt.rgba(1, 1, 1, 0.30)             // #FFFFFF4D
  readonly property color knob: "#F2F3F5"

  // ---------------------------------------------------------------------------
  // Regras de contraste (obrigatórias)
  // ---------------------------------------------------------------------------
  // 1. Texto secundário da shell é sempre muted (#C2C4C7), nunca #B4B6BA.
  // 2. Texto ou ícone NA COR do acento usa accentText, nunca accent puro.
  //    Freeside puro sobre o vidro fica em 3,08:1 — reprovado.
  // 3. Acento puro (accent / accentHover / accentPressed) só em preenchimentos
  //    e detalhes (trilho, anel, disco, botão primário, brilho).
  // 4. Texto/ícone em cima de um preenchimento de acento usa textOnAccent (#0D0E11).
  // 5. Em linha selecionada (fundo accentSubtle), o texto secundário usa `text`,
  //    não `muted`.
  // 6. placeholder (#86888B) nunca para texto que informa algo.
  // 7. dangerText / successText / attentionText para texto e ícones coloridos;
  //    danger / success / attention / warning para preenchimentos.

  // ---- vidro (igual nas 3; o brilho da base usa o acento atual) ----
  readonly property real glassBlur: 40                  // P-03 começou em 50; voltei para os 40 do Figma em 2026-11-17 (S13). No niri vira background-effect blur
  readonly property color glassTop: Qt.rgba(13 / 255, 14 / 255, 17 / 255, 0.94)   // #0D0E11 @ 94%
  readonly property color glassMid: Qt.rgba(22 / 255, 23 / 255, 26 / 255, 0.92)   // #16171A @ 92%, pos 0.55
  readonly property color glassBottom: Qt.rgba(42 / 255, 44 / 255, 49 / 255, 0.92) // #2A2C31 @ 92%
  readonly property real glassMidStop: 0.55
  readonly property real glassAccentGlowAlpha: 0.10     // elipse; com blur 40 o efetivo sobre o texto é ≤ 8%
  readonly property real glassAccentGlowWidthFactor: 1.20
  readonly property real glassAccentGlowHeightFactor: 0.50
  readonly property int glassAccentGlowMaxHeight: 80
  readonly property int glassAccentGlowBlur: 40
  readonly property color glassRimTop: Qt.rgba(1, 1, 1, 0.20)
  readonly property color glassRimMid: Qt.rgba(1, 1, 1, 0.06)
  readonly property color glassRimBottom: Qt.rgba(1, 1, 1, 0.16)
  readonly property int glassRimWidth: 1
  readonly property color glassInnerHighlight: Qt.rgba(1, 1, 1, 0.08)  // inner shadow 0,1 blur 0

  // Sombras do vidro Armitage (substitui as 5 camadas da Pond em PanelStyle)
  readonly property var glassShadows: [
    { x: 0, y: 2, blur: 6, alpha: 0.30 },
    { x: 0, y: 12, blur: 32, alpha: 0.45 }
  ]

  // ---- raios ----
  readonly property int radiusCard: 16
  readonly property int radiusPanel: 16        // painel empilhado (Wi-Fi, som, BT) — Vidro/Tipo=Painel
  readonly property int radiusPopup: 20        // pop-up (bateria, alguns toasts)
  readonly property int radiusModal: 32
  readonly property int radiusLauncher: 24
  readonly property int radiusRow: 12
  readonly property int radiusPill: 999
  readonly property int radiusChip: 10
  readonly property int radiusToggle: 14
  readonly property int radiusIconButton32: 10
  readonly property int radiusIconButton40: 12
  readonly property int radiusPrimaryButton: 24
  readonly property int radiusSecondaryButton: 10

  // ---- espaçamentos e layout da barra (herdados da Pond, Theme.qml:45-93) ----
  readonly property int sidebarOuterMargin: 10
  readonly property int sidebarCardExpandedWidth: 156
  readonly property int sidebarCardCollapsedWidth: 48
  readonly property int sidebarCardRadius: 16
  readonly property int sidebarCardGap: 6
  readonly property int sidebarFadeWidth: 12
  readonly property int sidebarRowHorizontalPadding: 16
  readonly property int sidebarSimpleRowHeight: 48
  readonly property int sidebarStrokeWidth: 1

  // Relógio Armitage (refinado para a grade de 4; Pond era 75 / 155 / Advent Pro 39)
  readonly property int clockExpandedHeight: 76
  readonly property int clockCollapsedHeight: 156
  // Era 36. Com 36, a hora mais larga (23:33, 92,6 px em Geist Serif) passava da caixa de 88
  // e encostava no chip da data em 135 dos 1440 horários. Com 34 ela mede 87,5 e cabe.
  readonly property int clockTimeSize: 34
  readonly property int dateChipSize: 40
  readonly property int dateChipRadius: 8
  readonly property int batteryTrackHeight: 4
  readonly property int batteryTrackWidth: 132

  // Organizador (Pond Theme.qml:70-90 + refinamentos)
  readonly property int workspaceControlSize: 40
  readonly property int workspaceCollapsedControlSize: 32   // inclusive a variante "Recolhida focada"
  readonly property int workspaceControlGap: 8
  readonly property int workspaceControlPitch: workspaceControlSize + workspaceControlGap  // 48
  readonly property int workspaceRowGap: 10
  readonly property int workspaceRowPitch: workspaceControlSize + workspaceRowGap          // 50
  readonly property int workspaceCollapsedControlGap: 8
  readonly property int workspaceCollapsedControlPitch: workspaceCollapsedControlSize + workspaceCollapsedControlGap  // 40
  readonly property int workspaceGridColumns: 3
  readonly property int workspaceGridMinimumRows: 3
  readonly property int workspaceContentPadding: 10   // (156 − 3*40 − 2*8) / 2
  readonly property int workspaceActiveIndicatorInset: 5
  readonly property int workspaceActiveIndicatorWidth: 146
  readonly property int workspaceActiveIndicatorHeight: 50
  readonly property int workspaceActiveIndicatorRadius: 10
  readonly property int workspaceIconSize: 16
  readonly property int workspacePlaceholderDotSize: 4
  readonly property int workspaceCollapsedHeaderHeight: 37
  readonly property int workspacePillWidth: 14
  readonly property int workspacePillHeight: 20
  readonly property int workspaceGridMinimumHeight: workspaceContentPadding * 2
      + workspaceGridMinimumRows * workspaceControlSize
      + (workspaceGridMinimumRows - 1) * workspaceRowGap

  // Painéis (Pond PanelStyle.qml:41-47, com o vidro Armitage)
  readonly property int panelWidth: 316
  readonly property int panelBackWidth: 284
  readonly property int panelBackOffset: 16
  readonly property int panelFieldWidth: 276
  readonly property int panelFieldHeight: 44
  readonly property int panelRowWidth: 300
  readonly property int panelRowHeight: 44
  readonly property int audioRowHeight: 40
  readonly property int settingsRowWidth: 520
  readonly property int settingsRowHeight: 52
  readonly property int settingsRowPitch: 60
  readonly property int settingsModalWidth: 580
  readonly property int settingsCategorySize: 264
  readonly property int settingsCategoryPitch: 272
  readonly property int settingsSessionSize: 128
  readonly property int settingsSessionPitch: 136
  // Tela inicial dos Ajustes (ficha 13; Figma 13:15797 e 13:15855). A composição é 2 cartões
  // + 1 coluna de sessão na largura (264 + 272 + 136 = 672) e 4 botões de sessão na altura (536).
  readonly property int settingsCompositionWidth: settingsCategoryPitch * 2 + settingsSessionSize
  readonly property int settingsCompositionHeight: settingsSessionPitch * 3 + settingsSessionSize
  readonly property int settingsEdgeMargin: 16          // bandeja no topo, selo embaixo e perfil à direita
  readonly property int settingsCategoryInset: 32       // bloco do ícone em (32,32) e nome em (32,184)
  readonly property int settingsCategoryNameY: 184
  readonly property int settingsCategoryNameHeight: 48
  readonly property int settingsCategoryArrowX: 212     // seta arrow-up-right do hover
  readonly property int settingsIconTileSize: 48        // raio radiusRow (12), ícone 20
  readonly property int settingsSessionRadius: 12
  readonly property int settingsSessionCircle: 80       // círculo em (24,24), ícone 20
  readonly property int settingsSessionDot: 8           // ponto dangerText do Desligar, em (100,20)
  readonly property int settingsSessionDotX: 100
  readonly property int settingsSessionDotY: 20
  readonly property int settingsSessionLabelGap: 16     // nome à direita: 128 + 16
  readonly property color settingsSessionCircleHover: Qt.rgba(13 / 255, 14 / 255, 17 / 255, 0.55) // Figma 13:15899
  readonly property int settingsTrayHeight: 44          // faixa de raio 8 com borda `border`
  readonly property int settingsTrayRadius: 8
  readonly property int settingsTrayPadding: 4
  readonly property int settingsTrayButton: 36          // raio 6, ícone 16 a 80%
  readonly property int settingsTrayButtonRadius: 6
  readonly property real settingsTrayIconOpacity: 0.8
  readonly property int settingsProfileWidth: 48        // coluna de vidro de raio 16 com 3 botões ícone 40
  readonly property int settingsProfileHeight: 136
  readonly property int settingsProfilePadding: 4
  readonly property int settingsBadgeWidth: 248         // pílula accentSubtle de raio 8
  readonly property int settingsBadgeHeight: 32
  readonly property int settingsBadgeRadius: 8
  readonly property int settingsBadgePadding: 12        // ícone 16 em (12,8), texto em 36
  // Modais das subpáginas (ficha 13; Figma 13:15915, 13:15927, 13:15971 e 13:15984).
  readonly property int settingsBodyTop: 84              // primeira linha, seletor ou busca em (30,84)
  readonly property int settingsBodyInset: 30
  readonly property int settingsBottomPadding: 32
  readonly property int settingsStepSliderWidth: 480     // trilho de 12, raio 6, em x 50; 9 marcas de 1×8 a cada 60
  readonly property int settingsStepSliderPitch: 60
  readonly property int settingsStepSliderKnob: 24
  readonly property int settingsStepSliderGroup: 104     // do rótulo de um slider ao rótulo do seguinte
  readonly property int settingsPickerRowHeight: 44      // opção de 520×44, raio 12
  readonly property int settingsPickerListTop: 140       // busca de 44 em y 84 e 12 de folga
  readonly property int settingsPickerMaxHeight: 460     // altura máxima do modal; a lista rola dentro
  // Tela e Organizar monitores (ficha 13; Figma 13:16041 e 13:16062).
  readonly property int settingsDisplayPreviewHeight: 280   // desenho dos monitores de 520×280, raio 16, em (30,84)
  readonly property int settingsDisplayRowsTop: 380         // primeira linha 16 abaixo do desenho
  readonly property int settingsDisplayTileRadius: 8        // monitor; selecionado com anel accentRing de 2
  readonly property int settingsDisplayTileInset: 2         // folga de 4 entre monitores vizinhos na Tela
  readonly property int settingsDisplayLineHeight: 20       // nome 13 Medium e conector 11 Medium, centrados juntos
  readonly property int settingsDisplayArrangeWidth: 96     // botão "Arrange" de 96×32 a 16 da direita e da base
  readonly property int settingsArrangeAreaHeight: 320      // área de arraste de 520×320, raio 16, em (30,84)
  readonly property int settingsArrangeGuideInset: 24       // guia de encaixe de 1 px, a 24 das bordas da área
  readonly property int settingsArrangeFooterTop: 420       // dica e botões 16 abaixo da área
  readonly property int settingsArrangeHintWidth: 300       // dica 13 Regular, linha de 20, muted
  readonly property int settingsArrangeButtonWidth: 104     // "Cancel" e "Done" de 104×40, raio 10, 16 entre eles
  readonly property int settingsArrangeBottomPadding: 40    // modal de 580×500
  // Informações (ficha 13; Figma 13:16083): modal de 580×620.
  readonly property int settingsInfoHeight: 620
  readonly property int settingsInfoRowPitch: 48         // 7 linhas a partir de y 84, divisor border de 1 entre elas
  readonly property int settingsInfoNumberSize: 24       // círculo control com borda border, Mono 11 Medium em text
  readonly property int settingsInfoLabelX: 66           // rótulo 15 Medium muted, 120 de largura
  readonly property int settingsInfoLabelWidth: 120
  readonly property int settingsInfoValueX: 186          // valor Serif 17 em text, até a borda direita (364)
  readonly property int settingsInfoManualTop: 436       // botão Manual de 520×64, raio 12
  readonly property int settingsInfoManualHeight: 64
  readonly property int settingsInfoManualBlock: 40      // bloco accentSubtle de raio 10 em (12,12), book-open 20 em accentText
  readonly property int settingsInfoManualBlockRadius: 10
  readonly property int settingsInfoManualTextX: 64      // "Manual" 15 Medium e a legenda 13 Regular muted, linhas de 20
  readonly property int settingsInfoFooterTop: 536       // rodapé de 56: broto 40×40, "Wintermute" Serif 17 e a versão Mono 11 muted, "ARCH" à direita (P-58)
  // Manual (Figma 13:16158): modal de 500×656 sem título
  readonly property int settingsManualWidth: 500
  readonly property int settingsManualHeight: 656
  readonly property int settingsManualSwitcherTop: 24     // seletor Keyboard / Touchpad de 168×40, centrado
  readonly property int settingsManualContentWidth: 440   // tutorial, lista e botão, em x 30
  readonly property int settingsManualTutorialTop: 80     // tutorial de 440×240, raio 16, cardHover com borda border
  readonly property int settingsManualTutorialHeight: 240
  readonly property int settingsManualCaptionTop: 192     // legenda 13 Medium muted numa caixa de 440×24
  readonly property int settingsManualCaptionHeight: 24
  readonly property int settingsManualListTop: 336        // linhas de 44; a área de seis linhas rola (P-52)
  readonly property int settingsManualRowPitch: 44
  readonly property int settingsManualVisibleRows: 6
  readonly property int settingsManualKeyGap: 4           // entre as teclas de uma linha
  readonly property int settingsManualLabelWidth: 230     // descrição 13 Medium muted, alinhada à direita
  readonly property int settingsManualButtonTop: 604      // "Got it" de 440×40, raio 10
  readonly property int settingsManualButtonHeight: 40
  // Papel de parede (ficha 13; Figma 13:16208): modal de 624×608, grade de miniaturas 276×156 em duas colunas.
  readonly property int settingsWallpaperWidth: 624
  readonly property int settingsWallpaperHeight: 608
  readonly property int settingsWallpaperListTop: 80        // a área rolante começa 4 acima da primeira linha, para o anel não ser cortado
  readonly property int settingsWallpaperGridTop: 4         // primeira linha em y 84
  readonly property int settingsWallpaperGridInset: 24      // colunas em x 24 e 324
  readonly property int settingsWallpaperColumnGap: 24
  readonly property int settingsWallpaperRowGap: 16         // linhas em y 84, 256 e 428
  readonly property int settingsWallpaperBottomPadding: 24  // 584 → 608
  readonly property int settingsWallpaperTileWidth: 276
  readonly property int settingsWallpaperTileHeight: 156    // raio radiusRow, borda border de 1 por cima da imagem
  readonly property int settingsWallpaperRingGap: 4         // anel accent de 1 a 4 da miniatura, raio 16
  readonly property int settingsWallpaperRingRadius: 16
  readonly property int settingsWallpaperMarkSize: 24       // círculo accent em (240,12), check 16 em (4,4) em textOnAccent
  readonly property int settingsWallpaperMarkX: 240
  readonly property int settingsWallpaperMarkY: 12
  readonly property int settingsWallpaperGradientHeight: 80 // degradê preto de 276×80 em y 76, de 0 a 80% na base (hover)
  readonly property real settingsWallpaperGradientOpacity: 0.8
  readonly property int settingsWallpaperTextX: 16          // título em y 108 (caixa 244×20) e autor em y 128 (caixa 244×14)
  readonly property int settingsWallpaperTitleY: 108
  readonly property int settingsWallpaperAuthorY: 128
  readonly property int settingsWallpaperTextWidth: 244
  readonly property int settingsWallpaperTitleHeight: 20
  readonly property int settingsWallpaperAuthorHeight: 14
  readonly property int settingsWallpaperDynamicTitleY: 120 // "Dynamic" sempre visível, caixa 200×20
  readonly property int settingsWallpaperDynamicTitleWidth: 200
  readonly property int settingsWallpaperAddIconX: 128      // "Choose an image": ícone 20 em (128,52), texto em caixa 276×24 em y 80
  readonly property int settingsWallpaperAddIconY: 52
  readonly property int settingsWallpaperAddLabelY: 80
  readonly property int settingsWallpaperAddLabelHeight: 24
  readonly property int settingsWallpaperErrorX: 30         // mensagem em y 58; a grade desce 28
  readonly property int settingsWallpaperErrorY: 58
  readonly property int settingsWallpaperErrorShift: 28
  readonly property int launcherWidth: 640
  readonly property int launcherSearchHeight: 56
  readonly property int launcherFooterHeight: 44
  readonly property int launcherResultHeight: 44
  // Tokens do launcher (ficha 14, board 13:17120; estados 13:17230 e 13:17275). Coordenadas do quadro de 640 de largura.
  readonly property color launcherScrim: Qt.rgba(0, 0, 0, 0.20)    // véu preto a 20% sobre o desktop (ficha 19); tokens.json extras_figma.launcherScrim
  readonly property real launcherTopRatio: 160 / 900                // topo do vidro: 160 de 900 de altura da tela (ficha 19), arredondado para pixel inteiro
  readonly property int launcherDividerHeight: 1                    // divisores de 640×1 (cabeçalho em y 56 e rodapé)
  readonly property int launcherSearchIconX: 18                     // ícone `search` de 20 em (18,18)
  readonly property int launcherSearchIconY: 18
  readonly property int launcherSearchIconSize: 20
  readonly property int launcherFieldX: 52                          // campo de texto em (52,16), altura 24, até 20 da borda direita
  readonly property int launcherFieldY: 16
  readonly property int launcherFieldHeight: 24
  readonly property int launcherFieldRightMargin: 20
  readonly property int launcherCursorWidth: 1                      // cursor de 1×24 em accentText; 1 de folga do texto e da sugestão
  readonly property int launcherCursorGap: 1
  readonly property real launcherGhostOpacity: 0.7                  // sugestão fantasma em muted a 70%
  readonly property int launcherSectionTop: 8                       // primeiro rótulo em y 64 (8 abaixo do cabeçalho)
  readonly property int launcherSectionGap: 8                       // rótulo seguinte, 8 abaixo da última linha do grupo anterior
  readonly property int launcherLabelX: 20                          // rótulo de seção: caixa de 400×24 em x 20
  readonly property int launcherLabelWidth: 400
  readonly property int launcherLabelHeight: 24
  readonly property int launcherRowX: 8                             // linha de 624×44 em x 8, raio radiusRow
  readonly property int launcherRowWidth: 624
  readonly property int launcherBlockSize: 28                       // bloco 28×28 raio 8 em (8,8), ícone de 16 em (6,6)
  readonly property int launcherBlockRadius: 8
  readonly property int launcherBlockOffset: 8
  readonly property int launcherBlockIconSize: 16
  readonly property int launcherBlockIconOffset: 6
  readonly property int launcherRowTextX: 48                        // título + detalhe em (48,12), linha de 20, 8 entre eles
  readonly property int launcherRowTextY: 12
  readonly property int launcherRowTextHeight: 20
  readonly property int launcherRowTextGap: 8
  readonly property int launcherTypeWidth: 140                      // tipo: caixa de 140×44 alinhada à direita, terminando em x 576
  readonly property int launcherTypeRight: 576
  readonly property int launcherEnterKeyX: 584                      // tecla ↵ em (584,12), só na selecionada
  readonly property int launcherEnterKeyY: 12
  readonly property int launcherFooterGap: 4                        // P-68: 4 de folga entre a última linha e o divisor do rodapé, sempre
  readonly property int launcherFooterIconX: 16                     // ícone do modo de 16 em (16, d+14) a 80%
  readonly property int launcherFooterIconY: 14
  readonly property int launcherFooterIconSize: 16
  readonly property real launcherFooterIconOpacity: 0.8
  readonly property int launcherFooterModeX: 40                     // nome do modo: caixa de 240×44 em (40, d)
  readonly property int launcherFooterModeWidth: 240
  readonly property int launcherFooterActionsRight: 624             // faixa de ações de 344×20 em (280, d+12), alinhada à direita (termina em x 624)
  readonly property int launcherFooterActionsY: 12
  readonly property int launcherFooterActionsHeight: 20
  readonly property int launcherFooterActionsGap: 8
  readonly property int launcherFooterDividerHeight: 16             // divisor de 1×16 entre as duas ações
  // Estado vazio (nó 13:17130): a seção "Tools" com a fila de chips. Chips do componente Chip (ficha 00).
  readonly property int launcherChipsX: 20                          // primeiro chip em x 20 (19 no código do Figma + 1 da borda), mesma coluna do rótulo
  readonly property int launcherChipHeight: 36                      // altura do Chip da ficha 00; a fila reserva o mesmo número
  readonly property int launcherChipsGap: 4                         // chips 4 abaixo do rótulo (rótulo 228 a 252, chips em 256)
  readonly property int launcherChipSpacing: 8                      // 8 entre os chips
  readonly property int launcherChipsFooterGap: 16                  // divisor do rodapé 16 abaixo dos chips (292 → 308)
  // Estado sem resultado (nó 13:17387; bloco "vazio" 13:17394). Coordenadas no quadro do launcher.
  readonly property int launcherNoResultCircleY: 80                 // círculo `control` de 48 (raio 24) em (296,80); x sai de centralizar nos 640
  readonly property int launcherNoResultCircleSize: 48
  readonly property int launcherNoResultIconSize: 20                // ícone `search-x` de 20 em (14,14) do círculo (13:17396)
  readonly property int launcherNoResultIconOffset: 14
  readonly property int launcherNoResultTitleY: 136                 // título (13:17397): caixa de 640×24 em y 136
  readonly property int launcherNoResultTitleHeight: 24
  readonly property int launcherNoResultHintY: 160                  // dica (13:17398): caixa de 640×20 em y 160, termina em 180
  readonly property int launcherNoResultHintHeight: 20
  readonly property int launcherNoResultTextMargin: 20              // o texto não passa de 20 de cada lado da caixa de 640
  readonly property int launcherNoResultActionsGap: 16              // linhas de ação 16 abaixo da dica (180 → 196); sem elas o divisor do rodapé fica nessa posição, a mesma folga de 16 que o board deixa entre os chips e o rodapé
  // Etiqueta de contexto "On workspace N" (estado "Aberto pelo +", nó 13:17179; etiqueta 13:17185). Coordenadas no quadro do launcher.
  readonly property int launcherContextHeight: 24                   // quadro de 24 de altura, raio 12, em y 16
  readonly property int launcherContextRadius: 12
  readonly property int launcherContextY: 16
  readonly property int launcherContextRightMargin: 20              // borda direita em x 620 (20 da borda do launcher)
  // O quadro 13:17185 tem 112 de largura com "No workspace 3" e o texto 13:17186 ocupa a caixa inteira, centrado: o Figma não dá recuo.
  // "No workspace 3" mede 84 em Geist Medium 11 no Qt, então o recuo é (112 - 84) / 2 = 14 de cada lado.
  readonly property int launcherContextPadding: 14
  readonly property int launcherContextFieldGap: launcherRowTextGap // o campo de busca termina 8 antes da etiqueta, a folga entre título e detalhe das linhas
  // Cartão do cálculo (estado "Cálculo", nó 13:17343; cartão 13:17351). 624×128 em (8,88), raio radiusCard, fundo cardHover e
  // borda border de 1. Medidas dentro do cartão, borda incluída; o resultado e a expressão são caixas de 260×48.
  readonly property int launcherCalcCardHeight: 128
  readonly property int launcherCalcCardGap: 16                     // linhas de ação 16 abaixo do cartão (y 232 com o cartão em 88)
  readonly property int launcherCalcBoxWidth: 260                   // caixas da expressão e do resultado: 260×48 em y 28
  readonly property int launcherCalcBoxHeight: 48
  readonly property int launcherCalcBoxY: 28
  readonly property int launcherCalcExpressionX: 24                 // expressão (13:17352) em (24,28)
  readonly property int launcherCalcResultX: 340                    // resultado (13:17356) em (340,28)
  readonly property int launcherCalcCaptionY: 80                    // legendas "Expression"/"Result" (13:17353, 13:17357): 260×20 em y 80, mesmo x de cada caixa
  readonly property int launcherCalcCaptionHeight: 20
  readonly property int launcherCalcEqualX: 296                     // círculo "igual" (13:17354) de 32 em (296,36), raio 16
  readonly property int launcherCalcEqualY: 36
  readonly property int launcherCalcEqualSize: 32
  readonly property int launcherCalcEqualIconSize: 16               // ícone `equal` de 16 em (8,8) do círculo
  readonly property int launcherCalcEqualIconOffset: 8
  // Página de resultado do seletor de cor (ficha 15, board 13:17120, nó 13:17499). Coordenadas no quadro do launcher (640×476); o quadro
  // do Figma tem as dos nós 1 px acima e à esquerda por causa da borda do pai, e aqui já estão somadas.
  readonly property int launcherColorFooterY: 432                   // altura fixa da página: divisor do rodapé em y 432, vidro de 476
  readonly property int launcherColorBackX: 12                      // botão voltar (IconButton de 32, raio 10) em (12,12), com o `chevron-left`
  readonly property int launcherColorBackY: 12
  readonly property int launcherColorTitleWidth: 400                // título "Color picker": caixa de 400×24 em (52,16), as mesmas de launcherFieldX/Y/Height
  readonly property int launcherColorSwatchX: 20                    // amostra 96×96 em (20,76), raio radiusCard, borda border de 1
  readonly property int launcherColorSwatchY: 76
  readonly property int launcherColorSwatchSize: 96
  readonly property int launcherColorNameX: 136                     // nome (13:17505): caixa de 300×32 em (136,84)
  readonly property int launcherColorNameY: 84
  readonly property int launcherColorNameWidth: 300
  readonly property int launcherColorNameHeight: 32
  readonly property int launcherColorOriginY: 116                   // origem (13:17506): caixa de 300×20 em (136,116)
  readonly property int launcherColorOriginHeight: 20
  readonly property int launcherColorButtonY: 140                   // "Pick another" (13:17507): 120×32 em (136,140), ActionButton small
  readonly property int launcherColorButtonWidth: 120
  readonly property int launcherColorFormatX: 20                    // linhas de formato (13:17509, 13:17515, 13:17519): 600×44 em x 20, y 188, 236 e 284
  readonly property int launcherColorFormatY: 188
  readonly property int launcherColorFormatStep: 48                 // passo de 48 (44 de altura e 4 entre elas)
  readonly property int launcherColorFormatWidth: 600
  readonly property int launcherColorFormatHeight: 44
  readonly property int launcherColorFormatLabelX: 16               // rótulo (HEX, RGB, HSL): caixa de 56×44 em x 16, Geist Mono Medium 11 muted
  readonly property int launcherColorFormatLabelWidth: 56
  readonly property int launcherColorFormatValueX: 72               // valor: caixa de 360×44 em x 72, Geist Mono Medium 13 text
  readonly property int launcherColorFormatValueWidth: 360
  readonly property int launcherColorFormatButtonX: 560             // botão de copiar (IconButton de 32) em (560,6)
  readonly property int launcherColorFormatButtonY: 6
  readonly property int launcherColorCheckX: 456                    // linha copiada: `check` de 16 em successText em (456,14)
  readonly property int launcherColorCheckY: 14
  readonly property int launcherColorCheckSize: 16
  readonly property int launcherColorCopiedX: 476                   // "Copied": caixa de 80×44 em x 476, Geist Medium 13 successText
  readonly property int launcherColorCopiedWidth: 80
  readonly property int launcherCopiedDuration: 1500                // a linha copiada mostra o `check` e "Copied" por 1,5 s (ficha 15, nota do board 13:17547)
  readonly property int launcherColorHistoryLabelY: 336             // rótulo "History" (13:17523): caixa de 400×24 em (20,336)
  readonly property int launcherColorHistoryY: 364                  // 12 amostras de 32×32, raio 8, borda border de 1, em y 364, uma a cada 40
  readonly property int launcherColorHistorySize: 32
  readonly property int launcherColorHistoryRadius: 8
  readonly property int launcherColorHistoryStep: 40
  readonly property int launcherColorHistoryMax: 12                 // o histórico guarda as 12 últimas cores
  readonly property int launcherColorHistoryHoverBorder: 2          // sob o ponteiro a borda passa a knob de 2 (13:17525)
  readonly property int launcherColorTipWidth: 88                   // dica do valor (13:17536): vidro de 88×28, raio 8, 4 abaixo da amostra, centrada nela
  readonly property int launcherColorTipHeight: 28
  readonly property int launcherColorTipRadius: 8
  readonly property int launcherColorTipGap: 4
  readonly property int launcherColorTipMargin: 20                  // a dica não passa dos 20 de margem do launcher (ficha 15, "Como funciona")
  // Lupa do seletor de cor, estado "pegando a cor" (ficha 15, board 13:17120, nó 13:17430). Coordenadas relativas ao ponteiro
  // (lupa e valor) ou ao monitor (dicas); o quadro do board não tem borda, então as coordenadas de lá já são as do quadro.
  readonly property color launcherLoupeBackdrop: "#000000"          // fundo da lupa (13:17434, `black`); tokens.json extras_figma.launcherLoupeBackdrop
  readonly property int launcherLoupeSize: 112                      // lupa 112×112, círculo de raio 56, centrada no ponteiro (13:17434)
  readonly property int launcherLoupeRingWidth: 2                   // traço `knob` de 2 por fora da área dos pixels; o do pixel central, também de 2, vai por dentro
  readonly property int launcherLoupeGrid: 7                        // grade de 7×7 pixels de 16×16, sem folga (13:17435 a 13:17483)
  readonly property int launcherLoupeCell: 16
  readonly property int launcherLoupeValueWidth: 112                // valor sob o cursor (13:17485): vidro de 112×28, raio 14, alinhado à lupa
  readonly property int launcherLoupeValueHeight: 28
  readonly property int launcherLoupeValueRadius: 14
  readonly property int launcherLoupeValueGap: 12                   // 12 abaixo da lupa (board: lupa em y 72, pílula em y 196); sem espaço embaixo, 12 acima
  readonly property int launcherLoupeSampleSize: 12                 // amostra redonda de 12 em (8,8) da pílula (13:17486)
  readonly property int launcherLoupeSampleOffset: 8
  readonly property int launcherLoupeHexX: 24                       // HEX (13:17487): caixa de 80×28 a partir de x 24, centrado, Geist Mono Medium 11
  readonly property int launcherLoupeHexWidth: 80
  readonly property int launcherLoupeTipsHeight: 40                 // dicas (13:17488): vidro de altura 40, raio 20, centrado na largura do monitor
  readonly property int launcherLoupeTipsRadius: 20
  readonly property int launcherLoupeTipsBottom: 16                 // a 16 da base (board: 340 − 284 − 40)
  readonly property int launcherLoupeTipsPaddingX: 16               // fila de itens a partir de (16,10), 8 entre os itens, 16 de recuo de cada lado
  readonly property int launcherLoupeTipsPaddingY: 10
  readonly property int launcherLoupeTipsGap: 8
  readonly property int launcherLoupeTipsRowHeight: 20              // a fila tem a altura da tecla (20); o texto de 16 fica centrado nela

  // Seletor de emoji (ficha 16, board 13:17120; grade 13:17552 e busca 13:17675). Coordenadas no quadro do launcher (640×436); o Figma
  // dá 1 a menos por causa da borda, como nos outros nós do launcher.
  // Família da fonte colorida (P-14, 2026-11-18): Noto Color Emoji (OFL), instalada pela F10. Sem ela o texto cai na fonte do sistema.
  readonly property string emojiFontFamily: "Noto Color Emoji"
  readonly property int launcherEmojiFooterY: 392                   // altura fixa de 436: divisor do rodapé em y 392 (13:17662)
  readonly property int launcherEmojiTabsX: 20                      // seis abas de 36×36, raio radiusChip, em y 64, x 20 + 44·i (13:17559 a 13:17569)
  readonly property int launcherEmojiTabsY: 64
  readonly property int launcherEmojiTabSize: 36
  readonly property int launcherEmojiTabStep: 44
  readonly property int launcherEmojiTabIconSize: 16                // ícone de 16 em (10,10) da aba
  readonly property int launcherEmojiTabIconOffset: 10
  readonly property real launcherEmojiTabRestOpacity: 0.8           // ícone `text` a 80% nas abas sem destaque (13:17561)
  readonly property real launcherEmojiTabDimOpacity: 0.5            // com texto na busca, as seis abas a 50% (13:17682); sem recentes, a aba dos recentes
  readonly property int launcherEmojiDividerY: 108                  // divisor `border` de 640×1 em y 108 (13:17571)
  readonly property int launcherEmojiLabelY: 116                    // primeiro rótulo de seção em y 116, 8 abaixo do divisor (13:17572)
  readonly property int launcherEmojiCellSize: 48                   // célula 48×48, raio radiusRow, emoji de 28 centrado (13:17574)
  readonly property int launcherEmojiCellStep: 52                   // passo de 52 na horizontal e na vertical
  readonly property int launcherEmojiGridX: 36                      // primeira célula em x 36; 11 por fileira (x 36 a 556)
  readonly property int launcherEmojiPerRow: 11
  readonly property int launcherEmojiGlyphSize: 28
  readonly property int launcherEmojiEndGap: 20                     // 20 de folga abaixo da última fileira (a fileira termina em 372 e o divisor está em 392)

  // Histórico da área de transferência (F6-T05, ficha 18; board 13:19344, estados texto 13:19621, imagem 13:19678, busca 13:19746, fixados 13:19790 e vazio
  // 13:19846). Mora dentro do launcher: mesma casca de 640×436, mesmo cabeçalho e mesmo rodapé, então o vidro, o campo de busca, o divisor em y 56, o bloco de
  // 28 da linha (launcherBlock*), o rótulo de seção (launcherLabel*) e as teclas do rodapé são os do launcher. As coordenadas são as do quadro de 640×436: o
  // Figma dá as de dentro a partir da borda de 1, e já somei 1.
  readonly property int clipboardFooterY: 392                       // altura fixa de 436: divisor do rodapé em y 392 (13:19621)
  readonly property int clipboardColumnWidth: 280                   // coluna da lista; o divisor vertical `border` de 1 em x 280 vai de y 57 até o rodapé (335)
  readonly property int clipboardFirstLabelY: 60                    // primeiro rótulo de seção em y 60 (3 abaixo do divisor), caixa de 24; centro em y 72
  readonly property int clipboardLabelGap: 4                        // rótulo da segunda seção 4 abaixo da última linha da primeira (188 → 192, board dos fixados)
  readonly property int clipboardRowWidth: 264                      // linha de 264×52 em x 8, raio radiusRow, empilhadas sem folga (a primeira em y 84)
  readonly property int clipboardRowHeight: 52
  readonly property int clipboardBlockY: 12                         // bloco 28 (launcherBlockSize) em (8,12) da linha; o do launcher fica em (8,8)
  readonly property int clipboardTitleX: 44                         // título: Geist Medium 13 `text`, caixa de 212×20 em (44,8); fixada, a caixa tem 184
  readonly property int clipboardTitleY: 8
  readonly property int clipboardTitleWidth: 212
  readonly property int clipboardTitleWidthPinned: 184
  readonly property int clipboardTitleHeight: 20
  readonly property int clipboardMetaCenterY: 35                    // meta: Geist Medium 11, caixa de 212 em x 44, centrada em y 35 (`text` na selecionada, `muted` nas outras)
  readonly property int clipboardPinX: 236                          // ícone `pin` de 16 em (236,18), em `accentText`
  readonly property int clipboardPinY: 18
  readonly property int clipboardPinSize: 16
  readonly property int clipboardPreviewX: 296                      // prévia 328×208 em (296,72), raio radiusRow, borda `border` de 1, fundo `cardHover`
  readonly property int clipboardPreviewY: 72
  readonly property int clipboardPreviewWidth: 328
  readonly property int clipboardPreviewHeight: 208
  readonly property int clipboardPreviewPadding: 16                 // texto e bloco do link a 16 da borda de dentro da prévia
  readonly property int clipboardPreviewTextWidth: 296              // texto: Geist Mono Medium 12, linha de 20, caixa de 296×176 em (16,16), corta o que passar
  readonly property int clipboardPreviewTextHeight: 176
  readonly property int clipboardPreviewLineHeight: 20
  readonly property int fontClipboardPreview: 12                    // Geist Mono Medium; o texto da prévia
  readonly property int clipboardLinkBlockSize: 40                  // link: bloco 40×40 em (16,16), raio radiusChip, `accentSubtle`, com o `globe` de 20 em (10,10) em `accentText`
  readonly property int clipboardLinkIconSize: 20
  readonly property int clipboardLinkIconOffset: 10
  readonly property int clipboardLinkTitleY: 68                     // título Geist Medium 15 (fontLabel), caixa de 296×24 em (16,68)
  readonly property int clipboardLinkTitleHeight: 24
  readonly property int clipboardLinkUrlY: 96                       // URL Geist Mono Medium 11 (fontMonoCaption), linha de 16, `muted`, em (16,96), 296 de largura, quebra linha
  readonly property int clipboardLinkUrlLineHeight: 16
  readonly property int clipboardMetaRowsTop: 296                   // metadados: linhas de 24 centradas em y 308, 332 e 356 (a primeira caixa começa em y 296)
  readonly property int clipboardMetaRowHeight: 24
  readonly property int clipboardMetaLabelWidth: 120                // rótulo: Geist Medium 11 `muted`, caixa de 120 em x 296
  readonly property int clipboardMetaValueWidth: 208                // valor: Geist Medium 11 `text`, caixa de 208 alinhada à direita, terminando em x 624
  readonly property int clipboardMetaValueRight: 624
  // Vazio (13:19846): o mesmo desenho do "sem resultado" do launcher, com outras alturas. Círculo de 48 em (296,120); título Geist Medium 15 numa caixa de 24 centrada em y
  // 196; dica Geist Regular 13, duas linhas de 20 a partir de y 212, 400 de largura, centrada.
  readonly property int clipboardEmptyCircleY: 120
  readonly property int clipboardEmptyTitleY: 184                   // caixa de 24 centrada em y 196
  readonly property int clipboardEmptyHintY: 212
  readonly property int clipboardEmptyHintWidth: 400
  readonly property int launcherEmojiRecentMax: 11                  // os recentes do board são uma fileira de 11
  readonly property int launcherEmojiPreviewX: 12                   // prévia no rodapé: caixa de 32×44 em x 12, emoji de 20 (13:17663)
  readonly property int launcherEmojiPreviewWidth: 32
  readonly property int launcherEmojiPreviewSize: 20
  readonly property int launcherEmojiNameX: 48                      // nome: caixa de 220×44 em x 48, Geist Medium 11 `text` (13:17664)
  readonly property int launcherEmojiNameWidth: 220

  // Captura de tela (ficha 17, board 13:19344; estado "Início (modo área)" 13:19354, "Modo janela" 13:19441). O quadro do board é uma
  // tela de 720×450; as coordenadas são as do Figma já com o 1 da borda somado onde o nó tem borda.
  readonly property color captureScrim: Qt.rgba(0, 0, 0, 0.30)      // véu preto a 30% sobre a tela inteira (13:19370)
  readonly property color captureCrosshair: Qt.rgba(1, 1, 1, 0.60)  // mira: duas linhas brancas a 60% (13:19371, 13:19372)
  readonly property int captureCrosshairWidth: 1                    // linhas de 1 px, de ponta a ponta do monitor
  readonly property int captureCoordsHeight: 24                     // pílula de coordenadas (13:19373): vidro de 24, raio 8, Geist Mono Medium 11
  readonly property int captureCoordsRadius: 8
  readonly property int captureCoordsOffset: 8                      // canto de cima à esquerda a (+8,+8) do ponteiro; perto da borda direita ou de baixo, a (−8,−8) para o outro lado
  // Recuo de cada lado do texto. No board a pílula tem 72 com "420, 236", que mede 54 em Geist Mono Medium 11 (TextMetrics.width, medido no Qt
  // com a fonte instalada; o avanço do texto, `Text.implicitWidth`, é 52,75). Recuo = (72 − 54) / 2 = 9.
  readonly property int captureCoordsPaddingX: 9
  readonly property int captureHintHeight: 40                       // dica (13:19375): vidro de 40, raio 20, centrado na largura, a 24 do topo
  readonly property int captureHintRadius: 20
  readonly property int captureHintTop: 24
  readonly property int captureHintPaddingX: 16                     // fila a 16 da esquerda e da direita (a largura é a da fila mais 16 de cada lado)
  readonly property int captureHintRowHeight: 20                    // fila de 20 de altura (a altura da tecla), centrada na vertical; texto de linha 16
  readonly property int captureHintGap: 8                           // 8 entre os itens
  readonly property int captureHintLineHeight: 16
  readonly property int captureBarWidth: 496                        // barra de modos (13:19381): vidro de 496×56, raio radiusCard, centrada, a 24 da base
  readonly property int captureBarHeight: 56
  readonly property int captureBarBottom: 24
  readonly property int captureBarPadding: 8                        // tudo na barra começa em y 8; o primeiro modo, em x 8
  readonly property int captureModeWidth: 88                        // modos de 88×40, raio radiusChip, em x 8, 100 e 192 (passo de 92: 88 e 4 de folga)
  readonly property int captureModeHeight: 40
  readonly property int captureModeStep: 92
  readonly property int captureModeIconX: 14                        // ícone de 16 em (14,12)
  readonly property int captureModeIconY: 12
  readonly property int captureModeIconSize: 16
  readonly property int captureModeLabelX: 36                       // rótulo: caixa de 48×40 em x 36, Geist Medium 13, centrado na vertical
  readonly property int captureModeLabelWidth: 48
  readonly property int captureDividerHeight: 24                    // divisores de 1×24 em (292,16) e (432,16)
  readonly property int captureDividerY: 16
  readonly property int captureDividerLeftX: 292
  readonly property int captureDividerRightX: 432
  readonly property int captureDelayX: 304                          // atraso (13:19392): caixa de 72×40 em (304,8)
  readonly property int captureDelayWidth: 72
  readonly property int captureDelayIconX: 12                       // `clock` de 16 em (12,12), em `text` (o traço do glifo no Figma é #F2F3F5)
  readonly property int captureDelayIconY: 12
  readonly property int captureDelayLabelX: 32                      // "0 s": caixa de 32×40 em x 32, Geist Medium 13 `muted`
  readonly property int captureDelayLabelWidth: 32
  readonly property int captureCursorX: 380                         // IconButton de 40 (raio 12, ícone 20) com `mouse-pointer-2` em (380,8)
  readonly property int captureCloseX: 444                          // IconButton de 40 com `x` em (444,8)
  readonly property int captureButtonSize: 40

  // Seleção de área (F6-T11, estado "Selecionando uma área", nó 13:19401). A seleção do board tem 320×200 em (200,104) no palco de 720×450.
  // O escurecimento de 45% da captura: por fora da seleção, nos quatro lados (13:19417 a 13:19420; dentro, a imagem limpa), sobre a tela inteira no modo
  // Window (13:19457) e sobre os monitores sem o ponteiro no modo Screen (composição, A-05). Os três usos são o mesmo preto a 45%, por isso o nome não fala de seleção.
  readonly property color captureDim: Qt.rgba(0, 0, 0, 0.45)
  readonly property int captureSelectionBorder: 1                   // borda de 1 px `accent`, por dentro do retângulo (13:19421)
  readonly property int captureHandleSize: 8                        // oito alças de 8×8, raio 2, `knob` com borda `accent` de 1 (13:19422 a 13:19429)
  readonly property int captureHandleRadius: 2
  readonly property int captureHandleBorder: 1
  // Área que responde ao arraste de cada alça: um quadrado de 16 centrado nela, o dobro do desenho de 8 (4 de cada lado, uma casa da grade de 4).
  // O board só desenha as alças; a área é composição (A-05), porque 8×8 é pequeno demais para o ponteiro. Em seleção pequena ela encolhe (Selection.js).
  readonly property int captureHandleHit: 16
  // Menos que isto, num eixo, soltar não cria seleção: o tamanho de uma alça.
  readonly property int captureSelectionMinSize: captureHandleSize
  readonly property int captureSizeHeight: 24                       // pílula de tamanho (13:19430): vidro pequeno de 24, raio 8, Geist Mono Medium 11 `text`, centrado
  readonly property int captureSizeRadius: 8
  readonly property int captureSizeGap: 8                           // 8 entre a seleção e a pílula (no board ela termina em y 96 e a seleção começa em 104)
  // Recuo de cada lado do texto. No board a pílula tem 88 com "320 × 200", que mede 60 em Geist Mono Medium 11 (TextMetrics.width, mesma medida da pílula de
  // coordenadas; o avanço do texto é 59,34). Recuo = (88 − 60) / 2 = 14.
  readonly property int captureSizePaddingX: 14
  readonly property int captureActionsWidth: 208                    // pílula de ações (13:19432): vidro de 208×48, raio 14, sem o brilho do acento
  readonly property int captureActionsHeight: 48
  readonly property int captureActionsRadius: 14
  readonly property int captureActionsGap: 8                        // 8 entre a seleção e a pílula (a pílula começa em y 312 e a seleção termina em 304); por dentro, 8 do canto
  readonly property int captureActionsEdge: 8                       // na horizontal a pílula fica a pelo menos 8 das bordas do monitor (composição, A-05)
  readonly property int captureActionsPadding: 8                    // tudo na pílula começa em y 8; o primeiro botão, em x 8
  readonly property int captureActionsButtonSize: 32                // três IconButton de 32 (raio radiusIconButton32, ícone de 16) em x 8, 44 e 80
  readonly property int captureActionsButtonStep: 36                // 32 de botão e 4 de folga
  readonly property int captureActionsPrimaryX: 116                 // "Capture": ActionButton primário pequeno de 84×32 em (116,8), raio 8, fundo `accent`, texto Geist Medium 13 `textOnAccent`
  readonly property int captureActionsPrimaryWidth: 84

  // Modos Window e Screen (F6-T12). A janela sob o ponteiro (estado "Modo janela", nó 13:19441): o anel (13:19458), 2 px `accent`, raio 14, com o retângulo
  // 2 para fora da janela em cada lado (a janela de 320×300 em (360,56) tem o anel de 324×304 em (358,54)), e a pílula (13:19459). O modo Screen não tem
  // board: é composição (A-05) com os mesmos valores, o anel de 2 por dentro da borda do monitor e sem raio (o monitor não tem cantos arredondados).
  readonly property int captureTargetRingWidth: 2                   // espessura do anel, nos dois modos; na janela ela fica toda por fora (o retângulo cresce 2 para cada lado)
  readonly property int captureWindowRingRadius: 14                 // o anel da janela: raio 14 ao redor de uma janela de raio 12
  readonly property int captureScreenRingRadius: 0                  // o anel do monitor: sem raio
  readonly property int captureTargetPillHeight: 24                 // pílula (13:19459): o vidro pequeno das pílulas de coordenadas e de tamanho, 24 de altura, raio 8, Geist Mono Medium 11 `text`
  readonly property int captureTargetPillRadius: 8
  readonly property int captureTargetPillGap: 8                     // a pílula termina 8 acima do anel (termina em y 46 e o anel começa em 54); sem lugar em cima, por dentro, a 8 do canto de cima à esquerda
  // Recuo de cada lado do texto. No board a pílula tem 152 com "Firefox · 320 × 300", que avança 125,28 em Geist Mono Medium 11 (TextMetrics.advanceWidth; 19 caracteres
  // de 6,59). Recuo = (152 − ⌈125,28⌉) / 2 = (152 − 126) / 2 = 13, com a largura da pílula sendo ⌈avanço⌉ + 2 × 13. Medi pelo avanço e não pela `TextMetrics.width`
  // das outras duas pílulas porque a `width` é a do desenho: o "F" tem folga à esquerda e o "Firefox" mede 125, os outros nomes de sete letras medem 126, e a
  // pílula mudaria 1 px com a primeira letra do nome. Numa fonte mono o avanço só depende de quantos caracteres há. Com a `width` o recuo seria 13,5.
  readonly property int captureTargetPillPaddingX: 13

  // Prévia depois da captura (F6-T04, ficha 17, estado 4; board 13:19344). Repouso (13:19531): miniatura de 156×112, raio radiusRow, borda `borderStrong` de 1 por cima da imagem
  // e a sombra do vidro (glassShadows). Hover (13:19557, dentro de 13:19554): véu preto a 50% (13:19570) e quatro botões redondos de 32 (13:19571 a 13:19577) em x 8, 44, 80 e 116
  // e y 40, o meio da altura ((112 − 32) / 2). Barra recolhida (13:19592, dentro de 13:19589): 48×48, mesmo raio e borda, sem sombra (o nó não tem). O hover recolhido não tem board:
  // é composição (A-05), o véu e um botão só, o de copiar, de 32 centrado (sobram 8 de cada lado).
  readonly property int capturePreviewWidth: 156
  readonly property int capturePreviewHeight: 112
  readonly property int capturePreviewCollapsedSize: 48
  readonly property int capturePreviewRadius: radiusRow
  readonly property int capturePreviewBorderWidth: 1                 // a cor é `borderStrong`
  readonly property color capturePreviewVeil: Qt.rgba(0, 0, 0, 0.50) // véu do hover sobre a imagem (13:19570)
  readonly property int capturePreviewButtonSize: 32                 // botão redondo (13:19571): raio 16, borda `borderStrong` de 1, ícone de 16 em `text`
  readonly property int capturePreviewButtonRadius: 16
  readonly property int capturePreviewButtonStep: 36                 // 32 de botão e 4 de folga: x 8, 44, 80 e 116
  readonly property int capturePreviewButtonPadding: 8               // o primeiro botão em x 8; recolhida, o único botão também fica a 8 de cada lado
  readonly property int capturePreviewIconSize: 16
  readonly property color capturePreviewButton: Qt.rgba(13 / 255, 14 / 255, 17 / 255, 0.70)       // fundo do botão: #0D0E11 a 70%
  readonly property color capturePreviewButtonHover: Qt.rgba(242 / 255, 243 / 255, 245 / 255, 0.20) // sob o ponteiro: #F2F3F5 (o `text`) a 20%
  readonly property int capturePreviewDuration: 6000                 // a prévia some sozinha em 6 s (ficha 17: "some em 6 s"); com o ponteiro em cima o relógio para (composição, A-05)

  // Editor de anotação (F6-T14, ficha 17, estado 5; board 13:19344, nó 13:19481 "Anotação · editor"). Vidro do launcher (raio radiusLauncher) de 720×480, sem o brilho do
  // acento. As coordenadas são as do quadro do editor, com o 1 da borda somado onde o nó tem borda. As ferramentas, o desfazer e a cor de cada marca são do board; o comportamento
  // de cada ferramenta, o texto sendo digitado, o recorte e a janela em volta são composição (A-05).
  readonly property int captureAnnotateWidth: 720
  readonly property int captureAnnotateHeight: 480
  readonly property int captureAnnotatePadding: 12                   // a barra começa em y 12 e o primeiro botão em x 12 (13:19482)
  readonly property int captureAnnotateToolStep: 36                  // seis IconButton de 32 em x 12, 48, 84, 120, 156 e 192 (13:19482 a 13:19487): 32 de botão e 4 de folga
  readonly property int captureAnnotateDividerY: 20                  // divisores `border` de 1×16 em (236,20) e (436,20) (13:19488, 13:19499)
  readonly property int captureAnnotateDividerHeight: 16
  readonly property int captureAnnotateDividerLeftX: 236
  readonly property int captureAnnotateDividerRightX: 436
  readonly property int captureAnnotateColorX: 248                   // cinco caixas de 32 em x 248, 284, 320, 356 e 392 (13:19489 a 13:19497), y 12
  readonly property int captureAnnotateColorStep: 36
  readonly property int captureAnnotateColorSize: 32                 // o círculo do anel da escolhida (raio 16)
  readonly property int captureAnnotateSwatchSize: 16                // a amostra: círculo de 16 na cor, centrado na caixa
  readonly property int captureAnnotateRingWidth: 2                  // anel `text` de 2 na cor escolhida (ficha 17: "amostra 16 no círculo 32; selecionada com anel text 2")
  readonly property int captureAnnotateUndoX: 448                    // IconButton de 32 com `undo-2` em (448,12) (13:19500)
  readonly property int captureAnnotateCopyX: 524                    // "Copy": ActionButton secundário pequeno, 88×32 em (524,12) (13:19501)
  readonly property int captureAnnotateSaveX: 620                    // "Save": ActionButton primário pequeno, 88×32 em (620,12) (13:19503)
  readonly property int captureAnnotateButtonWidth: 88
  readonly property int captureAnnotateAreaX: 16                     // a área da imagem (13:19505): 688×408 em (16,56), raio radiusRow, borda `border` de 1; atrás da imagem, o próprio vidro
  readonly property int captureAnnotateAreaY: 56
  readonly property int captureAnnotateAreaWidth: 688
  readonly property int captureAnnotateAreaHeight: 408
  readonly property int captureAnnotateAreaBorder: 1
  // As marcas, na tela (em pixels da imagem elas valem estes números divididos pela escala da imagem na tela; ver screenshot/Annotate.js).
  readonly property int captureAnnotatePencilWidth: 3                // lápis: traço livre de 3, pontas redondas; o board não desenha o lápis, e a espessura é a do contorno e da haste (composição, A-05)
  readonly property int captureAnnotateStrokeWidth: 3                // contorno do retângulo (13:19522) e haste da seta (13:19523)
  readonly property int captureAnnotateRectRadius: 8                 // raio do retângulo desenhado (13:19522)
  readonly property int captureAnnotateThickness: 20                 // marca-texto: faixa de 20 de espessura (13:19521)
  readonly property real captureAnnotateHighlightOpacity: 0.35       // marca-texto a 35% (13:19521)
  readonly property int captureAnnotateStripRadius: 2                // raio de 2 da faixa do marca-texto (13:19521) e da haste da seta (13:19523): na haste de 3 as pontas ficam redondas
  readonly property int captureAnnotateHeadSize: 20                  // ponta da seta: o `chevron-right` de 20, centrado na ponta e girado (13:19524)
  readonly property int captureAnnotateFontSize: 17                  // texto anotado: Geist SemiBold 17 (13:19525)
  // As cinco cores, na ordem do board: laranja, amarelo, o acento, verde e branco. Cada marca guarda a cor do momento em que foi feita.
  readonly property var captureAnnotateColors: [attentionText, warning, accentText, successText, text]

  // Aviso de salvo (F6-T03, ficha 17; board 13:19344, nó 13:19610 dentro de 13:19608). Cartão de 280×64 no vidro padrão, com o brilho do acento, raio radiusCard. As coordenadas
  // são a partir da borda de fora do cartão (o Figma dá as internas a partir de dentro da borda de 1; já somei 1). Onde ele aparece, por quanto tempo e a janela em volta são composição (A-05).
  readonly property int captureSavedWidth: 280
  readonly property int captureSavedHeight: 64
  readonly property int captureSavedBlockX: 12                       // bloco do ícone: 40×40 em (12,12), raio radiusChip, fundo `control`
  readonly property int captureSavedBlockY: 12
  readonly property int captureSavedBlockSize: 40
  readonly property int captureSavedIconInset: 10                    // `circle-check` de 20×20 em (10,10) dentro do bloco, em `successText`
  readonly property int captureSavedIconSize: 20
  readonly property int captureSavedTextX: 64                        // título e caminho: caixas de 200×20, centradas na vertical, uma linha
  readonly property int captureSavedTextWidth: 200
  readonly property int captureSavedTextHeight: 20
  readonly property int captureSavedTitleY: 12                       // título Geist Medium 13 `text` em (64,12)
  readonly property int captureSavedPathY: 32                        // caminho Geist Medium 11 `muted` em (64,32), reticências no fim
  readonly property int captureSavedDuration: 3000                   // o aviso some em 3 s: o tempo de um toast de notificação de urgência baixa (notifications/State.qml, [3000, 8000, 15000]); o board só diz "toast curto" (composição, A-05)
  readonly property int captureSavedSlide: 4                         // entra e sai com 4 de deslize horizontal, como o toast de notificação (notifications/ToastWindow.qml)
  readonly property int captureSavedShadowPadding: 55                // folga da janela em volta do cartão para a sombra do vidro (0,12 blur 32 e 0,2 blur 6), a mesma do toast de notificação

  // ---- tipografia ----
  // Geist Serif + Geist (OFL-1.1). Alternativa de texto: Inter.
  // Números e atalhos: Geist Mono.
  // Letter-spacing: os scripts do Figma não definem (fica 0). NÃO herdar
  // os tracking da Pond Gramercy / Advent Pro / IBM Plex.
  // Se a Geist não estiver instalada, o texto cai na Inter em vez de cair na
  // fonte padrão do sistema. Geist Serif só existe no corte Regular; conferi
  // que o Qt escolhe o Regular, e não os cortes decorativos, quando recebe só
  // o nome da família.
  readonly property string fontFamilyPreferred: "Geist"
  readonly property string fontFamilyFallback: "Inter"
  readonly property string fontFamily: Qt.fontFamilies().indexOf(fontFamilyPreferred) !== -1
      ? fontFamilyPreferred : fontFamilyFallback
  readonly property string titleFontFamily: "Geist Serif"
  readonly property string monoFontFamily: "Geist Mono"

  readonly property int fontBody: 13            // Medium, caixa ~16–20 conforme o contexto
  readonly property int fontLabel: 15           // Medium em rótulos; Regular nas linhas dos Ajustes
  readonly property int fontCaption: 11         // Medium
  readonly property int fontPanelTitle: 20      // Geist Serif Regular
  readonly property int fontModalTitle: 32      // Geist Serif Regular
  readonly property int fontSearch: 17          // Geist Regular (launcher)
  readonly property int fontLauncherExpression: 28   // Geist Serif Regular; expressão do cartão do cálculo (launcher, nó 13:17352, estilo "Armitage/Serif Regular 28")
  readonly property int fontLauncherResult: 40       // Geist Serif Regular; resultado do cartão do cálculo (launcher, nó 13:17356, estilo "Armitage/Serif Regular 40")
  readonly property int fontLauncherColorName: 24    // Geist Serif Regular; nome da cor na página do seletor de cor (launcher, nó 13:17505, estilo "Armitage/Serif Regular 24")
  readonly property int fontInfoValue: 17       // Geist Serif Regular
  readonly property int fontClock: 34           // Geist Serif Regular (mesmo texto do clockTimeSize)
  readonly property int fontBatteryPercent: 40  // Geist Serif Regular
  readonly property int fontMonoCaption: 11     // Geist Mono Medium
  readonly property int fontMonoNumber: 13      // Geist Mono Regular (recolhido)

  // ---- motion (herdado da Pond; ver spec-pond-shell.md §2.5) ----
  readonly property int motionDuration: 300
  readonly property var motionCurve: [0.2, 0, 0, 1, 1, 1]           // Motion.qml
  readonly property int hoverDuration: 120                          // HoverAnimation / Theme.qml:91 OutCubic
  readonly property int sidebarWorkspaceSwitchDuration: 180         // Theme.qml:92 OutCubic
  readonly property int workspaceDragSnapDuration: 110              // Theme.qml:93 OutCubic
  readonly property int mediaRevealDuration: 180                    // Theme.qml:95 Motion
  readonly property int panelOpenDuration: 220                      // PanelStyle.qml:49 InOutCubic, escala 0,9→1
  readonly property int panelCloseDuration: 200                     // CardStack.qml cubic-bezier(0.19, 1, 0.22, 1)
  readonly property int pageDuration: 350                           // PanelStyle.qml:48 mesma curva de fechar
  readonly property var panelCloseCurve: [0.19, 1, 0.22, 1, 1, 1]
  readonly property int controlDuration: 120                        // PanelStyle.qml:50
  readonly property int hoverExitDuration: 60                       // PanelStyle.qml:89
  readonly property int hoverCollapseDelay: 76                      // PanelStyle.qml:90
  readonly property int notificationDuration: 180                   // notifications/Style.qml:23 Motion
  readonly property int settingsCardStagger: 28                     // settings/Style.qml
  readonly property int settingsCardAppear: 32
  readonly property int settingsCloseDuration: 180
  readonly property int settingsHoverDuration: 100
  readonly property int settingsCategoryHoverDuration: 250          // InOutCubic
  readonly property int settingsSessionLabelDelay: 60               // nome do botão de sessão aparece 60 ms depois do hover (ficha 13)
  readonly property int toggleDuration: 200                         // Toggle.qml cubic-bezier(0.77, 0, 0.175, 1)
  readonly property var toggleCurve: [0.77, 0, 0.175, 1, 1, 1]
  readonly property int accordionDuration: 240                      // InOutCubic
  readonly property int osdHoldDuration: 1200                       // BottomControls / Brightness / Keyboard
  readonly property int carouselDuration: 220                       // organizador, mais de 3 janelas (ficha 02)
  readonly property real panelOpenScaleFrom: 0.9
  readonly property real blurRevealOpacity: 0.25                    // PanelStyle.qml:51

  // ---- helpers ----

  function fromCss(hex) {
    // Converte #RRGGBB ou #RRGGBBAA (CSS / tokens.json) para uma color QML.
    var h = String(hex).replace("#", "");
    if (h.length === 6)
      return "#" + h;
    if (h.length === 8)
      return "#" + h.slice(6, 8) + h.slice(0, 6);  // → #AARRGGBB
    return hex;
  }

  function clamp01(value) { return Math.max(0, Math.min(1, value)); }
  function lerp(from, to, progress) { return from + (to - from) * clamp01(progress); }
  function ramp(progress, start, end) { return clamp01((progress - start) / (end - start)); }
  function collapseWidth(progress) { return ramp(progress, 0, 0.56); }
  function collapseHeight(progress) { return ramp(progress, 0.56, 1); }

  function glassGlowHeight(cardHeight) {
    return Math.min(Math.round(cardHeight * glassAccentGlowHeightFactor), glassAccentGlowMaxHeight);
  }

  // ---------------------------------------------------------------------------
  // Esquemas de acento
  // ---------------------------------------------------------------------------
  readonly property QtObject chibaScheme: QtObject {
    readonly property string displayName: "Armitage Chiba"
    readonly property color accent: "#52C2F6"
    readonly property color accentHover: "#71CDF8"
    readonly property color accentPressed: "#48ABD8"
    readonly property color accentSubtle: Qt.rgba(82 / 255, 194 / 255, 246 / 255, 0.18)
    readonly property color accentRing: Qt.rgba(82 / 255, 194 / 255, 246 / 255, 0.50)
    readonly property color accentGlow: Qt.rgba(82 / 255, 194 / 255, 246 / 255, 0.08)
    readonly property color accentText: "#75CEF8"
    readonly property color textOnAccent: "#0D0E11"
  }

  readonly property QtObject freesideScheme: QtObject {
    readonly property string displayName: "Armitage Freeside"
    readonly property color accent: "#7F89E1"
    readonly property color accentHover: "#969EE6"
    readonly property color accentPressed: "#7079C6"
    readonly property color accentSubtle: Qt.rgba(127 / 255, 137 / 255, 225 / 255, 0.18)
    readonly property color accentRing: Qt.rgba(127 / 255, 137 / 255, 225 / 255, 0.50)
    readonly property color accentGlow: Qt.rgba(127 / 255, 137 / 255, 225 / 255, 0.08)
    readonly property color accentText: "#B7BDEE"
    readonly property color textOnAccent: "#0D0E11"
  }

  readonly property QtObject sprawlScheme: QtObject {
    readonly property string displayName: "Armitage Sprawl"
    readonly property color accent: "#F4A846"
    readonly property color accentHover: "#F6B867"
    readonly property color accentPressed: "#D7943E"
    readonly property color accentSubtle: Qt.rgba(244 / 255, 168 / 255, 70 / 255, 0.18)
    readonly property color accentRing: Qt.rgba(244 / 255, 168 / 255, 70 / 255, 0.50)
    readonly property color accentGlow: Qt.rgba(244 / 255, 168 / 255, 70 / 255, 0.08)
    readonly property color accentText: "#F6B867"
    readonly property color textOnAccent: "#0D0E11"
  }

  function setName(next) {
    const key = String(next).toLowerCase();
    if (schemeNames.indexOf(key) === -1)
      return;
    name = key;
  }

  // Caminho confirmado em 2026-11-14: ~/.config/wintermute-shell/theme.json.
  // A mesma pasta recebe depois os atalhos e as preferências.
  readonly property string themeFilePath: StandardPaths.writableLocation(StandardPaths.ConfigLocation)
      + "/wintermute-shell/theme.json"

  function reload() { themeFile.reload(); }

  FileView {
    id: themeFile
    path: root.themeFilePath
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: {
      try {
        const theme = JSON.parse(text()).theme;
        root.name = root.schemeNames.indexOf(theme) !== -1 ? theme : "chiba";
      } catch (error) {
        console.warn("Could not read theme selection:", error);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Compatibilidade com o código de partida
  // ---------------------------------------------------------------------------
  // O código que copiei na F0 ainda lê nomes que o tema Armitage não tem.
  // Mantenho esses nomes aqui, com os valores da origem, para a shell abrir com
  // o visual antigo enquanto as peças não são redesenhadas (F1 a F6). Cada fase
  // apaga daqui o que a peça dela deixou de ler. Código novo não usa nada deste
  // bloco.
  //
  // Sobraram só os papéis que ainda têm leitor: `translucent`, lido pela shell
  // inteira; e `sidebarDivider`, lido só pelo menu suspenso dos Ajustes, que
  // mantém o desenho da origem por enquanto (pendência P-46). O acento e o texto
  // saem daqui e vêm dos tokens direto.
  readonly property LegacyColors colors: LegacyColors {}
  readonly property bool translucent: colors.translucent

  readonly property color sidebarDivider: colors.sidebarDivider
}
