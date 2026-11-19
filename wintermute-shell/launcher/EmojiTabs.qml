pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import ".."
import "Emoji.js" as Emoji

// As seis abas do seletor de emoji (ficha 16, nós 13:17559 a 13:17569): quadros de 36×36, raio `radiusChip`, um a cada 44
// a partir de x 20, com o ícone de 16 em (10,10). A ativa leva `accentSubtle` e o ícone em `accentText` a 100%; as outras
// ficam sem fundo, com o ícone `text` a 80%. Com texto na busca as seis ficam a 50% e nenhuma é ativa (13:17682). O hover
// da aba não tem desenho no board: uso o fundo `hover`, o mesmo das células (composição, ajuste A-05).
// `available` diz quais abas levam a uma seção (a dos recentes some sem recentes: fica a 50% e não responde).
Item {
  id: root

  // A aba ativa, ou -1 (busca).
  property int activeTab: -1
  // Texto na busca: as seis a 50%, nenhuma ativa, nenhuma responde.
  property bool dimmed: false
  // Uma flag por aba.
  property var available: [true, true, true, true, true, true]
  // Para fixar o hover na vitrine.
  property int hoverTab: -1

  signal activated(int tab)

  implicitWidth: Theme.launcherEmojiTabsX + Emoji.TABS.length * Theme.launcherEmojiTabStep
  implicitHeight: Theme.launcherEmojiTabSize

  Repeater {
    model: Emoji.TABS

    delegate: Item {
      id: tab

      required property var modelData
      required property int index
      readonly property bool active: index === root.activeTab && !root.dimmed
      readonly property bool live: !root.dimmed && root.available[index] === true
      readonly property bool hovered: live && (index === root.hoverTab || pointer.containsMouse)

      x: Theme.launcherEmojiTabsX + index * Theme.launcherEmojiTabStep
      width: Theme.launcherEmojiTabSize
      height: Theme.launcherEmojiTabSize
      opacity: live ? 1 : Theme.launcherEmojiTabDimOpacity

      Accessible.role: Accessible.Button
      Accessible.name: modelData.name

      Rectangle {
        anchors.fill: parent
        radius: Theme.radiusChip
        color: tab.active ? Theme.accentSubtle : tab.hovered ? Theme.hover : "transparent"
        antialiasing: true

        Behavior on color {
          ColorAnimation {
            duration: Theme.controlDuration
            easing.type: Easing.OutCubic
          }
        }
      }

      Image {
        x: Theme.launcherEmojiTabIconOffset
        y: Theme.launcherEmojiTabIconOffset
        width: Theme.launcherEmojiTabIconSize
        height: Theme.launcherEmojiTabIconSize
        opacity: tab.active ? 1 : Theme.launcherEmojiTabRestOpacity
        source: Qt.resolvedUrl("../icons/" + tab.modelData.icon + ".svg")
        sourceSize: Qt.size(width * 2, height * 2)
        fillMode: Image.PreserveAspectFit
        smooth: true
        antialiasing: true
        layer.enabled: true
        layer.effect: MultiEffect {
          colorization: 1
          colorizationColor: tab.active ? Theme.accentText : Theme.text
        }
      }

      MouseArea {
        id: pointer
        anchors.fill: parent
        enabled: tab.live
        hoverEnabled: true
        onClicked: root.activated(tab.index)
      }
    }
  }
}
