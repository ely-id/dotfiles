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
