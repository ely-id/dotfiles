pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import "." as Notifications
import ".." as Shell

// Central de notificações em primeiro plano. A superfície de tela cheia dispensa o painel com um
// clique fora; o painel (notifications/Panel.qml, 280 de largura) fica alinhado à borda viva da barra,
// aberta ou recolhida.
PanelWindow {
  id: root

  required property var bar

  readonly property string outputName: bar && bar.screen ? bar.screen.name : ""
  readonly property bool requested: Notifications.State.panelOpen
      && Notifications.State.panelOutputName === outputName
  property real reveal: requested ? 1 : 0
  readonly property real panelHeight: panel.panelHeight
  readonly property real panelLeft: Shell.Theme.sidebarOuterMargin + bar.cardWidth
      + Notifications.Style.desktopMargin
  readonly property real panelTop: panelHeight >= Notifications.Style.panelMaxHeight
      ? Notifications.Style.desktopMargin
      : Math.max(Notifications.Style.desktopMargin,
                 Math.min(bar.notificationCardCenterY - panelHeight / 2,
                          height - Notifications.Style.desktopMargin - panelHeight))

  screen: bar.screen
  visible: requested || reveal > 0.001
  color: "transparent"
  BackgroundEffect.blurRegion: Shell.Theme.translucent ? panelBlur : null
  Region {
    id: panelBlur
    item: root.requested && root.reveal > Shell.PanelStyle.blurRevealOpacity ? panel.background : null
    radius: panel.background.radius
  }

  anchors {
    left: true
    right: true
    top: true
    bottom: true
  }

  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.namespace: "pond-notification-center-"
      + (outputName || "unknown")
  WlrLayershell.exclusionMode: ExclusionMode.Ignore

  mask: Region {
    intersection: Intersection.Subtract
    regions: [root.bar.mask]
  }

  Behavior on reveal { Shell.Motion { duration: Notifications.Style.panelDuration } }

  MouseArea {
    anchors.fill: parent
    z: 1
    acceptedButtons: Qt.LeftButton
    onClicked: Notifications.State.closePanel()
  }

  MouseArea {
    x: root.panelLeft - (1 - root.reveal) * 4
    y: root.panelTop
    width: panel.width
    height: root.panelHeight
    z: 2
    acceptedButtons: Qt.LeftButton
    onClicked: mouse => mouse.accepted = true
  }

  Notifications.Panel {
    id: panel
    x: root.panelLeft - (1 - root.reveal) * 4
    y: root.panelTop
    reveal: root.reveal
    z: 3
  }
}
