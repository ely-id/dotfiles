import QtQuick
import QtQuick.Effects
import QtQuick.Shapes

// Superfície de vidro Armitage (degradê vertical + brilho de acento na base +
// hover de cartão opcional), renderizada em float de 16 bits com dithering
// para evitar faixas nos tons escuros.
Item {
  id: root

  property Gradient fill: null
  property real radius: parent && "radius" in parent ? parent.radius : Theme.radiusCard
  property bool showGlow: true
  property bool hovered: false
  property alias color: surface.color

  readonly property real glowWidth: Math.round(surface.width * Theme.glassAccentGlowWidthFactor)
  readonly property real glowHeight: Theme.glassGlowHeight(surface.height)

  Gradient {
    id: defaultGlassGradient
    GradientStop { position: 0.0; color: Theme.glassTop }
    GradientStop { position: Theme.glassMidStop; color: Theme.glassMid }
    GradientStop { position: 1.0; color: Theme.glassBottom }
  }

  // Folga de 1 px para preservar o antialiasing da borda arredondada.
  anchors { fill: parent; margins: -1 }
  z: -1
  layer.enabled: true
  layer.smooth: true
  layer.format: ShaderEffectSource.RGBA16F
  layer.effect: ShaderEffect {
    fragmentShader: Qt.resolvedUrl("dither.frag.qsb")
  }

  Rectangle {
    id: surface
    anchors { fill: parent; margins: 1 }
    radius: root.radius
    color: "transparent"
    gradient: root.fill ? root.fill : defaultGlassGradient
    layer.enabled: root.showGlow
    layer.smooth: true
  }

  Item {
    id: glowSource
    anchors.fill: surface
    visible: false
    layer.enabled: root.showGlow && surface.width > 0 && surface.height > 0
    layer.smooth: true

    Shape {
      anchors.fill: parent
      preferredRendererType: Shape.CurveRenderer

      ShapePath {
        strokeWidth: 0
        strokeColor: "transparent"
        fillColor: Qt.alpha(Theme.accent, Theme.glassAccentGlowAlpha)

        PathSvg {
          path: {
            const cx = surface.width / 2;
            const cy = surface.height;
            const rx = Math.max(1, root.glowWidth / 2);
            const ry = Math.max(1, root.glowHeight / 2);
            return "M " + (cx - rx) + " " + cy
              + " A " + rx + " " + ry + " 0 1 0 " + (cx + rx) + " " + cy
              + " A " + rx + " " + ry + " 0 1 0 " + (cx - rx) + " " + cy
              + " Z";
          }
        }
      }
    }
  }

  MultiEffect {
    anchors.fill: surface
    visible: root.showGlow && surface.width > 0 && surface.height > 0
    source: glowSource
    autoPaddingEnabled: false
    blurEnabled: true
    blurMax: Theme.glassAccentGlowBlur
    blur: 1.0
    maskEnabled: true
    maskSource: surface
  }

  Rectangle {
    id: hoverOverlay
    anchors.fill: surface
    radius: root.radius
    color: root.hovered ? Theme.cardHover : Qt.alpha(Theme.cardHover, 0)
    visible: color.a > 0.001

    Behavior on color {
      ColorAnimation {
        duration: Theme.hoverDuration
        easing.type: Easing.OutCubic
      }
    }
  }
}
