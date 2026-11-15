import QtQuick
import QtQuick.Effects
import Quickshell
import "audio" as Audio
import "wifi" as Wifi

// Controles de baixo da barra lateral (ficha 03, boards 13:12277 e 13:14610):
// Aberto (156×48, r16): 4 botões em y 4 (36 no hover de 80 px), altura 40, ícone 16 no centro:
//   Wi-Fi (x 4, w 38, cantos 12,4,4,12), Som (x 42, w 36, cantos 4),
//   Ajustes (x 78, w 36, cantos 4), Recolher (x 114, w 38, cantos 4,12,12,4).
// Recolhido (48×168, r16): 4 botões 40×40 em x 4, y 4/44/84/124, ícone 16 em (12,12).
// Hover que cresce para 80 (aberto):
//   Wi-Fi: download (12,10) + texto 11 muted (32,8) + divisor (80,10) + upload (88,10) + texto 11 muted (108,8).
//   Som: slider compacto 132×8 r4 em (12,14), preenchimento accent, alça 16 knob em y 10.
Card {
  id: root
  property real collapseProgress: 0
  // Propriedades opcionais para amostra estática no painel de demonstração
  property string previewReveal: "" // "" | "wifi" | "sound"
  property int previewSelectedSlot: -1
  property int previewHoverSlot: -1
  property string previewDownloadRate: "12 MB/s"
  property string previewUploadRate: "1,2 MB/s"
  property real previewVolume: 0.61

  signal collapseClicked
  readonly property real widthProgress: Theme.collapseWidth(collapseProgress)
  readonly property real heightProgress: Theme.collapseHeight(collapseProgress)
  width: Theme.lerp(Theme.sidebarCardExpandedWidth, Theme.sidebarCardCollapsedWidth, widthProgress)
  height: Theme.lerp(openExpandedHeight, 168, heightProgress)
  contentClipped: false
  radius: Theme.sidebarCardRadius

  property bool wifiOpen: false
  property bool soundOpen: false
  property bool settingsOpen: false
  property bool wifiHoverRetained: false
  readonly property bool collapsed: collapseProgress >= 0.56

  property bool hoverHeightRetained: false
  property string displayedReveal: ""
  readonly property string effectiveReveal: previewReveal !== "" ? previewReveal : displayedReveal
  readonly property bool wifiContentVisible: effectiveReveal === "wifi"
  readonly property bool soundSliderContentVisible: effectiveReveal === "sound"
  readonly property string requestedReveal: wifiPresentationRequested ? "wifi"
      : soundSliderRequested ? "sound" : ""

  signal wifiClicked
  signal settingsClicked
  signal soundClicked

  property bool wifiButtonHovered: false
  property bool soundButtonHovered: false
  readonly property bool wifiHovered: wifiButtonHovered
      || (wifiHoverRetained && panelHover.hovered)
  readonly property bool noInternet: previewReveal === ""
      && Wifi.State.internetUnavailable
      && (Wifi.State.wifiConnected || Wifi.State.wiredConnected)
  readonly property bool soundHovered: soundButtonHovered
      || compactSoundSlider.hovered
  readonly property bool wifiPresentationRequested: wifiHovered || wifiOpen
  readonly property bool wifiMetricsVisible: previewReveal === "" && wifiMetrics.visible
  onWifiMetricsVisibleChanged: Wifi.State.setRateConsumer(root, wifiMetricsVisible)
  Component.onCompleted: Wifi.State.setRateConsumer(root, wifiMetricsVisible)
  Component.onDestruction: Wifi.State.setRateConsumer(root, false)
  readonly property bool soundSliderRequested: !soundOpen && !wifiPresentationRequested
      && collapseProgress <= 0.001
      && soundHovered
  readonly property int openExpandedHeight:
      (previewReveal !== "" || hoverHeightRetained) ? 80 : 48

  onWifiButtonHoveredChanged: {
    if (wifiButtonHovered)
      wifiHoverRetained = true;
  }

  onSoundButtonHoveredChanged: {
    if (soundButtonHovered)
      wifiHoverRetained = false;
  }

  onRequestedRevealChanged: Qt.callLater(syncReveal)
  function syncReveal() {
    if (requestedReveal === "") {
      displayedReveal = "";
      revealExit.restart();
      return;
    }
    revealExit.stop();
    hoverHeightRetained = true;
    displayedReveal = requestedReveal;
  }

  HoverHandler {
    id: panelHover
    onHoveredChanged: {
      if (!hovered)
        root.wifiHoverRetained = false;
    }
  }

  // Slider compacto no hover do Som: trilho 132×8 r4 em (12,14), alça 16×16 em y 10
  Slider {
    id: compactSoundSlider
    z: 2
    x: 12
    y: 0
    width: 132
    height: 36
    compact: true
    externalValue: root.previewReveal === "sound" ? root.previewVolume : Audio.State.outputVolume
    muted: root.previewReveal === "sound" ? false : Audio.State.outputMuted
    trackColor: Theme.track
    interactive: root.previewReveal === "sound" || root.soundSliderRequested
    hoverEnabled: root.soundSliderContentVisible
    visible: opacity > 0.001
    opacity: root.soundSliderContentVisible && root.collapseProgress <= 0.001 ? 1 : 0
    onMoved: if (root.previewReveal === "") Audio.State.setOutputVolume(compactSoundSlider.value)
  }

  Behavior on height {
    enabled: root.collapseProgress <= 0.001 && root.previewReveal === ""
    NumberAnimation {
      duration: Theme.controlDuration
      easing.type: Easing.OutCubic
    }
  }

  Text {
    id: noInternetLabel
    anchors.horizontalCenter: parent.horizontalCenter
    y: 8
    height: 20
    text: "Sem internet"
    color: Theme.muted
    font.family: Theme.fontFamily
    font.weight: Font.Medium
    font.pixelSize: Theme.fontCaption
    font.letterSpacing: 0
    verticalAlignment: Text.AlignVCenter
    opacity: root.noInternet && root.wifiContentVisible
        && root.collapseProgress <= 0.001 ? 1 : 0
    visible: opacity > 0
  }

  // Hover no Wi-Fi (ficha 03 / board 13:14610):
  // download 16 em (12,10) + texto 11 muted em (32,8) 44×20 + divisor 1×16 em (80,10)
  // + upload 16 em (88,10) + texto 11 muted em (108,8) 40×20.
  Item {
    id: wifiMetrics
    x: 0
    y: 0
    width: Theme.sidebarCardExpandedWidth
    height: 36
    opacity: root.wifiContentVisible && !root.noInternet
        && root.collapseProgress <= 0.001 ? 1 : 0
    visible: opacity > 0

    Image {
      x: 12
      y: 10
      width: 16
      height: 16
      source: Qt.resolvedUrl("icons/download.svg")
      sourceSize: Qt.size(32, 32)
      smooth: true
      antialiasing: true
    }

    Text {
      x: 32
      y: 8
      width: 44
      height: 20
      text: root.previewReveal === "wifi" ? root.previewDownloadRate : Wifi.State.downloadRate
      color: Theme.muted
      font.family: Theme.fontFamily
      font.weight: Font.Medium
      font.pixelSize: Theme.fontCaption
      font.letterSpacing: 0
      verticalAlignment: Text.AlignVCenter
      elide: Text.ElideRight
    }

    Rectangle {
      x: 80
      y: 10
      width: 1
      height: 16
      color: Theme.border
    }

    Image {
      x: 88
      y: 10
      width: 16
      height: 16
      source: Qt.resolvedUrl("icons/upload.svg")
      sourceSize: Qt.size(32, 32)
      smooth: true
      antialiasing: true
    }

    Text {
      x: 108
      y: 8
      width: 44
      height: 20
      text: root.previewReveal === "wifi" ? root.previewUploadRate : Wifi.State.uploadRate
      color: Theme.muted
      font.family: Theme.fontFamily
      font.weight: Font.Medium
      font.pixelSize: Theme.fontCaption
      font.letterSpacing: 0
      verticalAlignment: Text.AlignVCenter
      elide: Text.ElideRight
    }
  }

  readonly property var icons: [
    { icon: previewReveal !== "" || previewSelectedSlot >= 0 || previewHoverSlot >= 0
          ? "wifi.svg" : Wifi.State.statusIcon,
      width: 16,
      height: 16 },
    { icon: "volume-2.svg", width: 16, height: 16 },
    { icon: "settings.svg", width: 16, height: 16 },
    { icon: "", width: 16, height: 16 }
  ]

  Repeater {
    model: 7
    IconButton {
      id: action
      required property int index
      readonly property bool vertical: index > 3
      readonly property int slot: vertical ? index - 4 : index
      readonly property var modelData: root.icons[slot]
      opacity: !vertical && slot === 3 ? 1
          : vertical ? (root.collapsed ? Theme.clamp01((y + 8) / 12) : 0)
          : Theme.clamp01((x + 8) / 12)
      visible: opacity > 0.001
      x: vertical ? 4 : [4, 42, 78, 114][slot] - 110 * root.widthProgress
      y: vertical ? root.height - 44 - (3 - slot) * 40 : root.height - 44
      width: vertical ? 40 : Theme.lerp(slot === 0 || slot === 3 ? 38 : 36, 40, root.widthProgress)
      height: 40
      enabled: opacity > 0.5
      showBackground: false
      onHoveredChanged: {
        if (slot === 0) root.wifiButtonHovered = hovered;
        else if (slot === 1) root.soundButtonHovered = hovered;
      }
      readonly property bool selected: root.previewSelectedSlot >= 0
          ? slot === root.previewSelectedSlot
          : (slot === 0 ? root.wifiOpen : slot === 1 ? root.soundOpen : slot === 2 && root.settingsOpen)
      readonly property bool effectiveHovered: action.hovered || slot === root.previewHoverSlot
      checked: selected
      restingOpacity: 1.0
      iconSource: modelData.icon ? Qt.resolvedUrl("icons/" + modelData.icon) : ""
      iconWidth: modelData.width
      iconHeight: modelData.height
      onClicked: {
        if (slot === 0) root.wifiClicked();
        else if (slot === 1) root.soundClicked();
        else if (slot === 2) root.settingsClicked();
        else root.collapseClicked();
      }
      Accessible.role: Accessible.Button
      Accessible.name: slot === 0 ? "Wi-Fi" : slot === 1 ? "Som"
          : slot === 2 ? "Ajustes" : root.collapseProgress < 0.5 ? "Recolher barra" : "Expandir barra"
      Accessible.onPressAction: action.clicked()

      Rectangle {
        anchors.fill: parent
        z: -1
        topLeftRadius: action.slot === 0 ? 12 : 4
        topRightRadius: action.slot === 0 ? Theme.lerp(4, 12, root.collapseProgress)
            : action.slot === 3 ? Theme.lerp(12, 4, root.collapseProgress) : 4
        bottomLeftRadius: action.slot === 0 ? Theme.lerp(12, 4, root.collapseProgress)
            : action.slot === 3 ? Theme.lerp(4, 12, root.collapseProgress) : 4
        bottomRightRadius: action.slot === 3 ? 12 : 4
        color: action.selected ? Theme.accent
            : action.pressed ? Theme.pressed
            : action.effectiveHovered ? Theme.hover : "transparent"
        Behavior on color { ColorAnimation { duration: Theme.hoverDuration; easing.type: Easing.OutCubic } }
      }

      Repeater {
        model: action.slot === 3 ? 2 : 0
        Image {
          required property int index
          x: Math.round((parent.width - width) / 2)
          y: Math.round((parent.height - height) / 2)
          width: 16
          height: 16
          source: Qt.resolvedUrl(index === 0 ? "icons/panel-left-close.svg" : "icons/panel-left-open.svg")
          sourceSize: Qt.size(32, 32)
          fillMode: Image.PreserveAspectFit
          readonly property real flipProgress: root.collapseProgress >= 0.5 ? 1 : 0
          opacity: action.glyphOpacity * (index === 0 ? 1 - flipProgress : flipProgress)
          smooth: true
          antialiasing: true
        }
      }
    }
  }

  Timer {
    id: revealExit
    interval: Theme.hoverCollapseDelay
    onTriggered: if (root.requestedReveal === "") root.hoverHeightRetained = false
  }

}
