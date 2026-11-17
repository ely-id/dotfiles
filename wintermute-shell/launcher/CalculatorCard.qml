import QtQuick
import QtQuick.Effects
import ".."

// Cartão do cálculo do launcher (ficha 14, estado "Cálculo"): 624×128, raio radiusCard, fundo cardHover e
// borda border de 1. A expressão formatada à esquerda (Geist Serif 28, muted), o círculo "igual" no meio e o
// resultado à direita (Geist Serif 40, text), cada um numa caixa de 260×48 com a legenda de 260×20 embaixo.
// As posições são as do board, em coordenadas do cartão com a borda incluída.
//
// Expressão e resultado que não cabem na caixa são cortados com reticências (P-71).
Rectangle {
  id: root

  // Já formatados pelo serviço (Calculator.js), no separador decimal do locale.
  property string expression: ""
  property string result: ""

  implicitWidth: Theme.launcherRowWidth
  implicitHeight: Theme.launcherCalcCardHeight
  radius: Theme.radiusCard
  color: Theme.cardHover
  border.width: 1
  border.color: Theme.border
  antialiasing: true

  component Value: Text {
    width: Theme.launcherCalcBoxWidth
    height: Theme.launcherCalcBoxHeight
    y: Theme.launcherCalcBoxY
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
    font.family: Theme.titleFontFamily
    font.weight: Font.Normal
    font.letterSpacing: 0
  }

  component Caption: Text {
    width: Theme.launcherCalcBoxWidth
    height: Theme.launcherCalcCaptionHeight
    y: Theme.launcherCalcCaptionY
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
    color: Theme.muted
    font.family: Theme.fontFamily
    font.weight: Font.Medium
    font.pixelSize: Theme.fontCaption
    font.letterSpacing: 0
  }

  Value {
    x: Theme.launcherCalcExpressionX
    text: root.expression
    color: Theme.muted
    font.pixelSize: Theme.fontLauncherExpression
  }

  Caption {
    x: Theme.launcherCalcExpressionX
    text: "Expression"
  }

  Rectangle {
    x: Theme.launcherCalcEqualX
    y: Theme.launcherCalcEqualY
    width: Theme.launcherCalcEqualSize
    height: Theme.launcherCalcEqualSize
    radius: Theme.launcherCalcEqualSize / 2
    color: Theme.control
    antialiasing: true

    Image {
      x: Theme.launcherCalcEqualIconOffset
      y: Theme.launcherCalcEqualIconOffset
      width: Theme.launcherCalcEqualIconSize
      height: Theme.launcherCalcEqualIconSize
      source: Qt.resolvedUrl("../icons/equal.svg")
      sourceSize: Qt.size(width * 2, height * 2)
      fillMode: Image.PreserveAspectFit
      smooth: true
      antialiasing: true
      layer.enabled: true
      layer.effect: MultiEffect { colorization: 1; colorizationColor: Theme.text }
    }
  }

  Value {
    x: Theme.launcherCalcResultX
    text: root.result
    color: Theme.text
    font.pixelSize: Theme.fontLauncherResult
  }

  Caption {
    x: Theme.launcherCalcResultX
    text: "Result"
  }
}
