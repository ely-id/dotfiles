import QtQuick
import QtQuick.Effects
import Quickshell.Widgets
import ".." as Shell

// Círculo de janela do organizador (ficha 00 e ficha 02):
// Aberto: 40×40 (ícone 16 em 12,12).
//   Repouso: borda border 1 px, sem fundo.
//   Hover: fundo pressed (10%), sem borda.
//   Foco: borda accent 1,5 px.
//   Levantada: fundo raised + borda accent 1,5 px + sombra.
// Recolhido: 32×32 (ícone 16 em 8,8).
//   Recolhida: borda border 1 px.
//   Recolhida focada (13:11395, F2-T08): 32×32 + anel accent 1,5 px no mesmo centro.
Item {
  id: root

  property var windowData: ({})
  property real controlSize: Shell.Theme.workspaceControlSize
  property bool interactive: true
  property bool lifted: false
  property bool forceHovered: false
  signal activated(var windowId)

  readonly property bool hovered: forceHovered || pointer.containsMouse
  readonly property bool focused: Boolean(windowData.isFocused)
  readonly property bool hasAccentRing: lifted || focused
  readonly property string lucideIcon: windowData.lucideIcon || ""
  readonly property bool hasAgentState: (windowData.dotState || "") !== ""

  implicitWidth: controlSize
  implicitHeight: controlSize

  Shell.Shadow {
    anchors.fill: chrome
    cornerRadius: chrome.radius
    visible: root.visible && root.lifted
    shadows: Shell.Theme.glassShadows
    strength: 0.5
  }

  Rectangle {
    id: chrome
    anchors.fill: parent
    radius: width / 2
    antialiasing: true
    color: root.lifted ? Shell.Theme.raised
        : root.hovered ? Shell.Theme.pressed
        : Shell.Theme.control
    border.color: root.hasAccentRing ? Shell.Theme.accent : Shell.Theme.border
    border.width: root.hovered && !root.hasAccentRing ? 0 : (root.hasAccentRing ? 1.5 : 1)

    Behavior on color {
      ColorAnimation {
        duration: Shell.Theme.hoverDuration
        easing.type: Easing.OutCubic
      }
    }
  }

  // Ícone Lucide opcional (usado nas prévias dos 12 estados)
  Image {
    x: Math.round((parent.width - width) / 2)
    y: Math.round((parent.height - height) / 2)
    visible: !root.hasAgentState && root.lucideIcon !== ""
    width: Shell.Theme.workspaceIconSize
    height: Shell.Theme.workspaceIconSize
    source: root.lucideIcon !== "" ? Qt.resolvedUrl("../icons/" + root.lucideIcon + ".svg") : ""
    sourceSize: Qt.size(32, 32)
    fillMode: Image.PreserveAspectFit
    smooth: true
    antialiasing: true
    // Este Image só mostra o ícone de icons/ (`lucideIcon`); o ícone do aplicativo vai no IconImage abaixo,
    // que nunca é colorizado.
    layer.enabled: true
    layer.effect: MultiEffect { colorization: 1; colorizationColor: Shell.Theme.text }
  }

  IconImage {
    x: Math.round((parent.width - width) / 2)
    y: Math.round((parent.height - height) / 2)
    visible: !root.hasAgentState && root.lucideIcon === "" && (root.windowData.iconSource || "") !== ""
    implicitSize: width
    width: Shell.Theme.workspaceIconSize
    height: Shell.Theme.workspaceIconSize
    source: root.windowData.iconSource || ""
    asynchronous: true
    smooth: true
  }

  TerminalIndicator {
    x: Math.round((parent.width - width) / 2)
    y: Math.round((parent.height - height) / 2)
    visible: root.hasAgentState
    dotState: root.windowData.dotState || "read"
    loaderVariant: root.windowData.loaderVariant || 1
  }

  MouseArea {
    id: pointer
    anchors.fill: parent
    enabled: root.interactive
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton
    cursorShape: Qt.PointingHandCursor
    onClicked: {
      if (root.windowData.winId !== undefined)
        root.activated(root.windowData.winId);
    }
  }
}
