import QtQuick
import Quickshell
import Quickshell.Wayland
import "audio" as Audio
import "settings/appearance" as Appearance

// OSD de volume (ficha 10): o mesmo cartão 156×36 do brilho, com `volume-2` (ou `volume-x` no mudo),
// visível Theme.osdHoldDuration (1200 ms) depois do último evento. Aparece no mesmo lugar do OSD de brilho.
Item {
  id: root
  required property var screen
  required property real collapseProgress
  required property real expandedBottomMargin
  property real value: 0
  property bool muted: false
  readonly property bool collapsed: collapseProgress >= 0.56
  width: Theme.sidebarCardExpandedWidth
  height: 38 // O espaço de 6 px da barra completa os 8 px abaixo do cartão.
  visible: feedback.active && !collapsed

  Connections {
    target: Audio.State
    function onKeyboardOutputVolumeChanged(value) {
      if (NiriMsg.focusedOutputName !== "" && root.screen.name !== NiriMsg.focusedOutputName) return;
      root.value = value;
      root.muted = Audio.State.outputMuted;
      feedback.active = true;
      dismissTimer.restart();
    }
  }
  // Só um OSD de cada vez: o de brilho toma o lugar deste.
  Connections {
    target: Appearance.State
    function onKeyboardBrightnessChanged(outputName, value) { feedback.active = false; }
    function onKeyboardBrightnessFailed(outputName, reason) { feedback.active = false; }
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
      WlrLayershell.namespace: "pond-volume"
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
        iconName: root.muted ? "volume-x" : "volume-2"
        x: root.collapsed ? 67 : 0
        y: root.collapsed ? 67 : 0
        value: root.muted ? 0 : root.value
      }
    }
  }
}
