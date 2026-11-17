import QtQuick
import QtQuick.Effects
import Quickshell.Widgets
import "." as Notifications
import ".." as Shell

// Cartão de notificação (ficha 10), em três usos:
//  - item da central (`panelRow`): sem superfície própria, hover `hover` r10 com inset 4;
//  - toast / notificação sozinha: vidro Armitage r16, 288 (toast) ou 280 de largura;
//  - prévia no cartão da barra (`inlinePreview`): 140 de largura, r12, `control` + `border`.
// Anatomia: ícone 16 em (16,16), nome do app 13 muted em x 40, hora 11 muted à direita, corpo 13 Medium
// em y 40 (36 na prévia), largura = cartão − 32, entrelinha 16 e até 3 linhas.
// Altura = 40 + linhas × 16 + 16 (prévia: 36 + linhas × 16 + 20). No hover, o X de 24×24 aparece em
// (largura − 40, 13) e a hora recua 32 para dar lugar a ele.
Item {
  id: root
  property var service: Notifications.State
  property var notification: ({})
  property bool inlinePreview: false
  property bool showDivider: false
  property bool closeEnabled: true
  property bool extraHovered: false
  property bool panelRow: false
  signal activated
  signal dismissed
  readonly property bool hovered: pointer.containsMouse || closeButton.hovered || extraHovered
  readonly property bool closeShown: closeEnabled && hovered && !inlinePreview
  readonly property alias surface: surface
  readonly property int padding: inlinePreview ? 12 : 16
  readonly property int headerTop: inlinePreview ? 12 : 16
  readonly property int lineHeight: 16
  readonly property int bodyTop: inlinePreview ? 36 : 40
  readonly property int bodyLines: Math.max(1, Math.min(3,
      Math.round(bodyText.implicitHeight / lineHeight)))
  readonly property real targetHeight: inlinePreview
      ? bodyTop + bodyLines * lineHeight + 20
      : bodyTop + bodyLines * lineHeight + 16 + (showDivider ? 1 : 0)
  property real animatedHeight: targetHeight
  implicitWidth: Notifications.Style.interactiveWidth
  implicitHeight: animatedHeight
  Behavior on animatedHeight { Shell.Motion { duration: Notifications.Style.panelDuration } }

  Rectangle {
    id: surface
    width: root.width
    height: root.height
    radius: root.inlinePreview ? 12 : Notifications.Style.radius
    color: root.inlinePreview
        ? (root.hovered ? Shell.Theme.pressed : Shell.Theme.control) : "transparent"
    border.width: root.inlinePreview ? 1 : 0
    border.color: Shell.Theme.border
    antialiasing: true
    Shell.GradientFill {
      visible: !root.inlinePreview && !root.panelRow
      radius: surface.radius
    }
    Shell.PanelBorder {
      visible: !root.inlinePreview && !root.panelRow
      radius: surface.radius
    }
    Behavior on color {
      enabled: root.inlinePreview
      ColorAnimation { duration: Shell.Theme.hoverDuration; easing.type: Easing.OutCubic }
    }
  }

  Rectangle {
    x: 4
    y: 4
    width: root.width - 8
    height: Math.max(0, root.height - 8)
    radius: 10
    color: Notifications.Style.hover
    opacity: !root.inlinePreview && root.hovered ? 1 : 0
    antialiasing: true
    Behavior on opacity { Shell.HoverAnimation {} }
  }

  IconImage {
    visible: !root.inlinePreview
    x: 16
    y: 16
    implicitSize: width
    width: 16
    height: width
    source: root.service.iconSource(root.notification || ({}))
    asynchronous: true
    smooth: true
    // A notificação da própria shell traz um ícone de icons/ pelo `iconName` e esse é colorizado (P-64);
    // o ícone do aplicativo que enviou a notificação mantém as próprias cores. A State.iconSource decide
    // pelo mesmo campo.
    layer.enabled: !!(root.notification && root.notification.iconName)
    layer.effect: MultiEffect { colorization: 1; colorizationColor: Shell.Theme.text }
  }

  Text {
    id: timeText
    x: root.width - root.padding - width - (root.closeShown ? 32 : 0)
    y: root.headerTop
    height: 16
    text: root.notification ? root.service.relativeTimeLabel(root.notification.timestamp) : ""
    color: Shell.Theme.muted
    font.family: Shell.Theme.fontFamily
    font.weight: Font.Medium
    font.pixelSize: Shell.Theme.fontCaption
    font.letterSpacing: 0
    verticalAlignment: Text.AlignVCenter
    Behavior on x { Shell.HoverAnimation {} }
  }

  Text {
    x: root.inlinePreview ? root.padding : 40
    y: root.headerTop
    width: Math.max(0, timeText.x - x - 8)
    height: 16
    text: root.service.title(root.notification)
    color: Shell.Theme.muted
    elide: Text.ElideRight
    font.family: Shell.Theme.fontFamily
    font.weight: Font.Medium
    font.pixelSize: root.inlinePreview ? Shell.Theme.fontCaption : Shell.Theme.fontBody
    font.letterSpacing: 0
    verticalAlignment: Text.AlignVCenter
  }

  Text {
    id: bodyText
    x: root.padding
    y: root.bodyTop
    width: root.width - root.padding * 2
    height: root.bodyLines * root.lineHeight
    text: root.service.message(root.notification)
    color: Shell.Theme.text
    wrapMode: Text.Wrap
    maximumLineCount: 3
    elide: Text.ElideRight
    font.family: Shell.Theme.fontFamily
    font.weight: Font.Medium
    font.pixelSize: Shell.Theme.fontBody
    font.letterSpacing: 0
    lineHeightMode: Text.FixedHeight
    lineHeight: root.lineHeight
  }

  Rectangle {
    x: 16
    y: root.height - 1
    width: root.width - 32
    height: 1
    color: Notifications.Style.divider
    visible: root.showDivider
  }

  MouseArea {
    id: pointer
    width: root.width
    height: root.height
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: root.activated()
  }

  Notifications.CloseButton {
    id: closeButton
    x: root.width - 40
    y: 13
    z: 2
    opacity: root.closeShown ? 1 : 0
    visible: opacity > 0.001
    enabled: opacity > 0.5
    Behavior on opacity { Shell.HoverAnimation {} }
    onClicked: root.dismissed()
  }
}
