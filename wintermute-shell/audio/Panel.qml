import QtQuick
import Quickshell
import "." as Audio
import ".."

// Pop-up de som (ficha 07): um cartão de 316 com o botão de fechar pendurado em (296, 2) e folga
// de 22 em cima, como a pilha sem verso. `service` é o estado de áudio; a vitrine troca por um fictício.
Item {
  id: root

  property var service: Audio.State
  property bool opened: false
  property alias selectedTab: soundCard.selectedTab
  readonly property int closeAllDuration: 200
  readonly property Region blurRegion: Region {
    item: root.opened && root.opacity > PanelStyle.blurRevealOpacity ? soundCard : null
    radius: PanelStyle.radius
  }
  onXChanged: blurRegion.changed()
  onYChanged: blurRegion.changed()
  onScaleChanged: blurRegion.changed()

  width: PanelStyle.stackWidth
  height: soundCard.implicitHeight + PanelStyle.frontInsetSingle
  visible: opened || closeCleanup.running
  opacity: opened ? 1 : 0
  scale: opened ? 1 : 0.9
  transformOrigin: Item.BottomLeft

  Behavior on height {
    NumberAnimation {
      duration: Theme.pageDuration
      easing.type: Easing.Bezier
      easing.bezierCurve: [0.19, 1, 0.22, 1, 1, 1]
    }
  }

  Behavior on opacity {
    NumberAnimation {
      duration: root.opened ? PanelStyle.openDuration
                            : root.closeAllDuration
      easing.type: root.opened ? Easing.InOutCubic : Easing.Bezier
      easing.bezierCurve: [0.19, 1, 0.22, 1, 1, 1]
    }
  }

  Behavior on scale {
    NumberAnimation {
      duration: root.opened ? PanelStyle.openDuration
                            : root.closeAllDuration
      easing.type: root.opened ? Easing.InOutCubic : Easing.Bezier
      easing.bezierCurve: [0.19, 1, 0.22, 1, 1, 1]
    }
  }

  Shadow {
    anchors.fill: soundCard
    cornerRadius: Theme.radiusPanel
    shadows: Theme.glassShadows
  }

  Devices {
    id: soundCard
    y: PanelStyle.frontInsetSingle
    width: PanelStyle.width
    height: root.height - y
    service: root.service
    interactive: root.opened
  }

  PanelCloseButton {
    x: PanelStyle.closeButtonX
    y: PanelStyle.frontInsetSingle - PanelStyle.closeButtonOverhang
    enabled: root.opened
    onClicked: root.closeAll()
  }

  Timer {
    id: closeCleanup
    interval: root.closeAllDuration
  }

  function open() {
    closeCleanup.stop();
    opened = true;
    service.refreshPorts();
  }

  function closeAll() {
    if (!opened)
      return;
    opened = false;
    closeCleanup.restart();
  }

}
