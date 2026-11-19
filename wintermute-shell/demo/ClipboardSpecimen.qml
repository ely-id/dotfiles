import QtQuick
import ".."
import "../launcher" as Launcher

// O histórico da área de transferência (ficha 18, board 13:19344) dentro do launcher de verdade (launcher/Panel.qml, página `clipboard`),
// com o serviço fictício do launcher e o do histórico (demo/ClipboardService.qml), sem janela e sem véu.
//   state    "text" (os cinco itens, o primeiro selecionado), "image" (a captura selecionada), "search" (a busca `query`, padrão
//            "firefox": acha o link e o e-mail), "pinned" (dois itens fixados e dois de hoje), "empty" (nada copiado ainda),
//            "no-results" (a busca `query`, padrão "xyzzy", que não acha nada), "many" (cinquenta itens, para a rolagem), "menu" (o Ctrl+K da
//            página, F6-T16: o menu de ações do launcher com Copy, Pin, Delete e Clear history, para o item selecionado) ou "menu-armed" (o
//            mesmo, com "Clear history" selecionada e armada: "Press ↵ again to confirm")
//   selected a linha selecionada, contando as de todas as seções (padrão: 1 em "image", 0 nos outros)
//   hovered  a linha sob o ponteiro, ou -1 (padrão -1)
//   query    o texto da busca (padrão: o do estado)
Item {
  id: root

  property string state: "text"
  property int selected: state === "image" ? 1 : 0
  property int hovered: -1
  property string query: state === "search" ? "firefox" : state === "no-results" ? "xyzzy" : ""

  // Para o teste de comportamento.
  readonly property alias panel: panel
  readonly property alias clipboard: demoClipboard
  readonly property alias launcher: demoLauncher

  implicitWidth: panel.width
  implicitHeight: panel.height

  ClipboardService {
    id: demoClipboard
    scenario: root.state === "no-results" || root.state === "search" || root.state === "menu" || root.state === "menu-armed" ? "text" : root.state
  }

  LauncherService {
    id: demoLauncher
    scenario: "clipboard"
    clipboardService: demoClipboard
  }

  Launcher.Panel {
    id: panel
    service: demoLauncher
    clipboardService: demoClipboard
    clipboardSelected: root.selected
    clipboardHover: root.hovered
    clipboardQuery: root.query
    forceCursor: true
  }

  // O menu Ctrl+K da página: abre como a página abriria (o item selecionado e o serviço fictício do histórico), e arma o "Clear history".
  Component.onCompleted: {
    if (state !== "menu" && state !== "menu-armed")
      return;
    demoLauncher.openClipboardActions(demoClipboard.items[selected]);
    if (state === "menu-armed") {
      panel.selected = 3;
      demoLauncher.armedKey = "clipboard:clear";
    }
  }
}
