import QtQuick
import Quickshell
import ".." as Shell
import "../battery" as Battery

// Cartão de relógio + bateria da barra lateral (ficha 04):
// Aberto: 156×76 (116 com aviso de bateria baixa, 56 sem bateria), raio 16.
//   Hora Geist Serif 34 em (12,8) 88×40 sem AM/PM; chip da data 40×40 r8 em (104,8)
//   borderStrong; trilho da bateria 132×4 r2 em (12,60) track + carga text 80%.
// Recolhido: 48×156 (112 sem bateria), raio 16.
//   Hora em duas linhas Geist Mono Regular 13 (y 8 / 28), divisor em y 56,
//   dia abreviado 2 letras muted (y 64) + dia (y 84), divisor em y 112,
//   bateria 16 numa caixa 32×32 r8 em (8,116).
Shell.Card {
  id: root

  property real collapseProgress: 0
  property date previewTime: systemClock.date
  // Permite fixar hover na hora ou simular bateria para demonstração visual
  property bool forceTimeHovered: false
  property bool previewBattery: false
  property real previewBatteryPercentage: 76
  signal clicked
  signal batteryClicked

  readonly property bool battery: previewBattery || Battery.State.present
  readonly property bool low: !previewBattery && Battery.State.low
  readonly property real effectiveBatteryPercentage: previewBattery
      ? previewBatteryPercentage : Battery.State.percentage
  readonly property color batteryFillColor: (!previewBattery && Battery.State.charging) ? Shell.Theme.success
      : low ? Shell.Theme.danger : Shell.Theme.text
  readonly property color batteryIconColor: (!previewBattery && Battery.State.charging) ? Shell.Theme.successText
      : low ? Shell.Theme.dangerText : Shell.Theme.text
  readonly property var weekdaysShort: ["dom", "seg", "ter", "qua", "qui", "sex", "sáb"]
  readonly property var weekdaysCompact: ["DM", "SG", "TR", "QA", "QI", "SX", "SB"]

  Accessible.role: Accessible.Button
  Accessible.name: "Abrir calendário"
  Accessible.onPressAction: clicked()

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: root.clicked()
  }

  implicitWidth: Shell.Theme.lerp(Shell.Theme.sidebarCardExpandedWidth,
      Shell.Theme.sidebarCardCollapsedWidth, Shell.Theme.collapseWidth(collapseProgress))
  implicitHeight: Shell.Theme.lerp(
      battery ? (low ? 116 : Shell.Theme.clockExpandedHeight) : 56,
      battery ? Shell.Theme.clockCollapsedHeight : 112,
      Shell.Theme.collapseHeight(collapseProgress))
  radius: Shell.Theme.sidebarCardRadius

  readonly property real expandedOpacity: collapseProgress < 0.56 ? 1 : 0
  readonly property real collapsedProgress: collapseProgress >= 0.56 ? 1 : 0

  SystemClock {
    id: systemClock
    precision: SystemClock.Minutes
  }

  Item {
    id: expandedContent
    width: Shell.Theme.sidebarCardExpandedWidth
    height: root.height
    opacity: root.expandedOpacity
    visible: opacity > 0.001

    Rectangle {
      x: 4
      y: 4
      width: 148
      height: 50
      radius: 8
      color: Shell.Theme.hover
      opacity: (timeHover.hovered || root.forceTimeHovered) ? 1 : 0
      Behavior on opacity { Shell.HoverAnimation {} }
      HoverHandler { id: timeHover }
    }

    Text {
      id: timeText
      x: 12
      y: 8
      width: 88
      height: 40
      text: Qt.formatTime(root.previewTime, "h:mm")
      color: Shell.Theme.text
      font.family: Shell.Theme.titleFontFamily
      font.weight: Font.Normal
      font.pixelSize: Shell.Theme.clockTimeSize
      font.letterSpacing: 0
      verticalAlignment: Text.AlignVCenter
      horizontalAlignment: Text.AlignLeft
    }

    Rectangle {
      id: dateBox
      x: 104
      y: 8
      width: Shell.Theme.dateChipSize
      height: Shell.Theme.dateChipSize
      radius: Shell.Theme.dateChipRadius
      color: "transparent"
      border.width: 1
      border.color: Shell.Theme.borderStrong
      antialiasing: true

      Text {
        x: 0
        y: 4
        width: parent.width
        height: 16
        text: root.weekdaysShort[root.previewTime.getDay()] || "sex"
        color: Shell.Theme.muted
        font.family: Shell.Theme.fontFamily
        font.weight: Font.Medium
        font.pixelSize: Shell.Theme.fontCaption
        font.letterSpacing: 0
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
      }

      Text {
        x: 0
        y: 20
        width: parent.width
        height: 16
        text: String(root.previewTime.getDate())
        color: Shell.Theme.text
        font.family: Shell.Theme.fontFamily
        font.weight: Font.Medium
        font.pixelSize: Shell.Theme.fontBody
        font.letterSpacing: 0
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
      }
    }

    Rectangle {
      x: 4
      y: 54
      width: 148
      height: batteryArea.height
      radius: 8
      color: root.low ? Qt.alpha(Shell.Theme.danger, 0.12) : Shell.Theme.hover
      visible: batteryArea.containsMouse
    }

    Rectangle {
      x: 12
      y: 60
      width: Shell.Theme.batteryTrackWidth
      height: Shell.Theme.batteryTrackHeight
      radius: 2
      visible: root.battery
      color: Shell.Theme.track
      antialiasing: true
    }

    Rectangle {
      id: batteryFill
      x: 12
      y: 60
      width: Math.round(Shell.Theme.batteryTrackWidth * root.effectiveBatteryPercentage / 100)
      height: Shell.Theme.batteryTrackHeight
      radius: 2
      visible: root.battery && width > 0
      color: root.batteryFillColor
      opacity: root.low || (!root.previewBattery && Battery.State.charging) || batteryArea.containsMouse ? 1.0 : 0.8
      antialiasing: true
    }

    Rectangle {
      x: Math.max(12, Math.min(144 - width, batteryFill.x + batteryFill.width - width))
      y: 54
      width: Math.ceil(badgeText.implicitWidth) + 8
      height: 16
      radius: 8
      color: root.batteryFillColor
      visible: batteryArea.containsMouse

      Text {
        id: badgeText
        anchors.centerIn: parent
        text: Math.round(root.effectiveBatteryPercentage) + "%"
        color: Shell.Theme.textOnAccent
        font.family: Shell.Theme.monoFontFamily
        font.weight: Font.Medium
        font.pixelSize: Shell.Theme.fontMonoCaption
        font.letterSpacing: 0
      }
    }

    Rectangle {
      x: 12
      y: 72
      width: 132
      height: 32
      radius: 8
      visible: root.low
      color: Qt.alpha(Shell.Theme.danger, 0.12)

      Text {
        anchors.centerIn: parent
        text: "Bateria em " + Battery.State.level + "%"
        color: Shell.Theme.dangerText
        font.family: Shell.Theme.fontFamily
        font.weight: Font.Medium
        font.pixelSize: Shell.Theme.fontBody
        font.letterSpacing: 0
      }
    }

    MouseArea {
      id: batteryArea
      x: 4
      y: 54
      width: 148
      height: root.low ? 58 : 18
      visible: root.battery
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: root.batteryClicked()
      Accessible.role: Accessible.Button
      Accessible.name: "Abrir bateria"
      Accessible.description: Battery.State.description
      Accessible.onPressAction: root.batteryClicked()
    }
  }

  Item {
    id: collapsedContent
    width: Shell.Theme.sidebarCardCollapsedWidth
    height: parent.height
    visible: root.collapsedProgress > 0.001

    Text {
      x: 0
      y: 8
      width: 48
      height: 20
      text: Qt.formatTime(root.previewTime, "hh")
      color: Shell.Theme.text
      opacity: Shell.Theme.ramp(root.collapsedProgress, 0.00, 0.32)
      font.family: Shell.Theme.monoFontFamily
      font.weight: Font.Normal
      font.pixelSize: Shell.Theme.fontMonoNumber
      font.letterSpacing: 0
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
    }

    Text {
      x: 0
      y: 28
      width: 48
      height: 20
      text: Qt.formatTime(root.previewTime, "mm")
      color: Shell.Theme.text
      opacity: Shell.Theme.ramp(root.collapsedProgress, 0.12, 0.44)
      font.family: Shell.Theme.monoFontFamily
      font.weight: Font.Normal
      font.pixelSize: Shell.Theme.fontMonoNumber
      font.letterSpacing: 0
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
    }

    Rectangle {
      x: 16
      y: 56
      width: 16
      height: 1
      color: Shell.Theme.border
      opacity: Shell.Theme.ramp(root.collapsedProgress, 0.36, 0.68)
    }

    Text {
      x: 0
      y: 64
      width: 48
      height: 20
      text: root.weekdaysCompact[root.previewTime.getDay()] || "SX"
      color: Shell.Theme.muted
      opacity: Shell.Theme.ramp(root.collapsedProgress, 0.48, 0.80)
      font.family: Shell.Theme.monoFontFamily
      font.weight: Font.Normal
      font.pixelSize: Shell.Theme.fontMonoNumber
      font.letterSpacing: 0
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
    }

    Text {
      x: 0
      y: 84
      width: 48
      height: 20
      text: Qt.formatDate(root.previewTime, "dd")
      color: Shell.Theme.text
      opacity: Shell.Theme.ramp(root.collapsedProgress, 0.60, 0.92)
      font.family: Shell.Theme.monoFontFamily
      font.weight: Font.Normal
      font.pixelSize: Shell.Theme.fontMonoNumber
      font.letterSpacing: 0
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
    }

    Rectangle {
      x: 16
      y: 112
      width: 16
      height: 1
      visible: root.battery
      color: Shell.Theme.border
    }

    Rectangle {
      x: 8
      y: 116
      width: 32
      height: 32
      radius: 8
      visible: root.battery
      color: root.low ? Qt.alpha(Shell.Theme.danger, 0.12) : "transparent"

      Battery.Indicator {
        x: 8
        y: 8
        percentage: root.effectiveBatteryPercentage
        charging: !root.previewBattery && Battery.State.charging
        color: root.batteryIconColor
      }

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.batteryClicked()
        Accessible.role: Accessible.Button
        Accessible.name: "Abrir bateria"
        Accessible.description: Battery.State.description
        Accessible.onPressAction: root.batteryClicked()
      }
    }
  }
}
