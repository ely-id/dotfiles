import QtQuick
import ".."
import "../audio" as Audio

// O pop-up de som de verdade (audio/Panel.qml) com dispositivos fictícios, na aba "output" ou "input".
Item {
  id: root
  property string tab: "output"
  implicitWidth: PanelStyle.stackWidth
  implicitHeight: 258

  AudioService { id: demoService }

  Audio.Panel {
    id: panel
    anchors.bottom: parent.bottom
    service: demoService
    selectedTab: root.tab
    Component.onCompleted: open()
  }
}
