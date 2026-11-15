pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import ".." as Shell

// Indicador de terminal com agente 16×16 (ficha 00 e ficha 02, P-05):
//   Trabalhando (working):   hourglass     em Theme.accentText
//   Atenção     (attention): circle-alert  em Theme.attentionText
//   Não lido    (unread):    sprout        em Theme.warning
//   Lido        (read):      circle-check  em Theme.successText
Item {
  id: root

  property string dotState: "read"
  property int loaderVariant: 1

  implicitWidth: 16
  implicitHeight: 16

  readonly property string iconName: dotState === "working" ? "hourglass.svg"
      : dotState === "attention" ? "circle-alert.svg"
      : dotState === "unread" ? "sprout.svg"
      : "circle-check.svg"

  readonly property color iconColor: dotState === "working" ? Shell.Theme.accentText
      : dotState === "attention" ? Shell.Theme.attentionText
      : dotState === "unread" ? Shell.Theme.warning
      : Shell.Theme.successText

  Accessible.role: Accessible.Indicator
  Accessible.name: dotState === "working" ? "Terminal com agente trabalhando"
      : dotState === "attention" ? "Terminal com agente aguardando atenção"
      : dotState === "unread" ? "Terminal com agente concluído (não lido)"
      : "Terminal com agente concluído (lido)"

  Image {
    anchors.fill: parent
    source: Qt.resolvedUrl("../icons/" + root.iconName)
    sourceSize: Qt.size(32, 32)
    fillMode: Image.PreserveAspectFit
    smooth: true
    antialiasing: true
    layer.enabled: true
    layer.effect: MultiEffect {
      colorization: 1
      colorizationColor: root.iconColor
    }
  }
}
