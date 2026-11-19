import QtQuick
import ".."

// Cabeçalho da página de ações do launcher (ficha 14, F5-T05; sem board, ajuste A-05): o botão de voltar da página do
// seletor de cor, em (12,12), e o nome do item na caixa do campo de busca, em Geist Regular 17 `text`, cortado com reticências.
// É um FocusScope porque, sem o campo de busca, as teclas da página chegam por aqui: o Panel liga os sinais ao que cada
// uma faz. O divisor em y 56 é do Panel.
FocusScope {
  id: root

  // O nome do item cujas ações aparecem (o título da linha, ou a expressão no cálculo).
  property string title: ""

  signal upPressed
  signal downPressed
  signal accepted
  // Esc, Backspace e o botão de voltar: um passo para trás.
  signal backRequested
  // Ctrl+K de novo: fecha o menu inteiro, de qualquer camada.
  signal menuRequested

  implicitWidth: Theme.launcherWidth
  implicitHeight: Theme.launcherSearchHeight

  // As teclas da página: ↑↓ andam, Enter roda, Esc e Backspace voltam e Ctrl+K fecha o menu. As outras não fazem
  // nada; Ctrl, Alt e Meta com outra tecla passam, não são minhas. Devolve se tratou a tecla.
  function handleKey(key, modifiers) {
    if ((modifiers & Qt.ControlModifier) && key === Qt.Key_K) {
      root.menuRequested();
      return true;
    }
    if (modifiers & (Qt.ControlModifier | Qt.AltModifier | Qt.MetaModifier))
      return false;
    if (key === Qt.Key_Up) {
      root.upPressed();
      return true;
    }
    if (key === Qt.Key_Down) {
      root.downPressed();
      return true;
    }
    if (key === Qt.Key_Return || key === Qt.Key_Enter) {
      root.accepted();
      return true;
    }
    if (key === Qt.Key_Escape || key === Qt.Key_Backspace) {
      root.backRequested();
      return true;
    }
    return false;
  }

  Keys.onPressed: event => { event.accepted = root.handleKey(event.key, event.modifiers); }

  IconButton {
    x: Theme.launcherColorBackX
    y: Theme.launcherColorBackY
    iconName: "chevron-left"
    accessibleName: "Back to launcher"
    onClicked: root.backRequested()
  }

  // A caixa do campo de busca: de x 52 até 20 da borda direita, 24 de altura.
  Text {
    x: Theme.launcherFieldX
    y: Theme.launcherFieldY
    width: root.width - x - Theme.launcherFieldRightMargin
    height: Theme.launcherFieldHeight
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
    text: root.title
    color: Theme.text
    font.family: Theme.fontFamily
    font.weight: Font.Normal
    font.pixelSize: Theme.fontSearch
    font.letterSpacing: 0
  }
}
