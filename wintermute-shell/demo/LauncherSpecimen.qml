import QtQuick
import ".."
import "../launcher" as Launcher

// O launcher de verdade (launcher/Panel.qml) com um serviço fictício, sem janela e sem véu (ficha 14).
//   state    "empty-shell" (sem seções), "typing" (busca "ter" com a sugestão "minal") ou
//            "grouped" (busca "no", quatro seções)
//   selected índice da linha selecionada, contando as linhas de todas as seções
//   hovered  índice da linha sob o ponteiro, ou -1
Item {
  id: root

  property string state: "typing"
  property int selected: 0
  property int hovered: -1

  implicitWidth: panel.width
  implicitHeight: panel.height

  LauncherService {
    id: demoService
    scenario: root.state
  }

  Launcher.Panel {
    id: panel
    service: demoService
    selected: root.selected
    hoverIndex: root.hovered
    forceCursor: true
  }
}
