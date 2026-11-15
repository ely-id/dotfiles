pragma Singleton
import QtQuick
import ".." as Shell

// Medidas e cores das notificações (ficha 10). Movimento de 180 ms.
QtObject {
  readonly property int panelWidth: 280          // central
  readonly property int interactiveWidth: 288    // toast
  readonly property int rowHeight: 88            // estimativa antes de medir a lista
  readonly property int panelHeaderHeight: 60
  readonly property int panelBottomPadding: 22   // respiro embaixo da lista, medido no print (316 com 3 itens)
  readonly property int panelMaxHeight: 647
  readonly property int desktopMargin: 10
  readonly property int radius: 16
  readonly property int contentPadding: 16
  readonly property int summaryIconSize: 16
  readonly property int closeSize: 24
  readonly property int closeIconSize: 16
  readonly property color hover: Shell.Theme.hover
  readonly property color closeFill: Shell.Theme.pressed
  readonly property color closeHover: Shell.Theme.borderStrong
  readonly property color foreground: Shell.Theme.text
  readonly property color divider: Shell.Theme.border
  readonly property real secondaryIconOpacity: 0.4
  readonly property int panelDuration: Shell.Theme.notificationDuration
}
