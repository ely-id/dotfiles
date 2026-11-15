import QtQuick
import Quickshell

Rectangle {
  id: root
  // Páginas empilhadas usam a superfície e a borda pintadas por CardLayer.
  property bool stacked: false
  property Gradient fill: null
  property bool showGlow: true
  property bool hovered: false
  readonly property Region blurRegion: Region {
    item: root
    radius: root.radius
  }
  color: "transparent"
  radius: Theme.radiusPanel
  border.width: 0
  antialiasing: true
  clip: true
  GradientFill {
    visible: !root.stacked
    fill: root.fill
    radius: root.radius
    showGlow: root.showGlow
    hovered: root.hovered
  }
  PanelBorder {
    visible: !root.stacked
    radius: root.radius
    z: 2
  }
}
