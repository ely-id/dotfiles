import QtQuick
import QtQuick.Effects

// Linha de lista Armitage (ficha 00):
// 300×44, raio 12. Ícone 20 em (12,12); título 13 Medium em x 40;
// detalhe 11 Medium à direita; ícone final 16 em (272,14).
// Estados: repouso (vazio), hover (hover 6%), pressionado (pressed 10%),
// selecionada (accentSubtle, detalhe em accentText).
Item {
  id: root

  property string title: ""
  property string detail: ""
  property bool showDetail: detail !== ""
  property string iconName: ""
  property url iconSource: ""
  property string trailingIconName: ""
  property url trailingIconSource: ""
  property bool showTrailingIcon: trailingIconName !== "" || trailingIconSource.toString() !== ""
  property bool selected: false
  property bool interactive: true
  property real labelRight: showDetail ? (showTrailingIcon ? 172 : 192) : (showTrailingIcon ? 264 : 288)
  property real labelGap: 8
  property int labelSize: Theme.fontBody
  property real contentOpacity: 1.0
  property color titleColor: Theme.text
  property Component leading: null
  property Component trailing: null
  // Opcional para fixar o estado na demonstração: "" | "rest" | "hover" | "pressed" | "selected"
  property string visualState: ""

  // Os ícones de icons/ são desenhados em branco puro e a cor vem da colorização (P-64). Só eles são
  // colorizados: uma imagem de outra origem passada por `iconSource` sairia chapada numa cor só.
  readonly property bool isShellIcon: iconName !== ""
      || iconSource.toString().startsWith(Qt.resolvedUrl("icons/").toString())

  readonly property bool isSelectedState: visualState === "selected" || (visualState === "" && selected)
  readonly property bool isPressedState: visualState === "pressed" || (visualState === "" && pointer.pressed && interactive)
  readonly property bool isHoverState: visualState === "hover" || (visualState === "" && hover.hovered && interactive)
  readonly property bool hovered: isHoverState
  readonly property bool pressed: isPressedState

  signal clicked

  implicitWidth: Theme.panelRowWidth
  implicitHeight: Theme.panelRowHeight

  Rectangle {
    anchors.fill: parent
    radius: Theme.radiusRow
    color: root.isSelectedState ? Theme.accentSubtle
        : root.isPressedState ? Theme.pressed
        : root.isHoverState ? Theme.hover
        : "transparent"
    antialiasing: true

    Behavior on color {
      ColorAnimation {
        duration: Theme.controlDuration
        easing.type: Easing.OutCubic
      }
    }
  }

  Loader {
    x: 12
    y: 12
    width: 20
    height: 20
    active: root.leading !== null
    sourceComponent: root.leading
    opacity: root.contentOpacity
  }

  Image {
    x: 12
    y: 12
    width: 20
    height: 20
    visible: root.leading === null && (root.iconName !== "" || root.iconSource.toString() !== "")
    source: root.iconName !== "" ? Qt.resolvedUrl("icons/" + root.iconName + ".svg") : root.iconSource
    sourceSize: Qt.size(40, 40)
    fillMode: Image.PreserveAspectFit
    smooth: true
    antialiasing: true
    opacity: root.contentOpacity
    layer.enabled: root.isShellIcon
    layer.effect: MultiEffect { colorization: 1; colorizationColor: Theme.text }
  }

  Text {
    x: 32 + root.labelGap
    anchors.verticalCenter: parent.verticalCenter
    width: Math.max(0, root.labelRight - x)
    elide: Text.ElideRight
    text: root.title
    color: root.titleColor
    opacity: root.contentOpacity
    font.family: Theme.fontFamily
    font.weight: Font.Medium
    font.pixelSize: root.labelSize
    font.letterSpacing: 0
  }

  Text {
    x: (root.showTrailingIcon ? 268 : 288) - width
    anchors.verticalCenter: parent.verticalCenter
    width: 92
    visible: root.trailing === null && root.showDetail
    horizontalAlignment: Text.AlignRight
    elide: Text.ElideRight
    text: root.detail
    color: root.isSelectedState ? Theme.accentText : Theme.muted
    opacity: root.contentOpacity
    font.family: Theme.fontFamily
    font.weight: Font.Medium
    font.pixelSize: Theme.fontCaption
    font.letterSpacing: 0
  }

  Image {
    x: 272
    y: 14
    width: 16
    height: 16
    visible: root.trailing === null && root.showTrailingIcon
    source: root.trailingIconName !== "" ? Qt.resolvedUrl("icons/" + root.trailingIconName + ".svg") : root.trailingIconSource
    sourceSize: Qt.size(32, 32)
    fillMode: Image.PreserveAspectFit
    smooth: true
    antialiasing: true
    opacity: root.contentOpacity
    layer.enabled: true
    layer.effect: MultiEffect {
      colorization: 1
      colorizationColor: Theme.muted
    }
  }

  Loader {
    anchors.fill: parent
    active: root.trailing !== null
    sourceComponent: root.trailing
  }

  MouseArea {
    id: pointer
    anchors.fill: parent
    enabled: root.interactive && root.visualState === ""
    cursorShape: Qt.PointingHandCursor
    onClicked: root.clicked()
  }

  HoverHandler {
    id: hover
    enabled: root.interactive && root.visualState === ""
    cursorShape: Qt.PointingHandCursor
  }
}
