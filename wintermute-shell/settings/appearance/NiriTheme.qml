pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "../.." as Shell

// O anel de foco das janelas do Niri no acento da variação (ficha 19, estado 1). Quem escreve o arquivo é o niri_theme.py, que deixa
// `niri/cfg/wintermute.kdl` com o anel de 2 px e o raio 12 das janelas; este singleton só decide quando chamá-lo: uma vez quando a shell
// começa (o shell.qml chama `start()`, e a vitrine e a bancada não) e toda vez que o acento muda. O Niri observa os arquivos incluídos
// e recarrega sozinho, e o script não reescreve o arquivo quando o conteúdo já é o mesmo.
//
// Espero a primeira leitura do theme.json (`Theme.selectionLoaded`) antes de chamar: sem isso a primeira chamada levaria o acento
// padrão e a segunda, a escolha de verdade, e o anel piscaria numa cor que eu não escolhi.
Singleton {
  id: root

  property bool started: false
  readonly property bool ready: started && Shell.Theme.selectionLoaded
  // O acento da variação em uso, no #RRGGBB em maiúsculas que o script pede.
  readonly property string accent: String(Shell.Theme.accent).toUpperCase()
  // Pedido em andamento: uma troca que chega com o script rodando espera ele acabar e roda de novo, para duas chamadas nunca
  // disputarem o arquivo e a última cor vencer.
  property bool busy: false
  property bool pending: false

  readonly property string script: decodeURIComponent(Qt.resolvedUrl("niri_theme.py").toString().replace(/^file:\/\//, ""))

  // Gancho que o teste troca: roda o comando e chama `done(código, mensagem)` quando ele acaba.
  property var execute: (argv, done) => {
    runner.createObject(root, { command: argv, done: done }).running = true;
  }

  function start() {
    started = true;
  }

  function apply() {
    if (busy) {
      pending = true;
      return;
    }
    busy = true;
    const color = accent;
    execute(["python3", script, "generate", "--accent", color], (code, message) => {
      busy = false;
      // Falha do script não derruba nada: a shell segue com o anel que o Niri já tinha.
      if (code !== 0)
        console.warn("niri-theme: o niri_theme.py saiu com código " + code + (message ? ": " + message : "") + ". Sigo sem mudar o anel de foco.");
      if (pending) {
        pending = false;
        if (accent !== color)
          apply();
      }
    });
  }

  onReadyChanged: if (ready) apply()
  onAccentChanged: if (ready) apply()

  Component {
    id: runner
    Process {
      id: process
      property var done
      stderr: StdioCollector { id: errors }
      stdout: StdioCollector { id: output }
      onExited: code => {
        const message = (errors.text || output.text).trim();
        const callback = done;
        process.destroy();
        callback(code, message);
      }
    }
  }
}
