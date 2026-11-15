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

  property color outline: Qt.rgba(1, 1, 1, 0.10)

  property color controlFill: Qt.rgba(1, 1, 1, 0.05)
  property color controlHover: Qt.rgba(1, 1, 1, 0.10)
  property color rowHover: Qt.rgba(1, 1, 1, 0.06)
  property color settingsRow: controlFill
  property color monitorFill: controlFill
  property color sliderTrack: Qt.rgba(1, 1, 1, 0.07)


  property real overlayOpacity: 0.8
  property color card: "#1D1D1D"
  property color sessionControl: Qt.rgba(1, 1, 1, 0.15)
  property color menuCard: Qt.alpha("#494949", 0.5)
  property color menuControl: Qt.alpha("#56575E", 0.5)
  property color menuCardHover: Qt.alpha("#707070", 0.5)
  property Gradient menuCardHoverGradient: null
  property color menuCardBorder: "transparent"
  property color menuCardHoverBorder: menuCardBorder
  property color trayHover: menuControl


  property color sidebarCardOutline: Qt.alpha("#F9EFFF", 0.1)
  property color sidebarDivider: sidebarCardOutline
}
