pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import "../.." as Shell

// Rodapé das Informações (ficha 13), de 56 de altura, a partir de y 536 no modal de 580×620. Só enfeites:
// sem contato, sem link e sem hover (P-50). Três elementos, como pedi na P-58 ("Broto | Wintermute | logo
// ARCH"), e a grade de "+" saiu.
//   - À esquerda, o logo provisório (o broto, de 40×40, P-51) em x 30, centrado na faixa: (56 − 40) / 2 = 8.
//     A cor é Theme.brandMark, o meio termo entre text e muted. O arquivo é um só (assets/brand/logo.svg,
//     decisão 0013) e a cor vem da colorização.
//   - "Wintermute" (e não "Wintermute Shell", decisão 0013) em Serif 17, caixa de 24, e a versão em Mono 11
//     Medium muted, caixa de 20, os dois em x 78 = 30 + 40 + 8. O bloco de 24 + 20 = 44 fica centrado na
//     faixa, como o broto: (56 − 44) / 2 = 6. Essa posição vertical não tem board: é composição (A-05).
//   - À direita, o "ARCH" (símbolo icon/information/arch do Figma, nó 7:1799, 151,43×42,96) numa caixa de
//     152×43 em x 398, alinhado à direita para terminar em x 550 = 580 − 30. Topo em y 6, o mesmo do bloco de
//     texto: (56 − 43) / 2 = 6,5, arredondado para baixo. Em muted; as listras a 50% são do desenho.
Item {
  id: root
  implicitWidth: Shell.Theme.settingsModalWidth
  implicitHeight: 56

  Image {
    objectName: "informationBrandMark"
    x: Shell.Theme.settingsBodyInset
    y: 8
    width: 40
    height: 40
    source: Qt.resolvedUrl("../../assets/brand/logo.svg")
    sourceSize: Qt.size(80, 80)
    smooth: true
    layer.enabled: true
    layer.effect: MultiEffect {
      colorization: 1
      colorizationColor: Shell.Theme.brandMark
    }
  }

  Text {
    objectName: "informationBrandName"
    x: 78
    y: 6
    height: 24
    verticalAlignment: Text.AlignVCenter
    text: "Wintermute"
    color: Shell.Theme.text
    font.family: Shell.Theme.titleFontFamily
    font.weight: Font.Normal
    font.pixelSize: Shell.Theme.fontInfoValue
    font.letterSpacing: 0
  }
  Text {
    objectName: "informationVersion"
    x: 78
    y: 30
    height: 20
    verticalAlignment: Text.AlignVCenter
    text: "V0.1 · preview"
    color: Shell.Theme.muted
    font.family: Shell.Theme.monoFontFamily
    font.weight: Font.Medium
    font.pixelSize: Shell.Theme.fontMonoCaption
    font.letterSpacing: 0
  }

  Image {
    objectName: "informationArch"
    x: 398
    y: 6
    width: 152
    height: 43
    source: Qt.resolvedUrl("../../assets/information/arch.svg")
    sourceSize: Qt.size(304, 86)
    fillMode: Image.PreserveAspectFit
    horizontalAlignment: Image.AlignRight
    smooth: true
    layer.enabled: true
    layer.effect: MultiEffect {
      colorization: 1
      colorizationColor: Shell.Theme.muted
    }
  }
}
