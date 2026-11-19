import QtQuick

// O serviço fictício da captura de tela (decisão 0011, ficha 17): a mesma superfície de screenshot/CaptureState.qml
// (`mode`, `showCursor`, `delaySeconds`, `selection`, `selectionOutput`, `selecting`, `setMode`, `nextMode`, `toggleCursor`,
// `setSelection`, `clearSelection`, `copySelection`, `saveSelection`, `annotateSelection`, `capture`, `captureWindow`,
// `captureScreen`, `close`, mais a foto das janelas `windowSnapshot`), sem janela e sem captura. Clicar nos modos e no botão do cursor muda o estado, e o espécime reage; `close()` e as quatro ações só contam,
// porque a vitrine não fecha nem captura nada.
QtObject {
  id: root

  property string mode: "area"
  property bool showCursor: false
  property int delaySeconds: 0
  // A seleção de área ({ x, y, width, height } em pixels do palco, ou null), o monitor dela (a vitrine tem um só: "") e se o
  // ponteiro ainda a arrasta.
  property var selection: null
  property string selectionOutput: ""
  property bool selecting: false
  // A foto das janelas de cada monitor, no formato do CaptureState: { nomeDoMonitor: [ { id, appId, title, entryName, isFloating,
  // layout } ] } com o `layout` cru do Niri. Quem monta é o espécime, com janelas inventadas.
  property var windowSnapshot: ({})
  // Quantas vezes pediram cada coisa (para o teste de comportamento).
  property int closeCount: 0
  property int copyCount: 0
  property int saveCount: 0
  property int annotateCount: 0
  property int captureCount: 0
  // As escolhas dos modos Window e Screen: quantas vezes e o último id de janela e o último nome de monitor.
  property int windowCaptureCount: 0
  property int lastWindowId: -1
  property int screenCaptureCount: 0
  property string lastScreenName: ""

  readonly property var modes: ["area", "window", "screen"]

  // Sair do modo Area apaga a seleção, como no serviço de verdade.
  onModeChanged: {
    if (mode !== "area")
      clearSelection();
  }

  function setMode(newMode) {
    if (modes.indexOf(newMode) >= 0)
      mode = newMode;
  }

  function nextMode() {
    mode = modes[(modes.indexOf(mode) + 1) % modes.length];
  }

  function toggleCursor() {
    showCursor = !showCursor;
  }

  function setSelection(outputName, rect, dragging) {
    selection = rect;
    selectionOutput = outputName;
    selecting = !!dragging;
  }

  function clearSelection() {
    selection = null;
    selectionOutput = "";
    selecting = false;
  }

  function copySelection() { copyCount++; }
  function saveSelection() { saveCount++; }
  function annotateSelection() { annotateCount++; }
  function capture() { captureCount++; }
  function captureWindow(id) {
    lastWindowId = id;
    windowCaptureCount++;
  }
  function captureScreen(outputName) {
    lastScreenName = outputName;
    screenCaptureCount++;
  }

  function close() {
    closeCount++;
  }
}
