pragma Singleton

import QtQuick
import "../settings" as Settings
import "Calculator.js" as Calculator
import Quickshell

// Estado do launcher (ficha 14). É a superfície que a peça lê (decisão 0011); o serviço fictício de
// demo/LauncherService.qml tem os mesmos nomes. Na F5-T01 ainda não existe fonte de dados: `sections`, `recents`
// e `ghost` ficam vazios. A fonte de verdade chega na F5-T02. O cálculo (F5-T03) já funciona: depende
// só do texto, então `calculation`, o modo e o rodapé saem dele. As ferramentas do estado vazio (F5-T04) são
// fixas; o que cada uma abre ainda não existe (F5-T08, F5-T09 e a F6), então `openTool` só registra no log.
Singleton {
  id: root

  property bool opened: false
  property string outputName: ""
  property string query: ""
  // O resto da palavra sugerida (para "ter", "minal"). Vazio quando não há sugestão.
  property string ghost: ""
  // Lista de { label, rows }; cada linha é { title, detail, kind, icon, iconSource, danger }.
  // `icon` é o nome de um ícone de icons/; `iconSource` é um caminho ou um nome de ícone do tema.
  property var sections: []
  // Os apps recentes, mostrados na busca vazia sob "Recent": lista de linhas, no mesmo formato das de `sections`.
  // Sem recentes, a seção não aparece.
  property var recents: []
  // As ferramentas da busca vazia, na ordem do board: { key, label, icon }. A chave vai para `openTool`.
  readonly property var tools: [
    { key: "color", label: "Color picker", icon: "pipette" },
    { key: "emoji", label: "Emoji", icon: "smile" },
    { key: "screenshot", label: "Screenshot", icon: "scan" },
    { key: "clipboard", label: "Clipboard", icon: "clipboard" }
  ]
  // As linhas de ação do "sem resultado" ("Search the web", "Search files"). O que elas fazem é a P-73, ainda
  // aberta: por enquanto não ofereço nenhuma, e o aviso aparece sem elas.
  readonly property var fallbackRows: []

  // O resultado sai no formato do locale do sistema (decisão 0012; P-70).
  readonly property string decimalSeparator: Qt.locale().decimalPoint
  // null quando o texto não é um cálculo; senão { expression, result, hex, rows } (launcher/Calculator.js).
  // Enquanto não for null, o modo cálculo ocupa o launcher inteiro.
  readonly property var calculation: Calculator.describe(query, decimalSeparator)

  readonly property string mode: calculation ? "calculator" : "launcher"
  readonly property string modeLabel: calculation ? "Calculator" : "Launcher"
  readonly property string modeIcon: calculation ? "calculator" : "sparkles"
  // Ícone do cabeçalho de busca.
  readonly property string searchIcon: calculation ? "calculator" : "search"
  // Ações do rodapé: { label, keys, primary }. No cálculo só "Copy"; o "Paste" (Ctrl+↵) ficou de fora (P-71).
  readonly property var actions: calculation ? [
    { label: "Copy", keys: ["↵"], primary: true }
  ] : [
    { label: "Open", keys: ["↵"], primary: true },
    { label: "Actions", keys: ["Ctrl", "K"], primary: false }
  ]

  function open(requestedOutputName) {
    outputName = requestedOutputName || Settings.State.focusedOutputName();
    query = "";
    ghost = "";
    opened = true;
  }

  function close() {
    opened = false;
  }

  function toggle(requestedOutputName) {
    const targetOutput = requestedOutputName || Settings.State.focusedOutputName();
    if (opened && outputName === targetOutput)
      close();
    else
      open(targetOutput);
  }

  function setQuery(text) {
    query = text;
    ghost = "";
  }

  // Tab: o texto passa a ser a palavra inteira.
  function acceptGhost() {
    if (ghost === "")
      return;
    setQuery(query + ghost);
  }

  // O comando que copia o texto. O texto vai depois de `--`, como argumento, nunca por shell.
  function copyCommand(text) {
    return ["wl-copy", "--", text];
  }

  // O wl-copy fica vivo em segundo plano servindo a área de transferência, por isso `execDetached`.
  function copyText(text) {
    Quickshell.execDetached(copyCommand(text));
  }

  // Clique num chip, ou Enter com o chip em foco. Ainda não há o que abrir: registro no log e deixo o launcher aberto.
  function openTool(key) {
    console.info("launcher: ferramenta pedida, ainda sem destino:", key);
  }

  // Enter ou clique numa linha. A linha de ação do cálculo traz o texto em `copy`: copio e fecho. Sem fonte
  // de dados ainda para as outras linhas, só fecho.
  function activate(row) {
    if (row && row.copy !== undefined)
      copyText(String(row.copy));
    close();
  }
}
