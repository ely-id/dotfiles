pragma Singleton
import QtQuick
import QtCore
import ".." as Settings
import "../.." as Shell
import "../../wallpaper/daylight/SkyState.js" as SkyState
import "Places.js" as Places
import Quickshell
import Quickshell.Io

Singleton {
  id: root
  property string expandedSection: ""
  property string wallpaperMode: "dynamic"
  property string wallpaperPath: ""
  property string wallpaperUrl: ""
  property var wallpapers: []
  property bool wallpaperRefreshPending: false
  property string placeJob: ""
  // Papéis de parede por lugar (F4-T24, P-67). As duas chaves do cartão Customize e as escolhas de cada
  // lugar, como o wallpaper.json as guarda; a chave de um lugar é "light", "dark", "display:<conector>" ou
  // "display:<conector>:light|dark" (ver Places.js). Lugar sem escolha usa o marcado na grade.
  property bool followScheme: false
  property bool perDisplay: false
  property var places: ({})
  // A chave do lugar para o qual a grade está escolhendo; vazia quando a grade escolhe o marcado de sempre.
  property string choosingPlace: ""
  // Uma escolha foi gravada no lugar (a navegação devolve o cartão Customize).
  signal placeSaved(string key)
  property var display: ({})
  property real brightness: 1
  property real pendingBrightness: -1
  property string pendingBrightnessOutput: ""
  property bool draggingBrightness: false
  property string error: ""
  // Modo claro ou escuro dos aplicativos ("dark" ou "light"), como o GSettings o tem. Só muda quando o
  // modo de fato mudou (a F4-T24 ouve este valor para trocar o papel de parede junto).
  property string appsScheme: "dark"
  // Troca por horário ligada (apps.json). `appsPeriod` é o período ("day" ou "night") que a shell aplicou
  // por último; vazio quer dizer que ainda não aplicou nenhum desde que a chave foi ligada ou a shell subiu.
  property bool appsAutomatic: false
  property string appsPeriod: ""
  property var appsQueue: []
  signal keyboardBrightnessChanged(string outputName, real value)
  // A tecla de brilho falhou (P-62): o OSD mostra o alerta. O motivo que a página Aparência exibe continua
  // vindo da leitura do estado, então este sinal não mexe em `error` nem em `display`.
  signal keyboardBrightnessFailed(string outputName, string reason)
  readonly property bool pickingWallpaper: picker.running
  readonly property bool busy: action.running || picker.running
  readonly property bool active: Settings.State.opened && Settings.State.page === "appearance"
  // O cartão Customize também conta: a grade fica viva atrás dele e as miniaturas das linhas vêm da lista.
  readonly property bool wallpapersActive: Settings.State.opened
      && (Settings.State.page === "wallpaper" || Settings.State.page === "customize")
  // O marcado na grade, como existia antes dos lugares.
  readonly property var grid: ({ mode: wallpaperMode, path: wallpaperPath, url: wallpaperUrl })
  // O que a grade marca: o que vale no lugar em escolha (a escolha dele ou, sem escolha, o marcado na
  // grade) ou, sem lugar em escolha, o marcado na grade.
  readonly property var marked: Places.resolve(grid, places, choosingPlace)
  readonly property string markedMode: marked.mode
  readonly property string markedPath: marked.path
  // O título do seletor: o nome do lugar em escolha (o mesmo texto da linha do cartão) ou vazio.
  readonly property string choosingName: Places.nameOf(choosingPlace)
  // Os conectores ligados, a tela embutida primeiro, e as linhas do cartão Customize: cada uma com a
  // chave, o nome, a miniatura que vale (`dynamic`, `url`).
  readonly property var connectors: Places.sortConnectors(screenNames())
  readonly property var placeRows: Places.rows(followScheme, perDisplay, connectors, places, grid)
  readonly property bool brightnessAvailable: display.brightness !== undefined && display.brightness !== null
  // O motivo que o control.py já devolve em frase pronta (sem ddcutil, sem permissão no i2c, sem DDC).
  readonly property string brightnessError: display.brightnessError || ""

  onWallpapersActiveChanged: if (wallpapersActive) loadWallpapers()
  // O lugar em escolha só vale com a grade à vista: zero quando o cartão volta, quando os Ajustes saem do
  // papel de parede e quando fecham.
  Connections {
    target: Settings.State
    function onPageChanged() { if (Settings.State.page !== "wallpaper") root.choosingPlace = ""; }
    function onOpenedChanged() { if (!Settings.State.opened) root.choosingPlace = ""; }
  }
  Component.onCompleted: readApps()

  onActiveChanged: {
    // Releio o modo ao abrir a página: eu posso ter mudado por fora (o GSettings não é vigiado).
    if (active) { expandedSection = ""; error = ""; settleDelay.restart(); readApps(); }
    else settleDelay.stop();
  }
  // DDC/CI brightness reads stall the GPU's display driver for a few hundred
  // ms, freezing every animating window. Only query once the page is static.
  Timer { id: settleDelay; interval: Shell.Theme.settingsCloseDuration + 60; onTriggered: root.refresh() }
  Connections {
    target: Settings.State
    function onOutputNameChanged() { root.display = ({}); if (root.active) root.refresh(); }
  }
  FileView {
    id: wallpaperFile
    path: StandardPaths.writableLocation(StandardPaths.ConfigLocation) + "/pond-interface/wallpaper.json"
    printErrors: false
    watchChanges: true
    onFileChanged: reload()
    onLoaded: {
      try {
        const state = JSON.parse(text());
        root.wallpaperMode = state.mode === "custom" ? "custom" : "dynamic";
        root.wallpaperPath = state.path || "";
        root.wallpaperUrl = state.url || "";
        root.followScheme = state.followScheme === true;
        root.perDisplay = state.perDisplay === true;
        root.places = Places.cleanPlaces(state.places);
      } catch(e) { console.warn("Appearance wallpaper:", e); }
    }
  }
  Process {
    id: query
    property string outputName
    onExited: if (root.active && outputName !== Settings.State.outputName) root.refresh()
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          const result = JSON.parse(text);
          if (query.outputName !== Settings.State.outputName) return;
          if (result.error) { root.error = result.error; return; }
          root.display = result;
          if (!root.draggingBrightness && root.pendingBrightness < 0 && !brightnessWriter.running && result.brightness !== null)
            root.brightness = result.brightness;
        } catch(e) { root.error = "Could not read display settings"; }
      }
    }
  }
  Process {
    id: action
    stdout: StdioCollector {
      onStreamFinished: root.finishPlace(root.receive(text, "Could not apply appearance settings"))
    }
    onExited: {
      if (root.wallpaperRefreshPending) root.loadWallpapers();
      else if (root.active) root.refresh();
    }
  }
  FileView {
    path: StandardPaths.writableLocation(StandardPaths.ConfigLocation) + "/background"
    printErrors: false
    watchChanges: true
    // Quem põe o arquivo é outro programa: vale para o marcado na grade, mesmo com um lugar em escolha.
    onFileChanged: root.applyWallpaper(["set", "custom", decodeURIComponent(path.replace(/^file:\/\//, ""))])
  }
  Process {
    id: picker
    command: ["python3", Quickshell.shellDir + "/wallpaper/control.py", "pick"]
    stdout: StdioCollector {
      onStreamFinished: root.finishPlace(root.receive(text, "Could not open the image picker"))
    }
    onExited: if (root.wallpaperRefreshPending) root.loadWallpapers()
  }
  Process {
    id: brightnessWriter
    property string outputName
    stdout: StdioCollector {
      onStreamFinished: root.receive(text, "Could not change brightness")
    }
    onExited: (exitCode, exitStatus) => {
      if (exitCode !== 0 && outputName === root.display.output)
        root.display = Object.assign({}, root.display, {brightnessDevice: null});
      if (root.pendingBrightness >= 0) brightnessDelay.restart();
      else if (!root.draggingBrightness && exitCode !== 0) root.refresh();
    }
  }
  // Fila de um processo só para tudo o que toca o modo dos aplicativos (ler, gravar o modo, gravar a chave
  // automática): na ordem em que pedi, para uma leitura nunca passar na frente de uma gravação.
  Process {
    id: appsProcess
    property var job: ({})
    stdout: StdioCollector {
      onStreamFinished: root.receiveApps(appsProcess.job, text)
    }
    onExited: Qt.callLater(root.runApps)
  }
  // Não confio num temporizador até a próxima passagem do dia para a noite: a máquina suspende. Confiro
  // o período a cada minuto e só aplico quando ele mudou desde o último que apliquei.
  Timer {
    interval: 60000
    running: root.appsAutomatic
    repeat: true
    onTriggered: root.applyAppsPeriod()
  }
  Timer { id: brightnessDelay; interval: 90; onTriggered: root.flushBrightness() }

  // Os nomes dos conectores ligados, na ordem em que o Quickshell os lista.
  function screenNames() {
    const names = [];
    for (let index = 0; index < Quickshell.screens.length; index++) names.push(Quickshell.screens[index].name);
    return names;
  }
  // O papel de parede que vale numa tela, para o `shell.qml`: se é imagem e qual `url`. Depende das duas
  // chaves, dos lugares, do marcado na grade e do modo dos aplicativos, então a janela troca de papel de
  // parede sozinha quando qualquer um deles muda, à mão ou pelo horário.
  function wallpaperFor(connector) {
    return Places.forScreen(followScheme, perDisplay, places, grid, connector, appsScheme);
  }
  // Devolve o resultado lido (ou null) para quem precisa saber se a gravação de um lugar deu certo.
  function receive(text, failure) {
    try {
      const result = JSON.parse(text);
      if (result.error) {
        error = result.error;
        // Uma chave do cartão que não gravou volta ao que o arquivo diz.
        wallpaperFile.reload();
      }
      // As gravações devolvem o mesmo que o `list`; aplico já, sem esperar o arquivo ser relido.
      if (result.places !== undefined) places = Places.cleanPlaces(result.places);
      if (result.followScheme !== undefined) followScheme = result.followScheme === true;
      if (result.perDisplay !== undefined) perDisplay = result.perDisplay === true;
      if (result.theme) {
        Shell.Theme.setName(result.theme);
        Shell.Theme.reload();
      }
      if (result.mode) wallpaperFile.reload();
      if (result.wallpapers && JSON.stringify(result.wallpapers) !== JSON.stringify(wallpapers))
        wallpapers = result.wallpapers;
      return result;
    } catch (exception) { error = failure; }
    return null;
  }
  // `placeJob` é a chave do lugar que o comando em andamento grava. Terminou sem erro e sem cancelar:
  // o cartão Customize volta (o seletor avisa pelo sinal).
  function finishPlace(result) {
    const key = placeJob;
    placeJob = "";
    if (key !== "" && result && !result.error && !result.cancelled) placeSaved(key);
  }
  function refresh() {
    if (query.running || brightnessWriter.running || draggingBrightness || !Settings.State.outputName) return;
    query.outputName = Settings.State.outputName;
    query.command = ["python3", Quickshell.shellDir + "/settings/appearance/control.py", "status", query.outputName,
        cachedDevice(query.outputName)];
    query.running = true;
  }
  function cachedDevice(output) {
    return display.output === output && display.brightnessDevice ? JSON.stringify(display.brightnessDevice) : "";
  }
  function receiveBrightness(output, value) {
    if (output === display.output && !draggingBrightness && pendingBrightness < 0 && !brightnessWriter.running)
      brightness = value;
    keyboardBrightnessChanged(output, value);
  }
  function receiveBrightnessFailure(output, reason) {
    keyboardBrightnessFailed(output, reason);
  }
  // O período de uma data, pela regra do "Dynamic" do papel de parede: dia do nascer ao pôr do sol
  // (SkyState.DEFAULTS, em hora decimal local), noite fora disso. Pura: só olha a data que recebe.
  function periodOf(date) {
    const hour = date.getHours() + date.getMinutes() / 60;
    return hour >= SkyState.DEFAULTS.sunrise && hour < SkyState.DEFAULTS.sunset ? "day" : "night";
  }
  function applyAppsPeriod() {
    const period = periodOf(new Date());
    if (period === appsPeriod) return;
    appsPeriod = period;
    writeAppsScheme(period === "day" ? "light" : "dark", true);
  }
  function setAppsDark(dark) {
    error = "";
    writeAppsScheme(dark ? "dark" : "light", false);
  }
  function setAppsAutomatic(automatic) {
    if (automatic === appsAutomatic) return;
    appsAutomatic = automatic;
    // Ligar (ou desligar) zera o período aplicado: ligada, aplico o do horário na hora, mesmo que seja o
    // mesmo de antes de eu desligar.
    appsPeriod = "";
    enqueueApps({ kind: "automatic", args: ["apps-automatic", automatic ? "true" : "false"] });
    if (automatic) applyAppsPeriod();
  }
  function writeAppsScheme(scheme, automatic) {
    enqueueApps({ kind: "scheme", scheme: scheme, automatic: automatic, args: ["apps-scheme", scheme] });
  }
  function readApps() { enqueueApps({ kind: "read", args: ["apps-status"] }); }
  function enqueueApps(job) {
    appsQueue = appsQueue.concat([job]);
    runApps();
  }
  function runApps() {
    if (appsProcess.running || appsQueue.length === 0) return;
    appsProcess.job = appsQueue[0];
    appsQueue = appsQueue.slice(1);
    appsProcess.command = ["python3", Quickshell.shellDir + "/settings/appearance/control.py"].concat(appsProcess.job.args);
    appsProcess.running = true;
  }
  function receiveApps(job, text) {
    let result;
    try { result = JSON.parse(text); } catch (exception) {
      result = { error: job.kind === "read" ? "Could not read the app color mode" : "Could not change the app color mode" };
    }
    if (job.kind === "read") {
      // Erro só de leitura não vai para a tela: fica no log e a página segue com o que tinha.
      if (result.error) { console.warn("Appearance apps:", result.error); return; }
      appsScheme = result.scheme === "dark" ? "dark" : "light";
      appsAutomatic = result.automatic === true;
      if (appsAutomatic) applyAppsPeriod();
      return;
    }
    if (!result.error) {
      if (job.kind === "scheme") appsScheme = job.scheme;
      return;
    }
    error = result.error;
    // Troca por horário que falhou tenta de novo no minuto seguinte; as outras voltam a mostrar o que vale.
    if (job.automatic) appsPeriod = "";
    else readApps();
  }
  function toggleSection(section) { expandedSection = expandedSection === section ? "" : section; }
  function apply(args, script = "settings/appearance/control.py") {
    if (action.running || picker.running) return;
    error = "";
    action.command = ["python3", Quickshell.shellDir + "/" + script].concat(args);
    action.running = true;
  }
  function applyWallpaper(args) { apply(args, "wallpaper/control.py"); }
  function selectTheme(theme) {
    if (busy) return;
    Shell.Theme.setName(theme);
    apply(["theme", theme]);
  }
  // Com um lugar em escolha, a escolha vai para o lugar; sem, para o marcado na grade, como sempre.
  function selectDynamic() {
    if (choosingPlace) applyPlace(["place", choosingPlace, "dynamic"]);
    else applyWallpaper(["set", "dynamic"]);
  }
  function selectWallpaper(path) {
    if (choosingPlace) applyPlace(["place", choosingPlace, "custom", path]);
    else applyWallpaper(["set", "custom", path]);
  }
  function applyPlace(args) {
    if (action.running || picker.running) return;
    placeJob = choosingPlace;
    applyWallpaper(args);
  }
  // As duas chaves do cartão. A chave muda na hora; o comando grava e devolve o que ficou. Se a gravação
  // falhar, o `receive` mostra o erro e o arquivo relido desfaz a mudança.
  function setFollowScheme(on) { setOption("follow-scheme", on); }
  function setPerDisplay(on) { setOption("per-display", on); }
  function setOption(name, on) {
    if (busy || on === (name === "follow-scheme" ? followScheme : perDisplay)) return;
    if (name === "follow-scheme") followScheme = on; else perDisplay = on;
    applyWallpaper(["option", name, on ? "true" : "false"]);
  }
  // Tocar numa linha do cartão: a grade passa a escolher para aquele lugar (quem navega é o seletor).
  function beginPlace(key) { if (Places.validKey(key)) { error = ""; choosingPlace = key; } }
  function cancelPlace() { choosingPlace = ""; }
  function loadWallpapers() {
    wallpaperRefreshPending = action.running || picker.running;
    if (!wallpaperRefreshPending) applyWallpaper(["list"]);
  }
  function pickWallpaper() {
    if (busy) return;
    error = "";
    placeJob = choosingPlace;
    picker.command = ["python3", Quickshell.shellDir + "/wallpaper/control.py", "pick"]
        .concat(choosingPlace ? [choosingPlace] : []);
    picker.running = true;
  }
  function setBrightness(value) {
    brightness = Math.max(0.01, Math.min(1, value));
    pendingBrightness = brightness;
    pendingBrightnessOutput = Settings.State.outputName;
    brightnessDelay.restart();
  }
  function flushBrightness() {
    if (brightnessWriter.running || pendingBrightness < 0) return;
    error = "";
    brightnessWriter.outputName = pendingBrightnessOutput;
    brightnessWriter.command = ["python3", Quickshell.shellDir + "/settings/appearance/control.py", "brightness",
        pendingBrightnessOutput, String(pendingBrightness), cachedDevice(pendingBrightnessOutput)];
    pendingBrightness = -1;
    brightnessWriter.running = true;
  }
}
