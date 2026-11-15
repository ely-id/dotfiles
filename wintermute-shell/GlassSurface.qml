import QtQuick
import Quickshell

// Componente reutilizável da superfície de vidro Armitage (ficha 00).
// Inclui sombra de duas camadas, degradê vertical com dithering 16-bit,
// brilho de acento na base, rim de 1 px, brilho interno de 1 px no topo,
// hover de cartão (cardHover, branco 4%) e região de blur para o compositor.
Item {
  id: root

  default property alias contentData: content.data
  // "card" (16) | "panel" (16) | "popup" (20) | "modal" (32) | "launcher" (24)
  property string surfaceType: "card"
  property real radius: surfaceType === "modal" ? Theme.radiusModal
      : surfaceType === "launcher" ? Theme.radiusLauncher
      : surfaceType === "popup" ? Theme.radiusPopup
      : surfaceType === "panel" ? Theme.radiusPanel
      : Theme.radiusCard
  property bool hoverable: false
  property bool forceHovered: false
  property bool showShadow: true
  property bool showGlow: true
  property bool contentClipped: true
  readonly property bool hovered: forceHovered || (hoverable && surfaceHover.hovered)

  readonly property Region blurRegion: Region {
    item: root
    radius: root.radius
  }

  implicitWidth: surfaceType === "modal" ? 580
      : surfaceType === "launcher" ? Theme.launcherWidth
      : surfaceType === "popup" ? 280
      : surfaceType === "panel" ? Theme.panelWidth
      : Theme.sidebarCardExpandedWidth
  implicitHeight: surfaceType === "modal" ? 200
      : surfaceType === "popup" ? 120
      : surfaceType === "panel" ? 160
      : 64

  Shadow {
    anchors.fill: parent
    visible: root.showShadow
    cornerRadius: root.radius
    shadows: Theme.glassShadows
  }

  GradientFill {
    radius: root.radius
    showGlow: root.showGlow
    hovered: root.hovered
  }

  Item {
    id: content
    anchors.fill: parent
    clip: root.contentClipped
  }

  PanelBorder {
    radius: root.radius
    z: 2
  }

  HoverHandler {
    id: surfaceHover
    enabled: root.hoverable
  }
}
