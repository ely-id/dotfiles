import QtQuick
import "../settings" as Settings
import "../settings/appearance" as Appearance

// A página Aparência (settings/appearance/Body.qml) de verdade, dentro do Modal de 580, com valores
// fictícios e sem ligar nenhum serviço: os sinais não fazem nada aqui, então escolher um disco não
// grava theme.json nem pede brilho a ninguém. O quadro tem 600 de largura e 13 de folga em cima, como
// o do seletor de papel de parede (o botão de fechar pendura 13 acima).
// `appsDark` e `appsAutomatic` ligam as duas chaves dos aplicativos (F4-T23); os sinais não fazem nada.
// `brightnessAvailable`: false desliga a linha "Brilho da tela" e mostra "Indisponível".
// `error`: o texto do erro no fim da coluna; vazio não mostra nada. Com o brilho indisponível, a
// página real põe aqui o motivo que o control.py devolve (ficha 11).
Item {
  id: root
  property bool appsDark: false
  property bool appsAutomatic: false
  property bool brightnessAvailable: true
  property string error: ""

  implicitWidth: 600
  implicitHeight: modal.height + 26

  Settings.Modal {
    id: modal
    x: 0; y: 13
    title: "Appearance"
    bodyTop: 0
    contentHeight: body.contentHeight
    Appearance.Body {
      id: body
      appsDark: root.appsDark
      appsAutomatic: root.appsAutomatic
      brightnessAvailable: root.brightnessAvailable
      error: root.error
    }
  }
}
