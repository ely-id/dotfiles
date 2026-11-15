pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import "settings/appearance" as Appearance

PanelWindow {
  id: root
  required property var panelScreen
  property bool opened: false
  signal closeRequested

  screen: panelScreen
  visible: opened
  color: "transparent"

  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.namespace: "wintermute-font-test-" + (screen ? screen.name : "unknown")
  WlrLayershell.keyboardFocus: opened ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
  WlrLayershell.exclusionMode: ExclusionMode.Ignore

  implicitWidth: 440
  implicitHeight: 316

  Rectangle {
    id: panel
    anchors.fill: parent
    radius: Theme.radiusPopup
    color: Theme.secondary
    border.width: 1
    border.color: Theme.accentRing
    focus: root.opened
    Keys.onEscapePressed: root.closeRequested()

    IconButton {
      x: parent.width - 44
      y: 12
      width: 32
      height: 32
      iconWidth: 16
      iconHeight: 16
      iconSource: Qt.resolvedUrl("icons/x.svg")
      accessibleName: "Fechar painel de teste"
      onClicked: root.closeRequested()
    }

    Column {
      x: 24
      y: 20
      width: parent.width - 48
      spacing: 16

      Column {
        width: parent.width
        spacing: 4

        Text {
          text: "GEIST SERIF · TÍTULO"
          color: Theme.muted
          font.family: Theme.monoFontFamily
          font.pixelSize: Theme.fontCaption
          font.weight: Font.Medium
        }

        Text {
          width: parent.width - 36
          text: "Wintermute Shell · " + Theme.displayName
          color: Theme.text
          font.family: Theme.titleFontFamily
          font.pixelSize: Theme.fontPanelTitle
          font.weight: Font.Normal
          elide: Text.ElideRight
        }
      }

      Rectangle {
        width: parent.width
        height: 1
        color: Theme.border
      }

      Column {
        width: parent.width
        spacing: 4

        Text {
          text: "GEIST · CORPO (" + Theme.fontFamily + ")"
          color: Theme.muted
          font.family: Theme.monoFontFamily
          font.pixelSize: Theme.fontCaption
          font.weight: Font.Medium
        }

        Text {
          width: parent.width
          text: "A shell abre sobre o Niri com superfície escura constante, tipografia Geist e ícones Lucide. Só o acento muda entre as três variações."
          color: Theme.text
          font.family: Theme.fontFamily
          font.pixelSize: Theme.fontBody
          font.weight: Font.Normal
          wrapMode: Text.WordWrap
        }
      }

      Column {
        width: parent.width
        spacing: 4

        Text {
          text: "GEIST MONO · NÚMEROS E CÓDIGOS"
          color: Theme.muted
          font.family: Theme.monoFontFamily
          font.pixelSize: Theme.fontCaption
          font.weight: Font.Medium
        }

        Text {
          width: parent.width
          text: "0123456789 · 14:32:08 · 192.168.0.42 · 98%"
          color: Theme.accentText
          font.family: Theme.monoFontFamily
          font.pixelSize: Theme.fontLabel
          font.weight: Font.Medium
        }
      }

      Rectangle {
        width: parent.width
        height: 1
        color: Theme.border
      }

      Row {
        spacing: 8

        Repeater {
          model: [
            { key: "chiba", label: "Chiba" },
            { key: "freeside", label: "Freeside" },
            { key: "sprawl", label: "Sprawl" }
          ]

          delegate: Rectangle {
            id: schemeBtn
            required property var modelData
            readonly property bool active: Theme.name === modelData.key
            width: 124
            height: 36
            radius: Theme.radiusSecondaryButton
            color: active ? Theme.accentSubtle
                : btnMouse.containsMouse ? Theme.hover : Theme.control
            border.width: 1
            border.color: active ? Theme.accentRing : Theme.border

            Row {
              anchors.centerIn: parent
              spacing: 8

              Rectangle {
                width: 10
                height: 10
                radius: 5
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.schemes[schemeBtn.modelData.key].accent
              }

              Text {
                text: schemeBtn.modelData.label
                color: schemeBtn.active ? Theme.text : Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontBody
                font.weight: Font.Medium
              }
            }

            MouseArea {
              id: btnMouse
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: Appearance.State.selectTheme(schemeBtn.modelData.key)
            }
          }
        }
      }
    }
  }
}
