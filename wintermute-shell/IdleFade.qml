import QtQuick
import Quickshell
import Quickshell.Wayland
import "settings/system" as System

// Escurece todas as telas até o preto quando passa o tempo de "desligar a tela" e depois desliga os
// monitores (ficha 12). O véu sobe de 0 a 100% em 5 s, em linha reta: 50% aos 2,5 s e preto aos 5 s,
// que são os três quadros do Figma. Qualquer atividade encerra o estado ocioso e o véu some.
Scope {
  id: root
  readonly property int duration: 5000

  IdleMonitor {
    id: idle
    enabled: timeout > 0
    timeout: System.Idle.current.display
  }

  Timer {
    interval: root.duration
    running: idle.isIdle
    onTriggered: Quickshell.execDetached(["niri", "msg", "action", "power-off-monitors"])
  }

  Variants {
    model: idle.isIdle ? Quickshell.screens : []
    PanelWindow {
      required property var modelData
      screen: modelData
      color: "transparent"
      anchors { left: true; right: true; top: true; bottom: true }
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.namespace: "pond-idle-fade"
      WlrLayershell.exclusionMode: ExclusionMode.Ignore
      mask: Region {}
      ColorAnimation on color { to: "black"; duration: root.duration; easing.type: Easing.Linear }
    }
  }
}
