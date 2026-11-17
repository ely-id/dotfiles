import QtQuick
import Quickshell.Widgets
import "../../wallpaper/daylight" as Daylight
import "../.." as Shell

// Miniatura da linha de um lugar no cartão Customize (F4-T24, P-67). Não tem board: composição pela regra
// A-05, com a miniatura da grade encolhida. 64×36, raio `settingsDisplayTileRadius` (8, o do monitor em
// miniatura da página Tela), conteúdo recortado no raio e a borda `border` de 1 por cima, como na miniatura
// da grade. A altura é 36 = 52 − 2 × 8 (a mesma folga em cima, embaixo e à esquerda dentro da linha de 52) e
// a largura é 64 = 36 × 16 / 9, a proporção das imagens de 1920×1080. "Dynamic" mostra o céu da Daylight no
// lugar da imagem, sem texto, como a miniatura da grade.
Item {
  id: root
  property bool dynamic: false
  property url source

  implicitWidth: 64
  implicitHeight: 36

  ClippingRectangle {
    anchors.fill: parent
    radius: Shell.Theme.settingsDisplayTileRadius
    color: Shell.Theme.control

    Image {
      anchors.fill: parent
      visible: !root.dynamic
      source: root.dynamic ? "" : root.source
      sourceSize: Qt.size(Math.ceil(width * Screen.devicePixelRatio), Math.ceil(height * Screen.devicePixelRatio))
      fillMode: Image.PreserveAspectCrop
      asynchronous: true
      autoTransform: true
    }
    Loader {
      anchors.fill: parent
      active: root.dynamic
      sourceComponent: Daylight.Sky {}
    }
  }
  Rectangle {
    anchors.fill: parent
    radius: Shell.Theme.settingsDisplayTileRadius
    color: "transparent"
    border.width: 1
    border.color: Shell.Theme.border
    antialiasing: true
  }
}
