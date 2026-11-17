pragma ComponentBehavior: Bound
import QtQuick
import "." as Manual
import ".." as Settings
import "../.." as Shell

// Manual (ficha 13; Figma 13:16158): modal de 500×656 sem título. Em cima, o seletor Keyboard / Touchpad
// de 168×40, que só troca o tutorial de 440×240. Embaixo, a lista de atalhos em linhas de 44 (teclas à
// esquerda, descrição 13 Medium muted à direita, divisor border de 1) e o botão "Got it" de 440×40.
// A lista é a minha, completa (P-11 e P-52): ela rola na área das seis linhas do Figma e o botão fica
// fixo. Lê a lista por `service` (decisão 0011).
Settings.Modal {
  id: root
  objectName: "manualPanel"

  property var service: Manual.State
  property string mode: "keyboard"
  // Só para a vitrine e os prints: tutorial parado e a lista já rolada até uma linha.
  property bool animated: true
  property int firstRow: 0

  readonly property int pitch: Shell.Theme.settingsManualRowPitch

  title: ""
  implicitWidth: Shell.Theme.settingsManualWidth
  bodyTop: 0
  contentHeight: Shell.Theme.settingsManualHeight
  closeLabel: "Close manual"
  Accessible.role: Accessible.Dialog
  Accessible.name: "Manual"
  onBackRequested: Settings.State.back()
  Keys.onEscapePressed: Settings.State.back()
  Keys.onReturnPressed: Settings.State.back()
  Keys.onEnterPressed: Settings.State.back()
  Keys.onDownPressed: scrollBy(pitch)
  Keys.onUpPressed: scrollBy(-pitch)
  Keys.onPressed: event => {
    if (event.key === Qt.Key_PageDown || event.key === Qt.Key_PageUp) {
      scrollBy((list.height - 1 - pitch) * (event.key === Qt.Key_PageDown ? 1 : -1));
      event.accepted = true;
    } else if (event.key === Qt.Key_Home) {
      list.contentY = 0;
      event.accepted = true;
    } else if (event.key === Qt.Key_End) {
      list.contentY = Math.max(0, list.contentHeight - list.height);
      event.accepted = true;
    }
  }

  function scrollBy(distance) {
    list.contentY = Math.max(0, Math.min(list.contentHeight - list.height, list.contentY + distance));
  }

  Shell.SegmentedSelector {
    objectName: "manualMode"
    x: Math.round((root.width - width) / 2)
    y: Shell.Theme.settingsManualSwitcherTop
    model: [{ key: "keyboard", label: "Keyboard", width: 80 }, { key: "touchpad", label: "Touchpad", width: 80 }]
    current: root.mode
    onSelected: key => root.mode = key
  }

  Manual.NavigationTutorial {
    objectName: "manualTutorial"
    x: Shell.Theme.settingsBodyInset
    y: Shell.Theme.settingsManualTutorialTop
    mode: root.mode
    active: root.animated
  }

  Flickable {
    id: list
    objectName: "manualShortcuts"
    x: Shell.Theme.settingsBodyInset
    y: Shell.Theme.settingsManualListTop
    width: Shell.Theme.settingsManualContentWidth
    // O divisor de cada linha cai no primeiro pixel da linha seguinte, por isso o 1 a mais.
    height: Shell.Theme.settingsManualVisibleRows * root.pitch + 1
    contentHeight: root.service.rows.length * root.pitch + 1
    contentY: Math.max(0, Math.min(contentHeight - height, root.firstRow * root.pitch))
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    interactive: contentHeight > height
    Shell.ScrollWheel { view: list }

    Repeater {
      model: root.service.rows
      delegate: Item {
        id: row
        required property var modelData
        required property int index
        y: index * root.pitch
        width: list.width
        height: root.pitch
        Accessible.role: Accessible.ListItem
        Accessible.name: modelData.keys.join(" + ") + ": " + modelData.label

        Row {
          anchors.verticalCenter: parent.verticalCenter
          spacing: Shell.Theme.settingsManualKeyGap
          Repeater {
            model: row.modelData.keys
            delegate: Shell.KeyCap {
              required property string modelData
              text: modelData
            }
          }
        }

        Text {
          x: parent.width - width
          width: Shell.Theme.settingsManualLabelWidth
          height: parent.height
          horizontalAlignment: Text.AlignRight
          verticalAlignment: Text.AlignVCenter
          elide: Text.ElideRight
          text: row.modelData.label
          color: Shell.Theme.muted
          font.family: Shell.Theme.fontFamily
          font.weight: Font.Medium
          font.pixelSize: Shell.Theme.fontBody
          font.letterSpacing: 0
        }

        Rectangle {
          y: parent.height
          width: parent.width
          height: 1
          color: Shell.Theme.border
        }
      }
    }
  }

  Shell.ActionButton {
    objectName: "manualGotIt"
    x: Shell.Theme.settingsBodyInset
    y: Shell.Theme.settingsManualButtonTop
    width: Shell.Theme.settingsManualContentWidth
    height: Shell.Theme.settingsManualButtonHeight
    kind: "primary"
    compact: true
    text: "Got it"
    activeFocusOnTab: true
    Accessible.role: Accessible.Button
    Accessible.name: text
    Accessible.onPressAction: Settings.State.back()
    Keys.onSpacePressed: Settings.State.back()
    onClicked: Settings.State.back()
  }
}
