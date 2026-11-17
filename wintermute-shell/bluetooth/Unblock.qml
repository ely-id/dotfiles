import QtQuick
import Quickshell
import Quickshell.Io

// Desbloqueio do rádio Bluetooth pelo rfkill. Deixei a sequência separada do State.qml para
// poder testá-la sem o BlueZ: quem usa só liga `blocked` ao estado do adaptador, chama run() e
// espera o sinal finished.
//
// A sequência: roda o comando; se ele falha, termina com o motivo; se ele passa, espera o
// adaptador sair do estado bloqueado. Um bloqueio de hardware (chave física ou modo avião da
// placa) faz o rfkill voltar com 0 e o adaptador continuar bloqueado, e é por isso que a espera
// tem limite.
Scope {
  id: root

  // O comando é propriedade para o teste trocar por um falso. O padrão não pede sudo porque o
  // /dev/rfkill tem ACL de escrita para o meu usuário.
  property var command: ["rfkill", "unblock", "bluetooth"]
  // Ligada de fora ao estado do adaptador (BluetoothAdapterState.Blocked).
  property bool blocked: false
  // Verdadeira do run() até o fim, depois de o finished ter sido emitido. Assim quem trata o
  // finished (por exemplo mandando o `power`) ainda vê a chave ocupada e não há um instante livre
  // entre o desbloqueio e o próximo passo.
  readonly property bool busy: _stage !== ""

  // success é verdadeiro quando o adaptador saiu do bloqueio; senão error traz o texto de interface.
  signal finished(bool success, string error)

  // Tempo que espero o adaptador sair do bloqueio depois de o rfkill terminar com 0. É espera de
  // processo, não valor de desenho: o BlueZ avisa a mudança em poucas dezenas de milissegundos, e 3 s
  // sobra para a máquina lenta e ainda é curto o bastante para o bloqueio de hardware não parecer travado.
  readonly property int settleTimeout: 3000

  // "" (parado), "running" (esperando o comando), "settling" (esperando o adaptador) ou "finishing".
  property string _stage: ""
  property string _stderrText: ""
  property bool _stderrDone: false
  property int _exitCode: -1
  property bool _exited: false
  property bool _started: false

  function run() {
    if (busy) return;
    _stderrText = "";
    _stderrDone = false;
    _exited = false;
    _started = false;
    _stage = "running";
    process.command = command;
    process.running = true;
  }

  function _finish(success, error) {
    settle.stop();
    _stage = "finishing";  // mantém busy até depois do sinal e não deixa nada reentrar
    finished(success, error);
    _stage = "";
  }

  // O stderr e a saída do processo chegam em eventos separados, sem ordem garantida entre eles.
  // Só decido quando os dois chegaram, para não perder a primeira linha do erro.
  function _evaluate() {
    if (_stage !== "running" || !_exited || !_stderrDone) return;
    if (_exitCode !== 0) {
      const firstLine = _stderrText.split("\n").map(line => line.trim()).find(line => line !== "");
      _finish(false, "Could not unblock Bluetooth: " + (firstLine || "rfkill exited with code " + _exitCode));
    } else if (!blocked) {
      _finish(true, "");
    } else {
      _stage = "settling";
      settle.restart();
    }
  }

  onBlockedChanged: if (_stage === "settling" && !blocked) _finish(true, "")

  Process {
    id: process
    environment: ({ "LC_ALL": "C" })
    stderr: StdioCollector {
      onStreamFinished: { root._stderrText = text; root._stderrDone = true; root._evaluate(); }
    }
    onStarted: root._started = true
    // O Quickshell não tem sinal de falha de início: quando o binário não existe, só avisa no log e
    // devolve `running` a falso, sem started nem exited. Essa é a minha pista de que o rfkill falta.
    onRunningChanged: {
      if (!running && root._stage === "running" && !root._started && !root._exited)
        root._finish(false, "Could not unblock Bluetooth: rfkill is not installed");
    }
    onExited: (exitCode, exitStatus) => { root._exitCode = exitCode; root._exited = true; root._evaluate(); }
  }

  Timer {
    id: settle
    interval: root.settleTimeout
    onTriggered: root._finish(!root.blocked,
        root.blocked ? "Bluetooth is still blocked. Check the hardware switch or airplane mode." : "")
  }
}
