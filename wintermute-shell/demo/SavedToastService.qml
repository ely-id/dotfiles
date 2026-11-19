import QtQuick

// O serviço fictício do aviso de captura salva (decisão 0011, ficha 17): a mesma superfície de screenshot/SavedState.qml que a peça lê
// (`displayPath`), sem janela, sem relógio de sumir e sem pasta nenhuma. O caminho é inventado: nada da máquina.
QtObject {
  id: root

  property string path: "~/Pictures/Screenshots/Screenshot from 2026-01-12 14-32-05.png"
  readonly property string displayPath: path
}
