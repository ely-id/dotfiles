import QtQuick
import ".."
import "../settings" as Settings

// O menu suspenso dos Ajustes de verdade (settings/Dropdown.qml), com opções inventadas (ficha 13, seção "Menu suspenso",
// composição A-05, P-81). Quatro estados, escolhidos por `kind`, cada um com a largura do chamador real:
//   "list"    Bloqueio e suspensão: três valores, o atual em accentSubtle (181 de largura)
//   "icons"   Tela, Orientation: quatro opções com o monitor girado à esquerda (276)
//   "tray"    bandeja: marcada, submenu, separador e desativada (236)
//   "scroll"  Tela, Refresh rate: opções demais para a altura máxima, com a barra de rolagem de 2 (276)
//   hover     índice da linha com o hover fixo (-1 não fixa nenhuma)
//   current   valor atual; vazio usa o de cada estado
//   focused   o menu com o foco do teclado, como abre nos Ajustes (a linha em foco ganha `hover`)
Item {
  id: root

  property string kind: "list"
  property int hover: -1
  property string current: ""
  property bool focused: false

  readonly property var lists: ({
    list: {
      width: 181, current: "display",
      options: [
        { label: "Lock screen", value: "lock" },
        { label: "Turn off screen", value: "display" },
        { label: "Sleep", value: "sleep" }
      ]
    },
    icons: {
      width: 276, current: "Normal",
      options: [
        { label: "Landscape", value: "Normal", icon: "monitor", iconRotation: 0 },
        { label: "Portrait right", value: "90", icon: "monitor", iconRotation: 90 },
        { label: "Portrait left", value: "270", icon: "monitor", iconRotation: -90 },
        { label: "Landscape (flipped)", value: "180", icon: "monitor", iconRotation: 180 }
      ]
    },
    tray: {
      width: 236, current: "",
      options: [
        { label: "Open window", value: 0 },
        { label: "Pause sync", value: 1, checked: true },
        { label: "Sync now", value: 2, disabled: true },
        { label: "", value: 3, separator: true, disabled: true },
        { label: "Account", value: 4, submenu: true },
        { label: "Quit", value: 5 }
      ]
    },
    scroll: {
      width: 276, current: "120000",
      options: [
        { label: "30 Hz", value: "30000" },
        { label: "48 Hz", value: "48000" },
        { label: "60 Hz", value: "60000" },
        { label: "75 Hz", value: "75000" },
        { label: "90 Hz", value: "90000" },
        { label: "100 Hz", value: "100000" },
        { label: "120 Hz", value: "120000" },
        { label: "144 Hz", value: "144000" },
        { label: "165 Hz", value: "165000" },
        { label: "240 Hz", value: "240000" }
      ]
    }
  })
  readonly property var spec: lists[kind] || lists.list

  // Para o teste de comportamento.
  readonly property alias menu: dropdown
  property string lastSelected: ""
  property int dismissCount: 0

  implicitWidth: dropdown.width
  implicitHeight: dropdown.height

  Settings.Dropdown {
    id: dropdown
    objectName: "specimenDropdown"
    width: root.spec.width
    options: root.spec.options
    currentValue: root.current !== "" ? root.current : root.spec.current
    pinnedHover: root.hover
    Component.onCompleted: if (root.focused) forceActiveFocus()
    onSelected: value => root.lastSelected = value
    onDismissed: root.dismissCount += 1
  }
}
