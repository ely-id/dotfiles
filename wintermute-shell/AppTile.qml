import QtQuick

// Bloco de aplicativo Armitage (ficha 00):
// 28 px (raio 8, ícone 16 em 6,6) ou 48 px (raio 14, ícone 20 em 14,14).
// Repouso: fundo control + borda border 1 px.
// Foco: fundo control + traço accentRing 1,5 px.
Rectangle {
  id: root

  property int tileSize: 48
  property string iconName: "terminal"
  property url iconSource: ""
  property bool focused: false
  // Opcional para fixar o estado na demonstração: "" | "rest" | "focus"
  property string visualState: ""

  readonly property bool isFocusState: visualState === "focus" || (visualState === "" && focused)
  readonly property int iconSize: tileSize >= 48 ? 20 : 16

  implicitWidth: tileSize
  implicitHeight: tileSize
  radius: tileSize >= 48 ? 14 : 8
  color: Theme.control
  border.width: isFocusState ? 1.5 : 1
  border.color: isFocusState ? Theme.accentRing : Theme.border
  antialiasing: true

  Image {
    x: Math.round((root.width - width) / 2)
    y: Math.round((root.height - height) / 2)
    width: root.iconSize
    height: root.iconSize
    source: root.iconName !== "" ? Qt.resolvedUrl("icons/" + root.iconName + ".svg") : root.iconSource
    sourceSize: Qt.size(width * 2, height * 2)
    fillMode: Image.PreserveAspectFit
    smooth: true
    antialiasing: true
  }
}
