import QtQuick

// Campo de texto Armitage (ficha 00):
// 276×44, raio 12. Fundo control (hover pressed).
// Borda border 1 px; foco ou erro: 1,5 px accent ou dangerText.
// Texto 13 Medium, padding x 16; vazio/foco usa muted, preenchido usa text.
// Cursor de foco: 2×20 raio 1, accent, em (16,12).
// Senha / erro: botão olho 28×28 raio 8 em (240,8), ícone eye 16.
Rectangle {
  id: root

  property alias text: editor.text
  property string placeholderText: ""
  property bool password: false
  property bool revealed: false
  property bool error: false
  property real rightPadding: password || isPasswordState || isErrorState ? 44 : 16
  property bool readOnly: false
  property bool highlighted: false
  // Opcional para fixar o estado na demonstração: "" | "empty" | "hover" | "focus" | "filled" | "password" | "error"
  property string visualState: ""
  signal accepted

  readonly property bool isErrorState: visualState === "error" || (visualState === "" && error)
  readonly property bool isPasswordState: visualState === "password" || (visualState === "" && password)
  readonly property bool isFocusState: visualState === "focus" || (visualState === "" && editor.activeFocus && !isErrorState)
  readonly property bool isHoverState: visualState === "hover" || (visualState === "" && (fieldHover.hovered || highlighted) && !isFocusState && !isErrorState)
  readonly property bool hovered: isHoverState
  readonly property bool focused: isFocusState

  function focusEditor() {
    editor.forceActiveFocus(Qt.OtherFocusReason);
  }

  implicitWidth: Theme.panelFieldWidth
  implicitHeight: Theme.panelFieldHeight
  radius: Theme.radiusRow
  color: isHoverState ? Theme.pressed : Theme.control
  border.width: isErrorState || isFocusState ? 1.5 : 1
  border.color: isErrorState ? Theme.dangerText : isFocusState ? Theme.accent : Theme.border
  antialiasing: true

  Behavior on color {
    ColorAnimation { duration: Theme.controlDuration }
  }

  Text {
    x: 16
    anchors.verticalCenter: parent.verticalCenter
    width: parent.width - x - root.rightPadding
    text: root.placeholderText
    visible: editor.text.length === 0
    color: Theme.muted
    font.family: Theme.fontFamily
    font.weight: Font.Medium
    font.pixelSize: Theme.fontBody
    font.letterSpacing: 0
  }

  // Cursor de foco 2×20 raio 1 em (16,12) quando vazio ou em demonstração
  Rectangle {
    x: 16
    y: 12
    width: 2
    height: 20
    radius: 1
    color: Theme.accent
    visible: root.visualState === "focus" && editor.text.length === 0
  }

  TextInput {
    id: editor
    x: 16
    anchors.verticalCenter: parent.verticalCenter
    width: parent.width - x - root.rightPadding
    enabled: root.visualState === ""
    color: Theme.text
    selectionColor: Theme.accentSubtle
    selectedTextColor: Theme.text
    font.family: Theme.fontFamily
    font.weight: Font.Medium
    font.pixelSize: Theme.fontBody
    font.letterSpacing: 0
    echoMode: root.isPasswordState && !root.revealed && root.visualState === ""
        ? TextInput.Password : TextInput.Normal
    passwordCharacter: "•"
    readOnly: root.readOnly || root.visualState !== ""
    activeFocusOnTab: root.visualState === ""
    clip: true
    cursorDelegate: Rectangle {
      width: 2
      height: 20
      radius: 1
      color: Theme.accent
      visible: editor.activeFocus
    }
    onAccepted: root.accepted()
  }

  HoverHandler {
    id: fieldHover
    enabled: root.visualState === ""
    cursorShape: Qt.IBeamCursor
  }
  TapHandler {
    enabled: root.visualState === ""
    onTapped: editor.forceActiveFocus(Qt.MouseFocusReason)
  }

  IconButton {
    id: eyeButton
    visible: root.isPasswordState || (root.isErrorState && root.password) || root.visualState === "error"
    x: root.width - 36
    y: 8
    width: 28
    height: 28
    radius: 8
    z: 2
    iconWidth: 16
    iconHeight: 16
    iconSource: Qt.resolvedUrl(root.revealed || root.visualState !== "" ? "icons/eye.svg" : "icons/eye-off.svg")
    onClicked: if (root.visualState === "") root.revealed = !root.revealed
  }
}
