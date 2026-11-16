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
  readonly property real glassBlur: 50                  // definido em P-03 (2026-11-14); no niri vira background-effect blur
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
  readonly property int clockTimeSize: 36
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
  readonly property int settingsInfoFooterTop: 536       // "Wintermute Shell" Serif 17 (caixa de 24) e a versão Mono 11 muted
  readonly property int settingsInfoGridX: 398           // grade de "+" 7×3 de 152×56, passo 20
  readonly property int settingsInfoGridCell: 20
  readonly property int launcherWidth: 640
  readonly property int launcherSearchHeight: 56
  readonly property int launcherFooterHeight: 44
  readonly property int launcherResultHeight: 44

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
  readonly property int fontInfoValue: 17       // Geist Serif Regular
  readonly property int fontClock: 36           // Geist Serif Regular
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
  // Só o acento e o texto principal já vêm dos tokens, para que trocar a
  // variação troque o acento da shell inteira desde a F0.
  readonly property LegacyColors colors: LegacyColors {
    accent: root.accent
    text: root.text
  }
  readonly property bool translucent: colors.translucent

  readonly property color sidebarDivider: colors.sidebarDivider
}
