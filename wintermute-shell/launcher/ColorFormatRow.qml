import QtQuick
import QtQuick.Effects
import ".."

// Linha de formato do seletor de cor (ficha 15): 600×44, raio radiusRow, fundo `control`, sem borda. O rótulo
// (HEX, RGB, HSL) em Geist Mono Medium 11 `muted`, o valor em Geist Mono Medium 13 `text` e, à direita, o botão
// de ícone de 32 com o `copy`. Recém-copiada (`copied`), a linha mostra o `check` em `successText` e "Copied", e
// o botão passa ao estado selecionado, com o `check`.
Item {
  id: root

  property string label: ""
  property string value: ""
  property bool copied: false
  // O nome acessível do botão: "Copy HEX", "Copy RGB", "Copy HSL".
  property string copyName: ""

  signal copyRequested

  implicitWidth: Theme.launcherColorFormatWidth
  implicitHeight: Theme.launcherColorFormatHeight

  Rectangle {
    anchors.fill: parent
    radius: Theme.radiusRow
    color: Theme.control
    antialiasing: true
  }

  Text {
    x: Theme.launcherColorFormatLabelX
    width: Theme.launcherColorFormatLabelWidth
    height: parent.height
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
    text: root.label
    color: Theme.muted
    font.family: Theme.monoFontFamily
    font.weight: Font.Medium
    font.pixelSize: Theme.fontMonoCaption
    font.letterSpacing: 0
  }

  Text {
    x: Theme.launcherColorFormatValueX
    width: Theme.launcherColorFormatValueWidth
    height: parent.height
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
    text: root.value
    color: Theme.text
    font.family: Theme.monoFontFamily
    font.weight: Font.Medium
    font.pixelSize: Theme.fontMonoNumber
    font.letterSpacing: 0
  }

  Image {
    visible: root.copied
    x: Theme.launcherColorCheckX
    y: Theme.launcherColorCheckY
    width: Theme.launcherColorCheckSize
    height: Theme.launcherColorCheckSize
    source: Qt.resolvedUrl("../icons/check.svg")
    sourceSize: Qt.size(width * 2, height * 2)
    fillMode: Image.PreserveAspectFit
    smooth: true
    antialiasing: true
    layer.enabled: true
    layer.effect: MultiEffect { colorization: 1; colorizationColor: Theme.successText }
  }

  Text {
    visible: root.copied
    x: Theme.launcherColorCopiedX
    width: Theme.launcherColorCopiedWidth
    height: parent.height
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
    text: "Copied"
    color: Theme.successText
    font.family: Theme.fontFamily
    font.weight: Font.Medium
    font.pixelSize: Theme.fontBody
    font.letterSpacing: 0
  }

  IconButton {
    x: Theme.launcherColorFormatButtonX
    y: Theme.launcherColorFormatButtonY
    iconName: root.copied ? "check" : "copy"
    // `checked` e não `visualState`: o estado fixado desliga o ponteiro, e o botão continua clicável enquanto mostra "Copied".
    checked: root.copied
    accessibleName: root.copyName
    onClicked: root.copyRequested()
  }
}
