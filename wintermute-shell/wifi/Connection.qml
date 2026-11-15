import QtQuick
import QtQuick.Effects
import "." as Wifi
import ".."

// Status da conexão (ficha 05, 316×112): três pontos accent em (opacidade 1 / 0,6 / 0,3)
// enquanto conecta, check em successText quando conectou, alerta em dangerText quando falhou.
// Pontos 8×8 com espaço 4 e ícones 20×20, centrados em y 34; título Serif 20 centrado em y 70.
Item {
  id: root
  readonly property bool headerDividerVisible: false
  property var stackController
  property bool interactive: true
  property var service: stackController ? stackController.service : Wifi.State
  readonly property bool connecting: service.phase === "connecting" || service.phase === "working"
  readonly property bool failed: service.phase === "failed"
  readonly property color statusColor: failed ? Theme.dangerText
      : connecting ? Theme.text : Theme.successText
  implicitWidth: PanelStyle.width
  implicitHeight: 112

  PanelBackground {
    anchors.fill: parent
    stacked: true

    Row {
      visible: root.connecting
      x: (parent.width - width) / 2
      y: 30
      spacing: 4
      Repeater {
        model: [1, 0.6, 0.3]
        delegate: Rectangle {
          required property real modelData
          width: 8; height: 8; radius: 4
          color: Theme.accent
          opacity: modelData
        }
      }
    }
    Image {
      visible: !root.connecting
      x: (parent.width - width) / 2
      y: 24
      width: 20; height: 20
      source: Qt.resolvedUrl(root.failed ? "../icons/circle-alert.svg" : "../icons/circle-check.svg")
      sourceSize: Qt.size(40, 40)
      fillMode: Image.PreserveAspectFit
      layer.enabled: true
      layer.effect: MultiEffect {
        colorization: 1
        colorizationColor: root.statusColor
      }
    }
    Text {
      x: 20; y: 54
      width: 276; height: 32
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      elide: Text.ElideRight
      text: root.service.statusText
      color: root.statusColor
      font.family: Theme.titleFontFamily
      font.weight: Font.Normal
      font.pixelSize: Theme.fontPanelTitle
      font.letterSpacing: 0
    }
  }
}
