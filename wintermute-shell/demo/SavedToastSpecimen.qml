import QtQuick
import ".."
import "../screenshot" as Screenshot

// O aviso de captura salva de verdade (screenshot/SavedToast.qml) com um serviço fictício (ficha 17, aviso de salvo, board 13:19344, nó
// 13:19610): o cartão de 280×64 com o `circle-check`, "Screenshot saved" e o caminho.
//   path  o caminho que o aviso mostra (padrão: um caminho inventado em ~/Pictures/Screenshots; um mais comprido que a caixa é cortado com reticências)
Item {
  id: root

  property string path: "~/Pictures/Screenshots/Screenshot from 2026-01-12 14-32-05.png"

  implicitWidth: card.width
  implicitHeight: card.height

  // Para o teste de comportamento.
  readonly property alias toast: card
  readonly property alias service: demoService

  SavedToastService {
    id: demoService
    path: root.path
  }

  Screenshot.SavedToast {
    id: card
    service: demoService
  }
}
