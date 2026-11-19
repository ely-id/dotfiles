pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland

// OSD do teclado (ficha 10): 156×76, raio 12. Uma linha por layout, com o rádio marcado no atual e o
// nome dos outros em `muted`. Visível Theme.osdHoldDuration (1200 ms) depois da troca de layout.
Item {
  id: root
  objectName: "keyboardFeedback"
  required property var screen
  required property real collapseProgress
  required property real expandedTopMargin
  readonly property bool collapsed: collapseProgress >= 0.56
  readonly property real cardHeight: 20 + NiriMsg.keyboardLayouts.length * 28
  width: Theme.sidebarCardExpandedWidth
  height: cardHeight
  visible: feedback.active && !collapsed
  onVisibleChanged: if (visible) parent.forceLayout()

  Connections {
    target: NiriMsg
    function onKeyboardLayoutSwitched() {
      if (NiriMsg.focusedOutputName !== root.screen.name) return;
      feedback.active = true;
      dismissTimer.restart();
    }
  }
  Timer { id: dismissTimer; interval: Theme.osdHoldDuration; onTriggered: feedback.active = false }

  LazyLoader {
    id: feedback
    PanelWindow {
      screen: root.screen
      color: "transparent"
      BackgroundEffect.blurRegion: card.blurRegion
      implicitWidth: Theme.sidebarCardExpandedWidth + (root.collapsed ? 134 : 0)
      implicitHeight: root.cardHeight + (root.collapsed ? 107 : 0)
      anchors { left: true; top: !root.collapsed; bottom: root.collapsed }
      margins.left: root.collapsed ? Math.round((screen.width + Theme.sidebarOuterMargin
          + Theme.sidebarCardCollapsedWidth - implicitWidth) / 2) : Theme.sidebarOuterMargin
      margins.top: root.collapsed ? 0 : Math.round(root.expandedTopMargin)
      onMarginsChanged: contentItem.Window.window?.requestUpdate()
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.namespace: "pond-keyboard"
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
      WlrLayershell.exclusionMode: ExclusionMode.Ignore
      mask: Region {}

      Shadow {
        visible: root.collapsed
        anchors.fill: card
        cornerRadius: card.radius
        shadows: Theme.glassShadows
      }
      KeyboardLayoutCard {
        id: card
        objectName: "keyboardLayoutCard"
        x: root.collapsed ? 67 : 0
        y: root.collapsed ? 67 : 0
      }
    }
  }
}
