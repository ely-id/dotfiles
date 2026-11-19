pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import ".."
import "." as Screenshot
import "Save.js" as Save
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
  // De onde a imagem da prévia veio: o arquivo que o Niri salvou (Super+Shift+2 e 3), ou o temporário da captura da shell. Serve para o "salvar"
  // não gravar uma segunda cópia do que o Niri já salvou na pasta de capturas (F6-T03). Vazio quando a imagem veio da área de transferência.
  property string sourcePath: ""
  readonly property string helper: decodeURIComponent(Qt.resolvedUrl("clipboard.py").toString().replace(/^file:\/\//, ""))

  function receive(path, output) {
    copied = false;
    if (!dragging) dismissTimer.restart();
    const reader = readerComponent.createObject(root, {
      captureGeneration: ++generation,
      captureOutput: output || Quickshell.screens[0]?.name || "",
      captureSource: path || "",
      command: ["python3", helper, "read", path || ""]
    });
    reader.running = true;
  }

  function dismiss() {
    dismissTimer.stop();
    ++generation;
    imageSource = "";
    sourcePath = "";
    copied = false;
  }

  // Salvar (F6-T03): grava a imagem da prévia na pasta das capturas (SavedState.dir) com o nome no padrão do Niri, mostra o aviso "Screenshot saved"
  // e fecha a prévia. Se a gravação falhar, fica um aviso no log e a prévia continua. As capturas do Niri chegam aqui com um arquivo que ele já
  // salvou: estando ele dentro da pasta de capturas, não gravo outra cópia, só mostro o aviso com o caminho dele.
  function save() {
    if (!imageSource || saver.running)
      return;
    if (Save.isInside(sourcePath, Screenshot.SavedState.dir)) {
      Screenshot.CaptureState.notifySaved(sourcePath, outputName);
      dismiss();
      return;
    }
    saver.captureGeneration = generation;
    saver.captureOutput = outputName;
    saver.target = Screenshot.SavedState.nextPath();
    saver.payload = imageSource.substring("data:image/png;base64,".length);
    saver.stdinEnabled = true;
    saver.running = true;
  }

  // Anotar abre o editor (F6-T14) com a imagem que a prévia mostra, no monitor dela, e fecha a prévia. A imagem vai como o `data:` que a
  // prévia já guarda: o arquivo de onde ela veio pode já não existir (a captura seguinte apaga o anterior).
  function annotate() {
    if (!imageSource)
      return;
    const source = imageSource;
    const output = outputName;
    dismiss();
    Screenshot.AnnotateState.open(source, output);
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
      required property string captureSource
      property string payload: ""
      stdout: StdioCollector { onStreamFinished: reader.payload = text.trim() }
      stderr: StdioCollector { onStreamFinished: if (text.trim()) console.warn(text.trim()) }
      onExited: code => {
        if (captureGeneration === root.generation && code === 0 && payload) {
          root.outputName = captureOutput;
          root.sourcePath = captureSource;
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

  // O `save` do clipboard.py: cria a pasta, confere o PNG e grava sem sobrescrever um arquivo que já exista.
  Process {
    id: saver
    property int captureGeneration
    property string captureOutput
    property string target
    property string payload
    command: ["python3", root.helper, "save", target]
    onStarted: { write(payload); stdinEnabled = false; payload = ""; }
    stderr: StdioCollector { onStreamFinished: if (text.trim()) console.warn(text.trim()) }
    onExited: code => {
      if (code !== 0) {
        console.warn("Screenshot preview: could not save the screenshot; the preview stays.");
        return;
      }
      // O arquivo está gravado: o aviso sai mesmo que a prévia já tenha mudado enquanto gravava. Só fecho a prévia se ainda for a mesma.
      Screenshot.CaptureState.notifySaved(target, captureOutput);
      if (captureGeneration === root.generation)
        root.dismiss();
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
