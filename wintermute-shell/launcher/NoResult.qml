import QtQuick
import QtQuick.Effects
import ".."

// Bloco do estado "sem resultado" do launcher (ficha 14, nó 13:17394): círculo de 48 com o ícone `search-x`,
// título e dica, centrados nos 640 do launcher. A origem do item é o topo do círculo (y 80 no quadro); o
// título e a dica ficam a Theme.launcherNoResultTitleY e Theme.launcherNoResultHintY menos essa origem.
// O histórico da área de transferência (ficha 18) usa o mesmo desenho no estado vazio, com outro ícone, outros textos e outras
// alturas: as propriedades abaixo do `query` trocam isso, e com os valores de fábrica a peça é a do launcher.
Item {
  id: root

  property string query: ""
  property string iconName: "search-x"
  property string titleText: "Nothing found for “" + query + "”"
  property string hintText: "Check the spelling or try another search."
  // Do topo do círculo ao topo do título e ao da dica; a dica pode ter mais de uma linha (de 20 cada) e ser mais estreita que o quadro.
  property real titleTop: Theme.launcherNoResultTitleY - Theme.launcherNoResultCircleY
  property real hintTop: Theme.launcherNoResultHintY - Theme.launcherNoResultCircleY
  property int hintLines: 1
  property real hintWidth: width - 2 * Theme.launcherNoResultTextMargin

  implicitWidth: Theme.launcherWidth
  implicitHeight: hintTop + hintLines * Theme.launcherNoResultHintHeight

  Rectangle {
    x: Math.round((root.width - width) / 2)
    width: Theme.launcherNoResultCircleSize
    height: Theme.launcherNoResultCircleSize
    radius: width / 2
    color: Theme.control
    antialiasing: true

    Image {
      x: Theme.launcherNoResultIconOffset
      y: Theme.launcherNoResultIconOffset
      width: Theme.launcherNoResultIconSize
      height: Theme.launcherNoResultIconSize
      source: Qt.resolvedUrl("../icons/" + root.iconName + ".svg")
      sourceSize: Qt.size(width * 2, height * 2)
      fillMode: Image.PreserveAspectFit
      smooth: true
      antialiasing: true
      layer.enabled: true
      layer.effect: MultiEffect { colorization: 1; colorizationColor: Theme.text }
    }
  }

  // Aspas curvas, como no board. Busca longa é cortada com reticências: o texto não passa de 20 de cada lado.
  Text {
    x: Theme.launcherNoResultTextMargin
    y: root.titleTop
    width: root.width - 2 * Theme.launcherNoResultTextMargin
    height: Theme.launcherNoResultTitleHeight
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
    text: root.titleText
    color: Theme.text
    font.family: Theme.fontFamily
    font.weight: Font.Medium
    font.pixelSize: Theme.fontLabel
    font.letterSpacing: 0
  }

  Text {
    x: Math.round((root.width - root.hintWidth) / 2)
    y: root.hintTop
    width: root.hintWidth
    height: root.hintLines * Theme.launcherNoResultHintHeight
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    // Linha de 20 fixa: sem isso o Qt usa a altura natural da fonte (17) entre as linhas da dica de duas linhas.
    lineHeightMode: Text.FixedHeight
    lineHeight: Theme.launcherNoResultHintHeight
    elide: Text.ElideRight
    maximumLineCount: root.hintLines
    text: root.hintText
    color: Theme.muted
    font.family: Theme.fontFamily
    font.weight: Font.Normal
    font.pixelSize: Theme.fontBody
    font.letterSpacing: 0
  }
}
