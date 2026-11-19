pragma ComponentBehavior: Bound

import QtQuick
import "Windows.js" as Win
import ".."

// O alvo do modo Window ou do modo Screen da captura (ficha 17, board 13:19344, estado "Modo janela" 13:19441): o anel no acento e a
// pílula com o nome e o tamanho. Fica sobre a peça (Capture.qml) e usa as coordenadas dela.
//
// No modo Window o alvo é a janela sob o ponteiro, e o anel (13:19458) sai 2 para fora dela em cada lado: 2 px, raio 14, a borda
// toda por fora (a janela de 320×300 em (360,56) tem o anel de 324×304 em (358,54)). No modo Screen (composição, A-05) o alvo é o
// monitor inteiro, com o anel de 2 por dentro da borda e sem raio. A pílula (13:19459) é a mesma nos dois: o vidro pequeno, alinhada
// à esquerda do alvo e terminando 8 acima do anel, ou, sem lugar em cima, por dentro, a 8 do canto de cima à esquerda (Windows.pillPlace).
//
// O texto é `Nome · 320 × 300`. O nome comprido é cortado com reticências antes de a pílula passar da largura do alvo, e o tamanho fica
// inteiro. O tamanho é em pixels do monitor: `ratioX` e `ratioY` são quadro / tela, 1 sem escala.
Item {
  id: root

  // O retângulo do alvo em pixels lógicos da peça: { x, y, width, height }, e o nome que a pílula mostra.
  property var rect: ({ x: 0, y: 0, width: 0, height: 0 })
  property string name: ""
  // "window": o anel por fora do retângulo. "screen": o anel por dentro, sem raio.
  property string kind: "window"
  // A largura da peça: a pílula não sai dela na horizontal.
  property real monitorWidth: 0
  property real ratioX: 1
  property real ratioY: 1

  readonly property bool outside: kind === "window"
  readonly property int ringWidth: Theme.captureTargetRingWidth
  readonly property int pillPadding: Theme.captureTargetPillPaddingX

  // A parte fixa do texto, e o nome cortado para a pílula caber na largura do alvo.
  readonly property string suffix: Win.pillSuffix(rect, ratioX, ratioY)
  readonly property string shownText: nameMetrics.elidedText + suffix

  // Medi pelo avanço do texto (TextMetrics.advanceWidth) e não pela `width`; o porquê está no comentário de Theme.captureTargetPillPaddingX.
  TextMetrics {
    id: suffixMetrics
    font.family: Theme.monoFontFamily
    font.weight: Font.Medium
    font.pixelSize: Theme.fontMonoCaption
    font.letterSpacing: 0
    text: root.suffix
  }

  TextMetrics {
    id: nameMetrics
    font.family: Theme.monoFontFamily
    font.weight: Font.Medium
    font.pixelSize: Theme.fontMonoCaption
    font.letterSpacing: 0
    text: root.name
    elide: Text.ElideRight
    elideWidth: Math.max(0, root.rect.width - 2 * root.pillPadding - suffixMetrics.advanceWidth)
  }

  TextMetrics {
    id: shownMetrics
    font.family: Theme.monoFontFamily
    font.weight: Font.Medium
    font.pixelSize: Theme.fontMonoCaption
    font.letterSpacing: 0
    text: root.shownText
  }

  readonly property real pillWidth: Math.min(root.rect.width, Math.ceil(shownMetrics.advanceWidth) + 2 * pillPadding)
  readonly property var pillSpot: Win.pillPlace(rect, pillWidth, Theme.captureTargetPillHeight, Theme.captureTargetPillGap,
      outside ? ringWidth : 0, monitorWidth)

  // O anel. Na janela o retângulo cresce `ringWidth` para cada lado e a borda fica toda por fora dela; no monitor ele é o próprio
  // monitor, com a borda por dentro.
  Rectangle {
    x: root.rect.x - (root.outside ? root.ringWidth : 0)
    y: root.rect.y - (root.outside ? root.ringWidth : 0)
    width: root.rect.width + (root.outside ? 2 * root.ringWidth : 0)
    height: root.rect.height + (root.outside ? 2 * root.ringWidth : 0)
    radius: root.outside ? Theme.captureWindowRingRadius : Theme.captureScreenRingRadius
    color: "transparent"
    border.width: root.ringWidth
    border.color: Theme.accent
    antialiasing: true
  }

  // A pílula: a mesma construção das pílulas de coordenadas e de tamanho. Não engole o clique.
  GlassSurface {
    x: root.pillSpot.x
    y: root.pillSpot.y
    width: root.pillWidth
    height: Theme.captureTargetPillHeight
    radius: Theme.captureTargetPillRadius
    showGlow: false

    Text {
      anchors.fill: parent
      leftPadding: root.pillPadding
      rightPadding: root.pillPadding
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      elide: Text.ElideRight
      text: root.shownText
      color: Theme.text
      font.family: Theme.monoFontFamily
      font.weight: Font.Medium
      font.pixelSize: Theme.fontMonoCaption
      font.letterSpacing: 0
    }
  }
}
