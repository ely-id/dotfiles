import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import ".." as Shell

// Indicador de progresso / estado do cartão de instalações (ficha 04):
// 16×16. Instalando: trilho track (2,5 px) + arco accent (innerRadius ~0,69).
// Concluído: circle-check 16 em successText. Falhou: circle-alert 16 em dangerText.
Item {
  id: root
  property real progress: -1
  property string status: "installing"
  readonly property bool indeterminate: status === "installing" && progress < 0
  property real displayedProgress: indeterminate ? 0.28 : Math.max(0, Math.min(1, progress))
  property real spinAngle: -90

  implicitWidth: 16
  implicitHeight: 16

  Behavior on displayedProgress {
    enabled: !root.indeterminate
    NumberAnimation { duration: 100 }
  }

  NumberAnimation on spinAngle {
    running: root.visible && root.indeterminate
    from: -90
    to: 270
    duration: 1000
    loops: Animation.Infinite
  }

  Rectangle {
    anchors.fill: parent
    visible: root.status === "installing"
    radius: width / 2
    color: "transparent"
    border.width: 2.5
    border.color: Shell.Theme.track
    antialiasing: true
  }

  Shape {
    anchors.fill: parent
    visible: root.status === "installing" && (root.indeterminate || root.displayedProgress > 0)
    preferredRendererType: Shape.CurveRenderer
    ShapePath {
      strokeColor: Shell.Theme.accent
      strokeWidth: 2.5
      fillColor: "transparent"
      capStyle: ShapePath.FlatCap
      PathAngleArc {
        centerX: 8
        centerY: 8
        radiusX: 6.75
        radiusY: 6.75
        startAngle: root.indeterminate ? root.spinAngle : -90
        sweepAngle: 360 * root.displayedProgress
      }
    }
  }

  Image {
    anchors.fill: parent
    visible: root.status === "installed"
    source: Qt.resolvedUrl("../icons/circle-check.svg")
    sourceSize: Qt.size(32, 32)
    smooth: true
    antialiasing: true
    layer.enabled: true
    layer.effect: MultiEffect {
      colorization: 1
      colorizationColor: Shell.Theme.successText
    }
  }

  Image {
    anchors.fill: parent
    visible: root.status === "failed"
    source: Qt.resolvedUrl("../icons/circle-alert.svg")
    sourceSize: Qt.size(32, 32)
    smooth: true
    antialiasing: true
    layer.enabled: true
    layer.effect: MultiEffect {
      colorization: 1
      colorizationColor: Shell.Theme.dangerText
    }
  }
}
