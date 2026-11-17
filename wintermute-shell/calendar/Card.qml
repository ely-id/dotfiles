pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import Quickshell
import "Dates.js" as Dates
import ".." as Shell

// Calendário (ficha 09): 264×296, raio 16. Título 13 Medium em (16,16), três botões 24×24 r6 em
// y 16 (x 176 / 204 / 232: voltar para hoje, mês anterior, mês seguinte), dias da semana 11 muted em
// y 48 e células de dia 32×32 r8 a cada 36 a partir de (8,72). A semana começa na segunda.
Shell.PanelBackground {
  id: root
  property date today: clock.date
  property bool followToday: true
  property date browsedMonth: Dates.monthStart(today)
  readonly property date displayedMonth: followToday
      ? Dates.monthStart(today) : browsedMonth
  readonly property bool isCurrentMonth: Dates.sameMonth(displayedMonth, today)
  readonly property var days: Dates.monthDays(displayedMonth)
  readonly property int weekRow: isCurrentMonth
      ? Dates.currentWeekRow(days, today) : -1
  // Sigo o idioma do sistema: nome do mês, iniciais da semana e texto do leitor de tela saem do
  // locale, sem montar a frase à mão. O que não é do locale é a ordem da grade, que fica na segunda.
  readonly property var locale: Qt.locale()
  readonly property string monthName: locale.standaloneMonthName(
      displayedMonth.getMonth(), Locale.LongFormat)
  readonly property string monthTitle: monthName.charAt(0).toUpperCase() + monthName.slice(1)
      + " " + displayedMonth.getFullYear()
  // dayName conta do domingo (0); a grade começa na segunda, por isso o (i + 1) % 7.
  readonly property var weekdayInitials: [0, 1, 2, 3, 4, 5, 6].map(
      i => locale.dayName((i + 1) % 7, Locale.NarrowFormat))

  implicitWidth: 264
  implicitHeight: 296
  Accessible.role: Accessible.Pane
  Accessible.name: "Calendar, " + monthTitle

  function showMonth(month) {
    browsedMonth = Dates.monthStart(month);
    followToday = Dates.sameMonth(month, today);
  }
  function moveMonth(delta) { showMonth(Dates.shiftMonth(displayedMonth, delta)); }
  function goToday() { followToday = true; }

  SystemClock { id: clock; precision: SystemClock.Minutes }

  // Consome os cliques no painel para que só cliques fora dele o dispensem.
  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
  }

  Text {
    x: 16; y: 16
    width: 160; height: 24
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
    text: root.monthTitle
    color: Shell.Theme.text
    font.family: Shell.Theme.fontFamily
    font.pixelSize: Shell.Theme.fontBody
    font.weight: Font.Medium
    font.letterSpacing: 0
  }

  NavigationButton {
    x: 176; y: 16
    iconName: "rotate-ccw"
    accessibleName: "Back to today"
    onClicked: root.goToday()
  }
  NavigationButton {
    x: 204; y: 16
    iconName: "chevron-up"
    accessibleName: "Previous month"
    onClicked: root.moveMonth(-1)
  }
  NavigationButton {
    x: 232; y: 16
    iconName: "chevron-down"
    accessibleName: "Next month"
    onClicked: root.moveMonth(1)
  }

  Repeater {
    model: root.weekdayInitials
    delegate: Text {
      required property int index
      required property string modelData
      x: 8 + index * 36
      y: 48
      width: 32
      height: 18
      text: modelData
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      color: Shell.Theme.muted
      font.family: Shell.Theme.fontFamily
      font.weight: Font.Medium
      font.pixelSize: Shell.Theme.fontCaption
      font.letterSpacing: 0
    }
  }

  // Faixa da semana atual: 248×32 r8, atrás das células.
  Rectangle {
    x: 8
    y: 72 + root.weekRow * 36
    width: 248
    height: 32
    radius: 8
    color: Shell.Theme.hover
    visible: root.weekRow >= 0
  }

  Repeater {
    model: root.days
    delegate: Rectangle {
      id: cell
      required property int index
      required property date modelData
      readonly property bool isToday: Dates.sameDay(modelData, root.today)
      readonly property bool inMonth: Dates.sameMonth(modelData, root.displayedMonth)
      x: 8 + index % 7 * 36
      y: 72 + Math.floor(index / 7) * 36
      width: 32
      height: 32
      radius: 8
      color: isToday && root.isCurrentMonth ? Shell.Theme.accent
          : dayHover.hovered ? Shell.Theme.pressed : "transparent"
      antialiasing: true
      Accessible.role: Accessible.StaticText
      // toString(data, LongFormat) traria hora e fuso; o formato longo só da data vem de dateFormat.
      Accessible.name: root.locale.toString(modelData, root.locale.dateFormat(Locale.LongFormat))
          + (isToday ? ", today" : "")

      Behavior on color {
        ColorAnimation { duration: Shell.Theme.hoverDuration; easing.type: Easing.OutCubic }
      }

      HoverHandler { id: dayHover }

      Text {
        anchors.fill: parent
        text: cell.modelData.getDate()
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: cell.isToday && root.isCurrentMonth ? Shell.Theme.textOnAccent : Shell.Theme.text
        opacity: cell.inMonth ? 1 : 0.5
        font.family: Shell.Theme.fontFamily
        font.weight: Font.Medium
        font.pixelSize: Shell.Theme.fontBody
        font.letterSpacing: 0
      }
    }
  }

  // Botão 24×24 r6 com ícone Lucide de 16, hover `hover`.
  component NavigationButton: Item {
    id: nav
    property string iconName
    property string accessibleName
    signal clicked
    width: 24
    height: 24
    activeFocusOnTab: true
    Accessible.role: Accessible.Button
    Accessible.name: accessibleName
    Accessible.onPressAction: clicked()
    Keys.onSpacePressed: clicked()
    Keys.onReturnPressed: clicked()

    Rectangle {
      anchors.fill: parent
      radius: 6
      color: navHover.hovered || nav.activeFocus ? Shell.Theme.hover : "transparent"
      antialiasing: true
    }
    Image {
      anchors.centerIn: parent
      width: 16
      height: 16
      source: Qt.resolvedUrl("../icons/" + nav.iconName + ".svg")
      sourceSize: Qt.size(32, 32)
      fillMode: Image.PreserveAspectFit
      layer.enabled: true
      layer.effect: MultiEffect { colorization: 1; colorizationColor: Shell.Theme.text }
    }
    HoverHandler { id: navHover; cursorShape: Qt.PointingHandCursor }
    TapHandler { onTapped: nav.clicked() }
  }
}
