import QtQuick
import ".."

// Entrar na rede (ficha 05, 316×228): título (20,16), rótulo "Senha" 15 em (20,72), campo em
// (20,100) e botão primário "Conectar" em (20,160), desativado até haver senha.
// Redes empresariais usam o formulário rolável, a partir de y 72.
Item {
  id: root
  readonly property bool headerDividerVisible: !optionsMenu.visible || optionsMenu.y > PanelStyle.headerDividerY
  property var stackController
  property var selection: ({})
  property bool interactive: true
  property var menu: ({})
  property bool dropdownOpen: false
  readonly property bool isEnterprise: selection.enterprise === true
  readonly property bool canConnect: isEnterprise ? enterprise.complete : password.text.length > 0

  implicitWidth: PanelStyle.width
  implicitHeight: isEnterprise ? connectButton.y + connectButton.height + 20 : 228

  function focusEditor() {
    if (isEnterprise) enterprise.focusEditor();
    else password.focusEditor();
  }
  function connect() {
    if (!canConnect)
      return;
    root.stackController.connectNetwork(
        String(root.selection.ssid || ""),
        root.isEnterprise ? enterprise.secret : password.text, false,
        root.isEnterprise ? "wpa-eap" : "auto",
        root.isEnterprise ? enterprise.settings : undefined);
  }
  Component.onCompleted: if (interactive) focusEditor()
  onInteractiveChanged: if (interactive) focusEditor()

  PanelBackground { anchors.fill: parent; stacked: true }
  Item {
    anchors.fill: parent
    enabled: root.interactive && !root.dropdownOpen
    opacity: root.dropdownOpen ? 0.2 : 1
    Behavior on opacity {
      NumberAnimation { duration: PanelStyle.controlDuration }
    }

    Text {
      x: 20; y: 16
      width: 276; height: 32
      verticalAlignment: Text.AlignVCenter
      elide: Text.ElideRight
      text: "Entrar em “" + String(root.selection.ssid || "Rede Wi-Fi") + "”"
      color: Theme.text
      font.family: Theme.titleFontFamily
      font.weight: Font.Normal
      font.pixelSize: Theme.fontPanelTitle
      font.letterSpacing: 0
    }
    Text {
      x: 20; y: 72
      text: "Senha"
      visible: !root.isEnterprise
      color: Theme.text
      font.family: Theme.fontFamily
      font.weight: Font.Medium
      font.pixelSize: Theme.fontLabel
      font.letterSpacing: 0
    }
    Field {
      id: password
      x: 20; y: 100
      visible: !root.isEnterprise
      password: true
      placeholderText: "Senha"
      onAccepted: root.connect()
    }
    FormViewport {
      id: form
      y: 72
      width: parent.width
      height: 416
      contentHeight: enterprise.height
      visible: root.isEnterprise
      EnterpriseFields {
        id: enterprise
        x: 20
        onFieldFocused: field => form.reveal(field)
        onAccepted: root.connect()
        onMenuRequested: menu => { root.menu = menu; root.dropdownOpen = true; }
      }
    }
    ActionButton {
      id: connectButton
      x: 20
      y: root.isEnterprise ? form.y + form.height + 16 : 160
      kind: "primary"
      text: "Conectar"
      interactive: root.canConnect
      onClicked: root.connect()
    }
  }
  Item {
    anchors.fill: parent
    enabled: root.interactive && root.dropdownOpen
    TapHandler { onTapped: root.dropdownOpen = false }
  }
  SecurityMenu {
    id: optionsMenu
    z: 20
    open: root.dropdownOpen
    anchorItem: root.menu?.anchor ?? null
    options: root.menu?.options ?? []
    currentMode: root.menu?.mode ?? ""
    onDismissed: root.dropdownOpen = false
    onSelected: (label, mode) => {
      enterprise.select(root.menu.setting, mode);
      root.dropdownOpen = false;
    }
  }
}
