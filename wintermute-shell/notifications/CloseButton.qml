import QtQuick
import "." as Notifications
import ".." as Shell

// Botão fechar das notificações (ficha 10): 24×24 r6 `pressed` com X de 16; no hover vira
// `borderStrong`. A variante compacta (16×16) fica na borda da prévia do cartão da barra.
Rectangle {
  id: root

  signal clicked
  property bool compact: false
  readonly property bool hovered: pointer.containsMouse

  implicitWidth: compact ? 16 : Notifications.Style.closeSize
  implicitHeight: implicitWidth
  radius: compact ? 4 : 6
  color: compact ? Shell.Theme.borderMuted : pointer.containsMouse
      ? Notifications.Style.closeHover : Notifications.Style.closeFill
  antialiasing: true

  Behavior on color {
    enabled: !root.compact
    ColorAnimation {
      duration: Shell.Theme.hoverDuration
      easing.type: Easing.OutCubic
    }
  }

  Image {
    anchors.centerIn: parent
    width: root.compact ? 12 : Notifications.Style.closeIconSize
    height: width
    source: Qt.resolvedUrl("../icons/x.svg")
    sourceSize: Qt.size(width * 2, height * 2)
    fillMode: Image.PreserveAspectFit
    smooth: true
    antialiasing: true
  }

  MouseArea {
    id: pointer
    anchors.fill: parent
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton
    cursorShape: Qt.PointingHandCursor
    onClicked: root.clicked()
  }
}
