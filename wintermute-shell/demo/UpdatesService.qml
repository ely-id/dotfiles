import QtQuick

// Estado fictício do Cachy Update para a vitrine da F4 (ficha 13): 3 atualizações disponíveis.
// Mesma superfície que updates/State.qml lê na tela inicial dos Ajustes.
QtObject {
  id: root
  property string status: "available"
  property string pending: ""
  property int availableCount: 3

  function start() { status = "updating"; }
  function after(action) { pending = pending === action ? "" : action; }
}
