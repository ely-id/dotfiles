pragma ComponentBehavior: Bound
import QtQuick
import "." as Appearance
import "../.." as Shell

// Conteúdo da página Aparência (ficha 11), em coordenadas do modal de 580: rótulo "Variação" 13 muted
// em (30,64), três discos de 120×116 em y 88 (x 70 / 230 / 390) e as três linhas de 52 com 8 de espaço,
// em x 30 a partir de y 260. Não lê estado nenhum: quem usa liga as propriedades e os sinais, e a
// vitrine liga valores fictícios.
Item {
  id: root
  width: 580
  height: contentHeight

  property string selectedTheme: Shell.Theme.name
  property string wallpaperSummary: "Dynamic"
  property bool brightnessAvailable: true
  property real brightness: 0.8
  property bool brightnessExpanded: false
  property string displaySummary: "1 monitor"
  property string error: ""
  readonly property real contentHeight: fields.y + fields.height + 24
  readonly property alias brightnessSlider: brightnessSlider

  signal themeSelected(string key)
  signal wallpaperRequested
  signal brightnessToggled
  signal brightnessMoved(real value)
  signal brightnessDragStarted
  signal brightnessDragFinished
  signal displayRequested

  readonly property var themes: [
    { key: "chiba", label: "Chiba", x: 70, y: 88, accent: "#52C2F6" },
    { key: "freeside", label: "Freeside", x: 230, y: 88, accent: "#7F89E1" },
    { key: "sprawl", label: "Sprawl", x: 390, y: 88, accent: "#F4A846" }
  ]

  Text {
    x: 30; y: 64; height: 20
    text: "Variation"
    font.family: Shell.Theme.fontFamily; font.pixelSize: Shell.Theme.fontBody; font.weight: Font.Medium
    font.letterSpacing: 0
    color: Shell.Theme.muted; verticalAlignment: Text.AlignVCenter
  }
  Repeater {
    model: root.themes
    delegate: ThemeButton {
      required property var modelData
      x: modelData.x; y: modelData.y
      objectName: "theme" + modelData.label
      theme: modelData
      selected: root.selectedTheme === modelData.key
      onClicked: root.themeSelected(modelData.key)
    }
  }
  Column {
    id: fields
    x: 30; y: 260; width: root.width - 60; spacing: 8
    Accordion {
      objectName: "wallpaperSection"
      width: parent.width; title: "Wallpaper"
      summary: root.wallpaperSummary
      navigation: true
      onToggled: root.wallpaperRequested()
    }
    Accordion {
      objectName: "brightnessSection"
      width: parent.width; title: "Screen brightness"
      summary: root.brightnessAvailable ? Math.round(root.brightness * 100) + "%" : "Unavailable"
      enabled: root.brightnessAvailable
      expanded: enabled && root.brightnessExpanded
      expandedHeight: 111
      onToggled: root.brightnessToggled()
      Shell.Slider {
        id: brightnessSlider
        objectName: "brightnessSlider"
        x: 0; y: 5; width: parent.width
        externalValue: root.brightness
        showInlineValue: false
        onMoved: root.brightnessMoved(brightnessSlider.value)
        onDragStarted: root.brightnessDragStarted()
        onDragFinished: root.brightnessDragFinished()
        activeFocusOnTab: true
        Accessible.role: Accessible.Slider
        Accessible.name: "Screen brightness"
        Keys.onLeftPressed: root.brightnessMoved(value - 0.1)
        Keys.onRightPressed: root.brightnessMoved(value + 0.1)
      }
    }
    Accordion {
      objectName: "displaySection"
      width: parent.width; title: "Display"
      summary: root.displaySummary
      navigation: true
      onToggled: root.displayRequested()
    }
    Text {
      width: parent.width
      visible: root.error !== ""
      text: root.error
      wrapMode: Text.Wrap
      font.family: Shell.Theme.fontFamily; font.pixelSize: Shell.Theme.fontBody
      color: Shell.Theme.dangerText
    }
  }
}
