import QtQuick

// Estado fictício das páginas do Sistema para a vitrine da F4 (ficha 13): touchpad no passo 6, mouse no
// passo 5, rolagem natural só no touchpad e quatro layouts de teclado. Mesma superfície de
// settings/system/State.qml. Nada aqui grava no input.kdl.
QtObject {
  id: root
  property var languages: [
    { id: "br", label: "Portuguese (Brazil)" },
    { id: "pt", label: "Portuguese" },
    { id: "br(dvorak)", label: "Portuguese (Brazil, Dvorak)" },
    { id: "us(intl)", label: "English (US, intl., with dead keys)" }
  ]
  property var selectedLanguages: ["br"]
  property var languageNames: ["Portuguese (Brazil)"]
  property string error: ""
  property var mouse: ({ touchpadSpeed: 6, mouseSpeed: 5, acceleration: true, naturalTouchpad: true, naturalMouse: false })

  function toggleLanguage(id) {
    const chosen = selectedLanguages.indexOf(id) >= 0
        ? selectedLanguages.filter(value => value !== id) : selectedLanguages.concat(id);
    if (!chosen.length) return;
    selectedLanguages = chosen;
    languageNames = chosen.map(value => languages.find(item => item.id === value).label);
  }
  function setMouse(key, value) { mouse = Object.assign({}, mouse, { [key]: value }); }
}
