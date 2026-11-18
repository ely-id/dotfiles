pragma Singleton

import QtQuick
import ".."
import "../settings" as Settings
import "Calculator.js" as Calculator
import "Colors.js" as Colors
import Quickshell
import Quickshell.Io

// Estado do launcher (ficha 14). É a superfície que a peça lê (decisão 0011); o serviço fictício de
// demo/LauncherService.qml tem os mesmos nomes. Na F5-T01 ainda não existe fonte de dados: `sections`, `recents`
// e `ghost` ficam vazios. A fonte de verdade chega na F5-T02. O cálculo (F5-T03) já funciona: depende
// só do texto, então `calculation`, o modo e o rodapé saem dele. As ferramentas do estado vazio (F5-T04) são
// fixas. O seletor de cor (F5-T08) abre uma página própria, `page === "color"`, com a cor mais recente do histórico;
// as outras (F5-T09 e a F6) ainda não existem, então `openTool` só registra no log para elas.
Singleton {
  id: root

  property bool opened: false
  property string outputName: ""
  property string query: ""
  // De onde o launcher foi aberto: { workspaceId, number } quando vem do "+" do organizador (o aplicativo escolhido
  // abre nesse workspace), null pelo atalho e pelo IPC. `number` é o que o organizador mostra, não o id do Niri.
  property var context: null
  readonly property string contextLabel: context ? "On workspace " + context.number : ""
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

  // A página aberta no lugar da busca: "" (a busca) ou "color" (o resultado do seletor de cor). Abrir o launcher
  // sempre começa na busca.
  property string page: ""

  readonly property string mode: page === "color" ? "color" : calculation ? "calculator" : "launcher"
  readonly property string modeLabel: page === "color" ? "Color picker" : calculation ? "Calculator" : "Launcher"
  readonly property string modeIcon: page === "color" ? "pipette" : calculation ? "calculator" : "sparkles"
  // Ícone do cabeçalho de busca.
  readonly property string searchIcon: calculation ? "calculator" : "search"
  // Ações do rodapé: { label, keys, primary }. No cálculo só "Copy"; o "Paste" (Ctrl+↵) ficou de fora (P-71).
  readonly property var actions: page === "color" ? [
    { label: "Copy HEX", keys: ["↵"], primary: true },
    { label: "Pick another", keys: ["P"], primary: false }
  ] : calculation ? [
    { label: "Copy", keys: ["↵"], primary: true }
  ] : [
    { label: "Open", keys: ["↵"], primary: true },
    { label: "Actions", keys: ["Ctrl", "K"], primary: false }
  ]

  // `requestedContext` é opcional: sem ele o launcher abre sem etiqueta. Quem abre pelo "+" já deixou o workspace
  // em foco (NiriMsg.openLauncher), então o que eu escolher nasce nele.
  function open(requestedOutputName, requestedContext) {
    outputName = requestedOutputName || Settings.State.focusedOutputName();
    query = "";
    ghost = "";
    context = requestedContext || null;
    closePage();
    // Uma abertura nova não tem cor "pega agora".
    colorFreshStamp = "";
    loadColors();
    opened = true;
  }

  function close() {
    opened = false;
    context = null;
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

  // ---- Seletor de cor (ficha 15, F5-T08) ----
  // O histórico: lista de { hex, pickedAt, app }, a mais nova primeiro, no máximo 12. Fica em
  // $XDG_STATE_HOME/wintermute-shell/colors.json e é relido toda vez que o launcher abre.
  property var colorHistory: []
  // A cor mostrada na página: uma das entradas do histórico, ou null fora da página.
  property var colorShown: null
  // O instante (`pickedAt`) da cor que entrou por `addColor` nesta abertura do launcher: a origem dela diz "Picked just now".
  property string colorFreshStamp: ""
  // O formato recém-copiado ("hex", "rgb", "hsl") durante `launcherCopiedDuration`, ou "".
  property string colorCopied: ""

  // { hex, rgb, hsl, name } da cor mostrada (launcher/Colors.js), ou null.
  readonly property var colorInfo: colorShown ? Colors.describe(colorShown.hex) : null
  readonly property string colorOrigin: {
    if (!colorShown)
      return "";
    const fresh = colorShown.pickedAt === colorFreshStamp;
    // Data e hora curtas no locale do sistema (decisão 0012); a cor "pega agora" não precisa delas.
    const when = fresh ? "" : new Date(colorShown.pickedAt).toLocaleString(Qt.locale(), Locale.ShortFormat);
    return Colors.originText(colorShown, fresh, when);
  }

  FileView {
    id: colorFile
    path: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state")
        + "/wintermute-shell/colors.json"
    // O arquivo é pequeno: leio e gravo sem esperar, como o histórico de notificações.
    blockLoading: true
    blockWrites: true
    atomicWrites: true
    printErrors: false
    onSaveFailed: error => console.warn("launcher: não gravei o histórico de cores:", error)
  }

  Timer {
    id: copiedTimer
    interval: Theme.launcherCopiedDuration
    onTriggered: root.colorCopied = ""
  }

  // Relê o arquivo. Ausente, ilegível ou fora do formato vale como lista vazia, sem erro na tela.
  function loadColors() {
    colorFile.reload();
    let text = "";
    try {
      text = colorFile.text();
    } catch (error) {
      text = "";
    }
    colorHistory = Colors.parseHistory(text, Theme.launcherColorHistoryMax);
  }

  function saveColors() {
    colorFile.setText(Colors.serializeHistory(colorHistory));
  }

  // A cor que a lupa pegou (F5-T12 chama isto, depois de `open`): vai para a frente do histórico sem repetir, o
  // histórico é cortado em 12, a cor fica marcada como "pega agora" e a página a mostra. `app` é o aplicativo em foco
  // quando peguei, se eu souber. Devolve se a cor era um HEX válido.
  function addColor(hex, app) {
    const clean = Colors.normalizeHex(hex);
    if (clean === "")
      return false;
    const entry = { hex: clean, pickedAt: new Date().toISOString(), app: app ? String(app) : "" };
    colorHistory = Colors.pushHistory(colorHistory, entry, Theme.launcherColorHistoryMax);
    colorFreshStamp = entry.pickedAt;
    colorShown = colorHistory[0];
    colorCopied = "";
    page = "color";
    saveColors();
    return true;
  }

  // Clique numa amostra do histórico: ela vira a cor mostrada, e a ordem do histórico não muda.
  function showColor(index) {
    if (index >= 0 && index < colorHistory.length) {
      colorShown = colorHistory[index];
      colorCopied = "";
    }
  }

  // Copia um formato da cor mostrada ("hex", "rgb" ou "hsl") e deixa a linha em "Copied" por 1,5 s. Não fecha o launcher.
  function copyColor(format) {
    const info = colorInfo;
    if (!info || ["hex", "rgb", "hsl"].indexOf(format) < 0)
      return;
    copyText(info[format]);
    colorCopied = format;
    copiedTimer.restart();
  }

  // Pegar uma cor: o launcher some e a lupa aparece sobre a tela congelada (LoupeState.qml, ficha 15). Guardo de onde
  // vim para o Esc: a página de resultado, com a cor que eu via, ou a busca. Se o launcher nem estava aberto (um
  // teste, por exemplo), o `begin` só esconde o que não existe.
  function pickAnother() {
    LoupeState.begin({
      output: outputName,
      context: context,
      fromPage: page === "color",
      shown: colorShown,
      stamp: colorFreshStamp
    });
  }

  // Volta à página de resultado com a cor que a lupa interrompeu (Esc na lupa). Vem depois do `open`, que zera a marca
  // de "pega agora": devolvo a que a cor tinha, porque é a mesma tela de antes.
  function restoreColorPage(shown, stamp) {
    colorShown = shown;
    colorFreshStamp = stamp || "";
    colorCopied = "";
    page = "color";
  }

  // Voltar ao launcher: busca vazia, sem a cor mostrada. A marca de "pega agora" fica até o launcher fechar.
  function closePage() {
    copiedTimer.stop();
    colorCopied = "";
    colorShown = null;
    page = "";
    if (query !== "")
      setQuery("");
  }

  // Clique num chip, ou Enter com o chip em foco. O seletor de cor abre a página com a cor mais recente, ou vai direto
  // para a lupa quando não há nenhuma guardada. Para as outras ferramentas ainda não há o que abrir: registro no log e
  // deixo o launcher aberto.
  function openTool(key) {
    if (key === "color") {
      if (colorHistory.length > 0) {
        colorShown = colorHistory[0];
        colorCopied = "";
        page = "color";
      } else {
        pickAnother();
      }
      return;
    }
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
