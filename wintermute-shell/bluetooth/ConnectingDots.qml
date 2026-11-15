import QtQuick
import ".."

// Dois pontos accent 6×6 com espaço 4 no lugar do rádio (ficha 06, "Conectando"). Um fica aceso e
// o outro a 30%; trocam a cada 750 ms, o tempo que a origem já usava no pisca do Bluetooth.
Item {
  id: root
  property bool running: false
  property bool second: false
  implicitWidth: 16
  implicitHeight: 6

  onRunningChanged: second = false

  Rectangle {
    x: 0; width: 6; height: 6; radius: 3
    color: Theme.accent
    opacity: root.second ? 0.3 : 1
  }
  Rectangle {
    x: 10; width: 6; height: 6; radius: 3
    color: Theme.accent
    opacity: root.second ? 1 : 0.3
  }
  Timer {
    interval: 750
    running: root.running && root.visible
    repeat: true
    onTriggered: root.second = !root.second
  }
}
