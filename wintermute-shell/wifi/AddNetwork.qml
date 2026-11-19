import QtQuick
import ".."

// Adicionar rede (ficha 05, 316×436): rótulos 15 em y 72 / 156 / 240 (campo 28 abaixo), caixa
// "Rede oculta" em (20,328) com o rótulo em (48,328) e botão primário "Conectar" em (20,368),
// desativado até dar para conectar. Redes empresariais usam o formulário rolável.
Item {
  id: root
  readonly property bool headerDividerVisible: !securityMenu.visible || securityMenu.y > Theme.cardStackHeaderDividerY
  property var stackController
  property bool interactive: true
  property var menu: ({})
  property bool dropdownOpen: false
  property string securityValue: "WPA2/WPA3 Personal"
  property string securityMode: "wpa-psk"
  property bool hiddenNetwork: false
  readonly property bool isEnterprise: securityMode === "wpa-eap"
  readonly property bool needsPassword: securityMode !== "open"
      && securityMode !== "owe" && !isEnterprise
  readonly property bool canConnect: networkName.text.length > 0
      && (isEnterprise ? enterprise.complete : !needsPassword || password.text.length > 0)

  implicitWidth: Theme.panelWidth
  implicitHeight: connectButton.y + connectButton.height + 20
  onSecurityModeChanged: form.contentY = 0
  // A ficha mostra o campo do SSID já em foco.
  Component.onCompleted: if (interactive) networkName.focusEditor()
  onInteractiveChanged: if (interactive) networkName.focusEditor()

  function connect() {
    if (!canConnect)
      return;
    root.stackController.connectNetwork(
        networkName.text, root.isEnterprise ? enterprise.secret : password.text,
        root.hiddenNetwork, root.securityMode,
        root.isEnterprise ? enterprise.settings : undefined);
  }

  PanelBackground { anchors.fill: parent; stacked: true }

  Item {
    id: cardContent
    anchors.fill: parent
    enabled: root.interactive && !root.dropdownOpen
    opacity: root.dropdownOpen ? 0.2 : 1
    Behavior on opacity {
      NumberAnimation { duration: Theme.controlDuration }
    }

    Text {
      x: 20; y: 16
      width: 276; height: 32
      verticalAlignment: Text.AlignVCenter
      text: "Add network"
      color: Theme.text
      font.family: Theme.titleFontFamily
      font.weight: Font.Normal
      font.pixelSize: Theme.fontPanelTitle
      font.letterSpacing: 0
    }

    // O formulário começa em y 72; as posições abaixo são relativas a ele.
    FormViewport {
      id: form
      y: 72
      width: parent.width
      height: root.isEnterprise ? 416 : 296
      contentHeight: hidden.y + hidden.height + 8

      component FieldLabel: Text {
        x: 20
        color: Theme.text
        font.family: Theme.fontFamily
        font.weight: Font.Medium
        font.pixelSize: Theme.fontLabel
        font.letterSpacing: 0
      }

      FieldLabel { text: "Network name (SSID)" }
      Field {
        id: networkName
        x: 20; y: 28
        placeholderText: "Network name"
        onFocusedChanged: if (focused) form.reveal(this)
      }
      FieldLabel { y: 84; text: "Security" }
      SelectField {
        x: 20; y: 112
        text: root.securityValue
        onActiveFocusChanged: if (activeFocus) form.reveal(this)
        onClicked: {
          root.menu = {setting: "security", options: securityMenu.securityOptions,
                       mode: root.securityMode, anchor: this};
          root.dropdownOpen = true;
        }
      }

      FieldLabel { y: 168; text: "Password"; visible: root.needsPassword }
      Field {
        id: password
        x: 20; y: 196
        password: true
        placeholderText: "Password"
        visible: root.needsPassword
        onAccepted: root.connect()
      }
      EnterpriseFields {
        id: enterprise
        x: 20; y: 168
        visible: root.isEnterprise
        onFieldFocused: field => form.reveal(field)
        onAccepted: root.connect()
        onMenuRequested: menu => { root.menu = menu; root.dropdownOpen = true; }
      }

      CheckBox {
        id: hidden
        x: 20
        y: root.isEnterprise ? enterprise.y + enterprise.height + 12 : 256
        checked: root.hiddenNetwork
        onToggled: checked => root.hiddenNetwork = checked
      }
      Text {
        x: 48
        anchors.verticalCenter: hidden.verticalCenter
        text: "Hidden network"
        color: Theme.text
        font.family: Theme.fontFamily
        font.weight: Font.Medium
        font.pixelSize: Theme.fontBody
        font.letterSpacing: 0
      }
    }

    ActionButton {
      id: connectButton
      x: 20
      y: form.y + form.height + (root.isEnterprise ? 16 : 0)
      kind: "primary"
      text: "Connect"
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
    id: securityMenu
    z: 20
    open: root.dropdownOpen
    anchorItem: root.menu?.anchor ?? null
    options: root.menu?.options ?? []
    currentMode: root.menu?.mode ?? ""
    onDismissed: root.dropdownOpen = false
    onSelected: (label, mode) => {
      if (root.menu.setting === "security") {
        root.securityValue = label;
        root.securityMode = mode;
      } else {
        enterprise.select(root.menu.setting, mode);
      }
      root.dropdownOpen = false;
    }
  }
}
