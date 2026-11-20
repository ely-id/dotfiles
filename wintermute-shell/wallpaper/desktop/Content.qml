import QtQuick
import "../daylight"

Rectangle {
  id: root
  property bool custom: false
  property bool dimmed: false
  property url imageSource: ""
  property alias now: sky.now
  property alias live: sky.live
  color: "#0b101c"
  layer.enabled: root.dimmed
  layer.format: ShaderEffectSource.RGBA16F
  // Dither the scrim over custom wallpapers; the sky already includes noise.
  layer.effect: root.custom ? dither : null

  Component {
    id: dither
    ShaderEffect { fragmentShader: Qt.resolvedUrl("dither.frag.qsb") }
  }

  Sky {
    id: sky
    anchors.fill: parent
    visible: !root.custom
  }
  Image {
    objectName: "wallpaperImage"
    anchors.fill: parent
    source: root.custom ? root.imageSource : ""
    sourceSize: Qt.size(Math.ceil(width * Screen.devicePixelRatio), Math.ceil(height * Screen.devicePixelRatio))
    fillMode: Image.PreserveAspectCrop
    asynchronous: true
  }
  Rectangle {
    visible: root.dimmed
    // Razão do Figma: 656 de 1440 (ficha 19, "Véu à esquerda", nó 13:21209); a origem usava 788 / 1728.
    width: parent.width * 656 / 1440
    height: parent.height
    gradient: Gradient {
      orientation: Gradient.Horizontal
      GradientStop { position: 0; color: Qt.rgba(0, 0, 0, 0.4) }
      GradientStop { position: 1; color: Qt.rgba(0, 0, 0, 0) }
    }
  }
}
