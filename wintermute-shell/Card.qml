import QtQuick
import Quickshell

Rectangle {
  id: root
  default property alias contentData: content.data
  property bool contentClipped: true
  property color classicColor: Theme.background
  property bool animateClassicColor: false
  property bool hoverEnabled: true
  property bool forceHovered: false
  property bool showGlow: true
  readonly property bool cardHovered: cardHover.hovered || forceHovered
  readonly property Region blurRegion: Region {
    item: root
    radius: root.radius
  }
  color: "transparent"
  border.width: 0
  radius: Theme.radiusCard
  antialiasing: true

  GradientFill {
    radius: root.radius
    showGlow: root.showGlow
    hovered: root.hoverEnabled && root.cardHovered
  }

  // Recorta o conteúdo sem cortar o antialiasing da borda.
  Item {
    id: content
    anchors.fill: parent
    clip: root.contentClipped
  }

  PanelBorder {
    radius: root.radius
    z: 2
  }

  HoverHandler { id: cardHover }
}
