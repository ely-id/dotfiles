import QtQuick
import QtQuick.Effects
import Quickshell
import ".." as Shell

// Botão de sessão da tela inicial dos Ajustes (ficha 13; Figma 13:15832 e 13:15898).
// Vidro de 128×128, raio 12, sem o brilho do acento. Círculo de 80 em `control` em
// (24,24) com o ícone de 20. No hover o botão inteiro vira `danger` (Desligar) ou
// `accent` (os outros três), o círculo escurece para o fundo a 55%, o rim some e o nome
// aparece à direita em Geist Serif 32, em dangerText ou accentText, 60 ms depois.
// O Desligar tem um ponto dangerText de 8 em (100,20), que some no hover.
Item {
  id: root

  property string iconName: ""
  property string label: ""
  property bool danger: false
  property bool showStatusDot: false
  property bool revealed: false
  // Hover vindo de fora: o selo "Restart recommended" acende o Reiniciar.
  property bool highlighted: false
  // Fixa o hover na vitrine.
  property bool forceHovered: false
  property bool labelShown: false
  signal clicked

  readonly property bool hovered: (pointer.containsMouse && pointer.enabled) || highlighted || forceHovered
  readonly property color fillColor: danger ? Shell.Theme.danger : Shell.Theme.accent
  readonly property color labelColor: danger ? Shell.Theme.dangerText : Shell.Theme.accentText
  readonly property Region blurRegion: Region {
    item: root.revealed && root.opacity > Shell.Theme.blurRevealOpacity ? root : null
    radius: Shell.Theme.settingsSessionRadius
  }

  implicitWidth: Shell.Theme.settingsSessionSize
  implicitHeight: Shell.Theme.settingsSessionSize
  visible: opacity > 0.001
  opacity: revealed ? 1 : 0
  scale: revealed ? 1 : 0.86
  transformOrigin: Item.Center
  onScaleChanged: blurRegion.changed()

  Accessible.role: Accessible.Button
  Accessible.name: label
  Accessible.onPressAction: clicked()

  onRevealedChanged: {
    if (!revealed) {
      labelDelay.stop();
      labelShown = false;
    } else if (hovered) {
      labelDelay.restart();
    }
  }

  onHoveredChanged: {
    if (hovered && revealed) {
      labelDelay.restart();
    } else {
      labelDelay.stop();
      labelShown = false;
    }
  }

  Component.onCompleted: if (hovered && revealed) labelDelay.restart()

  Behavior on opacity {
    NumberAnimation {
      duration: root.revealed ? Shell.Theme.settingsCardAppear : Shell.Theme.settingsCloseDuration
      easing.type: Easing.OutCubic
    }
  }

  Behavior on scale {
    NumberAnimation {
      duration: root.revealed ? Shell.Theme.settingsCardAppear : Shell.Theme.settingsCloseDuration
      easing.type: Easing.OutCubic
    }
  }

  Shell.Shadow {
    anchors.fill: parent
    cornerRadius: Shell.Theme.settingsSessionRadius
    shadows: Shell.Theme.glassShadows
  }

  Shell.GradientFill {
    radius: Shell.Theme.settingsSessionRadius
    showGlow: false
  }

  Rectangle {
    anchors.fill: parent
    radius: Shell.Theme.settingsSessionRadius
    color: root.fillColor
    opacity: root.hovered ? 1 : 0
    antialiasing: true

    Behavior on opacity {
      NumberAnimation { duration: Shell.Theme.settingsHoverDuration; easing.type: Easing.InOutCubic }
    }
  }

  Rectangle {
    x: (root.width - width) / 2
    y: (root.height - height) / 2
    width: Shell.Theme.settingsSessionCircle
    height: width
    radius: width / 2
    color: root.hovered ? Shell.Theme.settingsSessionCircleHover : Shell.Theme.control
    antialiasing: true

    Behavior on color {
      ColorAnimation { duration: Shell.Theme.settingsHoverDuration; easing.type: Easing.InOutCubic }
    }

    Image {
      anchors.centerIn: parent
      width: 20
      height: 20
      source: root.iconName !== "" ? Qt.resolvedUrl("../icons/" + root.iconName + ".svg") : ""
      sourceSize: Qt.size(40, 40)
      fillMode: Image.PreserveAspectFit
      smooth: true
      layer.enabled: true
      layer.effect: MultiEffect { colorization: 1; colorizationColor: Shell.Theme.text }
    }
  }

  Rectangle {
    x: Shell.Theme.settingsSessionDotX
    y: Shell.Theme.settingsSessionDotY
    width: Shell.Theme.settingsSessionDot
    height: width
    radius: width / 2
    visible: root.showStatusDot
    color: Shell.Theme.dangerText
    opacity: root.hovered ? 0 : 1
    antialiasing: true

    Behavior on opacity {
      NumberAnimation { duration: Shell.Theme.settingsHoverDuration; easing.type: Easing.InOutCubic }
    }
  }

  Shell.PanelBorder {
    radius: Shell.Theme.settingsSessionRadius
    topColor: root.hovered ? "transparent" : Shell.Theme.glassRimTop
    midColor: root.hovered ? "transparent" : Shell.Theme.glassRimMid
    bottomColor: root.hovered ? "transparent" : Shell.Theme.glassRimBottom
    z: 2
  }

  Text {
    x: root.width + Shell.Theme.settingsSessionLabelGap
    y: (root.height - height) / 2
    height: Shell.Theme.settingsCategoryNameHeight
    verticalAlignment: Text.AlignVCenter
    text: root.label
    color: root.labelColor
    opacity: root.labelShown && root.revealed ? 1 : 0
    font.family: Shell.Theme.titleFontFamily
    font.weight: Font.Normal
    font.pixelSize: Shell.Theme.fontModalTitle

    Behavior on opacity {
      NumberAnimation { duration: Shell.Theme.settingsHoverDuration; easing.type: Easing.OutCubic }
    }
  }

  Timer {
    id: labelDelay
    interval: Shell.Theme.settingsSessionLabelDelay
    onTriggered: {
      if (root.hovered && root.revealed)
        root.labelShown = true;
    }
  }

  MouseArea {
    id: pointer
    anchors.fill: parent
    enabled: root.revealed && root.opacity > 0.9
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: root.clicked()
  }
}
