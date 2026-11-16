import QtQuick

// Fatos fictícios das Informações para a vitrine e os prints da F4 (ficha 13: nada de dado real da
// máquina em material compartilhado). Mesma superfície de settings/information/State.qml.
QtObject {
  property var facts: ({
    os: "CachyOS · Linux 6.17",
    host: "Wintermute",
    board: "B650 board (fictitious)",
    cpu: "Ryzen 7 · 8 cores",
    gpu: "Radeon · 16 GB",
    memory: "32 GB",
    disk: "1 TB NVMe · 412 GB free"
  })
  function value(key) { return facts[key] || "…"; }
}
