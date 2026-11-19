pragma Singleton

import QtQuick
import ".."
import Quickshell

// O estado da janela de captura de tela (ficha 17, F6-T01 e T02). As janelas (CaptureWindow.qml, uma por tela) leem
// `opened`, `mode`, `showCursor`, `delaySeconds` e `pointerOutput`; o IPC `screenshot` do shell.qml e o chip "Screenshot" do
// launcher chamam `open`, `close` e `toggle`. A prévia pós-captura tem outro estado (State.qml) e não passa por aqui.
//
// A regra de ouro da ficha: a captura sempre começa do zero. Nenhuma propriedade abaixo é lida de arquivo nem guardada
// entre uma abertura e outra: `reset()` devolve tudo ao padrão na abertura e de novo no fechamento, para a próxima vez
// não herdar o modo, o cursor, o atraso nem o monitor da anterior.
//
// O ciclo, como o da lupa do seletor de cor (launcher/LoupeState.qml):
//   ""         fechada
//   "waiting"  o launcher ou os Ajustes saíram e eu espero eles sumirem da tela antes de capturar, para não saírem no quadro
//   "open"     as janelas estão à vista, cada uma com o quadro congelado do seu monitor
Singleton {
  id: root

  property string phase: ""
  readonly property bool waiting: phase === "waiting"
  readonly property bool opened: phase === "open"

  // Os modos, na ordem em que o Espaço os percorre.
  readonly property var modes: ["area", "window", "screen"]
  property string mode: "area"
  // Mostrar o cursor na captura. Desligado ao abrir.
  property bool showCursor: false
  // O atraso antes de capturar, em segundos. Sempre 0 ao abrir; o seletor é a F6-T03.
  property int delaySeconds: 0
  // O monitor em que o ponteiro está agora. Só a janela dele mostra a mira, a dica e a barra, e recebe o teclado.
  property string pointerOutput: ""
  // Os monitores cujo quadro já chegou.
  property var readyOutputs: []

  // Limite de falha, não valor de desenho: sem o protocolo de captura (como no GNOME) o quadro nunca chega, e depois
  // disto eu desisto e fecho. 2 s, o mesmo da lupa.
  readonly property int captureTimeout: 2000
  // Folga depois da animação de fechar do launcher e dos Ajustes: a janela deles só sai da tela depois do
  // `settingsCloseDuration` e o compositor leva alguns quadros para tirá-la. 100 ms, como na lupa.
  readonly property int settleMargin: 100

  property string pendingOutput: ""

  Timer {
    id: settleTimer
    interval: Theme.settingsCloseDuration + root.settleMargin
    onTriggered: root.show()
  }

  Timer {
    id: giveUpTimer
    interval: root.captureTimeout
    onTriggered: root.fail()
  }

  // Volta ao padrão de toda abertura (F6-T02): modo Area, cursor desligado, atraso 0 s, nenhum quadro recebido.
  function reset() {
    mode = "area";
    showCursor = false;
    delaySeconds = 0;
    readyOutputs = [];
  }

  // Abre a captura no monitor `outputName`. `afterClose` é verdadeiro quando o launcher ou os Ajustes estavam abertos e
  // acabaram de ser fechados: espero eles saírem da tela antes de capturar. Sem isso abro na hora.
  function open(outputName, afterClose) {
    if (phase !== "")
      return;
    reset();
    pendingOutput = outputName || "";
    pointerOutput = pendingOutput;
    if (afterClose) {
      phase = "waiting";
      settleTimer.restart();
    } else {
      show();
    }
  }

  function show() {
    if (phase === "open")
      return;
    pointerOutput = pendingOutput;
    phase = "open";
    giveUpTimer.restart();
  }

  // Fecha a captura (Esc, o botão de fechar, o IPC, abrir o launcher ou os Ajustes) e zera tudo.
  function close() {
    settleTimer.stop();
    giveUpTimer.stop();
    phase = "";
    pendingOutput = "";
    pointerOutput = "";
    reset();
  }

  function toggle(outputName) {
    if (phase !== "")
      close();
    else
      open(outputName, false);
  }

  // Abrir o launcher ou os Ajustes enquanto a captura está aberta a fecha.
  function abort() {
    if (phase !== "")
      close();
  }

  function setMode(newMode) {
    if (modes.indexOf(newMode) >= 0)
      mode = newMode;
  }

  // Espaço: Area, Window, Screen e de volta a Area.
  function nextMode() {
    mode = modes[(modes.indexOf(mode) + 1) % modes.length];
  }

  function toggleCursor() {
    showCursor = !showCursor;
  }

  // Um monitor entregou o quadro. Com todos prontos, não há mais o que esperar.
  function markReady(outputName) {
    if (phase !== "open" || readyOutputs.indexOf(outputName) >= 0)
      return;
    readyOutputs = readyOutputs.concat([outputName]);
    if (Quickshell.screens.every(screen => readyOutputs.indexOf(screen.name) >= 0))
      giveUpTimer.stop();
  }

  // O quadro não chegou a tempo: desisto e fecho, com um aviso no log.
  function fail() {
    if (phase !== "open")
      return;
    const missing = Quickshell.screens.map(screen => screen.name).filter(name => readyOutputs.indexOf(name) < 0);
    console.warn("screenshot: a captura não recebeu o quadro da tela em " + captureTimeout + " ms (monitores sem quadro: "
        + missing.join(", ") + "); sem o protocolo de captura do compositor ela não funciona. Fechando.");
    close();
  }
}
