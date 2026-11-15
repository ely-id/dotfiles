import QtQuick
import Quickshell
import Quickshell.Wayland
import "audio" as Audio
import "settings/appearance" as Appearance

// OSD de brilho (ficha 10): 156×36, visível Theme.osdHoldDuration (1200 ms) depois do último evento.
Item {
  id: root
  required property var screen
  required property real collapseProgress
  required property real expandedBottomMargin
  property real value: 0
  readonly property bool collapsed: collapseProgress >= 0.56
  width: Theme.sidebarCardExpandedWidth
  height: 38 // The sidebar's 6px spacing completes the 8px gap below the card.
  visible: feedback.active && !collapsed

  Connections {
    target: Appearance.State
    function onKeyboardBrightnessChanged(outputName, value) {
      if (outputName !== root.screen.name) return;
      root.value = value;
      feedback.active = true;
      dismissTimer.restart();
    }
  }
  // Só um OSD de cada vez: o de volume toma o lugar deste.
  Connections {
    target: Audio.State
    function onKeyboardOutputVolumeChanged(value) { feedback.active = false; }
  }
  Timer { id: dismissTimer; interval: Theme.osdHoldDuration; onTriggered: feedback.active = false }

  LazyLoader {
    id: feedback
    PanelWindow {
      screen: root.screen
      color: "transparent"
      BackgroundEffect.blurRegion: Theme.translucent ? indicator.blurRegion : null
      implicitWidth: Theme.sidebarCardExpandedWidth + (root.collapsed ? 134 : 0)
      implicitHeight: root.collapsed ? 67 + 36 + 40 : 36
      anchors { left: true; bottom: true }
      margins.left: root.collapsed ? Math.round((screen.width + Theme.sidebarOuterMargin
          + Theme.sidebarCardCollapsedWidth - implicitWidth) / 2) : Theme.sidebarOuterMargin
      margins.bottom: root.collapsed ? 0 : Math.round(root.expandedBottomMargin)
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.namespace: "pond-brightness"
      WlrLayershell.exclusionMode: ExclusionMode.Ignore
      mask: Region {}

      Shadow {
        visible: root.collapsed
        anchors.fill: indicator
        cornerRadius: Theme.radiusCard
        shadows: Theme.glassShadows
      }
      OsdCard {
        id: indicator
        iconName: "sun"
        x: root.collapsed ? 67 : 0
        y: root.collapsed ? 67 : 0
        value: root.value
      }
    }
  }
}
