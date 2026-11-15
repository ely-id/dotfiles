import QtQuick

// Cartão do OSD do teclado (ficha 10): 156 de largura, raio 12, uma linha de 16 por layout com 12 de
// espaço (altura = 20 + layouts × 28; 2 layouts = 76). O layout atual leva `text` e o rádio marcado;
// os outros, `muted`.
Card {
  id: root
  property var layouts: NiriMsg.keyboardLayouts
  property int activeIndex: NiriMsg.keyboardLayoutIndex

  width: Theme.sidebarCardExpandedWidth
  height: 20 + layouts.length * 28
  radius: Theme.radiusRow
  hoverEnabled: false

  Column {
    x: 16; y: 16; width: parent.width - 32; spacing: 12
    Repeater {
      model: root.layouts
      delegate: Item {
        id: row
        required property string modelData
        required property int index
        width: root.width - 32; height: 16
        Accessible.role: Accessible.StaticText
        Accessible.name: modelData + (index === root.activeIndex ? ", ativo" : "")
        Text {
          width: parent.width - 24
          height: 16
          verticalAlignment: Text.AlignVCenter
          text: row.modelData; elide: Text.ElideRight
          color: row.index === root.activeIndex ? Theme.text : Theme.muted
          font.family: Theme.fontFamily; font.pixelSize: Theme.fontBody; font.weight: Font.Medium
          font.letterSpacing: 0
        }
        RadioButton {
          anchors.right: parent.right
          checked: row.index === root.activeIndex
          interactive: false
        }
      }
    }
  }
}
