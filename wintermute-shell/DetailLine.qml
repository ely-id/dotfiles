import QtQuick

// Linha de detalhe (ficha 05, Detalhes): 276×48, rótulo 15 Medium à esquerda, valor 13 muted
// à direita e divisor de 1 px embaixo (as linhas se repetem a cada 49).
Item {
  id: root
  property string label: ""
  property string value: "—"
  property bool showDivider: true
  implicitWidth: 276
  implicitHeight: 48 + (showDivider ? 1 : 0)

  Text {
    x: 0
    y: 0
    height: 48
    width: Math.min(implicitWidth, root.width * 0.55)
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
    text: root.label
    color: Theme.text
    font.family: Theme.fontFamily
    font.weight: Font.Medium
    font.pixelSize: Theme.fontLabel
    font.letterSpacing: 0
  }
  Text {
    x: root.width * 0.45
    y: 0
    height: 48
    width: root.width * 0.55
    horizontalAlignment: Text.AlignRight
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideLeft
    text: root.value
    color: Theme.muted
    font.family: Theme.fontFamily
    font.weight: Font.Normal
    font.pixelSize: Theme.fontBody
    font.letterSpacing: 0
  }
  Rectangle {
    visible: root.showDivider
    x: 0
    y: 48
    width: parent.width
    height: 1
    color: Theme.border
  }
}
