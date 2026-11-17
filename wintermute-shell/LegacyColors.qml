import QtQuick

// Paleta herdada do código de partida.
//
// O código que copiei lê cerca de cem papéis de cor por `Theme.colors.<papel>`.
// O tema Armitage não tem esses papéis: ele tem tokens (`Theme.accent`,
// `Theme.hover`, `Theme.border`...). Este arquivo existe para a shell abrir
// enquanto as peças não são redesenhadas, e encolhe a cada fase: quando uma
// peça passa a ler os tokens, os papéis que só ela usava saem daqui. No fim da
// F6 o arquivo deixa de existir.
//
// Os valores são os do tema padrão da origem, o translúcido, sem alteração.
// Nenhum valor daqui é referência de design: os valores certos estão em
// docs/design/.
//
// Sobraram quatro papéis, por motivos diferentes:
// - `translucent`: a shell inteira lê, para saber se as superfícies desfocam o
//   que está atrás.
// - `rowHover` e `sidebarDivider`: só o menu suspenso dos Ajustes
//   (`settings/Dropdown.qml`) lê. Ele mantém o desenho da origem por enquanto
//   (pendência P-46).
// - `sidebarCardOutline`: é a cor de partida de `sidebarDivider`; nenhuma peça o
//   lê direto.
QtObject {
  // As superfícies são translúcidas e desfocam o que está atrás.
  property bool translucent: true

  property color rowHover: Qt.rgba(1, 1, 1, 0.06)

  property color sidebarCardOutline: Qt.alpha("#F9EFFF", 0.1)
  property color sidebarDivider: sidebarCardOutline
}
