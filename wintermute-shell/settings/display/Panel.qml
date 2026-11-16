pragma ComponentBehavior: Bound
import QtQuick
import "." as Display
import ".." as Settings
import "../.." as Shell
import "Geometry.js" as Geometry

// Página Tela (ficha 13; Figma 13:16041): modal de 580×704. Desenho dos monitores de 520×280, raio 16,
// em cardHover com borda border, em (30,84); com mais de um monitor, o selecionado fica em accentSubtle
// com anel accentRing de 2 e o botão "Arrange" (96×32) aparece a 16 da direita e da base. Linhas de
// 520×52 a cada 60 a partir de y 380. A primeira é Orientation (P-49), que não está no Figma: o menu
// mostra cada posição com o ícone do monitor girado do jeito que ele vai ficar. Depois vêm Scale,
// Resolution, Refresh rate e Adaptive sync (VRR), cada uma só quando há o que escolher, como na origem.
// Os valores abrem o menu suspenso da origem (P-46). Lê o estado por `service` (decisão 0011).
Settings.Modal {
  id: root
  objectName: "displayPanel"

  property var service: Display.State
  // Só para a vitrine: fixa o hover numa linha ("orientation", "scale", "resolution", "refresh" ou "vrr").
  property string hoverRow: ""

  title: "Display"
  closeLabel: "Back to Appearance"
  bodyTop: 0
  contentHeight: fields.y + fields.height + Shell.Theme.settingsBottomPadding
  titleOpacity: dropdownField ? 0.3 : 1

  property string dropdownField: ""
  property real dropdownCenter: 0
  readonly property var monitor: service.selected
  readonly property bool several: service.monitors.length > 1

  function percent(scale) { return Math.round(scale * 100) + "%"; }
  function hertz(refresh) { return (refresh / 1000).toFixed(3).replace(/\.?0+$/, "") + " Hz"; }

  // O transform do Niri gira no sentido anti-horário: o monitor virado para a direita é o "90".
  // O ícone gira no sentido em que o monitor vai ficar.
  readonly property var orientations: [
    { label: "Landscape", value: "Normal", icon: "monitor", iconRotation: 0 },
    { label: "Portrait right", value: "90", icon: "monitor", iconRotation: 90 },
    { label: "Portrait left", value: "270", icon: "monitor", iconRotation: -90 },
    { label: "Landscape (flipped)", value: "180", icon: "monitor", iconRotation: 180 }
  ]

  readonly property var rows: {
    const m = monitor;
    if (!m) return [];
    const result = [];
    const orientation = orientations.find(o => o.value === m.orientation) || orientations[0];
    result.push({ key: "orientation", title: "Orientation", value: orientation.label, current: orientation.value,
                  options: orientations });
    if (m.scales.length > 1)
      result.push({ key: "scale", title: "Scale", value: percent(m.scale), current: String(m.scale),
                    options: m.scales.map(s => ({ label: percent(s), value: String(s) })) });
    if (m.resolutions.some(r => r.value !== m.width + "x" + m.height))
      result.push({ key: "resolution", title: "Resolution", value: m.width + " × " + m.height,
                    current: m.width + "x" + m.height, options: m.resolutions });
    if (m.rates.some(r => r.value !== String(m.refresh)))
      result.push({ key: "refresh", title: "Refresh rate", value: hertz(m.refresh), current: String(m.refresh),
                    options: m.rates });
    if (m.vrrSupported)
      result.push({ key: "vrr", title: "Adaptive sync (VRR)", value: "", current: "", options: [] });
    return result;
  }
  readonly property var dropdownRow: rows.find(r => r.key === dropdownField) || null

  onBackRequested: { if (dropdownField) closeDropdown(); else Settings.State.back(); }
  Keys.onEscapePressed: { if (dropdownField) closeDropdown(); else Settings.State.back(); }

  Connections {
    target: root.service
    function onMonitorsChanged() { root.closeDropdown(); }
    function onSelectedNameChanged() { root.closeDropdown(); }
  }

  function closeDropdown() { dropdownField = ""; forceActiveFocus(); }
  function openDropdown(row, field) {
    const p = field.mapToItem(root, 0, field.height / 2);
    dropdownCenter = p.y;
    dropdownField = row.key;
    Qt.callLater(() => { const menu = dropdownLoader.item as Settings.Dropdown; if (menu) menu.forceActiveFocus(); });
  }
  function openArrange() { Settings.State.openPage("arrange"); }

  Rectangle {
    id: preview
    objectName: "displayPreview"
    x: Shell.Theme.settingsBodyInset
    y: Shell.Theme.settingsBodyTop
    width: Shell.Theme.settingsRowWidth
    height: Shell.Theme.settingsDisplayPreviewHeight
    radius: Shell.Theme.radiusCard
    color: Shell.Theme.cardHover
    border.width: 1
    border.color: Shell.Theme.border
    antialiasing: true
    clip: true
    opacity: root.dropdownField ? 0.3 : 1
    enabled: !root.dropdownField && !root.service.busy

    // Área de encaixe: a altura do desenho menos a faixa do botão (48), como na origem.
    Item {
      id: previewArea
      width: parent.width
      height: parent.height - 48
      readonly property var layout: Geometry.fit(root.service.geometry, width, height, 48, 286)
      readonly property real inset: root.several ? Shell.Theme.settingsDisplayTileInset : 0

      Repeater {
        model: root.service.monitors
        delegate: Display.Monitor {
          id: monitorTile
          required property var modelData
          readonly property real originX: previewArea.layout.x + modelData.logical.x * previewArea.layout.scale
          readonly property real originY: previewArea.layout.y + modelData.logical.y * previewArea.layout.scale
          objectName: "displayMonitor" + modelData.name
          x: Math.round(originX + previewArea.inset)
          y: Math.round(originY + previewArea.inset)
          width: Math.max(20, Math.round(originX + modelData.logical.width * previewArea.layout.scale - previewArea.inset) - x)
          height: Math.max(20, Math.round(originY + modelData.logical.height * previewArea.layout.scale - previewArea.inset) - y)
          label: modelData.number + "\u00a0\u00b7 " + modelData.label
          detail: modelData.name
          selected: root.several && modelData.name === root.service.selectedName
          hovered: tileHover.hovered
          activeFocusOnTab: root.several
          Accessible.role: Accessible.RadioButton
          Accessible.name: modelData.label + ", " + modelData.name
          Accessible.checked: selected
          Accessible.onPressAction: root.service.select(modelData.name)
          Keys.onSpacePressed: root.service.select(modelData.name)
          Keys.onReturnPressed: root.service.select(modelData.name)
          HoverHandler { id: tileHover; enabled: root.several; cursorShape: Qt.PointingHandCursor }
          TapHandler { enabled: root.several; onTapped: root.service.select(monitorTile.modelData.name) }
        }
      }

      Text {
        anchors.centerIn: parent
        visible: !root.service.monitors.length
        text: root.service.loaded ? "No connected displays" : "Loading displays…"
        color: Shell.Theme.muted
        font.family: Shell.Theme.fontFamily
        font.pixelSize: Shell.Theme.fontLabel
      }
    }

    Shell.ActionButton {
      id: arrangeButton
      objectName: "arrangeDisplays"
      x: parent.width - width - Shell.Theme.settingsEdgeMargin
      y: parent.height - height - Shell.Theme.settingsEdgeMargin
      width: Shell.Theme.settingsDisplayArrangeWidth
      small: true
      text: "Arrange"
      visible: root.several
      activeFocusOnTab: visible && enabled
      Accessible.role: Accessible.Button
      Accessible.name: "Arrange displays"
      Accessible.onPressAction: root.openArrange()
      Keys.onReturnPressed: root.openArrange()
      Keys.onSpacePressed: root.openArrange()
      onClicked: root.openArrange()
    }
  }

  Column {
    id: fields
    x: Shell.Theme.settingsBodyInset
    y: Shell.Theme.settingsDisplayRowsTop
    width: Shell.Theme.settingsRowWidth
    spacing: Shell.Theme.settingsRowPitch - Shell.Theme.settingsRowHeight

    Repeater {
      model: root.rows.length
      delegate: Settings.Field {
        id: field
        required property int index
        readonly property var modelData: root.rows[index] || { key: "", title: "", value: "" }
        objectName: "displayField" + modelData.key
        title: modelData.title
        value: modelData.value
        toggle: modelData.key === "vrr"
        checked: root.monitor ? root.monitor.vrrEnabled : false
        highlighted: root.dropdownField === modelData.key
        visualState: root.hoverRow === "" ? "" : root.hoverRow === modelData.key ? "hover" : "rest"
        opacity: root.dropdownField && !highlighted ? 0.3 : 1
        enabled: !root.service.busy && !root.dropdownField
        onClicked: root.openDropdown(modelData, field)
        onToggled: checked => root.service.change("vrr", checked ? "on" : "off")
      }
    }

    Text {
      width: parent.width
      visible: root.service.error !== ""
      text: root.service.error
      wrapMode: Text.Wrap
      color: Shell.Theme.dangerText
      font.family: Shell.Theme.fontFamily
      font.pixelSize: Shell.Theme.fontBody
    }
  }

  overlay: [
    MouseArea {
      anchors.fill: parent
      visible: !!root.dropdownField
      onClicked: root.closeDropdown()
      onWheel: event => { event.accepted = true; }
    },
    Loader {
      id: dropdownLoader
      objectName: "displayDropdownLoader"
      active: !!root.dropdownRow
      x: root.width - width - 38
      y: Math.max(60, Math.min(root.dropdownCenter - height / 2, root.height - height - 24))
      sourceComponent: Component {
        Settings.Dropdown {
          objectName: "displayDropdown"
          maximumHeight: Math.max(56, root.height - 84)
          width: root.dropdownField === "scale" ? 226 : 276
          options: root.dropdownRow ? root.dropdownRow.options : []
          currentValue: root.dropdownRow ? root.dropdownRow.current : ""
          onDismissed: root.closeDropdown()
          onSelected: value => { const field = root.dropdownField; root.closeDropdown(); root.service.change(field, value); }
        }
      }
    }
  ]
}
