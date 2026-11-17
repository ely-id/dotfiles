import QtQuick
import QtQuick.Effects
import "." as Installs
import ".." as Shell

// Cartão de instalações da barra lateral (ficha 04, board 13:14610):
// 156×88 (para 2 itens: padding 4 + 40 por linha), raio 16.
// Em cada linha: ícone 16 em (12,12), nome 13 Medium em (36,4) 80×32,
// e anel de progresso / circle-check 16 em (128,12).
Shell.Card {
  id: root
  property real collapseProgress: 0
  property var customModel: null

  readonly property real widthProgress: Shell.Theme.collapseWidth(collapseProgress)
  readonly property int contentPadding: 4
  readonly property int rowHeight: Shell.Theme.sidebarCardCollapsedWidth - 2 * contentPadding
  readonly property var activeModel: customModel !== null ? customModel : Installs.State.jobs
  readonly property int count: customModel !== null ? customModel.length : Installs.State.jobs.count

  // Ícone vazio ou só o nome (sem "/" nem ":") é um ícone de icons/; qualquer outra coisa é o caminho do
  // ícone do aplicativo que está sendo instalado. As duas funções usam a mesma regra.
  function isShellIcon(iconValue) {
    const str = String(iconValue || "");
    return str === "" || (str.indexOf("/") === -1 && str.indexOf(":") === -1);
  }

  function resolveIcon(iconValue) {
    if (!iconValue)
      return Qt.resolvedUrl("../icons/download.svg");
    const str = String(iconValue);
    if (str.indexOf("/") === -1 && str.indexOf(":") === -1)
      return Qt.resolvedUrl("../icons/" + (str.endsWith(".svg") ? str : str + ".svg"));
    return str;
  }

  implicitWidth: Shell.Theme.lerp(Shell.Theme.sidebarCardExpandedWidth,
      Shell.Theme.sidebarCardCollapsedWidth, widthProgress)
  implicitHeight: count === 0 ? 0 : 2 * contentPadding + count * rowHeight
  visible: count > 0
  radius: Shell.Theme.sidebarCardRadius

  Repeater {
    model: root.activeModel
    delegate: Item {
      id: row
      required property int index
      required property var modelData
      readonly property string jobId: modelData.jobId ?? ""
      readonly property string name: modelData.name ?? ""
      readonly property string status: modelData.status ?? "installing"
      readonly property real progress: modelData.progress ?? -1
      readonly property string icon: modelData.icon ?? ""
      readonly property bool canLaunch: root.customModel === null
          && status === "installed" && jobId !== "system-update"
          && Installs.State.findApp(name) !== null
      readonly property bool showDismiss: root.customModel === null
          && dismiss.visible && (rowHover.hovered || dismiss.hovered)
      readonly property string summary: status === "installed" ? "Installed"
          : status === "failed" ? "Failed" : progress < 0 ? "Installing"
          : "Installing " + Math.round(progress * 100) + "%"

      y: root.contentPadding + index * root.rowHeight
      width: root.width
      height: root.rowHeight
      Accessible.role: Accessible.ListItem
      Accessible.name: jobId === "system-update" ? name : name + ": " + summary
      Accessible.onPressAction: if (root.customModel === null) Installs.State.dismiss(jobId)

      HoverHandler { id: rowHover }

      Item {
        x: 0
        width: Math.max(0, parent.width - root.rowHeight - root.contentPadding)
        height: parent.height
        opacity: 1 - Shell.Theme.ramp(root.collapseProgress, 0, 0.3)
        visible: opacity > 0.001

        HoverFill {
          x: root.contentPadding
          width: Math.max(0, parent.width - root.contentPadding)
          height: parent.height
          active: row.canLaunch && nameHover.hovered
        }

        Image {
          id: appIcon
          x: 12
          y: 12
          width: 16
          height: 16
          visible: status === Image.Ready
          source: root.resolveIcon(row.icon)
          sourceSize: Qt.size(32, 32)
          fillMode: Image.PreserveAspectFit
          smooth: true
          antialiasing: true
          // O ícone de aplicativo mantém as próprias cores; só o de icons/ é colorizado (P-64).
          layer.enabled: root.isShellIcon(row.icon)
          layer.effect: MultiEffect { colorization: 1; colorizationColor: Shell.Theme.text }
        }

        Text {
          x: 36
          y: 4
          width: Math.max(0, 120 - x)
          height: 32
          text: row.name
          textFormat: Text.PlainText
          elide: Text.ElideRight
          color: Shell.Theme.text
          font.family: Shell.Theme.fontFamily
          font.pixelSize: Shell.Theme.fontBody
          font.weight: Font.Medium
          font.letterSpacing: 0
          verticalAlignment: Text.AlignVCenter
        }

        HoverHandler {
          id: nameHover
          cursorShape: row.canLaunch ? Qt.PointingHandCursor : Qt.ArrowCursor
        }
        TapHandler {
          enabled: row.canLaunch
          onTapped: Installs.State.launch(row.jobId)
        }
      }

      Installs.Indicator {
        id: indicator
        visible: !row.showDismiss
        x: Math.round(Shell.Theme.lerp(128, 16, root.widthProgress))
        y: 12
        progress: row.progress
        status: row.status
      }

      Shell.IconButton {
        id: dismiss
        visible: root.customModel === null && row.status !== "installing"
        opacity: row.showDismiss ? 1 : 0
        x: parent.width - width - root.contentPadding
        width: root.rowHeight
        height: parent.height
        buttonSize: 32
        showBackground: false
        iconSource: Qt.resolvedUrl("../icons/x.svg")
        iconWidth: 16
        iconHeight: 16
        onClicked: Installs.State.dismiss(row.jobId)
        HoverFill {
          anchors.fill: parent
          z: -1
          active: dismiss.hovered
        }
      }
    }
  }

  component HoverFill: Rectangle {
    property bool active: false
    radius: 12
    color: Shell.Theme.hover
    opacity: active ? 1 : 0
    Behavior on opacity { Shell.HoverAnimation {} }
  }
}
