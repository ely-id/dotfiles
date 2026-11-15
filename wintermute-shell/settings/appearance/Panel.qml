pragma ComponentBehavior: Bound
import QtQuick
import "." as Appearance
import ".." as Settings
import "../display" as Display
import "../.." as Shell

Settings.Modal {
  id: root
  title: "Appearance"
  contentHeight: fields.y + fields.height + 30
  onBackRequested: Settings.State.back()
  Keys.onEscapePressed: Settings.State.back()

  property string previewTheme: ""
  readonly property var themes: [
    { key: "chiba", label: "Chiba", x: 70, y: 88, accent: "#52C2F6", labelColor: "#75CEF8" },
    { key: "freeside", label: "Freeside", x: 230, y: 88, accent: "#7F89E1", labelColor: "#B7BDEE" },
    { key: "sprawl", label: "Sprawl", x: 390, y: 88, accent: "#F4A846", labelColor: "#F6B867" }
  ]
  function themeLabel(key) { return themes.find(theme => theme.key === key)?.label ?? ""; }

  Item {
    width: root.width; height: 240
    Text {
      x: 30; y: 64; height: 20
      text: "Variation"; font.family: Shell.Theme.fontFamily; font.pixelSize: 13; font.weight: Font.Medium
      color: Shell.Theme.muted; verticalAlignment: Text.AlignVCenter
    }
    Repeater {
      model: root.themes
      delegate: ThemeButton {
        required property var modelData
        x: modelData.x; y: modelData.y
        objectName: "theme" + modelData.label
        theme: modelData
        selected: Shell.Theme.name === modelData.key
        onClicked: Appearance.State.selectTheme(modelData.key)
        onHoveredChanged: {
          if (hovered) root.previewTheme = modelData.key;
          else if (root.previewTheme === modelData.key) root.previewTheme = "";
        }
      }
    }
  }
  Column {
    id: fields
    x: 30; y: 260; width: root.width - 60; spacing: 8
    Accordion {
      objectName: "wallpaperSection"
      width: parent.width; title: "Wallpaper"
      summary: Appearance.State.wallpaperMode === "dynamic" ? "Dynamic" : "Custom"
      navigation: true
      onToggled: Settings.State.openPage("wallpaper")
    }
    Accordion {
      objectName: "brightnessSection"
      width: parent.width; title: "Screen brightness"
      summary: Appearance.State.brightnessAvailable ? Math.round(Appearance.State.brightness * 100) + "%" : "Unavailable"
      enabled: Appearance.State.brightnessAvailable
      expanded: enabled && Appearance.State.expandedSection === "brightness"
      expandedHeight: 109
      onToggled: Appearance.State.toggleSection("brightness")
      Shell.Slider {
        id: brightnessSlider
        objectName: "brightnessSlider"
        x: 0; y: 5; width: parent.width
        externalValue: Appearance.State.brightness
        showInlineValue: false
        onMoved: Appearance.State.setBrightness(brightnessSlider.value)
        onDragStarted: Appearance.State.draggingBrightness = true
        onDragFinished: { Appearance.State.draggingBrightness = false; Appearance.State.flushBrightness(); }
        activeFocusOnTab: true
        Accessible.role: Accessible.Slider
        Accessible.name: "Screen brightness"
        Keys.onLeftPressed: Appearance.State.setBrightness(value - 0.05)
        Keys.onRightPressed: Appearance.State.setBrightness(value + 0.05)
      }
    }
    Accordion {
      objectName: "displaySection"
      width: parent.width; title: "Display"
      summary: Display.State.summary
      navigation: true
      onToggled: Settings.State.openPage("display")
    }
    Text {
      width: parent.width
      visible: Appearance.State.error !== ""
      text: Appearance.State.error
      wrapMode: Text.Wrap
      font.family: Shell.Theme.fontFamily; font.pixelSize: 13; color: "#ffb4ab"
    }
  }
}
