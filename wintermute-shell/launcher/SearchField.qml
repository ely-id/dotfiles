import QtQuick
import QtQuick.Effects
import ".."

// Cabeçalho de busca do launcher (ficha 14): ícone de 20 em (18,18) e o campo de 24 de altura em (52,16),
// Geist Regular 17. O cursor é meu, de 1×24 em accentText, porque o do TextInput não deixa 1 de folga do
// texto. A sugestão fantasma vem depois do cursor, com 1 de folga, em muted a 70%. Com contexto, a etiqueta fica
// à direita do cabeçalho e o campo termina 8 antes dela, em vez de 20 antes da borda.
Item {
  id: root

  property string text: ""
  property string placeholderText: "Search apps, files and commands"
  // O resto da palavra sugerida; vazio quando não há.
  property string ghost: ""
  // Na vitrine não há foco de teclado, então o cursor pode ser pedido à força.
  property bool forceCursor: false
  property string iconName: "search"
  // Com os chips das ferramentas em foco, ← e → andam nos chips; senão são do campo e movem o cursor do texto.
  property bool captureHorizontal: false
  // O contexto em que o launcher foi aberto ("On workspace 3"); vazio, sem etiqueta.
  property string contextLabel: ""

  signal edited(string text)
  signal accepted
  signal upPressed
  signal downPressed
  signal leftPressed
  signal rightPressed
  signal tabPressed
  signal escapePressed
  signal actionsPressed

  readonly property bool cursorShown: editor.activeFocus || forceCursor
  readonly property bool cursorAtEnd: editor.cursorPosition === editor.length

  implicitWidth: Theme.launcherWidth
  implicitHeight: Theme.launcherSearchHeight

  function focusEditor() {
    editor.forceActiveFocus(Qt.OtherFocusReason);
  }

  function moveCursorToEnd() {
    editor.cursorPosition = editor.length;
  }

  Image {
    x: Theme.launcherSearchIconX
    y: Theme.launcherSearchIconY
    width: Theme.launcherSearchIconSize
    height: Theme.launcherSearchIconSize
    source: Qt.resolvedUrl("../icons/" + root.iconName + ".svg")
    sourceSize: Qt.size(width * 2, height * 2)
    fillMode: Image.PreserveAspectFit
    smooth: true
    antialiasing: true
    layer.enabled: true
    layer.effect: MultiEffect { colorization: 1; colorizationColor: Theme.text }
  }

  ContextTag {
    id: contextTag
    visible: root.contextLabel !== ""
    text: root.contextLabel
    x: root.width - Theme.launcherContextRightMargin - width
    y: Theme.launcherContextY
  }

  // Caixa do campo: de x 52 até 20 da borda direita (ou 8 antes da etiqueta), 24 de altura, cortando o que passar.
  Item {
    id: field
    x: Theme.launcherFieldX
    y: Theme.launcherFieldY
    width: contextTag.visible ? contextTag.x - Theme.launcherContextFieldGap - x
        : root.width - x - Theme.launcherFieldRightMargin
    height: Theme.launcherFieldHeight
    clip: true

    // Vazio: o cursor fica na frente do placeholder, que começa 2 depois (1 do cursor e 1 de folga).
    Text {
      x: Theme.launcherCursorWidth + Theme.launcherCursorGap
      width: parent.width - x
      height: parent.height
      visible: editor.length === 0
      verticalAlignment: Text.AlignVCenter
      elide: Text.ElideRight
      text: root.placeholderText
      color: Theme.muted
      font.family: Theme.fontFamily
      font.weight: Font.Normal
      font.pixelSize: Theme.fontSearch
      font.letterSpacing: 0
    }

    TextInput {
      id: editor
      width: parent.width
      height: parent.height
      verticalAlignment: TextInput.AlignVCenter
      text: root.text
      color: Theme.text
      selectionColor: Theme.accentSubtle
      selectedTextColor: Theme.text
      selectByMouse: true
      font.family: Theme.fontFamily
      font.weight: Font.Normal
      font.pixelSize: Theme.fontSearch
      font.letterSpacing: 0
      // Escondo o cursor do Qt: o desenho é o do Rectangle abaixo.
      cursorDelegate: Item {}
      onTextEdited: root.edited(text)
      onAccepted: root.accepted()
      Keys.onUpPressed: event => { root.upPressed(); event.accepted = true; }
      Keys.onDownPressed: event => { root.downPressed(); event.accepted = true; }
      // Sem `captureHorizontal` devolvo o evento, e o TextInput move o cursor como sempre.
      Keys.onLeftPressed: event => {
        if (root.captureHorizontal) {
          root.leftPressed();
          event.accepted = true;
        } else {
          event.accepted = false;
        }
      }
      Keys.onRightPressed: event => {
        if (root.captureHorizontal) {
          root.rightPressed();
          event.accepted = true;
        } else {
          event.accepted = false;
        }
      }
      Keys.onTabPressed: event => { root.tabPressed(); event.accepted = true; }
      Keys.onEscapePressed: event => { root.escapePressed(); event.accepted = true; }
      // Ctrl+K abre o menu de ações (F5-T05). Aceito o evento também para o Qt não apagar até o fim da linha.
      Keys.onPressed: event => {
        if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_K) {
          root.actionsPressed();
          event.accepted = true;
        }
      }
    }

    // Com texto, o cursor fica 1 depois do último caractere; vazio, em x 0.
    Rectangle {
      x: editor.length > 0 ? Math.round(editor.cursorRectangle.x) + Theme.launcherCursorGap : 0
      width: Theme.launcherCursorWidth
      height: parent.height
      color: Theme.accentText
      visible: root.cursorShown
    }

    // A sugestão só aparece com o cursor no fim do texto.
    Text {
      x: Math.round(editor.cursorRectangle.x) + Theme.launcherCursorGap + Theme.launcherCursorWidth + Theme.launcherCursorGap
      width: Math.max(0, parent.width - x)
      height: parent.height
      visible: root.ghost !== "" && editor.length > 0 && root.cursorAtEnd
      verticalAlignment: Text.AlignVCenter
      elide: Text.ElideRight
      text: root.ghost
      color: Theme.muted
      opacity: Theme.launcherGhostOpacity
      font.family: Theme.fontFamily
      font.weight: Font.Normal
      font.pixelSize: Theme.fontSearch
      font.letterSpacing: 0
    }
  }
}
