import QtQuick
import ".."
import "../launcher" as Launcher

// O launcher de verdade (launcher/Panel.qml) com um serviço fictício, sem janela e sem véu (ficha 14).
//   state    "empty-shell" (sem seções), "typing" (busca "ter" com a sugestão "minal"),
//            "grouped" (busca "no", quatro seções) ou "calc" (a busca é `expression`; o cálculo
//            ocupa o launcher)
//   selected índice da linha selecionada, contando as linhas de todas as seções
//   hovered  índice da linha sob o ponteiro, ou -1
//   expression  o que digitei na busca no estado "calc" (padrão 128*3.5+12)
//   separator   separador decimal do cálculo, "." ou "," (padrão ".")
Item {
  id: root

  property string state: "typing"
  property int selected: 0
  property int hovered: -1
  property string expression: "128*3.5+12"
  property string separator: "."

  implicitWidth: panel.width
  implicitHeight: panel.height

  LauncherService {
    id: demoService
    scenario: root.state
    expression: root.expression
    decimalSeparator: root.separator
  }

  Launcher.Panel {
    id: panel
    service: demoService
    selected: root.selected
    hoverIndex: root.hovered
    forceCursor: true
  }
}
