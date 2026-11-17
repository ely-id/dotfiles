pragma Singleton

import QtQuick
import "../settings" as Settings
import Quickshell

// Estado do launcher (ficha 14). É a superfície que a peça lê (decisão 0011); o serviço fictício de
// demo/LauncherService.qml tem os mesmos nomes. Na F5-T01 ainda não existe fonte de dados: `sections`
// fica vazia, `ghost` fica vazio e `activate` só fecha. A fonte de verdade chega na F5-T02.
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

  readonly property string mode: "launcher"
  readonly property string modeLabel: "Launcher"
  readonly property string modeIcon: "sparkles"
  // Ações do rodapé: { label, keys, primary }. O modo cálculo troca esta lista na F5-T03.
  readonly property var actions: [
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

  // Enter ou clique numa linha. Sem fonte de dados ainda, só fecho.
  function activate(row) {
    close();
  }
}
