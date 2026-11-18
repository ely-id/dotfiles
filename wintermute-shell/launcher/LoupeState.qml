pragma Singleton

import QtQuick
import ".."
import "." as Launcher
import Quickshell

// O estado da lupa do seletor de cor (ficha 15, "Pegando a cor: como funciona", P-77). Separado do State.qml para
// ele não crescer com o ciclo da lupa. Quem pede a lupa é `State.pickAnother()`, que chama `begin`; as janelas
// (LoupeWindow.qml, uma por tela) leem `picking` e `pointerOutput` e devolvem o clique (`pick`), o cancelamento
// (`cancel`) e a captura pronta (`markReady`).
//
// O ciclo:
//   ""         lupa fechada
//   "waiting"  o launcher saiu e eu espero ele sumir da tela antes de capturar, para ele não sair no quadro
//   "picking"  as janelas estão à vista, cada uma com o quadro congelado do seu monitor
// Do "waiting" ao "picking" é a animação de fechar do launcher mais uma folga; do "picking" a falha, se algum
// quadro não chegar em `captureTimeout`.
Singleton {
  id: root

  property string phase: ""
  readonly property bool waiting: phase === "waiting"
  readonly property bool picking: phase === "picking"
  // O monitor em que o ponteiro está agora. Só a janela dele mostra a lupa e recebe o teclado.
  property string pointerOutput: ""

  // De onde eu vim, para o Esc: { output, context, fromPage, shown, stamp }.
  property var origin: null
  // Os monitores cujo quadro já chegou e já foi lido.
  property var readyOutputs: []

  // Limite de falha, não valor de desenho: sem o protocolo de captura (como no GNOME) ou com erro, o quadro nunca
  // chega, e depois disto eu desisto, fecho a lupa e reabro o launcher onde eu estava. 2 s.
  readonly property int captureTimeout: 2000
  // Folga depois da animação de fechar do launcher. A janela dele só sai da tela (e o desfoque do compositor com
  // ela) depois do `settingsCloseDuration`, e o compositor leva alguns quadros para tirá-la; 100 ms cobrem isso
  // sem o launcher aparecer no quadro capturado.
  readonly property int settleMargin: 100

  // A última janela em foco: o launcher, ao abrir, tira o foco do aplicativo (teclado exclusivo), então o
  // "aplicativo em foco quando peguei" é o último que esteve em foco antes. Guardo o id e não o appId: se a
  // janela fechar nesse meio tempo, ela não conta.
  property int lastFocusedWindow: -1
  readonly property var focusedWindow: {
    const windows = NiriMsg._windows || {};
    for (const id in windows) {
      if (windows[id].isFocused)
        return windows[id];
    }
    return null;
  }
  onFocusedWindowChanged: {
    if (focusedWindow)
      lastFocusedWindow = focusedWindow.id;
  }
  // O singleton nasce na primeira leitura (a das janelas da lupa, ao carregar a shell); a janela que já estiver em
  // foco nessa hora também conta, e o `changed` não dispara para o valor inicial.
  Component.onCompleted: {
    if (focusedWindow)
      lastFocusedWindow = focusedWindow.id;
  }

  Timer {
    id: settleTimer
    interval: Theme.settingsCloseDuration + root.settleMargin
    onTriggered: {
      if (root.phase !== "waiting")
        return;
      root.readyOutputs = [];
      root.phase = "picking";
      giveUpTimer.restart();
    }
  }

  Timer {
    id: giveUpTimer
    interval: root.captureTimeout
    onTriggered: root.fail()
  }

  // `State.pickAnother()` chama isto. `from` diz onde o launcher estava: { output, context, fromPage, shown, stamp }.
  // Esconde o launcher e, depois da animação dele, mostra as janelas da lupa.
  function begin(from) {
    if (phase !== "")
      return;
    origin = from;
    pointerOutput = from.output;
    phase = "waiting";
    Launcher.State.close();
    settleTimer.restart();
  }

  // Um monitor entregou o quadro e a lupa já o leu. Com todos prontos, não há mais o que esperar.
  function markReady(outputName) {
    if (phase !== "picking" || readyOutputs.indexOf(outputName) >= 0)
      return;
    readyOutputs = readyOutputs.concat([outputName]);
    if (Quickshell.screens.every(screen => readyOutputs.indexOf(screen.name) >= 0))
      giveUpTimer.stop();
  }

  // A captura não chegou a tempo: desisto e volto para onde eu estava, com um aviso no log.
  function fail() {
    if (phase !== "picking")
      return;
    const missing = Quickshell.screens.map(screen => screen.name).filter(name => readyOutputs.indexOf(name) < 0);
    console.warn("launcher: a lupa não recebeu a captura de tela em " + captureTimeout + " ms (monitores sem quadro: "
        + missing.join(", ") + "); sem o protocolo de captura do compositor ela não funciona. Voltando ao launcher.");
    cancel();
  }

  // Fecha a lupa sem guardar (Esc, botão direito, falha) e reabre o launcher onde eu estava: a página de resultado com
  // a cor que eu via, se vim dela; senão a busca.
  function cancel() {
    if (phase === "")
      return;
    const from = origin;
    close();
    // Reabro no monitor de onde vim. O contexto (o "+" do organizador) só volta nele.
    Launcher.State.open(from.output, from.context);
    if (from.fromPage && from.shown)
      Launcher.State.restoreColorPage(from.shown, from.stamp);
  }

  // O clique: guarda o HEX com o aplicativo que estava em foco e reabre o launcher no monitor do clique, na página de
  // resultado. O `addColor` vem depois do `open`, que zera a marca de "pega agora".
  function pick(hex, outputName) {
    if (phase === "")
      return;
    const from = origin;
    close();
    Launcher.State.open(outputName || from.output);
    Launcher.State.addColor(hex, focusedAppName());
  }

  // Abrir os Ajustes ou o launcher por atalho enquanto a lupa está aberta cancela a lupa, sem reabrir nada.
  function abort() {
    if (phase !== "")
      close();
  }

  // Zera o ciclo. Chamo antes de reabrir o launcher: o `open` dele dispara o `abort` do shell.qml, que já não acha lupa.
  function close() {
    settleTimer.stop();
    giveUpTimer.stop();
    phase = "";
    origin = null;
    readyOutputs = [];
  }

  // O nome do aplicativo em foco como a shell o mostra (o nome da entrada .desktop), ou "" se eu não souber.
  function focusedAppName() {
    const window = (NiriMsg._windows || {})[lastFocusedWindow];
    if (!window || window.appId === "")
      return "";
    const entry = DesktopEntries.heuristicLookup(window.appId);
    return entry && entry.name ? String(entry.name) : "";
  }
}
