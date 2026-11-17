import QtQuick
import QtQuick.Shapes
import ".." as Shell

// Botão novo (+) do organizador (ficha 00 e ficha 02):
// Modo normal (accentStyle: false, estados 2 e 3):
//   40×40, traço tracejado [4,4] borderStrong; hover preenche pressed (10%).
// Modo workspace ativo vazio (accentStyle: true, estados 6 e 12):
//   40×40, fundo accentSubtle + borda sólida accentRing 1 px, "+" sempre visível.
Item {
  id: root
  property bool revealed: false
  property bool accentStyle: false
  property bool forceHovered: false
  signal activated

  readonly property bool hovered: forceHovered || pointer.containsMouse

  visible: opacity > 0.001
  opacity: revealed ? 1 : 0
  scale: revealed ? 1 : 0.65
  Behavior on opacity { Shell.HoverAnimation {} }
  Behavior on scale { Shell.HoverAnimation {} }

  Rectangle {
    anchors.fill: parent
    radius: width / 2
    antialiasing: true
    color: root.accentStyle
        ? (root.hovered ? Qt.rgba(Shell.Theme.accent.r, Shell.Theme.accent.g, Shell.Theme.accent.b, 0.28)
                        : Shell.Theme.accentSubtle)
        : (root.hovered ? Shell.Theme.pressed : "transparent")
    border.width: root.accentStyle ? 1 : 0
    border.color: Shell.Theme.accentRing

    Behavior on color {
      ColorAnimation { duration: Shell.Theme.hoverDuration; easing.type: Easing.OutCubic }
    }
  }

  Shape {
    anchors.fill: parent
    visible: !root.accentStyle
    preferredRendererType: Shape.CurveRenderer
    ShapePath {
      strokeWidth: 1
      strokeColor: Shell.Theme.borderStrong
      strokeStyle: ShapePath.DashLine
      dashPattern: [4, 4]
      fillColor: "transparent"
      PathAngleArc {
        centerX: root.width / 2
        centerY: root.height / 2
        radiusX: (root.width - 1) / 2
        radiusY: (root.height - 1) / 2
        startAngle: 0
        sweepAngle: 360
      }
    }
  }

  Image {
    x: Math.round((parent.width - width) / 2)
    y: Math.round((parent.height - height) / 2)
    width: Shell.Theme.workspaceIconSize
    height: Shell.Theme.workspaceIconSize
    source: Qt.resolvedUrl("../icons/plus.svg")
    sourceSize: Qt.size(32, 32)
    smooth: true
    antialiasing: true
  }

  MouseArea {
    id: pointer
    anchors.fill: parent
    enabled: root.revealed
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    Accessible.role: Accessible.Button
    Accessible.name: "Open launcher on this workspace"
    Accessible.onPressAction: root.activated()
    onClicked: root.activated()
  }
}
