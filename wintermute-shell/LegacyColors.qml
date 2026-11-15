import QtQuick

// Paleta herdada do código de partida.
//
// O código que copiei lê cerca de cem papéis de cor por `Theme.colors.<papel>`.
// O tema Armitage não tem esses papéis: ele tem tokens (`Theme.accent`,
// `Theme.hover`, `Theme.border`...). Este arquivo existe para a shell abrir
// enquanto as peças não são redesenhadas, e encolhe a cada fase: quando uma
// peça passa a ler os tokens, os papéis que só ela usava saem daqui. No fim da
// F6 o arquivo deixa de existir.
//
// Os valores são os do tema padrão da origem, o translúcido, sem alteração.
// Dois papéis são religados aos tokens em Theme.qml: `accent` e `text`.
// Nenhum valor daqui é referência de design: os valores certos estão em
// docs/design/.
QtObject {
  // As superfícies são translúcidas e desfocam o que está atrás.
  property bool translucent: true

  property color text: "white"
  property color accent: "#CBA6F7"
  property color selection: accent
  property color errorText: accent

  property color surface: "#1D1D1D"
  property color border: "#3D3D3D"
  property color panelSurface: Qt.alpha("#202020", 0.8)
  property color panelBorder: Qt.alpha("#2F2F2F", 0.8)
  property Gradient panelGradient: null
  property Gradient calendarGradient: panelGradient
  property color hover: "#262626"
  property color outline: Qt.rgba(1, 1, 1, 0.10)

  property color controlFill: Qt.rgba(1, 1, 1, 0.05)
  property color controlHover: Qt.rgba(1, 1, 1, 0.10)
  property color rowHover: Qt.rgba(1, 1, 1, 0.06)
  property color settingsRow: controlFill
  property color accordionRow: controlFill
  property color monitorFill: controlFill
  property color weekFill: Qt.rgba(1, 1, 1, 0.06)
  property color sliderTrack: Qt.rgba(1, 1, 1, 0.07)
  property color todayFill: accent

  property color drawerFill: Qt.rgba(1, 1, 1, 0.08)
  property color drawerRowHover: Qt.rgba(1, 1, 1, 0.10)
  property color drawerSliderTrack: Qt.alpha("#F9EFFF", 0.1)
  property real drawerToggleAlpha: 0.12
  property color selectFill: Qt.rgba(1, 1, 1, 0.12)
  property color menuSurface: "#191A1B"
  property color menuBorder: "#3A3A3A"
  property color menuRowHover: drawerFill

  property real overlayOpacity: 0.8
  property color card: "#1D1D1D"
  property color modalSurface: Qt.alpha("#292929", panelSurface.a)
  property Gradient modalGradient: null
  property color modalBorder: panelBorder
  property color sessionControl: Qt.rgba(1, 1, 1, 0.15)
  property color menuCard: Qt.alpha("#494949", 0.5)
  property color menuControl: Qt.alpha("#56575E", 0.5)
  property color menuCardHover: Qt.alpha("#707070", 0.5)
  property Gradient menuCardHoverGradient: null
  property color menuCardBorder: "transparent"
  property color menuCardHoverBorder: menuCardBorder
  property color trayHover: menuControl

  property color notificationHover: drawerFill
  property color notificationText: "#F8F9F9"
  property color notificationTitle: notificationText
  property color notificationCloseFill: "#D1C9FF"
  property color notificationCloseHover: accent
  property color dismissGlyph: "#38224D"
  property color dismissHoverGlyph: "black"
  property color inlineFill: Qt.tint(Qt.alpha("#F9EFFF", 0.1), sidebarClearFill)
  property color inlineHoverFill: Qt.tint(Qt.alpha("#F9EFFF", 0.1), sidebarHoverFill)

  property color sidebarCardOutline: Qt.alpha("#F9EFFF", 0.1)
  property color sidebarHoverFill: Qt.rgba(1, 1, 1, 0.04)
  property color sidebarClearFill: Qt.rgba(1, 1, 1, 0)
  property color sidebarDivider: sidebarCardOutline
  property color sidebarForeground: "#F8F9F9"
  property color sidebarInnerOutline: Qt.rgba(1, 1, 1, 0.20)
  property color feedbackDotOff: sidebarInnerOutline
}
