import QtQuick
import QtQuick.Effects
import Quickshell
import ".." as Shell

// Cartão de categoria da tela inicial dos Ajustes (ficha 13; Figma 13:15811 e 13:15817).
// Vidro de 264×264, raio 16, com o brilho do acento na base. Bloco do ícone de 48 em
// (32,32) e nome em Geist Serif 32 em (32,184). No hover o vidro soma cardHover, o rim
// vira accentRing, o bloco do ícone ganha accentSubtle com anel e aparece a seta
// arrow-up-right em accentText em (212,32).
Item {
  id: root

  property string iconName: ""
  property string label: ""
  property bool revealed: false
  // Fixa o hover na vitrine.
  property bool forceHovered: false
  signal clicked

  readonly property bool hovered: forceHovered || (pointer.containsMouse && pointer.enabled)
  readonly property Region blurRegion: Region {
    item: root.revealed && root.opacity > Shell.Theme.blurRevealOpacity ? root : null
    radius: Shell.Theme.radiusCard
  }

  implicitWidth: Shell.Theme.settingsCategorySize
  implicitHeight: Shell.Theme.settingsCategorySize
  visible: opacity > 0.001
  opacity: revealed ? 1 : 0
  scale: revealed ? 1 : 0.86
  transformOrigin: Item.Center
  onScaleChanged: blurRegion.changed()

  Accessible.role: Accessible.Button
  Accessible.name: label
  Accessible.onPressAction: clicked()

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
    cornerRadius: Shell.Theme.radiusCard
    shadows: Shell.Theme.glassShadows
  }

  Shell.GradientFill {
    radius: Shell.Theme.radiusCard
    hovered: root.hovered
  }

  Rectangle {
    id: iconTile
    x: Shell.Theme.settingsCategoryInset
    y: Shell.Theme.settingsCategoryInset
    width: Shell.Theme.settingsIconTileSize
    height: Shell.Theme.settingsIconTileSize
    radius: Shell.Theme.radiusRow
    color: root.hovered ? Shell.Theme.accentSubtle : Shell.Theme.control
    border.width: 1
    border.color: root.hovered ? Shell.Theme.accentRing : Qt.alpha(Shell.Theme.accentRing, 0)
    antialiasing: true

    Behavior on color {
      ColorAnimation { duration: Shell.Theme.settingsCategoryHoverDuration; easing.type: Easing.InOutCubic }
    }
    Behavior on border.color {
      ColorAnimation { duration: Shell.Theme.settingsCategoryHoverDuration; easing.type: Easing.InOutCubic }
    }

    Image {
      anchors.centerIn: parent
      width: 20
      height: 20
      source: root.iconName !== "" ? Qt.resolvedUrl("../icons/" + root.iconName + ".svg") : ""
      sourceSize: Qt.size(40, 40)
      fillMode: Image.PreserveAspectFit
      smooth: true
    }
  }

  Text {
    x: Shell.Theme.settingsCategoryInset
    y: Shell.Theme.settingsCategoryNameY
    width: root.width - Shell.Theme.settingsCategoryInset * 2
    height: Shell.Theme.settingsCategoryNameHeight
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
    text: root.label
    color: Shell.Theme.text
    font.family: Shell.Theme.titleFontFamily
    font.weight: Font.Normal
    font.pixelSize: Shell.Theme.fontModalTitle
  }

  Image {
    x: Shell.Theme.settingsCategoryArrowX
    y: Shell.Theme.settingsCategoryInset
    width: 20
    height: 20
    source: Qt.resolvedUrl("../icons/arrow-up-right.svg")
    sourceSize: Qt.size(40, 40)
    fillMode: Image.PreserveAspectFit
    smooth: true
    opacity: root.hovered ? 1 : 0
    layer.enabled: true
    layer.effect: MultiEffect { colorization: 1; colorizationColor: Shell.Theme.accentText }

    Behavior on opacity {
      NumberAnimation { duration: Shell.Theme.settingsCategoryHoverDuration; easing.type: Easing.InOutCubic }
    }
  }

  Shell.PanelBorder {
    id: rim
    radius: Shell.Theme.radiusCard
    topColor: root.hovered ? Shell.Theme.accentRing : Shell.Theme.glassRimTop
    midColor: root.hovered ? Shell.Theme.accentRing : Shell.Theme.glassRimMid
    bottomColor: root.hovered ? Shell.Theme.accentRing : Shell.Theme.glassRimBottom
    z: 2

    Behavior on topColor {
      ColorAnimation { duration: Shell.Theme.settingsCategoryHoverDuration; easing.type: Easing.InOutCubic }
    }
    Behavior on midColor {
      ColorAnimation { duration: Shell.Theme.settingsCategoryHoverDuration; easing.type: Easing.InOutCubic }
    }
    Behavior on bottomColor {
      ColorAnimation { duration: Shell.Theme.settingsCategoryHoverDuration; easing.type: Easing.InOutCubic }
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
