import QtQuick
import ".."
import "../bluetooth" as Bluetooth

// A pilha do Bluetooth de verdade (bluetooth/Panel.qml) com dados fictícios, aberta numa página da
// ficha 06: "drawer" (lista), "nearby" (próximos), "details" ou "pair" (pareamento).
Item {
  id: root
  property string page: "drawer"
  property bool bluetoothEnabled: true
  // Rádio bloqueado pelo rfkill: o adaptador fica desligado e a frase parada pede para ligar.
  property bool bluetoothBlocked: false
  // Mensagem de erro do desbloqueio, como o State.qml a deixa em errorText. O painel zera o errorText
  // ao abrir, então escrevo depois da abertura em vez de ligar a propriedade.
  property string errorMessage: ""
  property bool searching: false
  implicitWidth: Theme.cardStackWidth
  implicitHeight: 400

  BluetoothService {
    id: demoService
    enabled: root.bluetoothEnabled
    blocked: root.bluetoothBlocked
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
        if (root.errorMessage !== "")
          demoService.errorText = root.errorMessage;
        if (root.page === "nearby")
          stack.openNearby();
        else if (root.page === "details")
          stack.openDetails({ path: "/demo/p1" });
      });
    }
  }
}
