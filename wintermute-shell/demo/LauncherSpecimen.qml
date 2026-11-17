import QtQuick
import ".."
import "../launcher" as Launcher

// O launcher de verdade (launcher/Panel.qml) com um serviço fictício, sem janela e sem véu (ficha 14).
//   state    "empty" (busca vazia: três recentes e as ferramentas), "empty-tools" (sem recentes),
//            "no-result" (busca "xyzzy", com as duas linhas de ação), "no-result-bare" (o mesmo sem as
//            linhas), "typing" (busca "ter" com a sugestão "minal"), "grouped" (busca "no", quatro
//            seções) ou "calc" (a busca é `expression`; o cálculo ocupa o launcher)
//   selected índice da linha selecionada, contando as linhas de todas as seções
//   hovered  índice da linha sob o ponteiro, ou -1
//   chip     chip das ferramentas com o foco do teclado, ou -1 (com um chip em foco nenhuma linha fica selecionada)
//   chipHovered chip das ferramentas sob o ponteiro, ou -1
//   expression  o que digitei na busca no estado "calc" (padrão 128*3.5+12)
//   separator   separador decimal do cálculo, "." ou "," (padrão ".")
Item {
  id: root

  property string state: "typing"
  property int selected: 0
  property int hovered: -1
  property int chip: -1
  property int chipHovered: -1
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
    chipIndex: root.chip
    chipHoverIndex: root.chipHovered
    forceCursor: true
  }
}
