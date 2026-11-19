import QtQuick
import Quickshell
import Quickshell.Wayland
import "." as Battery
import ".." as Shell

PanelWindow {
  id: root
  required property var bar
  required property var above

  screen: bar.screen
  visible: Battery.State.alert > 0 && bar.collapseProgress > 0.42
  color: "transparent"
  implicitWidth: card.width + 68
  implicitHeight: card.height + 145
  mask: Region { item: card }
  BackgroundEffect.blurRegion: card.blurRegion

  anchors { left: true; top: true }
  margins {
    left: Math.round(Shell.Theme.sidebarOuterMargin + bar.cardWidth + 20) - card.x
    top: (above.visible ? 20 + above.cardHeight : 20) - card.y
  }

  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.namespace: "pond-battery-alert-" + (screen ? screen.name : "unknown")
  WlrLayershell.exclusionMode: ExclusionMode.Ignore

  Battery.AlertCard {
    id: card
    x: 34
    y: 14
    onDismissed: Battery.State.alert = 0
  }
}
