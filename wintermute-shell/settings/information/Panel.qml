pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import "." as Information
import ".." as Settings
import "../.." as Shell

// Página Informações (ficha 13; Figma 13:16083): modal de 580×620. Sete linhas a cada 48 a partir de
// y 84, cada uma com o número num círculo de 24 (control com borda border, Mono 11 Medium), o rótulo 15
// Medium em muted em x 66 e o valor em Serif 17 em x 186, com divisor border de 1 entre elas. Embaixo,
// o botão Manual de 520×64 (bloco accentSubtle com book-open em accentText, "Manual" e a legenda, seta
// em text) e o rodapé só com enfeites: o broto, "Wintermute" com a versão e o "ARCH" (Footer.qml). Lê os
// fatos por `service` (decisão 0011).
Settings.Modal {
  id: root
  objectName: "informationPanel"

  property var service: Information.State
  // Só para a vitrine: fixa o hover no botão Manual.
  property bool manualHovered: false

  title: "Information"
  bodyTop: 0
  contentHeight: Shell.Theme.settingsInfoHeight
  onBackRequested: Settings.State.back()
  Keys.onEscapePressed: Settings.State.back()

  readonly property var rows: [
    { key: "os", label: "System" },
    { key: "host", label: "Machine" },
    { key: "board", label: "Board" },
    { key: "cpu", label: "CPU" },
    { key: "gpu", label: "GPU" },
    { key: "memory", label: "Memory" },
    { key: "disk", label: "Disk" }
  ]

  function openManual() { Settings.State.openPage("manual"); }

  Repeater {
    model: root.rows
    delegate: Item {
      id: row
      required property var modelData
      required property int index
      x: Shell.Theme.settingsBodyInset
      y: Shell.Theme.settingsBodyTop + index * Shell.Theme.settingsInfoRowPitch
      width: Shell.Theme.settingsRowWidth
      height: Shell.Theme.settingsInfoRowPitch

      Rectangle {
        y: (parent.height - height) / 2
        width: Shell.Theme.settingsInfoNumberSize
        height: width
        radius: width / 2
        color: Shell.Theme.control
        border.width: 1
        border.color: Shell.Theme.border
        antialiasing: true
        Text {
          anchors.fill: parent
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
          text: row.index + 1
          color: Shell.Theme.text
          font.family: Shell.Theme.monoFontFamily
          font.weight: Font.Medium
          font.pixelSize: Shell.Theme.fontMonoCaption
          font.letterSpacing: 0
        }
      }

      Text {
        x: Shell.Theme.settingsInfoLabelX - Shell.Theme.settingsBodyInset
        width: Shell.Theme.settingsInfoLabelWidth
        height: parent.height
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        text: row.modelData.label
        color: Shell.Theme.muted
        font.family: Shell.Theme.fontFamily
        font.weight: Font.Medium
        font.pixelSize: Shell.Theme.fontLabel
        font.letterSpacing: 0
      }

      Text {
        id: valueText
        objectName: "informationValue-" + row.modelData.key
        x: Shell.Theme.settingsInfoValueX - Shell.Theme.settingsBodyInset
        width: parent.width - x
        height: parent.height
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        text: root.service.value(row.modelData.key)
        color: Shell.Theme.text
        font.family: Shell.Theme.titleFontFamily
        font.weight: Font.Normal
        font.pixelSize: Shell.Theme.fontInfoValue
        font.letterSpacing: 0
        ToolTip.visible: valueHover.hovered && truncated
        ToolTip.text: text
        HoverHandler { id: valueHover }
      }

      Rectangle {
        visible: row.index < root.rows.length - 1
        y: parent.height
        width: parent.width
        height: 1
        color: Shell.Theme.border
      }
    }
  }

  Rectangle {
    id: manual
    objectName: "informationManual"
    readonly property bool hot: root.manualHovered || manualHover.hovered || activeFocus
    x: Shell.Theme.settingsBodyInset
    y: Shell.Theme.settingsInfoManualTop
    width: Shell.Theme.settingsRowWidth
    height: Shell.Theme.settingsInfoManualHeight
    radius: Shell.Theme.radiusRow
    color: hot ? Shell.Theme.pressed : Shell.Theme.control
    border.width: 1
    border.color: Shell.Theme.border
    antialiasing: true
    activeFocusOnTab: true
    Accessible.role: Accessible.Button
    Accessible.name: "Manual, shortcuts and gestures"
    Accessible.onPressAction: root.openManual()
    Keys.onReturnPressed: root.openManual()
    Keys.onSpacePressed: root.openManual()

    Behavior on color {
      ColorAnimation { duration: Shell.Theme.settingsHoverDuration; easing.type: Easing.OutCubic }
    }

    Rectangle {
      x: 12; y: 12
      width: Shell.Theme.settingsInfoManualBlock
      height: width
      radius: Shell.Theme.settingsInfoManualBlockRadius
      color: Shell.Theme.accentSubtle
      antialiasing: true
      Image {
        anchors.centerIn: parent
        width: 20; height: 20
        source: Qt.resolvedUrl("../../icons/book-open.svg")
        sourceSize: Qt.size(40, 40)
        smooth: true
        layer.enabled: true
        layer.effect: MultiEffect {
          colorization: 1
          colorizationColor: Shell.Theme.accentText
        }
      }
    }

    Text {
      x: Shell.Theme.settingsInfoManualTextX
      y: 12
      height: Shell.Theme.settingsDisplayLineHeight
      verticalAlignment: Text.AlignVCenter
      text: "Manual"
      color: Shell.Theme.text
      font.family: Shell.Theme.fontFamily
      font.weight: Font.Medium
      font.pixelSize: Shell.Theme.fontLabel
      font.letterSpacing: 0
    }
    Text {
      x: Shell.Theme.settingsInfoManualTextX
      y: 32
      height: Shell.Theme.settingsDisplayLineHeight
      verticalAlignment: Text.AlignVCenter
      text: "Shortcuts & gestures"
      color: Shell.Theme.muted
      font.family: Shell.Theme.fontFamily
      font.weight: Font.Normal
      font.pixelSize: Shell.Theme.fontBody
      font.letterSpacing: 0
    }

    Image {
      x: 488; y: 24
      width: 16; height: 16
      source: Qt.resolvedUrl("../../icons/chevron-right.svg")
      sourceSize: Qt.size(32, 32)
      smooth: true
      layer.enabled: true
      layer.effect: MultiEffect { colorization: 1; colorizationColor: Shell.Theme.text }
    }

    HoverHandler { id: manualHover; cursorShape: Qt.PointingHandCursor }
    TapHandler { onTapped: root.openManual() }
  }

  Information.Footer {
    objectName: "informationFooter"
    y: Shell.Theme.settingsInfoFooterTop
  }
}
