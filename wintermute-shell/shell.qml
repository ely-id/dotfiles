//@ pragma Env QSG_RENDER_LOOP = threaded
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "battery" as Battery
import "calendar" as Calendar
import "settings" as Settings
import "settings/appearance" as Appearance
import "settings/system" as System
import "notifications" as Notifications
import "wallpaper/desktop" as Wallpaper

ShellRoot {
  id: root
  property bool expanded: true
  property bool testPanelOpen: false

  Shortcuts {}

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

  // A abertura automática do Manual na primeira execução fica desligada até a
  // F4 redesenhar settings/manual/Panel.qml (o SVG de 2,9 MB da origem não foi
  // baixado). O caminho já aponta para wintermute-shell/manual-shown.
  FileView {
    path: Quickshell.screens.length
        ? (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/wintermute-shell/manual-shown"
        : ""
    printErrors: false
  }

  IpcHandler {
    target: "test"
    function toggle() { root.testPanelOpen = !root.testPanelOpen; }
    function open() { root.testPanelOpen = true; }
    function close() { root.testPanelOpen = false; }
  }

  IpcHandler {
    target: "sidebar"
    function toggle() { root.expanded = !root.expanded; }
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
      Wallpaper.Window {
        screen: modelData
        custom: Appearance.State.wallpaperMode === "custom"
        dimmed: Theme.translucent
        imageSource: Appearance.State.wallpaperUrl
      }
      Sidebar {
        id: sidebar
        screen: modelData
        expanded: root.expanded
        onToggleRequested: root.expanded = !root.expanded
      }
      Notifications.ToastWindow { id: toast; bar: sidebar }
      Notifications.CenterWindow { bar: sidebar }
      Calendar.Window { bar: sidebar }
      Battery.Window { bar: sidebar }
      Battery.Notification { bar: sidebar; above: toast }
      PanelDismissWindow { bar: sidebar }
      Settings.Window { menuScreen: modelData }
      FontTestPanel {
        panelScreen: modelData
        opened: root.testPanelOpen
        onCloseRequested: root.testPanelOpen = false
      }
    }
  }
}
