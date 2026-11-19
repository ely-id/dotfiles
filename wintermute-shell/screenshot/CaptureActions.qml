pragma ComponentBehavior: Bound

import QtQuick
import ".."

// A pílula de ações da seleção (ficha 17, board 13:19344, nó 13:19432): vidro de 208×48, raio 14, sem o brilho do acento,
// com três botões de ícone de 32 (copiar, salvar, anotar) em x 8, 44 e 80 e o "Capture" primário de 84×32 em (116,8).
// Não sabe o que cada ação faz: chama `service.copySelection()`, `saveSelection()`, `annotateSelection()` e `capture()`
// (CaptureState.qml na shell, demo/CaptureService.qml na vitrine). Quem a posiciona em volta da seleção é a Capture.qml.
GlassSurface {
  id: root

  property var service

  // Para fixar o hover na vitrine: "copy", "save" ou "annotate" (o board mostra o de anotar). Vazio: o ponteiro de verdade.
  property string hoverButton: ""

  width: Theme.captureActionsWidth
  height: Theme.captureActionsHeight
  radius: Theme.captureActionsRadius
  showGlow: false

  readonly property var buttons: [
    { key: "copy", icon: "copy", name: "Copy" },
    { key: "save", icon: "save", name: "Save" },
    { key: "annotate", icon: "pencil", name: "Annotate" }
  ]

  // Chama a ação de um dos três botões; o "Capture" tem a própria. Separado do clique para a vitrine testar sem o mouse.
  function trigger(key) {
    if (!service)
      return;
    if (key === "copy")
      service.copySelection();
    else if (key === "save")
      service.saveSelection();
    else if (key === "annotate")
      service.annotateSelection();
    else if (key === "capture")
      service.capture();
  }

  // A pílula engole o clique no vazio dela, para ele não começar uma seleção nova por baixo.
  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.AllButtons
  }

  Repeater {
    model: root.buttons

    delegate: IconButton {
      required property var modelData
      required property int index

      x: Theme.captureActionsPadding + index * Theme.captureActionsButtonStep
      y: Theme.captureActionsPadding
      buttonSize: Theme.captureActionsButtonSize
      iconName: modelData.icon
      accessibleName: modelData.name
      visualState: root.hoverButton === modelData.key ? "hover" : ""
      onClicked: root.trigger(modelData.key)

      Accessible.role: Accessible.Button
      Accessible.name: modelData.name
      Accessible.onPressAction: root.trigger(modelData.key)
    }
  }

  ActionButton {
    x: Theme.captureActionsPrimaryX
    y: Theme.captureActionsPadding
    width: Theme.captureActionsPrimaryWidth
    kind: "primary"
    small: true
    text: "Capture"
    onClicked: root.trigger("capture")

    Accessible.role: Accessible.Button
    Accessible.name: text
    Accessible.onPressAction: root.trigger("capture")
  }
}
