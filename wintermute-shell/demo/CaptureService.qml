import QtQuick

// O serviço fictício da captura de tela (decisão 0011, ficha 17): a mesma superfície de screenshot/CaptureState.qml
// (`mode`, `showCursor`, `delaySeconds`, `setMode`, `nextMode`, `toggleCursor`, `close`), sem janela e sem captura. Clicar
// nos modos e no botão do cursor muda o estado, e o espécime reage; `close()` só conta, porque a vitrine não fecha nada.
QtObject {
  id: root

  property string mode: "area"
  property bool showCursor: false
  property int delaySeconds: 0
  // Quantas vezes pediram para fechar (para o teste de comportamento).
  property int closeCount: 0

  readonly property var modes: ["area", "window", "screen"]

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

  function close() {
    closeCount++;
  }
}
