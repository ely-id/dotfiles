pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "." as Audio
import ".."

// Painel de som (ficha 07, 316 × (116 + 40 por dispositivo); com 3 dispositivos, 236).
// Abas "Saída" / "Entrada" em Serif 20: (20,16) 64×32 e (92,16) 96×32. Slider 276 em (20,56),
// divisor em y 100 e linhas 300×40 a partir de y 108.
Item {
  id: root

  property var service: Audio.State
  property bool interactive: true
  property string selectedTab: "output"

  readonly property var devices: selectedTab === "output"
      ? service.outputDevices : service.inputDevices
  readonly property int deviceCount: devices.length
  readonly property int visibleDeviceRows: Math.max(1,
      Math.min(4, deviceCount))
  readonly property real selectedVolume: selectedTab === "output"
      ? service.outputVolume : service.inputVolume
  readonly property bool selectedAudioAvailable: selectedTab === "output"
      ? service.hasOutput : service.hasInput

  implicitWidth: PanelStyle.width
  implicitHeight: 116 + visibleDeviceRows * Theme.audioRowHeight

  PanelBackground {
    anchors.fill: parent

    Repeater {
      model: [
        {tab: "output", label: "Output", x: 20, width: 64},
        {tab: "input", label: "Input", x: 92, width: 96}
      ]
      delegate: MouseArea {
        id: tabButton
        required property var modelData
        x: modelData.x
        y: 16
        width: modelData.width
        height: 32
        enabled: root.interactive
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.selectedTab = modelData.tab

        Text {
          anchors.fill: parent
          text: tabButton.modelData.label
          color: root.selectedTab === tabButton.modelData.tab || tabButton.containsMouse
              ? Theme.text : Theme.muted
          font.family: Theme.titleFontFamily
          font.weight: Font.Normal
          font.pixelSize: Theme.fontPanelTitle
          font.letterSpacing: 0
          verticalAlignment: Text.AlignVCenter
          Behavior on color { ColorAnimation { duration: Theme.hoverDuration } }
        }
      }
    }

    Slider {
      id: volumeSlider
      x: 20
      y: 56
      width: PanelStyle.fieldWidth
      height: 32
      externalValue: root.selectedVolume
      muted: root.selectedTab === "output" && root.service.outputMuted
      interactive: root.interactive && root.selectedAudioAvailable
      onMoved: {
        if (root.selectedTab === "output")
          root.service.setOutputVolume(volumeSlider.value);
        else
          root.service.setInputVolume(volumeSlider.value);
      }
    }

    Rectangle {
      x: 20
      y: 100
      width: 276
      height: 1
      color: Theme.border
      antialiasing: false
    }

    ListView {
      id: deviceList
      clip: true
      boundsBehavior: Flickable.StopAtBounds
      ScrollWheel { view: deviceList }
      x: 8
      y: 108
      width: PanelStyle.rowWidth
      height: parent.height - y - 8
      interactive: root.deviceCount > 4
      model: ScriptModel { values: root.devices }

      delegate: DeviceRow {
        required property var modelData
        width: deviceList.width
        device: modelData
        service: root.service
        interactive: root.interactive
        selected: root.selectedTab === "output"
            ? !!root.service.sink
                && Number(root.service.sink.id) === Number(modelData.id)
            : !!root.service.source
                && Number(root.service.source.id) === Number(modelData.id)
        onClicked: {
          if (root.selectedTab === "output")
            root.service.setOutputDevice(modelData);
          else
            root.service.setInputDevice(modelData);
        }
      }

    }

    Text {
      x: 20
      y: 108
      width: 276
      height: 40
      visible: root.deviceCount === 0
      text: root.selectedTab === "output"
          ? "No output devices" : "No input devices"
      horizontalAlignment: Text.AlignHCenter
      color: Theme.muted
      font.family: Theme.fontFamily
      font.weight: Font.Medium
      font.pixelSize: Theme.fontBody
      font.letterSpacing: 0
      verticalAlignment: Text.AlignVCenter
    }

    ScrollShade { view: deviceList; x: 0; y: 108; z: 3; width: parent.width; easingType: Easing.OutCubic }
  }
}
