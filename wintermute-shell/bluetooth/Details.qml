import QtQuick
import "." as Bluetooth
import ".." as Shell

// Detalhes do dispositivo (fichas 05 e 06): o mesmo layout do Wi-Fi, com o nome do dispositivo no título.
Shell.DeviceDetails {
  id: root
  property var service: stackController ? stackController.service : Bluetooth.State
  readonly property var device: service.deviceFor(selection.path || "")
  title: device ? device.name : "Dispositivo indisponível"
  detailRows: {
    if (!device) return [{label: "Status", value: "Este dispositivo não está mais disponível."}];
    const rows = [
      {label: "Tipo", value: device.type},
      {label: "Endereço", value: device.address},
      {label: "Conexão", value: device.connected ? "Conectado" : "Desconectado"},
      {label: "Pareamento", value: device.paired || device.bonded ? "Pareado" : "Não pareado"}
    ];
    if (device.battery >= 0 && device.connected)
      rows.push({label: "Bateria", value: device.battery + "%"});
    if (device.model) rows.push({label: "Modelo", value: device.model});
    if (device.deviceName && device.deviceName !== device.name)
      rows.push({label: "Nome do dispositivo", value: device.deviceName});
    return rows;
  }
  primaryText: "Esquecer"
  primaryEnabled: !!device && (device.paired || device.bonded) && !service.isBusy(device.path)
  secondaryEnabled: !!device && service.enabled && !service.isBusy(device.path)
  secondaryText: device && service.isBusy(device.path) ? "Aguarde…"
      : device && device.connected ? "Desconectar" : "Conectar"
  message: service.errorText
  onPrimaryClicked: service.forget(device)
  onSecondaryClicked: service.activate(device)
}
