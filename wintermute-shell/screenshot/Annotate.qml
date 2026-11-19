pragma ComponentBehavior: Bound

import QtQuick
import "." as Screenshot
import ".."

// O editor de anotação da captura de tela (ficha 17, estado 5; board 13:19344, nó 13:19481 "Anotação · editor"): o vidro do launcher de
// 720×480, sem o brilho do acento, com a barra em cima (as seis ferramentas, as cinco cores, o desfazer, "Copy" e "Save") e a área da
// imagem de 688×408 embaixo (AnnotateCanvas.qml). O board desenha um estado só; o comportamento de cada ferramenta, o texto sendo
// digitado, o recorte e a janela em volta são composição (ajuste A-05), sem valor novo.
//
// Não sabe de onde vem a imagem nem para onde ela vai: lê `service.imageSource` e `service.document` (a ferramenta, a cor, a imagem
// e as marcas) e chama `service.copy()`, `save()` e `close()` (screenshot/AnnotateState.qml na shell, demo/AnnotateService.qml na
// vitrine; decisão 0011). Para o "Copy" ela registra no serviço a si mesma como quem exporta a imagem com as marcas em PNG (`exportTo`).
//
// Teclas (`handleKey`, também chamada pelo campo de texto): Enter confirma o texto ou aplica o recorte; Esc cancela só o texto, ou só o
// recorte, e sem nenhum dos dois fecha o editor e descarta as marcas; Ctrl+Z desfaz. Desfazer com o texto em andamento cancela o texto,
// sem tirar nenhuma marca.
GlassSurface {
  id: root

  property var service: Screenshot.AnnotateState

  readonly property var document: service.document
  readonly property alias canvas: canvas

  // As ferramentas, na ordem do board, e as cores com o nome que cada uma tem para quem não vê (a lista de cores do Theme tem a mesma ordem).
  readonly property var toolButtons: [
    { key: "pencil", icon: "pencil", name: "Pencil" },
    { key: "highlighter", icon: "highlighter", name: "Highlighter" },
    { key: "rectangle", icon: "square", name: "Rectangle" },
    { key: "arrow", icon: "arrow-up-right", name: "Arrow" },
    { key: "text", icon: "type", name: "Text" },
    { key: "crop", icon: "crop", name: "Crop" }
  ]
  readonly property var colorNames: ["Orange", "Yellow", "Accent", "Green", "White"]

  surfaceType: "launcher"
  showGlow: false
  implicitWidth: Theme.captureAnnotateWidth
  implicitHeight: Theme.captureAnnotateHeight
  width: implicitWidth
  height: implicitHeight
  focus: true

  function selectTool(key) {
    canvas.settle(true);
    document.setTool(key);
  }

  function selectColor(index) {
    canvas.settle(false);
    document.setColor(index);
  }

  // O texto em andamento é descartado; sem ele, tira a última marca (ou desfaz o último recorte).
  function undo() {
    if (canvas.textActive) {
      canvas.cancelText();
      return;
    }
    document.undo();
  }

  function copy() {
    canvas.settle(false);
    service.copy();
  }

  function save() {
    canvas.settle(false);
    service.save();
  }

  // Devolve se tratou a tecla.
  function handleKey(key, modifiers) {
    if (key === Qt.Key_Z && (modifiers & Qt.ControlModifier) && !(modifiers & (Qt.AltModifier | Qt.MetaModifier))) {
      undo();
      return true;
    }
    if (modifiers & (Qt.ControlModifier | Qt.AltModifier | Qt.MetaModifier))
      return false;
    switch (key) {
    case Qt.Key_Escape:
      if (canvas.textActive)
        canvas.cancelText();
      else if (canvas.hasCrop)
        canvas.clearCrop();
      else
        service.close();
      return true;
    case Qt.Key_Return:
    case Qt.Key_Enter:
      if (canvas.textActive) {
        canvas.commitText();
        return true;
      }
      if (canvas.hasCrop) {
        canvas.applyCrop();
        return true;
      }
      return false;
    }
    return false;
  }

  Keys.onPressed: event => { event.accepted = root.handleKey(event.key, event.modifiers); }

  // A imagem com as marcas em PNG, no tamanho da imagem (depois do recorte), em pixels: `done(true)` ou `done(false)`. O FrameCropper lê a
  // cena sem a escala da tela, então o arquivo sai com o traço da tela dividido pela escala.
  function exportTo(path, done) {
    const state = document.state;
    if (!state) {
      console.warn("screenshot: o editor não tem imagem para exportar");
      done(false);
      return;
    }
    cropper.save({ x: 0, y: 0, width: state.width, height: state.height }, path, done);
  }

  Component.onCompleted: {
    if (service.registerExporter)
      service.registerExporter(root);
  }
  Component.onDestruction: {
    if (service.unregisterExporter)
      service.unregisterExporter(root);
  }

  Screenshot.FrameCropper {
    id: cropper
    source: canvas.scene
    frameWidth: root.document.ready ? root.document.state.width : 0
    frameHeight: root.document.ready ? root.document.state.height : 0
  }

  // ---- a barra ----

  Repeater {
    model: root.toolButtons

    delegate: IconButton {
      required property var modelData
      required property int index

      x: Theme.captureAnnotatePadding + index * Theme.captureAnnotateToolStep
      y: Theme.captureAnnotatePadding
      iconName: modelData.icon
      accessibleName: modelData.name
      checked: root.document.tool === modelData.key
      onClicked: root.selectTool(modelData.key)

      Accessible.role: Accessible.Button
      Accessible.name: modelData.name
      Accessible.checked: checked
      Accessible.onPressAction: root.selectTool(modelData.key)
    }
  }

  Rectangle {
    x: Theme.captureAnnotateDividerLeftX
    y: Theme.captureAnnotateDividerY
    width: 1
    height: Theme.captureAnnotateDividerHeight
    color: Theme.border
  }

  Repeater {
    model: Theme.captureAnnotateColors

    delegate: Item {
      id: swatch

      required property color modelData
      required property int index
      readonly property bool selected: root.document.colorIndex === index

      x: Theme.captureAnnotateColorX + index * Theme.captureAnnotateColorStep
      y: Theme.captureAnnotatePadding
      width: Theme.captureAnnotateColorSize
      height: Theme.captureAnnotateColorSize

      Accessible.role: Accessible.RadioButton
      Accessible.name: root.colorNames[index]
      Accessible.checked: selected
      Accessible.onPressAction: root.selectColor(index)

      Rectangle {
        anchors.centerIn: parent
        width: Theme.captureAnnotateSwatchSize
        height: Theme.captureAnnotateSwatchSize
        radius: width / 2
        color: swatch.modelData
        antialiasing: true
      }

      // O anel da cor escolhida: `text` de 2 no círculo de 32.
      Rectangle {
        anchors.fill: parent
        visible: swatch.selected
        radius: width / 2
        color: "transparent"
        border.width: Theme.captureAnnotateRingWidth
        border.color: Theme.text
        antialiasing: true
      }

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.selectColor(swatch.index)
      }
    }
  }

  Rectangle {
    x: Theme.captureAnnotateDividerRightX
    y: Theme.captureAnnotateDividerY
    width: 1
    height: Theme.captureAnnotateDividerHeight
    color: Theme.border
  }

  IconButton {
    x: Theme.captureAnnotateUndoX
    y: Theme.captureAnnotatePadding
    iconName: "undo-2"
    accessibleName: "Undo"
    enabled: root.document.canUndo
    onClicked: root.undo()

    Accessible.role: Accessible.Button
    Accessible.name: "Undo"
    Accessible.onPressAction: root.undo()
  }

  ActionButton {
    x: Theme.captureAnnotateCopyX
    y: Theme.captureAnnotatePadding
    width: Theme.captureAnnotateButtonWidth
    kind: "secondary"
    small: true
    text: "Copy"
    onClicked: root.copy()

    Accessible.role: Accessible.Button
    Accessible.name: text
    Accessible.onPressAction: root.copy()
  }

  ActionButton {
    x: Theme.captureAnnotateSaveX
    y: Theme.captureAnnotatePadding
    width: Theme.captureAnnotateButtonWidth
    kind: "primary"
    small: true
    text: "Save"
    onClicked: root.save()

    Accessible.role: Accessible.Button
    Accessible.name: text
    Accessible.onPressAction: root.save()
  }

  // ---- a área da imagem ----

  Screenshot.AnnotateCanvas {
    id: canvas
    x: Theme.captureAnnotateAreaX
    y: Theme.captureAnnotateAreaY
    width: Theme.captureAnnotateAreaWidth
    height: Theme.captureAnnotateAreaHeight
    document: root.document
    imageSource: root.service.imageSource
    focusTarget: root
    keyHandler: (key, modifiers) => root.handleKey(key, modifiers)
  }
}
