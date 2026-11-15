pragma Singleton
import QtQuick
import QtCore
import Quickshell
import Quickshell.Io
import "../installs" as Installs
import "../settings" as Settings

// Integração de atualizações do sistema com o Cachy Update / arch-update (P-32).
// Lê os arquivos de estado que o cachy-update grava em ~/.local/state/arch-update/:
//   - last_updates_check: pacotes disponíveis para atualização (1 por linha)
//   - tray_icon: "cachy-update_updates-available-..." quando há atualizações
//   - last_update_run: data da última execução concluída
Singleton {
  id: root
  property string status: ""
  property string pending: ""
  property int availableCount: 0

  readonly property string stateDir: (Quickshell.env("XDG_STATE_HOME")
      || (StandardPaths.writableLocation(StandardPaths.GenericStateLocation)
          || Quickshell.env("HOME") + "/.local/state")) + "/arch-update"
  readonly property string runtimeStatusPath: (Quickshell.env("XDG_RUNTIME_DIR") || "/tmp")
      + "/wintermute-cachy-update"

  function _recomputeFromFiles() {
    const lines = updatesCheckFile.loadedText.split("\n")
        .map(line => line.trim())
        .filter(line => line.length > 0);
    availableCount = lines.length;
    const trayHasUpdates = trayIconFile.loadedText.indexOf("updates-available") !== -1;
    if (root.status === "updating")
      return;
    if (availableCount > 0 || trayHasUpdates) {
      root.status = "available";
    } else if (root.status === "available") {
      root.status = "";
    }
  }

  function start() {
    if (status !== "available")
      return;
    pending = "";
    Settings.State.close();
    root.status = "updating";
    Installs.State.update("system-update", "Sistema", "installing", -1, "", "refresh-cw");
    Quickshell.execDetached(["sh", "-c",
      'rm -f "$1.after"; echo updating > "$1"; '
      + 'ghostty --title="Cachy-Update" -e cachy-update; '
      + 'if [ ! -f "/usr/lib/modules/$(uname -r)/vmlinuz" ]; then echo restart > "$1"; '
      + 'elif [ -s "$2" ]; then echo available > "$1"; '
      + 'else echo complete > "$1"; fi; '
      + 'action=$(cat "$1.after" 2>/dev/null) && [ -n "$action" ] && python3 "$3" "$action"',
      "sh", runtimeStatusPath, stateDir + "/last_updates_check",
      Quickshell.shellDir + "/settings/session.py"]);
  }

  function checkNow() {
    if (!checkProcess.running)
      checkProcess.running = true;
  }

  function after(action) {
    pending = pending === action ? "" : action;
    afterFile.setText(pending);
  }

  // Sondagem periódica via cachy-update --check (o systemd user timer do
  // arch-update também atualiza os mesmos arquivos em ~/.local/state/arch-update).
  Timer {
    interval: 6 * 60 * 60 * 1000
    running: true
    repeat: true
    triggeredOnStart: false
    onTriggered: root.checkNow()
  }

  Process {
    id: checkProcess
    command: ["cachy-update", "--check"]
    onExited: {
      updatesCheckFile.reload();
      trayIconFile.reload();
    }
  }

  Timer {
    interval: 60 * 60 * 1000
    running: root.status === "complete"
    onTriggered: root.status = ""
  }

  FileView {
    id: updatesCheckFile
    property string loadedText: ""
    path: root.stateDir + "/last_updates_check"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: {
      loadedText = text();
      root._recomputeFromFiles();
    }
  }

  FileView {
    id: trayIconFile
    property string loadedText: ""
    path: root.stateDir + "/tray_icon"
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: {
      loadedText = text().trim();
      root._recomputeFromFiles();
    }
  }

  FileView {
    id: statusFile
    path: root.runtimeStatusPath
    watchChanges: true
    printErrors: false
    onFileChanged: reload()
    onLoaded: {
      const result = text().trim();
      const wasUpdating = root.status === "updating";
      if (result === "updating") {
        root.status = "updating";
        Installs.State.update("system-update", "Sistema", "installing", -1, "", "refresh-cw");
      } else if (result === "restart") {
        root.status = "restart";
        if (wasUpdating)
          Installs.State.update("system-update", "Sistema", "installed", 100, "", "refresh-cw");
      } else if (wasUpdating && result === "complete") {
        root.status = "complete";
        Installs.State.update("system-update", "Sistema", "installed", 100, "", "refresh-cw");
      } else if (wasUpdating && result === "available") {
        root.status = "available";
        Installs.State.dismiss("system-update");
      } else if (wasUpdating && result === "failed") {
        root.status = "available";
        Installs.State.update("system-update", "Sistema", "failed", -1, "", "refresh-cw");
      }
    }
  }

  FileView {
    id: afterFile
    path: statusFile.path + ".after"
    printErrors: false
    onLoaded: root.pending = text().trim()
  }
}
