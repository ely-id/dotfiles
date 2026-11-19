pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import ".."

// O botão redondo da prévia de captura (ficha 17, estado 4; board 13:19344, nós 13:19571 a 13:19577): 32×32, raio 16, borda
// `borderStrong` de 1, fundo `capturePreviewButton` e, sob o ponteiro, `capturePreviewButtonHover`; ícone de 16 em `text`, centrado.
// Quem o põe no lugar e liga a ação é a Preview.qml. `done` troca o ícone pelo `check` em `successText`: é o "copiado" do botão
// de copiar (composição, A-05), o mesmo sinal que o launcher usa ao copiar uma cor.
Rectangle {
  id: root

  // Nome do ícone em icons/ (copy, save, pencil, x).
  property string iconName: ""
  property string label: ""
  property bool done: false
  // Para fixar o hover na vitrine; vazio, vale o ponteiro de verdade.
  property bool hoverPinned: false
  readonly property bool hovered: hoverPinned || pointer.containsMouse

  signal activated

  width: Theme.capturePreviewButtonSize
  height: Theme.capturePreviewButtonSize
  radius: Theme.capturePreviewButtonRadius
  color: hovered ? Theme.capturePreviewButtonHover : Theme.capturePreviewButton
  border { width: Theme.capturePreviewBorderWidth; color: Theme.borderStrong }
  antialiasing: true

  Accessible.role: Accessible.Button
  Accessible.name: label
  Accessible.onPressAction: activated()

  Behavior on color {
    ColorAnimation { duration: Theme.hoverDuration; easing.type: Easing.OutCubic }
  }

  Image {
    anchors.centerIn: parent
    width: Theme.capturePreviewIconSize
    height: Theme.capturePreviewIconSize
    source: Qt.resolvedUrl("../icons/" + (root.done ? "check" : root.iconName) + ".svg")
    sourceSize: Qt.size(Theme.capturePreviewIconSize * 2, Theme.capturePreviewIconSize * 2)
    fillMode: Image.PreserveAspectFit
    smooth: true
    // Os ícones de icons/ são brancos e a cor vem da colorização.
    layer.enabled: true
    layer.effect: MultiEffect {
      colorization: 1
      colorizationColor: root.done ? Theme.successText : Theme.text
    }
  }

  MouseArea {
    id: pointer
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: root.activated()
  }
}
