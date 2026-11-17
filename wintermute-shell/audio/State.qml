pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

// Shared PipeWire authority for the sidebar sound controls. The UI consumes
// real device nodes directly, so device names, selection and volume stay in
// sync with keyboard shortcuts and every other PipeWire client.
Singleton {
  id: root

  readonly property var sink: Pipewire.ready
      ? Pipewire.defaultAudioSink : null
  readonly property var source: Pipewire.ready ? Pipewire.defaultAudioSource : null
  readonly property var deviceNodes: Pipewire.ready ? Pipewire.nodes.values.filter(node =>
      !node.isStream && node.name !== "quickshell" && node.properties["media.name"] !== "quickshell") : []
  readonly property var outputDevices: deviceNodes.filter(node =>
      node.isSink && !unpluggedDevices[node.name])
  readonly property var inputDevices: deviceNodes.filter(node =>
      !node.isSink && node.audio && !unpluggedDevices[node.name])

  readonly property real outputVolume: clampVolume(
      sink && sink.audio ? sink.audio.volume : 0)
  readonly property real inputVolume: clampVolume(
      source && source.audio ? source.audio.volume : 0)
  readonly property bool hasOutput: !!(sink && sink.audio)
  readonly property bool hasInput: !!(source && source.audio)
  readonly property bool outputMuted: hasOutput && sink.audio.muted

  property var unpluggedDevices: ({})
  property int observedSinkId: -1
  property double suppressExternalUntil: 0

  signal keyboardOutputVolumeChanged(real value)

  function clampVolume(value) {
    const numeric = Number(value);
    if (!isFinite(numeric))
      return 0;
    return Math.max(0, Math.min(1, numeric));
  }

  function displayName(node) {
    if (!node)
      return "Unknown device";
    return String(node.description || node.nickname || node.name
                  || "Unknown device");
  }

  // Ícone Lucide da linha (ficha 07): saída = alto-falante, fones ou monitor (HDMI e afins);
  // entrada = microfone ou fones.
  function deviceIcon(node) {
    if (!node)
      return "speaker";
    const props = node.properties || ({});
    const text = [props["device.form-factor"], props["device.icon-name"], displayName(node)]
        .join(" ").toLowerCase();
    const headphones = /head(set|phone)|fone|earbud|buds/.test(text);
    if (!node.isSink)
      return headphones ? "headphones" : "mic";
    if (/hdmi|displayport|monitor|display|\btv\b/.test(text))
      return "monitor";
    return headphones ? "headphones" : "speaker";
  }

  function suppressExternalChanges(duration) {
    suppressExternalUntil = Math.max(
        suppressExternalUntil, Date.now() + (duration || 300));
  }

  function setOutputVolume(value) {
    if (!hasOutput)
      return;
    suppressExternalChanges(350);
    sink.audio.muted = false;
    sink.audio.volume = clampVolume(value);
  }

  function setInputVolume(value) {
    if (!hasInput)
      return;
    source.audio.muted = false;
    source.audio.volume = clampVolume(value);
  }

  function adjustOutputVolume(delta) {
    if (!hasOutput) return;
    setOutputVolume(outputVolume + delta);
    keyboardOutputVolumeChanged(outputVolume);
  }

  function toggleOutputMute() {
    if (!hasOutput) return;
    // Esta função já avisa abaixo; sem a janela, o observador de mudo avisaria uma segunda vez.
    suppressExternalChanges(350);
    sink.audio.muted = !sink.audio.muted;
    keyboardOutputVolumeChanged(outputVolume);
  }

  function toggleInputMute() {
    if (hasInput) source.audio.muted = !source.audio.muted;
  }

  function setOutputDevice(node) {
    if (!node || !Pipewire.ready)
      return;
    suppressExternalChanges(500);
    Pipewire.preferredDefaultAudioSink = node;
  }

  function setInputDevice(node) {
    if (!node || !Pipewire.ready)
      return;
    Pipewire.preferredDefaultAudioSource = node;
  }

  function refreshPorts() {
    portQuery.running = true;
  }

  function receivePorts(text) {
    const server = JSON.parse(text);
    const unplugged = {};
    for (const device of server.sinks.concat(server.sources)) {
      if (device.ports.length > 0 && device.ports.every(
          port => port.availability === "not available"))
        unplugged[device.name] = true;
    }
    unpluggedDevices = unplugged;
  }

  onOutputVolumeChanged: {
    const currentSinkId = sink ? Number(sink.id) : -1;
    if (currentSinkId !== observedSinkId) {
      observedSinkId = currentSinkId;
      return;
    }
    if (Date.now() >= suppressExternalUntil)
      keyboardOutputVolumeChanged(outputVolume);
  }

  // A tecla de mudo do Niri roda `wpctl set-mute ... toggle`, que muda o mudo sem mexer no volume,
  // então o tratador do volume acima nunca vê essa troca. Este observador avisa o OSD quando o mudo
  // muda por fora da shell.
  //
  // Não reaproveito o `observedSinkId` do volume: aquele tratador engole a primeira mudança de cada
  // aparelho, e aqui isso faria a primeira tecla de mudo depois da subida sumir. Guardo em vez disso
  // o último par (aparelho, mudo) que vi e o atualizo sempre, avisando só quando o aparelho é o
  // mesmo e o mudo trocou. A subida (sem saída ou aparelho novo aparecendo) e a troca de aparelho só
  // atualizam o par; a primeira tecla depois delas já encontra um par válido e avisa.
  // Um detalhe sustenta isso: o `audio` do nó aparece com o mudo desligado e o valor de verdade chega
  // alguns milissegundos depois, como uma troca de mudo no mesmo aparelho. Quem cala esse passo é a
  // janela de 500 ms que o `onDefaultAudioSinkChanged`, mais abaixo, abre. Encurtar aquela janela faz
  // o OSD aparecer sozinho na subida com a saída muda.
  //
  // Leio o aparelho direto do Pipewire, e não de `sink` e `outputMuted`, porque estes três sinais
  // chegam em ordem indefinida e uma leitura atrasada de uma propriedade derivada faria o par errar.
  QtObject {
    id: muteWatch
    property int sinkId: -1
    property bool muted: false

    function observe() {
      const node = Pipewire.ready ? Pipewire.defaultAudioSink : null;
      const audio = node ? node.audio : null;
      const currentId = audio ? Number(node.id) : -1;
      const currentMuted = !!(audio && audio.muted);
      const sameDevice = currentId !== -1 && currentId === sinkId;
      const changed = currentMuted !== muted;
      sinkId = currentId;
      muted = currentMuted;
      if (sameDevice && changed && Date.now() >= root.suppressExternalUntil)
        root.keyboardOutputVolumeChanged(root.outputVolume);
    }
  }

  // Se o Pipewire já estiver pronto quando a shell sobe, nenhum sinal de mudança chega; sem esta
  // chamada o par ficaria vazio e a primeira tecla de mudo seria tomada como "aparelho novo".
  Component.onCompleted: muteWatch.observe()
  onOutputMutedChanged: muteWatch.observe()
  onSinkChanged: muteWatch.observe()
  onHasOutputChanged: muteWatch.observe()

  Connections {
    target: Pipewire
    function onDefaultAudioSinkChanged() {
      root.suppressExternalChanges(500);
      root.observedSinkId = root.sink ? Number(root.sink.id) : -1;
    }
  }

  PwObjectTracker { objects: [root.sink, root.source].filter(node => node !== null) }

  Process {
    id: portQuery
    command: ["pactl", "-f", "json", "list"]
    environment: ({ "LC_ALL": "C" })
    running: true
    stdout: StdioCollector { onStreamFinished: root.receivePorts(text) }
  }
}
