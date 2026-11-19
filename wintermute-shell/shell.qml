//@ pragma Env QSG_RENDER_LOOP = threaded
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "battery" as Battery
import "calendar" as Calendar
import "clipboard" as Clipboard
import "launcher" as Launcher
import "settings" as Settings
import "settings/appearance" as Appearance
import "settings/system" as System
import "notifications" as Notifications
import "screenshot" as Screenshot
import "wallpaper/desktop" as Wallpaper

ShellRoot {
  id: root
  property bool expanded: true
  property bool sidebarDemoCards: false
  property bool testPanelOpen: false
  property bool demoPanelOpen: false

  Shortcuts {}

  // A escuta da área de transferência (ficha 18) só liga aqui, na shell de verdade: a vitrine e a bancada importam o serviço e não
  // ganham processo nenhum. Sem o protocolo de controle de dados do compositor (como no GNOME) o histórico fica vazio, com um aviso.
  Component.onCompleted: Clipboard.State.start()

  // O bloqueio antes de suspender dependia de um plugin compilado que mora na
  // tela de bloqueio da origem. Tirei na F0 para a shell abrir só com QML.
  // A ligação com a tela de bloqueio volta na F7.

  Variants {
    readonly property var commands: ({
      lock: ["python3", Quickshell.shellDir + "/settings/session.py", "lock"],
      sleep: ["python3", Quickshell.shellDir + "/settings/session.py", "suspend"]
    })
    model: Object.keys(commands).filter(key => System.Idle.current[key] > 0)
        .map(key => ({timeout: System.Idle.current[key], command: commands[key]}))
    delegate: IdleMonitor {
      required property var modelData
      timeout: modelData.timeout
      onIsIdleChanged: if (isIdle) Quickshell.execDetached(modelData.command)
    }
  }

  IdleFade {}

  // O Manual abre sozinho na primeira vez que a shell roda (ficha 13). O arquivo
  // manual-shown marca que ele já foi visto; sem o arquivo, abro o Manual e o crio.
  FileView {
    path: Quickshell.screens.length
        ? (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/wintermute-shell/manual-shown"
        : ""
    printErrors: false
    onLoadFailed: error => {
      if (error !== FileViewError.FileNotFound) return;
      Settings.State.open("", "manual");
      Qt.callLater(() => setText("shown\n"));
    }
  }

  IpcHandler {
    target: "test"
    function toggle() { root.testPanelOpen = !root.testPanelOpen; }
    function open() { root.testPanelOpen = true; }
    function close() { root.testPanelOpen = false; }
  }

  IpcHandler {
    target: "demo"
    function toggle() { root.demoPanelOpen = !root.demoPanelOpen; }
    function open() { root.demoPanelOpen = true; }
    function close() { root.demoPanelOpen = false; }
  }

  IpcHandler {
    target: "sidebar"
    function toggle() { root.expanded = !root.expanded; }
    function demoCards() { root.sidebarDemoCards = !root.sidebarDemoCards; }
  }

  IpcHandler {
    target: "launcher"
    function toggle() { Launcher.State.toggle(); }
    function open() { Launcher.State.open(); }
    function close() { Launcher.State.close(); }
    // O Super+V: o histórico da área de transferência direto, no monitor em foco; com ele aberto, fecha.
    function clipboard() { Launcher.State.toggleClipboard(); }
  }

  // O launcher e os Ajustes pedem teclado exclusivo na mesma camada, então abrir um fecha o outro. A lupa do seletor
  // de cor (launcher/LoupeWindow.qml) também: abrir qualquer um dos dois enquanto ela está aberta a cancela, sem
  // reabrir o launcher.
  Connections {
    target: Settings.State
    function onOpenedChanged() {
      if (!Settings.State.opened) return;
      Launcher.State.close();
      Launcher.LoupeState.abort();
      Screenshot.CaptureState.abort();
      Screenshot.AnnotateState.close();
    }
  }
  // O "+" do organizador pede o launcher pelo NiriMsg (que fica na raiz e não importa launcher/): abre no monitor
  // daquele organizador, com o número do workspace na etiqueta.
  Connections {
    target: NiriMsg
    function onLauncherRequested(outputName, workspaceId, number) {
      Launcher.State.open(outputName, { workspaceId: workspaceId, number: number });
    }
  }
  Connections {
    target: Launcher.State
    function onOpenedChanged() {
      if (!Launcher.State.opened) return;
      Settings.State.close();
      Launcher.LoupeState.abort();
      Screenshot.CaptureState.abort();
      Screenshot.AnnotateState.close();
    }
  }

  // A captura de tela (ficha 17) também pede teclado exclusivo, então abrir a captura fecha o launcher, os Ajustes, a lupa e o editor de anotação.
  // Quem já estava aberto saiu agora: a captura espera ele sumir da tela antes de pegar o quadro (CaptureState.open).
  Connections {
    target: Screenshot.CaptureState
    function onPhaseChanged() {
      if (Screenshot.CaptureState.phase === "")
        return;
      Launcher.State.close();
      Settings.State.close();
      Launcher.LoupeState.abort();
      Screenshot.AnnotateState.close();
    }
  }

  // O editor de anotação (ficha 17, estado 5) pede teclado exclusivo também: abrir o editor fecha o launcher, os Ajustes, a lupa e a captura.
  Connections {
    target: Screenshot.AnnotateState
    function onOpenedChanged() {
      if (!Screenshot.AnnotateState.opened) return;
      Launcher.State.close();
      Settings.State.close();
      Launcher.LoupeState.abort();
      Screenshot.CaptureState.abort();
    }
  }

  // A captura abre no monitor em foco, como o launcher. Com o launcher, os Ajustes ou o editor abertos ela espera eles sumirem da tela antes de
  // pegar o quadro, para não saírem na imagem.
  IpcHandler {
    target: "screenshot"
    function open() {
      Screenshot.CaptureState.open(Settings.State.focusedOutputName(),
          Launcher.State.opened || Settings.State.opened || Screenshot.AnnotateState.opened);
    }
    function close() { Screenshot.CaptureState.close(); }
    function toggle() {
      if (Screenshot.CaptureState.phase !== "")
        Screenshot.CaptureState.close();
      else
        open();
    }
  }

  IpcHandler {
    target: "manual"
    function open() { Settings.State.open("", "manual"); }
  }

  IpcHandler {
    target: "settings"
    function toggle() { Settings.State.toggle(); }
    function open(page: string) {
      if (page && Settings.State.pages.indexOf(page) < 0) return;
      Settings.State.open("", page);
    }
    function close() { Settings.State.close(); }
  }

  Variants {
    model: Quickshell.screens
    delegate: Scope {
      required property var modelData
      // O papel de parede que vale nesta tela e no modo atual dos aplicativos (F4-T24): com as chaves do
      // cartão Customize desligadas, o marcado na grade, como sempre.
      readonly property var placed: Appearance.State.wallpaperFor(modelData.name)
      Wallpaper.Window {
        screen: modelData
        custom: placed.custom
        dimmed: Theme.translucent
        imageSource: placed.url
      }
      Sidebar {
        id: sidebar
        screen: modelData
        expanded: root.expanded
        demoCards: root.sidebarDemoCards
        onToggleRequested: root.expanded = !root.expanded
      }
      Notifications.ToastWindow { id: toast; bar: sidebar }
      Screenshot.SavedToastWindow { bar: sidebar }
      Notifications.CenterWindow { bar: sidebar }
      Calendar.Window { bar: sidebar }
      Battery.Window { bar: sidebar }
      Battery.Notification { bar: sidebar; above: toast }
      PanelDismissWindow { bar: sidebar }
      Settings.Window { menuScreen: modelData }
      Launcher.Window { menuScreen: modelData }
      Launcher.LoupeWindow { menuScreen: modelData }
      Screenshot.CaptureWindow { menuScreen: modelData }
      Screenshot.AnnotateWindow { menuScreen: modelData }
      FontTestPanel {
        panelScreen: modelData
        opened: root.testPanelOpen
        onCloseRequested: root.testPanelOpen = false
      }
      ComponentDemoPanel {
        panelScreen: modelData
        opened: root.demoPanelOpen
        sidebarDemoCards: root.sidebarDemoCards
        onToggleSidebarDemoCards: root.sidebarDemoCards = !root.sidebarDemoCards
        onCloseRequested: root.demoPanelOpen = false
      }
    }
  }
}
