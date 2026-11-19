import QtQuick
import QtQuick.Effects
import "." as Screenshot
import ".."

// O aviso de captura salva (ficha 17, F6-T03; board 13:19344, nó 13:19610): um cartão de vidro de 280×64 com o brilho do acento, o
// `circle-check` de 20 em `successText` num bloco de 40×40 (raio radiusChip, fundo `control`) em (12,12), o título "Screenshot saved"
// (Geist Medium 13, `text`) e o caminho do arquivo (Geist Medium 11, `muted`, com reticências no fim) em caixas de 200×20 em x 64.
//
// Só mostra: não recebe clique. Lê `service.displayPath` (screenshot/SavedState.qml na shell, demo/SavedToastService.qml na vitrine; decisão 0011).
// Onde o aviso aparece e por quanto tempo é da SavedToastWindow.qml e do SavedState.qml.
GlassSurface {
  id: root

  property var service: Screenshot.SavedState

  surfaceType: "card"
  implicitWidth: Theme.captureSavedWidth
  implicitHeight: Theme.captureSavedHeight
  width: implicitWidth
  height: implicitHeight

  Accessible.role: Accessible.StaticText
  Accessible.name: "Screenshot saved, " + root.service.displayPath

  Rectangle {
    id: block
    x: Theme.captureSavedBlockX
    y: Theme.captureSavedBlockY
    width: Theme.captureSavedBlockSize
    height: Theme.captureSavedBlockSize
    radius: Theme.radiusChip
    color: Theme.control
    antialiasing: true

    Image {
      x: Theme.captureSavedIconInset
      y: Theme.captureSavedIconInset
      width: Theme.captureSavedIconSize
      height: Theme.captureSavedIconSize
      source: Qt.resolvedUrl("../icons/circle-check.svg")
      sourceSize: Qt.size(width * 2, height * 2)
      fillMode: Image.PreserveAspectFit
      smooth: true
      antialiasing: true
      // Os ícones de icons/ são brancos e a cor vem da colorização.
      layer.enabled: true
      layer.effect: MultiEffect { colorization: 1; colorizationColor: Theme.successText }
    }
  }

  Text {
    x: Theme.captureSavedTextX
    y: Theme.captureSavedTitleY
    width: Theme.captureSavedTextWidth
    height: Theme.captureSavedTextHeight
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
    maximumLineCount: 1
    text: "Screenshot saved"
    color: Theme.text
    font.family: Theme.fontFamily
    font.weight: Font.Medium
    font.pixelSize: Theme.fontBody
    font.letterSpacing: 0
  }

  Text {
    x: Theme.captureSavedTextX
    y: Theme.captureSavedPathY
    width: Theme.captureSavedTextWidth
    height: Theme.captureSavedTextHeight
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
    maximumLineCount: 1
    text: root.service.displayPath
    color: Theme.muted
    font.family: Theme.fontFamily
    font.weight: Font.Medium
    font.pixelSize: Theme.fontCaption
    font.letterSpacing: 0
  }
}
