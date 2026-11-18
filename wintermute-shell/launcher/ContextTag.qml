import QtQuick
import ".."

// Etiqueta de contexto do launcher (ficha 14, nó 13:17185): "On workspace N", à direita do cabeçalho de busca.
// Não é a Tag da ficha 00 (20 de altura): esta tem 24, raio 12, accentSubtle com borda accentRing e texto Geist
// Medium 11 em accentText. A largura é a do texto, arredondada para cima, mais o recuo de cada lado.
Rectangle {
  id: root

  property string text: ""

  implicitWidth: Math.ceil(label.implicitWidth) + 2 * Theme.launcherContextPadding
  implicitHeight: Theme.launcherContextHeight
  width: implicitWidth
  height: implicitHeight
  radius: Theme.launcherContextRadius
  color: Theme.accentSubtle
  border.width: 1
  border.color: Theme.accentRing
  antialiasing: true

  Text {
    id: label
    x: Math.round((root.width - width) / 2)
    y: Math.round((root.height - height) / 2)
    text: root.text
    color: Theme.accentText
    font.family: Theme.fontFamily
    font.weight: Font.Medium
    font.pixelSize: Theme.fontCaption
    font.letterSpacing: 0
  }
}
