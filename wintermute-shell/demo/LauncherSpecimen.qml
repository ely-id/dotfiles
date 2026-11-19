import QtQuick
import ".."
import "../launcher" as Launcher

// O launcher de verdade (launcher/Panel.qml) com um serviço fictício, sem janela e sem véu (ficha 14).
//   state    "empty" (busca vazia: três recentes e as ferramentas), "empty-tools" (sem recentes),
//            "no-result" (busca "xyzzy", com as duas linhas de ação), "no-result-bare" (o mesmo sem as
//            linhas), "deep-files" (a busca profunda, "Search files": busca "notes", uma seção "Files" com seis
//            arquivos, alguns em pastas ocultas), "no-result-deep" (a busca profunda sem resultado: só "Search the web"), "typing" (busca "ter" com a sugestão "minal"), "grouped" (busca "no", quatro
//            seções), "confirm" (o mesmo, com o comando perigoso armado: selecione a linha 5), "calc" (a busca é
//            `expression`; o cálculo ocupa o launcher) ou "color" (a página de resultado do seletor de cor: #3FA9D9
//            "pega agora" no Firefox e o histórico do board), "actions-app", "actions-file", "actions-command",
//            "actions-command-armed", "actions-workspaces" ou "actions-calc" (o menu de ações, Ctrl+K: as ações do app
//            "Notes", do arquivo "meeting-notes.md", do comando "Power off now" sem e com a confirmação armada, a escolha
//            do workspace do "Notes" e o cálculo; a busca é a do "grouped", ou `expression` no cálculo)
//            "emoji" (o seletor de emoji, ficha 16: a grade com os onze recentes do board), "emoji-empty" (sem recentes),
//            "emoji-search" (busca `emojiText`, padrão "gato") ou "emoji-none" (busca sem resultado)
//   selected índice da linha selecionada, contando as linhas de todas as seções (nos estados do emoji, a célula selecionada)
//   hovered  índice da linha sob o ponteiro, ou -1
//   chip     chip das ferramentas com o foco do teclado, ou -1 (com um chip em foco nenhuma linha fica selecionada)
//   chipHovered chip das ferramentas sob o ponteiro, ou -1
//   expression  o que digitei na busca no estado "calc" (padrão 128*3.5+12)
//   separator   separador decimal do cálculo, "." ou "," (padrão ".")
//   context     número do workspace de onde abri pelo "+" (etiqueta "On workspace N"); 0 abre sem etiqueta (padrão 0)
//   copied      no estado "color", a linha recém-copiada: "", "hex", "rgb" ou "hsl" (padrão "")
//   historyHover no estado "color", a amostra do histórico sob o ponteiro (a dica mostra o HEX dela), ou -1 (padrão -1)
//   emojiText   no estado "emoji-search", o que digitei na busca do emoji (padrão "gato")
//   tab         nos estados do emoji, a aba cuja seção a grade mostra no topo, 0 a 5 (padrão -1: no começo)
Item {
  id: root

  property string state: "typing"
  property int selected: 0
  property int hovered: -1
  property int chip: -1
  property int chipHovered: -1
  property string expression: "128*3.5+12"
  property string separator: "."
  property int context: 0
  property string copied: ""
  property int historyHover: -1
  property string emojiText: "gato"
  property int tab: -1

  implicitWidth: panel.width
  implicitHeight: panel.height

  LauncherService {
    id: demoService
    scenario: root.state
    expression: root.expression
    decimalSeparator: root.separator
    contextNumber: root.context
    copied: root.copied
    emojiText: root.emojiText
  }

  Launcher.Panel {
    id: panel
    service: demoService
    selected: root.selected
    hoverIndex: root.hovered
    chipIndex: root.chip
    chipHoverIndex: root.chipHovered
    historyHoverIndex: root.historyHover
    emojiSelected: root.selected
    emojiHover: root.hovered
    emojiStartTab: root.tab
    forceCursor: true
  }
}
