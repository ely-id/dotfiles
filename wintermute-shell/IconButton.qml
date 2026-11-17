import QtQuick
import QtQuick.Effects

// Botão de ícone Armitage (ficha 00): 32 px (raio 10, ícone 16) ou 40 px (raio 12, ícone 20).
// Estados: Repouso (sem fundo), Hover (hover 6%), Pressionado (pressed 10%),
// Selecionado (accent + ícone textOnAccent), Desativado (opacidade 0,4).
Item {
  id: root

  property int buttonSize: 32
  property alias iconSourceSize: glyph.sourceSize
  property alias mirrorIcon: glyph.mirror
  property url iconSource
  property string iconName: ""
  property real iconWidth: Math.max(width, height) >= 40 ? 20 : 16
  property real iconHeight: iconWidth
  property real radius: Math.max(width, height) >= 40 ? Theme.radiusIconButton40 : Theme.radiusIconButton32
  property bool checked: false
  property bool showBackground: true
  // Opcional para fixar o estado na demonstração: "" | "rest" | "hover" | "pressed" | "selected" | "disabled"
  property string visualState: ""
  property color iconColor: Theme.text
  property real restingOpacity: 1.0
  property bool animateGlyphOpacity: true
  property int hoverEasing: Easing.OutCubic
  property string accessibleName: ""

  readonly property bool isDisabledState: visualState === "disabled" || (visualState === "" && !enabled)
  readonly property bool isSelectedState: visualState === "selected" || (visualState === "" && checked)
  readonly property bool isPressedState: visualState === "pressed" || (visualState === "" && pointer.pressed && enabled)
  readonly property bool isHoveredState: visualState === "hover" || (visualState === "" && pointer.containsMouse && enabled)
  readonly property bool hovered: isHoveredState
  readonly property bool pressed: isPressedState

  property real glyphOpacity: isDisabledState ? 0.4 : (hovered || isSelectedState || isPressedState ? 1.0 : restingOpacity)
  readonly property color effectiveIconColor: isSelectedState ? Theme.textOnAccent : iconColor
  // Os ícones de icons/ são desenhados em branco puro e a cor vem sempre da colorização (P-64), então só
  // eles são colorizados: uma imagem de outra origem sairia chapada numa cor só. Decido pela pasta da
  // própria shell, porque `iconSource` aceita qualquer URL.
  readonly property bool isShellIcon: iconName !== ""
      || iconSource.toString().startsWith(Qt.resolvedUrl("icons/").toString())

  signal clicked

  implicitWidth: buttonSize
  implicitHeight: buttonSize

  Behavior on glyphOpacity {
    enabled: root.animateGlyphOpacity
    HoverAnimation { easing.type: root.hoverEasing }
  }

  Rectangle {
    id: background
    anchors.fill: parent
    visible: root.showBackground
    radius: root.radius
    antialiasing: true
    color: root.isDisabledState ? "transparent"
        : root.isSelectedState ? Theme.accent
        : root.isPressedState ? Theme.pressed
        : root.isHoveredState ? Theme.hover
        : "transparent"

    Behavior on color {
      ColorAnimation {
        duration: Theme.hoverDuration
        easing.type: Easing.OutCubic
      }
    }
  }

  Image {
    id: glyph
    x: Math.round((root.width - width) / 2)
    y: Math.round((root.height - height) / 2)
    width: root.iconWidth
    height: root.iconHeight
    source: root.iconName !== "" ? Qt.resolvedUrl("icons/" + root.iconName + ".svg") : root.iconSource
    sourceSize: Qt.size(Math.ceil(width * 2), Math.ceil(height * 2))
    fillMode: Image.PreserveAspectFit
    smooth: true
    antialiasing: true
    opacity: root.glyphOpacity
    layer.enabled: root.isShellIcon
    layer.effect: MultiEffect {
      colorization: 1
      colorizationColor: root.effectiveIconColor
    }
  }

  MouseArea {
    id: pointer
    anchors.fill: parent
    enabled: root.enabled && root.visualState === ""
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: root.clicked()
  }
}
