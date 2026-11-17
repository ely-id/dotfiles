import QtQuick
import "." as Bluetooth
import ".." as Shell

// Detalhes do dispositivo (fichas 05 e 06): o mesmo layout do Wi-Fi, com o nome do dispositivo no título.
Shell.DeviceDetails {
  id: root
  property var service: stackController ? stackController.service : Bluetooth.State
  readonly property var device: service.deviceFor(selection.path || "")
  title: device ? device.name : "Device unavailable"
  detailRows: {
    if (!device) return [{label: "Status", value: "This device is no longer available."}];
    const rows = [
      {label: "Type", value: device.type},
      {label: "Address", value: device.address},
      {label: "Connection", value: device.connected ? "Connected" : "Disconnected"},
      {label: "Pairing", value: device.paired || device.bonded ? "Paired" : "Not paired"}
    ];
    if (device.battery >= 0 && device.connected)
      rows.push({label: "Battery", value: device.battery + "%"});
    if (device.model) rows.push({label: "Model", value: device.model});
    if (device.deviceName && device.deviceName !== device.name)
      rows.push({label: "Device name", value: device.deviceName});
    return rows;
  }
  primaryText: "Forget"
  primaryEnabled: !!device && (device.paired || device.bonded) && !service.isBusy(device.path)
  secondaryEnabled: !!device && service.enabled && !service.isBusy(device.path)
  secondaryText: device && service.isBusy(device.path) ? "Please wait…"
      : device && device.connected ? "Disconnect" : "Connect"
  message: service.errorText
  onPrimaryClicked: service.forget(device)
  onSecondaryClicked: service.activate(device)
}
