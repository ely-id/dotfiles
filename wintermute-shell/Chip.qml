import QtQuick
import QtQuick.Effects

// Chip Armitage (ficha 00):
// Altura 36, padding 12/14, espaço 8, raio 10, ícone 16 + rótulo 13 Medium.
// Repouso: control + border; hover: pressed + border; selecionado: accentSubtle + accentRing.
Rectangle {
  id: root

  property string text: ""
  property string iconName: "pipette"
  property url iconSource: ""
  property bool selected: false
  property bool interactive: true
  // Opcional para fixar o estado na demonstração: "" | "rest" | "hover" | "selected"
  property string visualState: ""

  // Os ícones de icons/ são desenhados em branco puro e a cor vem da colorização (P-64). Só eles são
  // colorizados: um ícone de aplicativo passado por `iconSource` sairia chapado numa cor só.
  readonly property bool isShellIcon: iconName !== ""
      || iconSource.toString().startsWith(Qt.resolvedUrl("icons/").toString())

  readonly property bool isSelectedState: visualState === "selected" || (visualState === "" && selected)
  readonly property bool isHoverState: visualState === "hover" || (visualState === "" && chipHover.hovered && interactive)

  signal clicked

  implicitWidth: 12 + 16 + 8 + Math.ceil(labelText.implicitWidth) + 14
  implicitHeight: 36
  radius: Theme.radiusChip
  color: isSelectedState ? Theme.accentSubtle
      : isHoverState ? Theme.pressed
      : Theme.control
  border.width: 1
  border.color: isSelectedState ? Theme.accentRing : Theme.border
  antialiasing: true

  Behavior on color {
    ColorAnimation {
      duration: Theme.hoverDuration
      easing.type: Easing.OutCubic
    }
  }

  Image {
    x: 12
    y: 10
    width: 16
    height: 16
    source: root.iconName !== "" ? Qt.resolvedUrl("icons/" + root.iconName + ".svg") : root.iconSource
    sourceSize: Qt.size(32, 32)
    fillMode: Image.PreserveAspectFit
    smooth: true
    antialiasing: true
    layer.enabled: root.isShellIcon
    layer.effect: MultiEffect { colorization: 1; colorizationColor: Theme.text }
  }

  Text {
    id: labelText
    x: 36
    anchors.verticalCenter: parent.verticalCenter
    text: root.text
    color: Theme.text
    font.family: Theme.fontFamily
    font.weight: Font.Medium
    font.pixelSize: Theme.fontBody
    font.letterSpacing: 0
  }

  HoverHandler {
    id: chipHover
    enabled: root.interactive && root.visualState === ""
    cursorShape: Qt.PointingHandCursor
  }
  TapHandler {
    enabled: root.interactive && root.visualState === ""
    onTapped: root.clicked()
  }
}
