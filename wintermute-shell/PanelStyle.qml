pragma Singleton
import QtQuick

QtObject {
  readonly property color rowHover: Theme.colors.rowHover
  readonly property int width: 316
  // Pilha de cartões (ficha 05, board 13:13604; vale também para Bluetooth e Som).
  // Cartão da frente 316; carta de trás 284 em (16, 0), raio 16, conteúdo a 50% com
  // blur 8. A folga acima da frente é 22 sem verso e 32 com verso; o botão fechar de
  // 40×40 fica pendurado em (296, folga − 20), então a pilha inteira tem 336 de largura.
  readonly property int stackWidth: 336
  readonly property int frontInsetSingle: 22
  readonly property int frontInsetStacked: 32
  readonly property int backWidth: 284
  readonly property int backOffsetX: 16
  readonly property int backOffsetY: 0
  readonly property real backContentOpacity: 0.5
  readonly property real backContentBlur: 8
  readonly property int closeButtonX: 296
  readonly property int closeButtonOverhang: 20
  readonly property real headerDividerX: 20
  readonly property real headerDividerY: 60
  readonly property real headerDividerWidth: 276
  readonly property int fieldWidth: 276
  readonly property int fieldHeight: 44
  readonly property int rowWidth: 300
  readonly property int radius: 16
  readonly property int pageDuration: 350
  readonly property int openDuration: 220
  readonly property int controlDuration: 120
  readonly property real blurRevealOpacity: 0.25
  readonly property var frontShadows: Theme.glassShadows
  readonly property var controlShadows: Theme.glassShadows
}
