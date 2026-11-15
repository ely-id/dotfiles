import QtQuick
import Quickshell

// Cabeçalho, linhas rolantes, estado vazio e rodapé de uma lista de dispositivos (fichas 05 e 06).
// Título Serif 20 em (20,16), caixa de 32 de altura; ícone opcional de 20 em (20,22) empurra o
// título para x 48; controle (chave) em (242,18); linhas 300×44 em x 8 a partir de y 64.
Item {
  id: root
  property var stackController
  property bool interactive: true
  property string title: ""
  property url titleIcon: ""
  property Component headerControl
  property var devices: []
  property string deviceKey: ""
  property Component deviceDelegate
  property Component footer
  property string emptyText: ""
  // Legenda de seção 11 muted em (20,72), usada por "Procurando…" nos dispositivos próximos.
  property string sectionLabel: ""
  property string message: ""
  property int viewportHeight: 306
  property real listTop: 64
  property real listBottomPadding: 0
  readonly property alias contentY: deviceList.contentY
  implicitWidth: PanelStyle.width
  implicitHeight: viewportHeight + (message !== "" ? 44 : 0)

  PanelBackground {
    anchors.fill: parent
    stacked: true
    Image {
      x: 20; y: 22; width: 20; height: 20
      visible: root.titleIcon.toString() !== ""
      source: root.titleIcon
      sourceSize: Qt.size(40, 40)
      fillMode: Image.PreserveAspectFit
    }
    Text {
      x: root.titleIcon.toString() !== "" ? 48 : 20
      y: 16
      width: 222 - x
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
    Loader { x: 242; y: 18; width: 54; height: 28; sourceComponent: root.headerControl }
    Text {
      x: 20; y: 72; width: 276; height: 20
      visible: root.sectionLabel !== ""
      verticalAlignment: Text.AlignVCenter
      text: root.sectionLabel
      color: Theme.muted
      font.family: Theme.fontFamily
      font.weight: Font.Medium
      font.pixelSize: Theme.fontCaption
      font.letterSpacing: 0
    }
    ListView {
      id: deviceList
      clip: true
      boundsBehavior: Flickable.StopAtBounds
      ScrollWheel { view: deviceList }
      x: 8; y: root.listTop; width: PanelStyle.rowWidth
      height: root.viewportHeight - y - root.listBottomPadding
      model: ScriptModel { values: root.devices; objectProp: root.deviceKey }
      delegate: root.deviceDelegate
      footer: root.footer
      footerPositioning: ListView.InlineFooter
    }
    Text {
      x: 20; y: root.listTop + (root.footer ? 52 : 32); width: 276
      text: root.emptyText; visible: deviceList.count === 0
      horizontalAlignment: Text.AlignHCenter
      wrapMode: Text.Wrap
      color: Theme.muted
      font.family: Theme.fontFamily
      font.weight: Font.Normal
      font.pixelSize: Theme.fontBody
      font.letterSpacing: 0
    }
    Text {
      x: 20; y: root.viewportHeight; width: 276; height: 38
      text: root.message; visible: root.message !== ""
      wrapMode: Text.Wrap
      color: Theme.dangerText
      font.family: Theme.fontFamily
      font.pixelSize: Theme.fontCaption
      font.letterSpacing: 0
    }
    ScrollShade {
      view: deviceList
      x: 0; y: root.listTop - 4; width: parent.width
    }
  }
}
