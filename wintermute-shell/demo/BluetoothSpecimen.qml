import QtQuick
import ".."
import "../bluetooth" as Bluetooth

// A pilha do Bluetooth de verdade (bluetooth/Panel.qml) com dados fictícios, aberta numa página da
// ficha 06: "drawer" (lista), "nearby" (próximos), "details" ou "pair" (pareamento).
Item {
  id: root
  property string page: "drawer"
  property bool bluetoothEnabled: true
  property bool searching: false
  implicitWidth: PanelStyle.stackWidth
  implicitHeight: 400

  BluetoothService {
    id: demoService
    enabled: root.bluetoothEnabled
    discovering: root.searching
    prompt: root.page === "pair" ? ({ kind: "confirm", code: "482913", path: "/demo/n3" })
                                 : ({ kind: "" })
  }

  Bluetooth.Panel {
    id: stack
    anchors.bottom: parent.bottom
    service: demoService
    Component.onCompleted: {
      open();
      Qt.callLater(() => {
        if (root.page === "nearby")
          stack.openNearby();
        else if (root.page === "details")
          stack.openDetails({ path: "/demo/p1" });
      });
    }
  }
}
