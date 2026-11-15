import QtQuick
import QtQuick.Effects

// Botão fechar pendurado Armitage (ficha 00): 40×40, raio 12, ícone x 20 em (10,10).
// Superfície de vidro + rim no repouso; hover = fundo accent e ícone textOnAccent.
Item {
  id: root
  property bool forceHovered: false
  readonly property bool hovered: forceHovered || closeHover.hovered
  signal clicked

  implicitWidth: 40
  implicitHeight: 40

  Shadow {
    anchors.fill: parent
    cornerRadius: Theme.radiusIconButton40
    shadows: Theme.glassShadows
  }

  Rectangle {
    anchors.fill: parent
    radius: Theme.radiusIconButton40
    color: root.hovered ? Theme.accent : "transparent"
    border.width: 0
    antialiasing: true

    GradientFill {
      visible: !root.hovered
      radius: Theme.radiusIconButton40
      showGlow: false
    }

    PanelBorder {
      radius: Theme.radiusIconButton40
      z: 2
    }

    Image {
      x: 10
      y: 10
      width: 20
      height: 20
      source: Qt.resolvedUrl("icons/x.svg")
      sourceSize: Qt.size(40, 40)
      fillMode: Image.PreserveAspectFit
      smooth: true
      antialiasing: true
      layer.enabled: root.hovered
      layer.effect: MultiEffect {
        colorization: 1
        colorizationColor: Theme.textOnAccent
      }
    }
  }

  HoverHandler {
    id: closeHover
    enabled: !root.forceHovered
    cursorShape: Qt.PointingHandCursor
  }
  TapHandler {
    enabled: !root.forceHovered
    onTapped: root.clicked()
  }
}
