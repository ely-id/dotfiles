pragma ComponentBehavior: Bound
import QtQuick
import "." as Notifications
import ".." as Shell

// Painel da central de notificações (ficha 10), 280 de largura. Com 2 ou mais notificações é uma
// lista de vidro r16 com cabeçalho de 60 ("N notificações" em Serif 20 em (16,16) e "Limpar tudo"
// muted à direita), divisor de largura total em y 60 e respiro de 22 embaixo; com 1, é só o cartão.
// `service` é o estado das notificações; a vitrine troca por um fictício.
Item {
  id: root

  property var service: Notifications.State
  property var items: service.historyNotifications
  property real reveal: 1
  readonly property int itemCount: items.length
  readonly property bool listMode: itemCount >= 2
  property real measuredListHeight: 0
  property int measuredItemCount: -1
  readonly property real effectiveListHeight:
      measuredItemCount === itemCount && measuredListHeight > 0
      ? measuredListHeight : itemCount * Notifications.Style.rowHeight
  readonly property real panelHeight: listMode
      ? Math.min(Notifications.Style.panelHeaderHeight + effectiveListHeight
                 + Notifications.Style.panelBottomPadding,
                 Notifications.Style.panelMaxHeight)
      : effectiveListHeight
  readonly property alias background: panelBackground

  width: Notifications.Style.panelWidth
  height: panelHeight
  opacity: reveal

  Shell.Shadow {
    anchors.fill: panelBackground
    cornerRadius: panelBackground.radius
    shadows: Shell.Theme.glassShadows
    visible: root.itemCount > 0
  }

  Rectangle {
    id: panelBackground
    width: root.width
    height: root.panelHeight
    radius: Notifications.Style.radius
    color: "transparent"
    antialiasing: true
    visible: root.listMode
    Shell.GradientFill { radius: panelBackground.radius }
    Shell.PanelBorder { radius: panelBackground.radius }
  }

  Text {
    x: Notifications.Style.contentPadding
    y: Notifications.Style.contentPadding
    height: 28
    text: root.itemCount + " notificações"
    color: Shell.Theme.text
    font.family: Shell.Theme.titleFontFamily
    font.weight: Font.Normal
    font.pixelSize: Shell.Theme.fontPanelTitle
    font.letterSpacing: 0
    visible: root.listMode
    z: 3
  }

  Text {
    id: clearAll
    x: root.width - Notifications.Style.contentPadding - width
    y: 21
    height: 19
    text: "Limpar tudo"
    color: clearPointer.containsMouse ? Shell.Theme.text : Shell.Theme.muted
    font.family: Shell.Theme.fontFamily
    font.weight: Font.Medium
    font.pixelSize: Shell.Theme.fontBody
    font.letterSpacing: 0
    visible: root.listMode
    z: 4

    Behavior on color { ColorAnimation { duration: Shell.Theme.hoverDuration } }

    MouseArea {
      id: clearPointer
      anchors.fill: parent
      anchors.margins: -8
      hoverEnabled: true
      acceptedButtons: Qt.LeftButton
      cursorShape: Qt.PointingHandCursor
      onClicked: root.service.clearAll()
    }
  }

  Rectangle {
    x: 0
    y: Notifications.Style.panelHeaderHeight
    width: root.width
    height: 1
    color: Notifications.Style.divider
    visible: root.listMode
    z: 3
  }

  Item {
    id: listClip
    y: root.listMode ? Notifications.Style.panelHeaderHeight : 0
    width: root.width
    height: root.panelHeight - y - (root.listMode ? Notifications.Style.panelBottomPadding : 0)
    clip: true
    z: 3

    ListView {
      id: notificationList
      clip: true
      boundsBehavior: Flickable.StopAtBounds
      Shell.ScrollWheel { view: notificationList }
      width: root.width
      height: listClip.height
      model: root.items
      interactive: contentHeight > height
      onContentHeightChanged: {
        if (contentHeight > 0 || root.itemCount === 0) {
          root.measuredListHeight = contentHeight;
          root.measuredItemCount = root.itemCount;
        }
      }

      delegate: Notifications.Card {
        id: row
        required property var modelData
        required property int index

        service: root.service
        width: root.width
        height: implicitHeight
        notification: modelData
        showDivider: root.listMode && index < root.itemCount - 1
        panelRow: root.listMode
        onActivated: root.service.activate(modelData)
        onDismissed: root.service.remove(modelData)
      }
    }
  }
}
