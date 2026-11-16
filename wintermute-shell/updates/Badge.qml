import QtQuick
import QtQuick.Effects
import "." as Updates
import ".." as Shell

// Selo de atualização da tela inicial dos Ajustes (ficha 13; Figma 13:15849).
// Pílula accentSubtle de 248×32, raio 8. Ícone de 16 em accentText em (12,8) e texto
// Geist Medium 13 em accentText a partir de x 36. A contagem vem do Cachy Update (P-32).
// O Figma desenha só "atualizações disponíveis"; os outros estados da origem (atualizando,
// concluída, reiniciar) usam a mesma pílula com o próprio ícone. No hover de "reiniciar"
// a pílula vira accent com o conteúdo em textOnAccent, e o Reiniciar acende (restartHovered).
// Lê o estado por `service` (decisão 0011), com Updates.State como padrão.
Rectangle {
  id: root

  property var service: Updates.State
  signal restartRequested

  readonly property string status: service.status
  readonly property int count: service.availableCount
  readonly property bool actionable: status !== "updating"
  readonly property bool restartHovered: status === "restart" && pointer.containsMouse
  readonly property color foreground: restartHovered ? Shell.Theme.textOnAccent : Shell.Theme.accentText
  readonly property string iconName: ({
    available: "download", complete: "circle-check", restart: "rotate-ccw"
  })[status] ?? ""

  function activate() {
    if (status === "available") service.start();
    else if (status === "complete") service.status = "";
    else if (status === "restart") restartRequested();
  }

  implicitWidth: Shell.Theme.settingsBadgeWidth
  implicitHeight: Shell.Theme.settingsBadgeHeight
  radius: Shell.Theme.settingsBadgeRadius
  color: restartHovered ? Shell.Theme.accent : Shell.Theme.accentSubtle
  antialiasing: true
  activeFocusOnTab: actionable
  Accessible.role: actionable ? Accessible.Button : Accessible.StaticText
  Accessible.name: label.text
  Accessible.onPressAction: activate()
  Keys.onReturnPressed: activate()
  Keys.onSpacePressed: activate()

  Behavior on color {
    ColorAnimation { duration: Shell.Theme.hoverDuration; easing.type: Easing.OutCubic }
  }

  Image {
    x: Shell.Theme.settingsBadgePadding
    y: (root.height - height) / 2
    width: 16
    height: 16
    visible: root.iconName !== ""
    source: root.iconName !== "" ? Qt.resolvedUrl("../icons/" + root.iconName + ".svg") : ""
    sourceSize: Qt.size(32, 32)
    fillMode: Image.PreserveAspectFit
    smooth: true
    layer.enabled: true
    layer.effect: MultiEffect { colorization: 1; colorizationColor: root.foreground }
  }

  Updates.Indicator {
    x: Shell.Theme.settingsBadgePadding
    y: (root.height - height) / 2
    visible: root.status === "updating"
  }

  Text {
    id: label
    x: Shell.Theme.settingsBadgePadding + 16 + 8
    width: root.width - x - Shell.Theme.settingsBadgePadding
    height: root.height
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
    text: ({
      available: root.count === 1 ? "1 update available"
          : root.count > 1 ? root.count + " updates available" : "Updates available",
      updating: "Updating",
      complete: "Update complete",
      restart: "Restart recommended"
    })[root.status] ?? ""
    color: root.foreground
    font.family: Shell.Theme.fontFamily
    font.pixelSize: Shell.Theme.fontBody
    font.weight: Font.Medium
  }

  Text {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.baseline: parent.top
    anchors.baselineOffset: -14
    visible: root.restartHovered
    text: "Click to restart"
    color: Shell.Theme.accentText
    font.family: Shell.Theme.fontFamily
    font.pixelSize: Shell.Theme.fontBody
    font.weight: Font.Medium
  }

  MouseArea {
    id: pointer
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: root.actionable ? Qt.PointingHandCursor : Qt.ArrowCursor
    onClicked: root.activate()
  }
}
