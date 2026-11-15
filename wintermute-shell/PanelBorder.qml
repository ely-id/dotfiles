import QtQuick
import QtQuick.Shapes

// Borda (rim) de 1 px inside em degradê (20% → 6% → 16%) e brilho interno
// no topo (inner shadow 0,1 blur 0 branco 8%) do vidro Armitage.
Shape {
  id: root
  property real radius: Theme.radiusPanel
  property color color: Theme.glassRimTop
  property color topColor: Theme.glassRimTop
  property color midColor: Theme.glassRimMid
  property color bottomColor: Theme.glassRimBottom
  property bool showInnerHighlight: true
  anchors.fill: parent
  preferredRendererType: Shape.CurveRenderer

  // Brilho interno: inner shadow x 0, y 1, blur 0, branco 8%
  ShapePath {
    strokeWidth: 0
    strokeColor: "transparent"
    fillColor: root.showInnerHighlight ? Theme.glassInnerHighlight : "transparent"

    PathSvg {
      path: {
        const w = Math.max(0, root.width);
        const h = Math.max(0, root.height);
        if (w <= 0 || h <= 1)
          return "";
        const r = Math.max(0, Math.min(root.radius, w / 2, h / 2));
        return "M 0 " + r
          + " A " + r + " " + r + " 0 0 1 " + r + " 0"
          + " L " + (w - r) + " 0"
          + " A " + r + " " + r + " 0 0 1 " + w + " " + r
          + " L " + w + " " + (r + 1)
          + " A " + r + " " + r + " 0 0 0 " + (w - r) + " 1"
          + " L " + r + " 1"
          + " A " + r + " " + r + " 0 0 0 0 " + (r + 1)
          + " Z";
      }
    }
  }

  // Borda (rim) 1 px inside
  ShapePath {
    strokeWidth: Theme.glassRimWidth
    fillColor: "transparent"
    strokeGradient: LinearGradient {
      x1: 0; y1: 0
      x2: 0; y2: root.height
      GradientStop { position: 0.0; color: root.topColor }
      GradientStop { position: 0.5; color: root.midColor }
      GradientStop { position: 1.0; color: root.bottomColor }
    }
    PathRectangle {
      x: 0.5
      y: 0.5
      width: Math.max(0, root.width - 1)
      height: Math.max(0, root.height - 1)
      radius: Math.max(0, root.radius - 0.5)
    }
  }
}
