pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Widgets
import "." as Launcher
import ".."

// A lupa do seletor de cor (ficha 15, estado "pegando a cor", board 13:17430): o círculo de 112 com a grade de 7×7
// pixels, o valor sob o cursor e a pílula de dicas. A peça ocupa a área do monitor (ou da cena, no espécime) e
// desenha as três coisas em volta de (`pointX`, `pointY`). Não captura a tela e não tem janela: os pixels vêm de
// `source`, qualquer Item, lido por `PixelReader.qml`. Na shell o `source` é o quadro congelado do monitor
// (LoupeWindow.qml); no espécime, uma cena fictícia.
//
// O ponto é o do ponteiro, em coordenadas da peça (as mesmas do `source`, em pixels lógicos). A lupa mostra pixels
// do quadro: com escala 1 um pixel lógico é um pixel do quadro; com escala maior o quadro tem mais pixels que o
// monitor, e o pixel do meio é o `floor(ponto × razão)`. Os pixels de fora do quadro ficam na cor de fundo da lupa.
Item {
  id: root

  // De onde saem os pixels. Precisa ter o mesmo tamanho (e a mesma origem) da peça.
  property Item source
  // O tamanho pedido para o quadro, em pixels (padrão: o do `source`). Na shell vem do `sourceSize` da captura.
  property int frameWidth: source ? Math.round(source.width) : 0
  property int frameHeight: source ? Math.round(source.height) : 0
  // O `source` já tem imagem para ler (na shell, `hasContent` do quadro).
  property bool sourceReady: true
  // O ponto sob a lupa. Mexer o mouse o leva ao ponteiro (`follow`); as setas movem 1 px do quadro (`nudge`).
  property real pointX: width / 2
  property real pointY: height / 2
  // Falso esconde tudo (é o monitor em que o ponteiro não está).
  property bool active: true

  // O quadro já foi lido.
  readonly property bool ready: reader.ready
  readonly property bool failed: reader.failed
  // Pixels do quadro por pixel lógico da peça.
  readonly property real ratioX: reader.ready && width > 0 ? reader.pixelWidth / width : 1
  readonly property real ratioY: reader.ready && height > 0 ? reader.pixelHeight / height : 1
  // O pixel do quadro sob o ponto, preso ao quadro.
  readonly property int pixelX: clampPixel(Math.floor(pointX * ratioX), reader.pixelWidth)
  readonly property int pixelY: clampPixel(Math.floor(pointY * ratioY), reader.pixelHeight)
  // Os 49 pixels (em ordem de linha, "#RRGGBB" ou "" fora do quadro) e a cor do meio, em maiúsculas.
  readonly property var cells: reader.sample(pixelX, pixelY, Theme.launcherLoupeGrid, Theme.launcherLoupeGrid)
  readonly property string hex: cells[(cells.length - 1) / 2] || ""

  // O canto da lupa: o centro dela fica no pixel lógico do ponto.
  readonly property real loupeX: Math.floor(pointX) - Theme.launcherLoupeSize / 2
  readonly property real loupeY: Math.floor(pointY) - Theme.launcherLoupeSize / 2
  // O valor vai 12 abaixo da lupa; sem espaço embaixo, 12 acima. Horizontalmente alinhado à lupa, mas sem sair do monitor.
  readonly property bool valueAbove: loupeY + Theme.launcherLoupeSize + Theme.launcherLoupeValueGap
      + Theme.launcherLoupeValueHeight > height
  readonly property real valueX: Math.max(0, Math.min(width - Theme.launcherLoupeValueWidth, loupeX))
  readonly property real valueY: valueAbove
      ? loupeY - Theme.launcherLoupeValueGap - Theme.launcherLoupeValueHeight
      : loupeY + Theme.launcherLoupeSize + Theme.launcherLoupeValueGap

  // O usuário pegou a cor do pixel do meio (clique), ou pediu para cancelar (Esc).
  signal picked(string hex)
  signal cancelRequested

  function clampPixel(value, size) {
    return Math.max(0, Math.min(Math.max(0, size - 1), value));
  }

  // O ponteiro andou: a lupa vai para onde ele está.
  function follow(x, y) {
    pointX = x;
    pointY = y;
  }

  // As setas: movem 1 px do quadro a partir de onde a lupa está, sem sair do quadro. O ponto vai para o meio do
  // pixel novo, para o `floor` não errar por arredondamento.
  function nudge(dx, dy) {
    if (!reader.ready)
      return;
    const x = clampPixel(pixelX + dx, reader.pixelWidth);
    const y = clampPixel(pixelY + dy, reader.pixelHeight);
    pointX = (x + 0.5) / ratioX;
    pointY = (y + 0.5) / ratioY;
  }

  // O clique: devolve a cor do pixel do meio.
  function pick() {
    if (hex !== "")
      picked(hex);
  }

  // Teclas da lupa: setas movem 1 px, Esc cancela. Ctrl, Alt e Meta passam. Devolve se tratou a tecla.
  function handleKey(key, modifiers) {
    if (modifiers & (Qt.ControlModifier | Qt.AltModifier | Qt.MetaModifier))
      return false;
    switch (key) {
    case Qt.Key_Left:
      nudge(-1, 0);
      return true;
    case Qt.Key_Right:
      nudge(1, 0);
      return true;
    case Qt.Key_Up:
      nudge(0, -1);
      return true;
    case Qt.Key_Down:
      nudge(0, 1);
      return true;
    case Qt.Key_Escape:
      cancelRequested();
      return true;
    }
    return false;
  }

  Launcher.PixelReader {
    id: reader
    source: root.source
    frameWidth: root.frameWidth
    frameHeight: root.frameHeight
    sourceReady: root.sourceReady
  }

  // A lupa: o círculo de 112 (sombra do vidro, fundo preto, grade recortada no círculo) com o traço `knob` de 2 por fora.
  Item {
    id: loupe
    visible: root.active && root.ready
    x: root.loupeX
    y: root.loupeY
    width: Theme.launcherLoupeSize
    height: Theme.launcherLoupeSize

    Shadow {
      anchors.fill: parent
      cornerRadius: width / 2
      shadows: Theme.glassShadows
    }

    ClippingRectangle {
      anchors.fill: parent
      radius: width / 2
      color: Theme.launcherLoupeBackdrop

      Repeater {
        model: root.cells

        delegate: Rectangle {
          required property string modelData
          required property int index
          x: (index % Theme.launcherLoupeGrid) * Theme.launcherLoupeCell
          y: Math.floor(index / Theme.launcherLoupeGrid) * Theme.launcherLoupeCell
          width: Theme.launcherLoupeCell
          height: Theme.launcherLoupeCell
          // Pixel de fora do quadro: sem cor, e o fundo da lupa aparece.
          color: modelData !== "" ? modelData : "transparent"
        }
      }

      // O pixel do meio, só com o traço `knob` de 2, por dentro do quadrado de 16.
      Rectangle {
        readonly property int middle: (Theme.launcherLoupeGrid - 1) / 2 * Theme.launcherLoupeCell
        x: middle
        y: middle
        width: Theme.launcherLoupeCell
        height: Theme.launcherLoupeCell
        color: "transparent"
        border.width: Theme.launcherLoupeRingWidth
        border.color: Theme.knob
      }
    }

    // O traço de fora, em volta dos 112 dos pixels.
    Rectangle {
      x: -Theme.launcherLoupeRingWidth
      y: -Theme.launcherLoupeRingWidth
      width: parent.width + 2 * Theme.launcherLoupeRingWidth
      height: parent.height + 2 * Theme.launcherLoupeRingWidth
      radius: width / 2
      color: "transparent"
      border.width: Theme.launcherLoupeRingWidth
      border.color: Theme.knob
      antialiasing: true
    }
  }

  // O valor sob o cursor: vidro de 112×28 (raio 14, sem o brilho do acento), a amostra de 12 em (8,8) e o HEX.
  GlassSurface {
    visible: loupe.visible
    x: root.valueX
    y: root.valueY
    width: Theme.launcherLoupeValueWidth
    height: Theme.launcherLoupeValueHeight
    radius: Theme.launcherLoupeValueRadius
    showGlow: false

    Rectangle {
      x: Theme.launcherLoupeSampleOffset
      y: Theme.launcherLoupeSampleOffset
      width: Theme.launcherLoupeSampleSize
      height: Theme.launcherLoupeSampleSize
      radius: width / 2
      color: root.hex !== "" ? root.hex : "transparent"
      antialiasing: true
    }

    Text {
      x: Theme.launcherLoupeHexX
      width: Theme.launcherLoupeHexWidth
      height: parent.height
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      text: root.hex
      color: Theme.text
      font.family: Theme.monoFontFamily
      font.weight: Font.Medium
      font.pixelSize: Theme.fontMonoCaption
      font.letterSpacing: 0
    }
  }

  // As dicas: vidro de altura 40 (raio 20, sem o brilho do acento), centrado na largura e a 16 da base. A largura é a
  // do conteúdo mais 16 de cada lado.
  GlassSurface {
    visible: loupe.visible
    x: Math.round((root.width - width) / 2)
    y: root.height - Theme.launcherLoupeTipsBottom - height
    width: tips.implicitWidth + 2 * Theme.launcherLoupeTipsPaddingX
    height: Theme.launcherLoupeTipsHeight
    radius: Theme.launcherLoupeTipsRadius
    showGlow: false

    Row {
      id: tips
      x: Theme.launcherLoupeTipsPaddingX
      y: Theme.launcherLoupeTipsPaddingY
      spacing: Theme.launcherLoupeTipsGap

      KeyCap { text: "Click" }
      TipText { text: "pick" }
      KeyCap { text: "Arrows" }
      TipText { text: "move 1 px" }
      KeyCap { text: "Esc" }
      TipText { text: "cancel" }
    }
  }

  // Texto de uma dica: Geist Medium 11 muted, centrado na altura da fila (a tecla tem 20).
  component TipText: Text {
    height: Theme.launcherLoupeTipsRowHeight
    verticalAlignment: Text.AlignVCenter
    color: Theme.muted
    font.family: Theme.fontFamily
    font.weight: Font.Medium
    font.pixelSize: Theme.fontCaption
    font.letterSpacing: 0
  }
}
