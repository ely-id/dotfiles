pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import ".." as Settings
import "../.." as Shell

// Lista com busca das páginas do Sistema (ficha 13; Figma 13:15984), hoje usada pelo Idioma do teclado.
// Busca de 520×44 raio 12 em `control` em (30,84), com anel accentRing quando tem foco, lupa de 16 em
// (16,14) e cursor accentText. Opções de 520×44 raio 12 a partir de y 140: nome 13 Medium em x 16 e
// código Geist Mono 11 muted alinhado à direita em 476 (vira `text` na escolhida). A escolhida tem fundo
// accentSubtle e check de 16 em accentText em (488,14); o hover é `hover`. O modal cresce até 460 e a
// lista rola dentro. Escape limpa a busca antes de voltar; Enter escolhe a primeira opção da busca.
Settings.Modal {
  id: root
  property var options: []
  property var selected: []
  property bool multiple: false
  property string placeholder
  // Vitrine: texto da busca já digitado.
  property string initialQuery: ""
  signal picked(string id)

  readonly property string query: search.text.trim().toLowerCase()
  readonly property var rows: {
    const pinned = selected.map(id => options.find(option => option.id === id)).filter(Boolean);
    const ordered = pinned.concat(options.filter(option => selected.indexOf(option.id) < 0));
    return query ? ordered.filter(option => (option.search || option.label).toLowerCase().includes(query)) : ordered;
  }
  readonly property real listHeight: Math.min(rows.length * Shell.Theme.settingsPickerRowHeight,
      Shell.Theme.settingsPickerMaxHeight - Shell.Theme.settingsPickerListTop - Shell.Theme.settingsBottomPadding)

  bodyTop: 0
  contentHeight: Shell.Theme.settingsPickerListTop + listHeight + Shell.Theme.settingsBottomPadding
  onBackRequested: Settings.State.back()
  Keys.onEscapePressed: { if (search.text) search.clear(); else Settings.State.back(); }
  Component.onCompleted: { if (initialQuery) search.text = initialQuery; }

  // "br(dvorak)" vira "br · dvorak", como no Figma.
  function code(option) {
    if (option.code) return option.code;
    const match = /^([^(]+)(?:\((.+)\))?$/.exec(option.id);
    return match ? [match[1], match[2]].filter(Boolean).join(" · ") : option.id;
  }

  function choose(id) {
    picked(id);
    search.clear();
    search.forceActiveFocus();
  }

  Rectangle {
    objectName: "systemSearch"
    x: Shell.Theme.settingsBodyInset
    y: Shell.Theme.settingsBodyTop
    width: Shell.Theme.settingsRowWidth
    height: Shell.Theme.panelFieldHeight
    radius: Shell.Theme.radiusRow
    color: Shell.Theme.control
    border.width: 1
    border.color: search.activeFocus ? Shell.Theme.accentRing : Qt.alpha(Shell.Theme.accentRing, 0)
    antialiasing: true

    Behavior on border.color {
      ColorAnimation { duration: Shell.Theme.hoverDuration; easing.type: Easing.OutCubic }
    }

    HoverHandler { cursorShape: Qt.IBeamCursor }
    TapHandler { onTapped: search.forceActiveFocus() }

    Image {
      x: 16
      y: 14
      width: 16
      height: 16
      source: Qt.resolvedUrl("../../icons/search.svg")
      sourceSize: Qt.size(32, 32)
      fillMode: Image.PreserveAspectFit
      smooth: true
    }

    Text {
      x: 44
      anchors.verticalCenter: parent.verticalCenter
      visible: !search.text
      text: root.placeholder
      color: Shell.Theme.placeholder
      font.family: Shell.Theme.fontFamily
      font.weight: Font.Normal
      font.pixelSize: Shell.Theme.fontLabel
    }

    TextInput {
      id: search
      x: 44
      width: parent.width - x - 16
      anchors.verticalCenter: parent.verticalCenter
      clip: true
      focus: true
      color: Shell.Theme.text
      selectionColor: Shell.Theme.accentSubtle
      selectedTextColor: Shell.Theme.text
      font.family: Shell.Theme.fontFamily
      font.weight: Font.Normal
      font.pixelSize: Shell.Theme.fontLabel
      Accessible.role: Accessible.EditableText
      Accessible.name: root.placeholder
      cursorDelegate: Rectangle {
        id: caret
        width: 1
        color: Shell.Theme.accentText
        Timer {
          running: search.cursorVisible
          repeat: true
          interval: Qt.styleHints.cursorFlashTime / 2
          onRunningChanged: caret.opacity = 1
          onTriggered: caret.opacity = 1 - caret.opacity
        }
      }
      onAccepted: if (root.query && root.rows.length) root.choose(root.rows[0].id)
    }
  }

  ListView {
    id: list
    objectName: "systemOptions"
    x: Shell.Theme.settingsBodyInset
    y: Shell.Theme.settingsPickerListTop
    width: Shell.Theme.settingsRowWidth
    height: root.listHeight
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    model: root.rows
    Shell.ScrollWheel { view: list }

    delegate: Rectangle {
      id: row
      required property var modelData
      required property int index
      readonly property bool chosen: root.selected.indexOf(modelData.id) >= 0
      readonly property bool highlighted: hover.hovered || (!!root.query && index === 0 && !chosen)

      width: list.width
      height: Shell.Theme.settingsPickerRowHeight
      radius: Shell.Theme.radiusRow
      color: chosen ? Shell.Theme.accentSubtle : highlighted ? Shell.Theme.hover : Qt.alpha(Shell.Theme.hover, 0)
      antialiasing: true
      Accessible.role: root.multiple ? Accessible.CheckBox : Accessible.RadioButton
      Accessible.name: modelData.label
      Accessible.checked: chosen
      Accessible.onPressAction: root.choose(modelData.id)

      Behavior on color {
        ColorAnimation { duration: Shell.Theme.settingsHoverDuration; easing.type: Easing.OutCubic }
      }

      Text {
        x: 16
        width: 340
        height: parent.height
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        text: row.modelData.label
        color: Shell.Theme.text
        font.family: Shell.Theme.fontFamily
        font.weight: Font.Medium
        font.pixelSize: Shell.Theme.fontBody
      }

      Text {
        x: 356
        width: 120
        height: parent.height
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideLeft
        text: root.code(row.modelData)
        color: row.chosen ? Shell.Theme.text : Shell.Theme.muted
        font.family: Shell.Theme.monoFontFamily
        font.weight: Font.Medium
        font.pixelSize: Shell.Theme.fontMonoCaption
      }

      Image {
        x: 488
        y: 14
        width: 16
        height: 16
        visible: row.chosen
        source: Qt.resolvedUrl("../../icons/check.svg")
        sourceSize: Qt.size(32, 32)
        fillMode: Image.PreserveAspectFit
        smooth: true
        layer.enabled: true
        layer.effect: MultiEffect { colorization: 1; colorizationColor: Shell.Theme.accentText }
      }

      HoverHandler { id: hover; cursorShape: Qt.PointingHandCursor }
      TapHandler { onTapped: root.choose(row.modelData.id) }
    }
  }
}
