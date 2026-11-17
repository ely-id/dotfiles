import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell.Widgets
import "." as Media
import ".." as Shell

// Cartão de mídia da barra lateral (ficha 04):
// Repouso (aberto): 156×64, raio 16. Capa 40×40 r8 em (12,12);
//   título 13 Medium em (60,12) 84×20; artista 13 Regular muted em (60,32) 84×20.
// Hover (aberto): cresce para 156×92 em 180 ms (Theme.mediaRevealDuration).
//   Três botões de ícone 32×32 r10 em y 56, x 30 / 62 / 94 (voltar, pause selecionado, avançar).
// Recolhido: 48×48, capa 32×32 r8 em (8,8).
Shell.Card {
  id: root

  property real collapseProgress: 0
  property bool previewActive: false
  property string previewTitle: "Neon Drift"
  property string previewArtist: "Synthesizer"
  property bool previewRevealed: false

  readonly property real layoutProgress: Shell.Theme.collapseWidth(collapseProgress)
  readonly property real verticalProgress: Shell.Theme.collapseHeight(collapseProgress)
  readonly property bool hasPlayer: previewActive || Media.State.hasPlayer
  readonly property bool isPlaying: previewActive ? true : Media.State.isPlaying
  readonly property bool revealed: hasPlayer && (previewRevealed || hover.hovered || pointer.pressed)
  property real expandedTargetHeight: hasPlayer ? (revealed ? 92 : 64) : 0
  property real collapsedTargetHeight: hasPlayer ? 48 : 0

  readonly property string displayTitle: previewActive ? previewTitle
      : (Media.State.title !== "" ? Media.State.title
          : (Media.State.identity !== "" ? Media.State.identity : "Unknown track"))
  readonly property string displaySubtitle: previewActive ? previewArtist : Media.State.subtitle

  width: Shell.Theme.lerp(Shell.Theme.sidebarCardExpandedWidth,
      Shell.Theme.sidebarCardCollapsedWidth, layoutProgress)
  height: Shell.Theme.lerp(expandedTargetHeight, collapsedTargetHeight, verticalProgress)
  radius: Shell.Theme.sidebarCardRadius
  visible: height > 0

  Behavior on expandedTargetHeight {
    enabled: root.collapseProgress === 0 && !root.previewActive
    Shell.Motion { duration: Shell.Theme.mediaRevealDuration }
  }

  HoverHandler {
    id: hover
    cursorShape: Qt.PointingHandCursor
  }

  MouseArea {
    id: pointer
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton
    cursorShape: Qt.PointingHandCursor
    onClicked: {
      if (root.collapseProgress >= 0.56 && !root.previewActive && Media.State.canPlayPause)
        Media.State.playPause();
    }
  }

  ClippingRectangle {
    anchors.fill: parent
    radius: root.radius
    color: "transparent"
    visible: root.hasPlayer

    AlbumCover {
      id: artwork
      x: Math.round(Shell.Theme.lerp(12, 8, root.layoutProgress))
      y: Math.round(Shell.Theme.lerp(12, 8, root.verticalProgress))
      artSize: Math.round(Shell.Theme.lerp(40, 32, root.layoutProgress))
      artSource: root.previewActive ? "" : Media.State.artUrl
    }

    // Metadados permanecem alinhados em (60,12) e (60,32) enquanto o cartão encolhe.
    Item {
      x: 60
      y: 12
      width: Math.max(0, root.width - x - 12)
      height: 40
      clip: true
      opacity: 1 - root.layoutProgress
      visible: opacity > 0.001

      Media.MarqueeText {
        y: 0
        width: 84
        height: 20
        text: root.displayTitle
        textColor: Shell.Theme.text
        fontWeight: Font.Medium
        playing: root.isPlaying && !root.previewActive
      }

      Media.MarqueeText {
        y: 20
        width: 84
        height: 20
        text: root.displaySubtitle
        textColor: Shell.Theme.muted
        fontWeight: Font.Normal
        playing: root.isPlaying && !root.previewActive
      }
    }

    // Três botões de ícone 32×32 em y 56, x 30 / 62 / 94 (ficha 04)
    Item {
      x: 0
      y: 56
      width: Shell.Theme.sidebarCardExpandedWidth
      height: Math.max(0, root.height - 56)
      clip: true
      opacity: 1 - root.layoutProgress
      visible: opacity > 0.001 && height > 0
      enabled: root.revealed && root.collapseProgress < 0.56

      Shell.IconButton {
        x: 30
        y: 0
        buttonSize: 32
        iconSource: Qt.resolvedUrl("../icons/skip-back.svg")
        enabled: root.previewActive || Media.State.canPrevious
        onClicked: if (!root.previewActive) Media.State.previous()
      }

      Shell.IconButton {
        x: 62
        y: 0
        buttonSize: 32
        checked: true
        iconSource: Qt.resolvedUrl(root.isPlaying ? "../icons/pause.svg" : "../icons/play.svg")
        enabled: root.previewActive || Media.State.canPlayPause
        onClicked: if (!root.previewActive) Media.State.playPause()
      }

      Shell.IconButton {
        x: 94
        y: 0
        buttonSize: 32
        iconSource: Qt.resolvedUrl("../icons/skip-forward.svg")
        enabled: root.previewActive || Media.State.canNext
        onClicked: if (!root.previewActive) Media.State.next()
      }
    }
  }

  component AlbumCover: ClippingRectangle {
    id: coverRoot
    property real artSize: 40
    property url artSource: ""
    width: artSize
    height: artSize
    radius: 8
    color: "#22304D"
    antialiasing: true

    // Placeholder genérico do Figma (#22304D → #4D2F5C + ícone music 16×16 a 70%)
    Shape {
      anchors.fill: parent
      visible: coverImage.status !== Image.Ready
      ShapePath {
        strokeWidth: -1
        fillGradient: LinearGradient {
          x1: 0; y1: 0
          x2: coverRoot.width; y2: coverRoot.height
          GradientStop { position: 0.0; color: "#22304D" }
          GradientStop { position: 1.0; color: "#4D2F5C" }
        }
        PathRectangle { width: coverRoot.width; height: coverRoot.height }
      }
    }

    Image {
      anchors.centerIn: parent
      width: 16
      height: 16
      visible: coverImage.status !== Image.Ready
      source: Qt.resolvedUrl("../icons/music.svg")
      sourceSize: Qt.size(32, 32)
      opacity: 0.7
      smooth: true
      antialiasing: true
      layer.enabled: true
      layer.effect: MultiEffect { colorization: 1; colorizationColor: Shell.Theme.text }
    }

    Image {
      id: coverImage
      anchors.fill: parent
      source: coverRoot.artSource
      sourceSize: Qt.size(80, 80)
      fillMode: Image.PreserveAspectCrop
      asynchronous: true
      smooth: true
    }
  }
}
