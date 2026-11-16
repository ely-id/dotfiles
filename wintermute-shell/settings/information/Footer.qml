pragma ComponentBehavior: Bound
import QtQuick
import "../.." as Shell

// Rodapé das Informações (ficha 13; Figma 13:16083), a partir de y 536 no modal: "Wintermute Shell" em
// Serif 17 (caixa de 24) e a versão em Mono 11 Medium muted logo abaixo (caixa de 20), à esquerda; à
// direita, a grade de "+" 7×3 de 152×56 em x 398, Mono 11 Medium muted, passo 20, com opacidades
// 1 / 0,6 / 0,3 em sequência. O Figma diz que a grade some aos poucos no hover dos contatos, mas não
// desenha contatos, e os da origem (X, Instagram, site e e-mail) eram da marca dela e saíram. Até eu
// definir os contatos (P-50), a grade fica parada.
Item {
  id: root
  implicitWidth: Shell.Theme.settingsModalWidth
  implicitHeight: 56

  readonly property var steps: [1, 0.6, 0.3]

  Text {
    x: Shell.Theme.settingsBodyInset
    y: 0
    height: 24
    verticalAlignment: Text.AlignVCenter
    text: "Wintermute Shell"
    color: Shell.Theme.text
    font.family: Shell.Theme.titleFontFamily
    font.weight: Font.Normal
    font.pixelSize: Shell.Theme.fontInfoValue
    font.letterSpacing: 0
  }
  Text {
    x: Shell.Theme.settingsBodyInset
    y: 24
    height: 20
    verticalAlignment: Text.AlignVCenter
    text: "V0.1 · preview"
    color: Shell.Theme.muted
    font.family: Shell.Theme.monoFontFamily
    font.weight: Font.Medium
    font.pixelSize: Shell.Theme.fontMonoCaption
    font.letterSpacing: 0
  }

  Item {
    objectName: "informationPlusGrid"
    x: Shell.Theme.settingsInfoGridX
    width: 7 * Shell.Theme.settingsInfoGridCell + 12
    height: 56

    Repeater {
      model: 21
      delegate: Text {
        required property int index
        objectName: "informationPlus" + index
        // Centro de cada "+" em (10 + 20·coluna, 7 + 20·linha), como no Figma.
        x: 10 + (index % 7) * Shell.Theme.settingsInfoGridCell - width / 2
        y: 7 + Math.floor(index / 7) * Shell.Theme.settingsInfoGridCell - height / 2
        width: 12
        horizontalAlignment: Text.AlignHCenter
        text: "+"
        opacity: root.steps[index % 3]
        color: Shell.Theme.muted
        font.family: Shell.Theme.monoFontFamily
        font.weight: Font.Medium
        font.pixelSize: Shell.Theme.fontMonoCaption
        font.letterSpacing: 0
      }
    }
  }
}
