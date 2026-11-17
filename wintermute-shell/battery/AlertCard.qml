import QtQuick
import QtQuick.Effects
import Quickshell
import "." as Battery
import ".." as Shell

// Alerta de bateria baixa (ficha 08): 176×40, raio 12, só com a barra recolhida. Ícone battery-low
// e texto "Bateria em N%" em dangerText, botão de fechar 24×24 r6 à direita.
Shell.GlassSurface {
  id: root
  property var service: Battery.State
  signal dismissed

  radius: 12
  implicitWidth: 176
  implicitHeight: 40

  Image {
    x: 12; y: 12
    width: 16; height: 16
    source: Qt.resolvedUrl("../icons/battery-low.svg")
    sourceSize: Qt.size(32, 32)
    layer.enabled: true
    layer.effect: MultiEffect { colorization: 1; colorizationColor: Shell.Theme.dangerText }
  }

  Text {
    x: 36
    width: 100
    anchors.verticalCenter: parent.verticalCenter
    elide: Text.ElideRight
    text: "Battery at " + root.service.level + "%"
    color: Shell.Theme.dangerText
    font.family: Shell.Theme.fontFamily
    font.weight: Font.Medium
    font.pixelSize: Shell.Theme.fontBody
    font.letterSpacing: 0
  }

  Rectangle {
    x: 144; y: 8
    width: 24; height: 24
    radius: 6
    color: dismissPointer.containsMouse ? Shell.Theme.hover : "transparent"

    Image {
      anchors.centerIn: parent
      width: 16; height: 16
      source: Qt.resolvedUrl("../icons/x.svg")
      sourceSize: Qt.size(32, 32)
      layer.enabled: true
      layer.effect: MultiEffect { colorization: 1; colorizationColor: Shell.Theme.dangerText }
    }
    MouseArea {
      id: dismissPointer
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: root.dismissed()
      Accessible.role: Accessible.Button
      Accessible.name: "Dismiss"
      Accessible.onPressAction: root.dismissed()
    }
  }
}
