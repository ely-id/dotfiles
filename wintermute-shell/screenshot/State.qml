pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import ".."
import Quickshell
import Quickshell.Io

Singleton {
  id: root
  property string imageSource: ""
  property string outputName: ""
  property int generation: 0
  property bool copied: false
  property bool dragging: false
  // O ponteiro está sobre a prévia (quem escreve é a peça, como em `dragging`). Com ele em cima o relógio de sumir não corre:
  // senão a prévia sumiria debaixo do ponteiro enquanto escolho um botão.
  property bool hovered: false
  readonly property string helper: decodeURIComponent(Qt.resolvedUrl("clipboard.py").toString().replace(/^file:\/\//, ""))

  function receive(path, output) {
    copied = false;
    if (!dragging) dismissTimer.restart();
    const reader = readerComponent.createObject(root, {
      captureGeneration: ++generation,
      captureOutput: output || Quickshell.screens[0]?.name || "",
      command: ["python3", helper, "read", path || ""]
    });
    reader.running = true;
  }

  function dismiss() {
    dismissTimer.stop();
    ++generation;
    imageSource = "";
    copied = false;
  }

  // Salvar e anotar ainda não têm destino: salvar é a F6-T03 e anotar a F6-T14. Até lá só registro o pedido no log, e a
  // prévia continua onde está.
  function save() {
    console.log("Screenshot preview: save is not available yet (F6-T03).");
  }

  function annotate() {
    console.log("Screenshot preview: annotate is not available yet (F6-T14).");
  }

  function copy() {
    if (!imageSource || copier.running) return;
    copier.captureGeneration = generation;
    copier.payload = imageSource.substring("data:image/png;base64,".length);
    copier.stdinEnabled = true;
    copier.running = true;
  }

  onDraggingChanged: {
    if (dragging) dismissTimer.stop();
    else if (imageSource) dismissTimer.restart();
  }

  // Saiu o ponteiro: o tempo de 6 s recomeça do zero. O `receive` e o fim da leitura também reiniciam o relógio com o ponteiro
  // em cima; por isso o `onTriggered` confere `hovered` e não some nesse caso.
  onHoveredChanged: {
    if (hovered) dismissTimer.stop();
    else if (imageSource && !dragging) dismissTimer.restart();
  }

  Component {
    id: readerComponent
    Process {
      id: reader
      required property int captureGeneration
      required property string captureOutput
      property string payload: ""
      stdout: StdioCollector { onStreamFinished: reader.payload = text.trim() }
      stderr: StdioCollector { onStreamFinished: if (text.trim()) console.warn(text.trim()) }
      onExited: code => {
        if (captureGeneration === root.generation && code === 0 && payload) {
          root.outputName = captureOutput;
          root.imageSource = "data:image/png;base64," + payload;
          root.copied = true;
          copyTag.restart();
          if (!root.dragging) dismissTimer.restart();
        }
        destroy();
      }
    }
  }

  Process {
    id: copier
    property int captureGeneration
    property string payload
    command: ["python3", root.helper, "copy"]
    onStarted: { write(payload); stdinEnabled = false; payload = ""; }
    stderr: StdioCollector { onStreamFinished: if (text.trim()) console.warn(text.trim()) }
    onExited: code => {
      if (code === 0 && captureGeneration === root.generation) {
        root.copied = true;
        copyTag.restart();
      }
    }
  }

  Timer {
    id: dismissTimer
    interval: Theme.capturePreviewDuration
    onTriggered: if (!root.hovered && !root.dragging) root.dismiss()
  }

  Timer {
    id: copyTag
    interval: Theme.launcherCopiedDuration   // o mesmo "copiado" do launcher ao copiar uma cor: o `check` por 1,5 s
    onTriggered: root.copied = false
  }
}
