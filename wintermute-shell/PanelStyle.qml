pragma Singleton
import QtQuick

QtObject {
  readonly property color surface: Theme.colors.surface
  readonly property color panelSurface: Theme.colors.panelSurface
  readonly property Gradient panelGradient: Theme.colors.panelGradient
  readonly property Gradient modalGradient: Theme.colors.modalGradient
  readonly property color modalBorder: Theme.colors.modalBorder
  readonly property color controlFill: Theme.colors.controlFill
  readonly property color rowHover: Theme.colors.rowHover
  readonly property color sliderTrack: Theme.colors.sliderTrack
  readonly property color controlHover: Theme.colors.controlHover
  readonly property color outline: Theme.colors.outline
  readonly property color drawerRowHover: Theme.colors.drawerRowHover
  readonly property color drawerSliderTrack: Theme.colors.drawerSliderTrack
  readonly property color selectFill: Theme.colors.selectFill
  readonly property color menuSurface: Theme.colors.menuSurface
  readonly property color menuBorder: Theme.colors.menuBorder
  readonly property color menuRowHover: Theme.colors.menuRowHover
  readonly property real drawerToggleAlpha: Theme.colors.drawerToggleAlpha
  readonly property color accent: Theme.colors.accent
  readonly property color accentText: "#4F3D64"
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
  readonly property int rowHeight: 44
  readonly property int radius: 16
  readonly property int rowRadius: 12
  readonly property int pageDuration: 350
  readonly property int openDuration: 220
  readonly property int controlDuration: 120
  readonly property real blurRevealOpacity: 0.25
  readonly property var frontShadows: Theme.glassShadows
  readonly property var controlShadows: Theme.glassShadows
  readonly property int audioRowHeight: 40
  readonly property int hoverCollapseDelay: 76
}
