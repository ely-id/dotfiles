pragma Singleton
import QtQuick
import ".." as Settings
import Quickshell
import Quickshell.Io

// Estado das páginas do Sistema (ficha 13): idiomas do teclado e mouse/touchpad, lidos e gravados
// por control.py no input.kdl do Niri. O fuso horário saiu na F4-T02 (P-34): o relógio segue o sistema.
Singleton {
  id: root
  readonly property string helper: decodeURIComponent(Qt.resolvedUrl("control.py").toString().replace(/^file:\/\//, ""))
  property var languages: []
  property var selectedLanguages: []
  property var languageNames: []
  property string error: ""
  property var mouse: ({touchpadSpeed: 5, mouseSpeed: 5, acceleration: true, naturalTouchpad: true, naturalMouse: false})
  readonly property bool busy: action.running
  readonly property bool active: Settings.State.opened && ["system", "mouse", "keyboard"].indexOf(Settings.State.page) >= 0
  onActiveChanged: if (active) { error = ""; query.running = true; }
  Process {
    id: query
    command: ["python3", root.helper, "load"]
    stdout: StdioCollector { onStreamFinished: root.accept(text) }
  }
  Process {
    id: action
    stdout: StdioCollector { onStreamFinished: root.accept(text) }
  }
  Timer {
    id: mouseCommit
    interval: 300
    onTriggered: if (root.busy) restart(); else root.apply(["mouse", root.mouse.touchpadSpeed, root.mouse.mouseSpeed, root.mouse.acceleration, root.mouse.naturalTouchpad, root.mouse.naturalMouse].map(String))
  }
  function accept(text) {
    try {
      const result = JSON.parse(text);
      if (result.error) { error = result.error; return; }
      if (result.languages) languages = result.languages;
      selectedLanguages = result.selectedLanguages;
      languageNames = result.languageNames;
      if (!mouseCommit.running) mouse = result.mouse;
      error = "";
    } catch (e) { error = "Could not read system settings"; }
  }
  function apply(args) {
    if (busy) return;
    error = "";
    action.command = ["python3", root.helper].concat(args);
    action.running = true;
  }
  function toggleLanguage(id) { apply(["keyboard", id]); }
  function setMouse(key, value) { mouse = Object.assign({}, mouse, {[key]: value}); mouseCommit.restart(); }
}
