import QtQuick

// Botão de texto Armitage (ficha 00):
// - "primary":   276×48, raio 24, fundo accent / hover accentHover, texto textOnAccent 15 Medium
// - "secondary": 146×40, raio 10, fundo control + borda border / hover pressed, texto text 13 Medium
// - "danger":    146×40, raio 10, fundo control + borda border / hover pressed, texto dangerText 13 Medium
// Desativado: opacidade 0,4.
Rectangle {
  id: root

  // "primary" | "secondary" | "danger"
  property string kind: "secondary"
  property bool small: false
  property string text: ""
  property real textOpacity: 1.0
  property bool interactive: true
  // Opcional para fixar o estado na demonstração: "" | "rest" | "hover" | "disabled"
  property string visualState: ""

  readonly property bool isPrimary: kind === "primary"
  readonly property bool isDanger: kind === "danger"
  readonly property bool isDisabled: visualState === "disabled" || (visualState === "" && (!interactive || !enabled))
  readonly property bool isHovered: visualState === "hover" || (visualState === "" && pointer.containsMouse && !isDisabled)

  signal clicked

  // Compacto: 146×40 r10 em qualquer tipo, para botões lado a lado num painel
  // (por exemplo o "Parear" primário da ficha 06).
  property bool compact: false
  implicitWidth: compact ? 146 : (isPrimary && !small ? 276 : 146)
  implicitHeight: compact ? 40 : (small ? 32 : (isPrimary ? 48 : 40))
  radius: compact ? Theme.radiusSecondaryButton
      : small ? 8 : (isPrimary ? Theme.radiusPrimaryButton : Theme.radiusSecondaryButton)
  color: isPrimary
      ? (isHovered ? Theme.accentHover : Theme.accent)
      : (isHovered ? Theme.pressed : Theme.control)
  border.width: isPrimary ? 0 : 1
  border.color: Theme.border
  opacity: isDisabled ? 0.4 : 1.0
  antialiasing: true

  Behavior on color {
    ColorAnimation {
      duration: Theme.hoverDuration
      easing.type: Easing.OutCubic
    }
  }

  Text {
    anchors.centerIn: parent
    text: root.text
    color: root.isPrimary ? Theme.textOnAccent
        : root.isDanger ? Theme.dangerText
        : Theme.text
    opacity: root.textOpacity
    font.family: Theme.fontFamily
    font.weight: Font.Medium
    font.pixelSize: root.isPrimary && !root.small && !root.compact ? Theme.fontLabel : Theme.fontBody
    font.letterSpacing: 0
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
  }

  MouseArea {
    id: pointer
    anchors.fill: parent
    enabled: !root.isDisabled && root.visualState === ""
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: root.clicked()
  }
}
