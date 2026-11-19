pragma ComponentBehavior: Bound

import QtQuick
import "." as Screenshot
import "Selection.js" as Sel
import ".."

// A peça da janela de captura (ficha 17, board 13:19344, estado "Início (modo área)" 13:19354): o véu de 30% sobre a tela
// inteira, a mira em cruz com a pílula de coordenadas, a dica no alto e a barra de modos embaixo. Ocupa a área do
// monitor (ou do palco, na vitrine) e não captura nada nem tem janela: o quadro congelado fica atrás dela, na
// CaptureWindow.qml. Só o modo Area tem o que desenhar além da barra (o que Window e Screen mostram é a F6-T12).
//
// A seleção de área (F6-T11, estado "Selecionando uma área", nó 13:19401): no modo Area, apertar e arrastar cria a seleção;
// arrastar por dentro a move, arrastar uma alça a redimensiona e arrastar por fora começa outra no lugar dela. Com ela,
// o véu de 30% dá lugar ao escurecimento de 45% só por fora, a mira, as coordenadas e a dica somem, e aparecem a borda, a
// pílula de tamanho e, depois de soltar, as alças e a pílula de ações. As contas (normalizar, prender ao monitor, redimensionar
// por alça, onde cada pílula cai) são do Selection.js; aqui só ligo o ponteiro a elas. A seleção mora no serviço, e esta peça
// só a desenha se ela nasceu neste monitor (`outputName`).
//
// `service` é a fonte do estado (`mode`, `showCursor`, `delaySeconds`, `selection`, `selectionOutput`, `selecting`) e das
// ações (`setMode`, `nextMode`, `toggleCursor`, `close`, `setSelection`, `clearSelection`, `copySelection`, `saveSelection`,
// `annotateSelection`, `capture`): CaptureState.qml na shell, demo/CaptureService.qml na vitrine (decisão 0011).
//
// O ponto (`pointX`, `pointY`) é o do ponteiro em pixels lógicos da peça. A mira e as coordenadas só aparecem no modo Area,
// no monitor do ponteiro (`active`) e enquanto o ponteiro não está sobre a dica ou a barra (`overUi`): ali o ponteiro do
// sistema volta, e a janela decide isso lendo `overUi`.
Item {
  id: root

  property var service: Screenshot.CaptureState

  // O nome do monitor desta peça. A seleção fica presa ao monitor em que começou, então só a peça dele a mostra.
  property string outputName: ""

  // O ponto sob a mira.
  property real pointX: width / 2
  property real pointY: height / 2
  // Falso esconde a mira, a dica e a barra (é um monitor em que o ponteiro não está); o véu fica.
  property bool active: true
  // O ponteiro já foi visto neste monitor; sem isso a mira não sabe onde estar.
  property bool pointerSeen: true
  // O tamanho do quadro em pixels (padrão 0: a razão é 1). Com escala no monitor o quadro tem mais pixels que a tela, e as
  // coordenadas da pílula são dos pixels do monitor.
  property int frameWidth: 0
  property int frameHeight: 0
  // Para fixar o hover na vitrine: o índice do modo sob o ponteiro (-1: o ponteiro de verdade).
  property int hoverMode: -1
  // Para fixar o hover na vitrine: o botão da pílula de ações sob o ponteiro ("copy", "save" ou "annotate"; vazio: o de verdade).
  property string hoverAction: ""

  readonly property bool areaMode: service ? service.mode === "area" : true
  readonly property real ratioX: frameWidth > 0 && width > 0 ? frameWidth / width : 1
  readonly property real ratioY: frameHeight > 0 && height > 0 ? frameHeight / height : 1
  readonly property int cellX: Math.floor(pointX)
  readonly property int cellY: Math.floor(pointY)

  // A seleção desta peça: { x, y, width, height } em pixels lógicos, ou null.
  readonly property var selection: service && service.selection && service.selectionOutput === outputName ? service.selection : null
  readonly property bool hasSelection: selection !== null
  // O ponteiro ainda está arrastando a seleção (criando, movendo ou redimensionando): sem alças nem ações até soltar.
  readonly property bool selecting: hasSelection && !!service.selecting

  // O ponteiro está sobre a dica (some com a seleção), sobre a barra ou sobre a pílula de ações.
  readonly property bool overUi: active && (insideItem(bar) || (hint.visible && insideItem(hint)) || (actions.visible && insideItem(actions)))
  readonly property bool showCrosshair: active && pointerSeen && areaMode && !overUi && !hasSelection

  // Onde fica cada pílula em volta da seleção.
  readonly property var sizePlace: hasSelection
      ? Sel.sizePill(selection, sizePill.width, sizePill.height, Theme.captureSizeGap, width) : null
  readonly property var actionsPlace: hasSelection
      ? Sel.actionsPill(selection, actions.width, actions.height, Theme.captureActionsGap, Theme.captureActionsEdge, width, height,
          sizePlace, { x: bar.x, y: bar.y, width: bar.width, height: bar.height }) : null

  // O arraste em andamento: "" (nenhum), "new", "move" ou "resize" (com a alça em `dragHandle`), a seleção de quando apertei
  // e o ponto em que apertei. Mover e redimensionar medem o quanto o ponteiro andou desde o aperto, e não a posição dele,
  // para a alça não pular quando eu a pego fora do centro.
  property string dragMode: ""
  property string dragHandle: ""
  property var dragOrigin: null
  property real dragStartX: 0
  property real dragStartY: 0

  // O ponteiro do sistema. Sem seleção ele fica invisível (a mira faz o papel dele). Com seleção: a seta de mover por dentro,
  // as setas de redimensionar sobre cada alça, a cruz por fora, e a seta normal sobre a barra e a pílula de ações. Durante
  // o arraste vale o do arraste, não o do que está sob o ponteiro.
  readonly property int cursorShape: {
    if (dragMode === "move")
      return Qt.SizeAllCursor;
    if (dragMode === "resize")
      return handleCursor(dragHandle);
    if (dragMode === "new")
      return Qt.CrossCursor;
    if (overUi)
      return Qt.ArrowCursor;
    if (!hasSelection || !areaMode)
      return Qt.BlankCursor;
    const hit = Sel.hitTest(selection, pointX, pointY, Theme.captureHandleHit);
    return hit === "move" ? Qt.SizeAllCursor : hit === "" ? Qt.CrossCursor : handleCursor(hit);
  }

  function handleCursor(handle) {
    switch (handle) {
    case "nw":
    case "se":
      return Qt.SizeFDiagCursor;
    case "ne":
    case "sw":
      return Qt.SizeBDiagCursor;
    case "n":
    case "s":
      return Qt.SizeVerCursor;
    }
    return Qt.SizeHorCursor;
  }

  // As teclas da captura: Espaço troca o modo, Esc fecha (sempre, com ou sem seleção) e Enter vale o botão "Capture". Ctrl,
  // Alt e Meta passam. Devolve se tratou a tecla.
  function handleKey(key, modifiers) {
    if (modifiers & (Qt.ControlModifier | Qt.AltModifier | Qt.MetaModifier))
      return false;
    if (!service)
      return false;
    switch (key) {
    case Qt.Key_Space:
      service.nextMode();
      return true;
    case Qt.Key_Escape:
      service.close();
      return true;
    case Qt.Key_Return:
    case Qt.Key_Enter:
      // A seleção pode estar em outro monitor: o teclado fica na janela do ponteiro, e o serviço é um só.
      if (!service.selection || service.selecting)
        return false;
      service.capture();
      return true;
    }
    return false;
  }

  // Apertei em (x, y), em pixels da peça. Por dentro da seleção o arraste a move, sobre uma alça a redimensiona, e por fora
  // (ou sem seleção) começa uma nova, que apaga a anterior já no aperto.
  function pressAt(x, y) {
    if (!areaMode || !service)
      return;
    dragStartX = x;
    dragStartY = y;
    const hit = hasSelection ? Sel.hitTest(selection, x, y, Theme.captureHandleHit) : "";
    if (hit === "move") {
      dragMode = "move";
      dragOrigin = selection;
    } else if (hit !== "") {
      dragMode = "resize";
      dragHandle = hit;
      dragOrigin = selection;
    } else {
      dragMode = "new";
      if (service.selection)
        service.clearSelection();
    }
  }

  // O ponteiro andou até (x, y) com o botão apertado.
  function dragTo(x, y) {
    if (dragMode === "" || !service)
      return;
    let rect;
    if (dragMode === "new")
      rect = Sel.fromDrag(dragStartX, dragStartY, x, y, width, height);
    else if (dragMode === "move")
      rect = Sel.move(dragOrigin, x - dragStartX, y - dragStartY, width, height);
    else
      rect = Sel.resize(dragOrigin, dragHandle, x - dragStartX, y - dragStartY, width, height, Theme.captureSelectionMinSize);
    service.setSelection(outputName, rect, true);
  }

  // Soltei. Uma seleção nova com menos de 8 num eixo não vale: volta ao estado inicial (um clique sem arrastar também não
  // cria nada).
  function endDrag() {
    if (dragMode === "" || !service)
      return;
    const mode = dragMode;
    dragMode = "";
    const rect = selection;
    if (mode === "new" && !Sel.isUsable(rect, Theme.captureSelectionMinSize))
      service.clearSelection();
    else if (rect)
      service.setSelection(outputName, rect, false);
  }

  function insideItem(item) {
    return pointX >= item.x && pointX < item.x + item.width && pointY >= item.y && pointY < item.y + item.height;
  }

  // Véu: preto a 30% na tela inteira. Com seleção ele dá lugar ao escurecimento de 45% só por fora dela (quatro retângulos
  // em volta, sem se cobrirem); dentro da seleção a imagem aparece limpa.
  Rectangle {
    visible: !root.hasSelection
    anchors.fill: parent
    color: Theme.captureScrim
  }

  Item {
    visible: root.hasSelection
    anchors.fill: parent

    readonly property var sel: root.selection || { x: 0, y: 0, width: 0, height: 0 }

    Rectangle {
      x: 0
      y: 0
      width: parent.width
      height: parent.sel.y
      color: Theme.captureSelectionScrim
    }
    Rectangle {
      x: 0
      y: parent.sel.y + parent.sel.height
      width: parent.width
      height: parent.height - y
      color: Theme.captureSelectionScrim
    }
    Rectangle {
      x: 0
      y: parent.sel.y
      width: parent.sel.x
      height: parent.sel.height
      color: Theme.captureSelectionScrim
    }
    Rectangle {
      x: parent.sel.x + parent.sel.width
      y: parent.sel.y
      width: parent.width - x
      height: parent.sel.height
      color: Theme.captureSelectionScrim
    }
  }

  // A borda e as oito alças da seleção.
  Screenshot.CaptureSelection {
    visible: root.hasSelection
    rect: root.selection || { x: 0, y: 0, width: 0, height: 0 }
    showHandles: !root.selecting
  }

  // O arraste: criar, mover e redimensionar. Fica embaixo da dica, da barra e das ações, que engolem o próprio clique, e só
  // vale no modo Area. É uma MouseArea sem hover: quem segue o ponteiro parado é o HoverHandler da janela.
  MouseArea {
    anchors.fill: parent
    enabled: root.areaMode
    acceptedButtons: Qt.LeftButton
    onPressed: mouse => root.pressAt(mouse.x, mouse.y)
    onPositionChanged: mouse => root.dragTo(mouse.x, mouse.y)
    onReleased: mouse => {
      root.dragTo(mouse.x, mouse.y);
      root.endDrag();
    }
    onCanceled: root.endDrag()
  }

  // A mira: duas linhas de 1 px de ponta a ponta do monitor, cruzando no pixel do ponteiro.
  Rectangle {
    visible: root.showCrosshair
    x: root.cellX
    y: 0
    width: Theme.captureCrosshairWidth
    height: root.height
    color: Theme.captureCrosshair
  }
  Rectangle {
    visible: root.showCrosshair
    x: 0
    y: root.cellY
    width: root.width
    height: Theme.captureCrosshairWidth
    color: Theme.captureCrosshair
  }

  // As coordenadas, em pixels do monitor. O canto de cima à esquerda fica a (+8,+8) do ponteiro; perto da borda direita
  // ou da de baixo a pílula passa para o outro lado (−8), para não sair da tela. A largura é a do texto mais o mesmo
  // recuo dos dois lados (Theme.captureCoordsPaddingX).
  TextMetrics {
    id: coordsMetrics
    font.family: Theme.monoFontFamily
    font.weight: Font.Medium
    font.pixelSize: Theme.fontMonoCaption
    font.letterSpacing: 0
    text: Math.floor(root.cellX * root.ratioX) + ", " + Math.floor(root.cellY * root.ratioY)
  }

  GlassSurface {
    id: coords

    readonly property bool flipX: root.cellX + Theme.captureCoordsOffset + width > root.width
    readonly property bool flipY: root.cellY + Theme.captureCoordsOffset + height > root.height

    visible: root.showCrosshair
    x: flipX ? root.cellX - Theme.captureCoordsOffset - width : root.cellX + Theme.captureCoordsOffset
    y: flipY ? root.cellY - Theme.captureCoordsOffset - height : root.cellY + Theme.captureCoordsOffset
    width: Math.ceil(coordsMetrics.width) + 2 * Theme.captureCoordsPaddingX
    height: Theme.captureCoordsHeight
    radius: Theme.captureCoordsRadius
    showGlow: false

    Text {
      anchors.fill: parent
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      text: coordsMetrics.text
      color: Theme.text
      font.family: Theme.monoFontFamily
      font.weight: Font.Medium
      font.pixelSize: Theme.fontMonoCaption
      font.letterSpacing: 0
    }
  }

  // A dica: vidro de altura 40 (raio 20, sem o brilho do acento), centrado na largura e a 24 do topo. A largura é a da
  // fila mais 16 de cada lado.
  GlassSurface {
    id: hint

    visible: root.active && root.areaMode && !root.hasSelection
    x: Math.round((root.width - width) / 2)
    y: Theme.captureHintTop
    width: Math.ceil(hintRow.implicitWidth) + 2 * Theme.captureHintPaddingX
    height: Theme.captureHintHeight
    radius: Theme.captureHintRadius
    showGlow: false

    // A dica engole o clique, como a barra.
    MouseArea {
      anchors.fill: parent
      acceptedButtons: Qt.AllButtons
    }

    Row {
      id: hintRow
      x: Theme.captureHintPaddingX
      y: Math.round((hint.height - Theme.captureHintRowHeight) / 2)
      spacing: Theme.captureHintGap

      HintText { text: "Drag to select"; color: Theme.text }
      KeyCap { text: "Space" }
      HintText { text: "switches mode"; color: Theme.muted }
      KeyCap { text: "Esc" }
    }
  }

  // Texto da dica: Geist Medium 11, linha de 16, centrado na altura da fila (a tecla tem 20).
  component HintText: Text {
    height: Theme.captureHintRowHeight
    verticalAlignment: Text.AlignVCenter
    lineHeightMode: Text.FixedHeight
    lineHeight: Theme.captureHintLineHeight
    font.family: Theme.fontFamily
    font.weight: Font.Medium
    font.pixelSize: Theme.fontCaption
    font.letterSpacing: 0
  }

  // A pílula de tamanho da seleção, em pixels do monitor (com escala o quadro tem mais pixels que a tela): a mesma construção da
  // pílula de coordenadas, com o recuo do board (Theme.captureSizePaddingX). Alinhada à esquerda da seleção, 8 acima, ou por
  // dentro quando não há lugar em cima (Selection.sizePill). Não engole o clique.
  TextMetrics {
    id: sizeMetrics
    font.family: Theme.monoFontFamily
    font.weight: Font.Medium
    font.pixelSize: Theme.fontMonoCaption
    font.letterSpacing: 0
    text: root.selection ? Math.round(root.selection.width * root.ratioX) + " \u00D7 " + Math.round(root.selection.height * root.ratioY) : ""
  }

  GlassSurface {
    id: sizePill

    visible: root.hasSelection
    x: root.sizePlace ? root.sizePlace.x : 0
    y: root.sizePlace ? root.sizePlace.y : 0
    width: Math.ceil(sizeMetrics.width) + 2 * Theme.captureSizePaddingX
    height: Theme.captureSizeHeight
    radius: Theme.captureSizeRadius
    showGlow: false

    Text {
      anchors.fill: parent
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      text: sizeMetrics.text
      color: Theme.text
      font.family: Theme.monoFontFamily
      font.weight: Font.Medium
      font.pixelSize: Theme.fontMonoCaption
      font.letterSpacing: 0
    }
  }

  // A barra de modos: centrada na largura e a 24 da base.
  CaptureModeBar {
    id: bar

    visible: root.active
    x: Math.round((root.width - width) / 2)
    y: root.height - Theme.captureBarBottom - height
    service: root.service
    hoverMode: root.hoverMode
  }

  // A pílula de ações, depois de soltar a seleção. Por cima de tudo, para ficar clicável mesmo quando cai por dentro de uma
  // seleção que passa por baixo da barra.
  Screenshot.CaptureActions {
    id: actions

    visible: root.hasSelection && !root.selecting
    x: root.actionsPlace ? root.actionsPlace.x : 0
    y: root.actionsPlace ? root.actionsPlace.y : 0
    service: root.service
    hoverButton: root.hoverAction
  }
}
