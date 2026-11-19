import QtQuick
import ".."
import "../wifi" as Wifi

// A pilha do Wi-Fi de verdade (wifi/Panel.qml) com dados fictícios, aberta numa página da ficha 05:
// "drawer" (lista), "join" (entrar), "add" (adicionar rede), "details" ou "status".
Item {
  id: root
  property string page: "drawer"
  property var selection: ({})
  property string phase: "idle"
  property string statusText: ""
  implicitWidth: Theme.cardStackWidth
  implicitHeight: 468

  WifiService {
    id: demoService
    phase: root.phase
    statusText: root.statusText
  }

  Wifi.Panel {
    id: stack
    anchors.bottom: parent.bottom
    service: demoService
    Component.onCompleted: {
      open();
      if (root.page !== "drawer")
        Qt.callLater(() => stack.push(root.page, root.selection));
    }
  }
}
