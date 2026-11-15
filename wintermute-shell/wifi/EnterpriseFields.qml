pragma ComponentBehavior: Bound
import QtQuick
import ".."

// Campos de rede empresarial (WPA2/3 Enterprise): rótulo 15 Medium, campo 28 abaixo, 12 entre linhas.
Column {
  id: root
  property string eap: "peap"
  property string innerAuth: "mschapv2"
  readonly property var eapOptions: [
    { label: "PEAP", mode: "peap" },
    { label: "TTLS", mode: "ttls" }
  ]
  readonly property var innerOptions: eap === "ttls" ? [
    { label: "PAP", mode: "pap" },
    { label: "MSCHAPv2", mode: "mschapv2" },
    { label: "MSCHAP", mode: "mschap" },
    { label: "CHAP", mode: "chap" }
  ] : [{ label: "MSCHAPv2", mode: "mschapv2" }]
  readonly property bool complete: username.text.trim() !== ""
      && password.text !== "" && domain.text.trim() !== ""
  readonly property string secret: password.text
  readonly property var settings: ({
    identity: username.text.trim(), eap: eap, phase2: innerAuth,
    anonymousIdentity: anonymous.text.trim(), domain: domain.text.trim(),
    caCertificate: certificate.text.trim()
  })
  signal menuRequested(var menu)
  signal accepted()
  signal fieldFocused(var field)

  width: PanelStyle.fieldWidth
  spacing: 12

  function select(setting, mode) {
    if (setting === "eap") {
      eap = mode;
      innerAuth = mode === "ttls" ? "pap" : "mschapv2";
    } else if (setting === "inner") {
      innerAuth = mode;
    }
  }
  function focusEditor() { username.focusEditor(); }

  component InputField: Field {
    onFocusedChanged: if (focused) root.fieldFocused(this)
  }

  component FormRow: Column {
    property string label
    width: PanelStyle.fieldWidth
    spacing: 8
    Text {
      text: parent.label
      color: Theme.text
      font.family: Theme.fontFamily
      font.weight: Font.Medium
      font.pixelSize: Theme.fontLabel
      font.letterSpacing: 0
      height: 20
    }
  }

  FormRow {
    label: "Usuário"
    InputField { id: username; placeholderText: "Usuário" }
  }
  FormRow {
    label: "Senha"
    InputField {
      id: password
      password: true
      placeholderText: "Senha"
      onAccepted: root.accepted()
    }
  }
  FormRow {
    label: "Autenticação"
    SelectField {
      text: root.eap.toUpperCase()
      onActiveFocusChanged: if (activeFocus) root.fieldFocused(this)
      onClicked: root.menuRequested({setting: "eap", options: root.eapOptions,
                                    mode: root.eap, anchor: this})
    }
  }
  FormRow {
    label: "Autenticação interna"
    visible: root.innerOptions.length > 1
    SelectField {
      text: root.innerOptions.find(option => option.mode === root.innerAuth)?.label || ""
      onActiveFocusChanged: if (activeFocus) root.fieldFocused(this)
      onClicked: root.menuRequested({setting: "inner", options: root.innerOptions,
                                    mode: root.innerAuth, anchor: this})
    }
  }
  FormRow {
    label: "Domínio do servidor"
    InputField {
      id: domain
      placeholderText: "ex.: wifi.exemplo.edu.br"
      onAccepted: root.accepted()
    }
  }
  FormRow {
    label: "Identidade anônima (opcional)"
    InputField { id: anonymous; placeholderText: "Identidade anônima" }
  }
  FormRow {
    label: "Certificado CA (opcional)"
    InputField {
      id: certificate
      placeholderText: "/caminho/do/certificado.pem"
      onAccepted: root.accepted()
    }
  }
}
