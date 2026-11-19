pragma ComponentBehavior: Bound
import QtQuick


// Detalhes compartilhados do Wi-Fi e do Bluetooth (fichas 05 e 06). Dados e ações são de quem usa.
// Título Serif 20 em (20,16), ícone opcional 20×20 em (276,22); linhas de 48 com divisor a cada 49
// a partir de y 64; botões 146×40 em (8, y) e (162, y), 56 acima da base (6 linhas = 424).
Item {
  id: root
  property var stackController
  property var selection: ({})
  property bool interactive: true
  property string title: ""
  property var detailRows: []
  property Component titleIcon
  property string primaryText: "Forget"
  property string secondaryText: "Disconnect"
  property bool primaryEnabled: true
  property bool secondaryEnabled: true
  property string message: ""
  signal primaryClicked
  signal secondaryClicked
  readonly property real buttonsY: height - 56
  implicitWidth: Theme.panelWidth
  implicitHeight: 130 + detailRows.length * 49 + (message ? 40 : 0)

  PanelBackground {
    anchors.fill: parent
    stacked: true
    Text {
      x: 20; y: 16
      width: root.titleIcon ? 248 : 276
      height: 32
      verticalAlignment: Text.AlignVCenter
      elide: Text.ElideRight
      text: root.title
      color: Theme.text
      font.family: Theme.titleFontFamily
      font.weight: Font.Normal
      font.pixelSize: Theme.fontPanelTitle
      font.letterSpacing: 0
    }
    Loader { x: 276; y: 22; width: 20; height: 20; sourceComponent: root.titleIcon }
    Column {
      x: 20; y: 64
      Repeater {
        model: root.detailRows
        delegate: DetailLine {
          required property var modelData
          required property int index
          label: modelData.label
          value: String(modelData.value)
          showDivider: index < root.detailRows.length - 1
        }
      }
    }
    Text {
      x: 20; y: root.buttonsY - 44; width: 276; height: 36
      visible: root.message !== ""; text: root.message
      wrapMode: Text.Wrap
      color: Theme.dangerText
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontCaption
      font.letterSpacing: 0
    }
    ActionButton {
      x: 8; y: root.buttonsY
      kind: "danger"
      text: root.primaryText
      interactive: root.interactive && root.primaryEnabled
      onClicked: root.primaryClicked()
    }
    ActionButton {
      x: 162; y: root.buttonsY
      text: root.secondaryText
      interactive: root.interactive && root.secondaryEnabled
      onClicked: root.secondaryClicked()
    }
  }
}
