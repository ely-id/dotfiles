import QtQuick
import QtQuick.Effects
import ".."

// Bloco do estado "sem resultado" do launcher (ficha 14, nó 13:17394): círculo de 48 com o ícone `search-x`,
// título e dica, centrados nos 640 do launcher. A origem do item é o topo do círculo (y 80 no quadro); o
// título e a dica ficam a Theme.launcherNoResultTitleY e Theme.launcherNoResultHintY menos essa origem.
Item {
  id: root

  property string query: ""

  implicitWidth: Theme.launcherWidth
  implicitHeight: Theme.launcherNoResultHintY + Theme.launcherNoResultHintHeight - Theme.launcherNoResultCircleY

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
      source: Qt.resolvedUrl("../icons/search-x.svg")
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
    y: Theme.launcherNoResultTitleY - Theme.launcherNoResultCircleY
    width: root.width - 2 * Theme.launcherNoResultTextMargin
    height: Theme.launcherNoResultTitleHeight
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
    text: "Nothing found for “" + root.query + "”"
    color: Theme.text
    font.family: Theme.fontFamily
    font.weight: Font.Medium
    font.pixelSize: Theme.fontLabel
    font.letterSpacing: 0
  }

  Text {
    x: Theme.launcherNoResultTextMargin
    y: Theme.launcherNoResultHintY - Theme.launcherNoResultCircleY
    width: root.width - 2 * Theme.launcherNoResultTextMargin
    height: Theme.launcherNoResultHintHeight
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
    text: "Check the spelling or try another search."
    color: Theme.muted
    font.family: Theme.fontFamily
    font.weight: Font.Normal
    font.pixelSize: Theme.fontBody
    font.letterSpacing: 0
  }
}
