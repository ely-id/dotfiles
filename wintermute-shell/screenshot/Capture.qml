pragma ComponentBehavior: Bound

import QtQuick
import "." as Screenshot
import ".."

// A peça da janela de captura (ficha 17, board 13:19344, estado "Início (modo área)" 13:19354): o véu de 30% sobre a tela
// inteira, a mira em cruz com a pílula de coordenadas, a dica no alto e a barra de modos embaixo. Ocupa a área do
// monitor (ou do palco, na vitrine) e não captura nada nem tem janela: o quadro congelado fica atrás dela, na
// CaptureWindow.qml. Nesta tarefa (F6-T01) só o modo Area tem o que desenhar além da barra: selecionar a área é a F6-T11
// e o que Window e Screen mostram é a F6-T12.
//
// `service` é a fonte do estado (`mode`, `showCursor`, `delaySeconds`) e das ações (`setMode`, `nextMode`, `toggleCursor`,
// `close`): CaptureState.qml na shell, demo/CaptureService.qml na vitrine (decisão 0011).
//
// O ponto (`pointX`, `pointY`) é o do ponteiro em pixels lógicos da peça. A mira e as coordenadas só aparecem no modo Area,
// no monitor do ponteiro (`active`) e enquanto o ponteiro não está sobre a dica ou a barra (`overUi`): ali o ponteiro do
// sistema volta, e a janela decide isso lendo `overUi`.
Item {
  id: root

  property var service: Screenshot.CaptureState

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

  readonly property bool areaMode: service ? service.mode === "area" : true
  readonly property real ratioX: frameWidth > 0 && width > 0 ? frameWidth / width : 1
  readonly property real ratioY: frameHeight > 0 && height > 0 ? frameHeight / height : 1
  readonly property int cellX: Math.floor(pointX)
  readonly property int cellY: Math.floor(pointY)

  // O ponteiro está sobre a dica (só existe no modo Area) ou sobre a barra.
  readonly property bool overUi: active && (insideItem(bar) || (areaMode && insideItem(hint)))
  readonly property bool showCrosshair: active && pointerSeen && areaMode && !overUi

  // As teclas da captura: Espaço troca o modo, Esc fecha. Ctrl, Alt e Meta passam. Devolve se tratou a tecla.
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
    }
    return false;
  }

  function insideItem(item) {
    return pointX >= item.x && pointX < item.x + item.width && pointY >= item.y && pointY < item.y + item.height;
  }

  // Véu: preto a 30% na tela inteira.
  Rectangle {
    anchors.fill: parent
    color: Theme.captureScrim
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

    visible: root.active && root.areaMode
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

  // A barra de modos: centrada na largura e a 24 da base.
  CaptureModeBar {
    id: bar

    visible: root.active
    x: Math.round((root.width - width) / 2)
    y: root.height - Theme.captureBarBottom - height
    service: root.service
    hoverMode: root.hoverMode
  }
}
