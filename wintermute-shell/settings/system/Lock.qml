pragma ComponentBehavior: Bound
import QtQuick
import "." as System
import ".." as Settings
import "../../battery" as Battery
import "../.." as Shell

// Página Bloqueio e suspensão (ficha 13; Figma 13:15971): modal de 580×420. Seletor "Plugged in" /
// "On battery" de 168×40 em (30,84), três linhas de valor a partir de y 144 (bloquear, desligar a tela e
// suspender) e a chave "Ask for password on wake". Sem bateria, o seletor some e as linhas sobem para
// y 84, como na origem. Cada valor abre o menu suspenso dos Ajustes (Dropdown.qml, F6-T17). A chave fica guardada e só
// passa a valer com a tela de bloqueio da F7. Lê o estado por `idle` (decisão 0011).
Settings.Modal {
  id: root
  objectName: "lockPanel"

  property var idle: System.Idle
  property bool batteryPresent: Battery.State.present
  property string power: idle.source
  property string dropdownField: ""
  property real dropdownCenter: 0

  readonly property real rowsTop: Shell.Theme.settingsBodyTop + (batteryPresent ? Shell.Theme.settingsRowPitch : 0)
  readonly property var rows: [
    { key: "lock", title: "Lock screen" },
    { key: "display", title: "Turn off display" },
    { key: "sleep", title: "Sleep" }
  ]

  title: "Lock & sleep"
  closeLabel: "Back to System"
  bodyTop: 0
  // Figma: 420 com o seletor (última linha em 324 + 52 e 44 de folga).
  contentHeight: rowsTop + Shell.Theme.settingsRowPitch * 3 + Shell.Theme.settingsRowHeight + 44
  onBackRequested: { if (dropdownField) closeDropdown(); else Settings.State.back(); }
  Keys.onEscapePressed: { if (dropdownField) closeDropdown(); else Settings.State.back(); }

  function closeDropdown() { dropdownField = ""; forceActiveFocus(); }
  function openDropdown(key, field) {
    dropdownCenter = field.mapToItem(root, 0, field.height / 2).y;
    dropdownField = key;
    Qt.callLater(() => { const menu = dropdownLoader.item as Settings.Dropdown; if (menu) menu.forceActiveFocus(); });
  }

  Shell.SegmentedSelector {
    objectName: "lockPower"
    x: Shell.Theme.settingsBodyInset
    y: Shell.Theme.settingsBodyTop
    visible: root.batteryPresent
    opacity: root.dropdownField ? 0.3 : 1
    enabled: !root.dropdownField
    model: [{ key: "pluggedIn", label: "Plugged in", width: 80 }, { key: "battery", label: "On battery", width: 80 }]
    current: root.power
    onSelected: key => root.power = key
  }

  Column {
    x: Shell.Theme.settingsBodyInset
    y: root.rowsTop
    spacing: Shell.Theme.settingsRowPitch - Shell.Theme.settingsRowHeight

    Repeater {
      model: root.rows
      delegate: Settings.Field {
        id: field
        required property var modelData
        objectName: "lockField" + modelData.key
        title: modelData.title
        value: root.idle.label(root.idle.timeouts[root.power][modelData.key])
        highlighted: root.dropdownField === modelData.key
        opacity: root.dropdownField && !highlighted ? 0.3 : 1
        enabled: !root.dropdownField
        onClicked: root.openDropdown(modelData.key, field)
      }
    }

    Settings.Field {
      objectName: "lockAskPassword"
      toggle: true
      title: "Ask for password on wake"
      checked: root.idle.askPasswordOnWake
      opacity: root.dropdownField ? 0.3 : 1
      enabled: !root.dropdownField
      onToggled: checked => root.idle.setAskPasswordOnWake(checked)
    }
  }

  overlay: [
    MouseArea {
      anchors.fill: parent; visible: !!root.dropdownField
      onClicked: root.closeDropdown()
      onWheel: event => { event.accepted = true; }
    },
    Loader {
      id: dropdownLoader
      active: !!root.dropdownField
      x: root.width - width - 38
      // Com a linha de 44 o menu cheio tem 280 e passaria da base do modal na linha Sleep: mesma trava da Tela (F6-T17).
      y: Math.max(60, Math.min(root.dropdownCenter - height / 2, root.height - height - 24))
      sourceComponent: Component {
        Settings.Dropdown {
          objectName: "lockDropdown"
          width: 181
          options: root.idle.options
          currentValue: String(root.idle.timeouts[root.power][root.dropdownField])
          onDismissed: root.closeDropdown()
          onSelected: value => { const key = root.dropdownField; root.closeDropdown(); root.idle.set(root.power, key, Number(value)); }
        }
      }
    }
  ]
}
