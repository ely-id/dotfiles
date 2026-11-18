pragma ComponentBehavior: Bound

import QtQuick
import ".."

// Página de resultado do seletor de cor (ficha 15, board 13:17120, nó 13:17499): o corpo do launcher no lugar da
// busca e da lista, com o cabeçalho (voltar e título), a amostra, o nome e a origem, "Pick another", os três
// formatos copiáveis e o histórico. O vidro, o divisor do cabeçalho em y 56 e o rodapé são do Panel.qml.
// `service` é a fonte de tudo (colorInfo, colorOrigin, colorHistory, colorCopied e as ações); a vitrine troca por
// um serviço fictício. É um FocusScope porque, sem o campo de busca, as teclas desta página chegam por aqui.
FocusScope {
  id: root

  property var service
  // Para fixar na vitrine a amostra do histórico sob o ponteiro (-1: nenhuma).
  property int historyHoverIndex: -1

  readonly property var info: service ? service.colorInfo : null

  // As teclas da página (P-76): Enter copia o HEX, P pede outra cor, Esc e Backspace voltam ao launcher. As outras
  // não fazem nada. Ctrl, Alt e Meta passam: não são minhas. Devolve se tratou a tecla.
  function handleKey(key, modifiers) {
    if (modifiers & (Qt.ControlModifier | Qt.AltModifier | Qt.MetaModifier))
      return false;
    if (key === Qt.Key_Return || key === Qt.Key_Enter) {
      service.copyColor("hex");
      return true;
    }
    if (key === Qt.Key_P) {
      service.pickAnother();
      return true;
    }
    if (key === Qt.Key_Escape || key === Qt.Key_Backspace) {
      service.closePage();
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
    onClicked: root.service.closePage()
  }

  // Mesma caixa do campo de busca (52,16, de 24 de altura), só mais curta.
  Text {
    x: Theme.launcherFieldX
    y: Theme.launcherFieldY
    width: Theme.launcherColorTitleWidth
    height: Theme.launcherFieldHeight
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
    text: "Color picker"
    color: Theme.text
    font.family: Theme.fontFamily
    font.weight: Font.Normal
    font.pixelSize: Theme.fontSearch
    font.letterSpacing: 0
  }

  Rectangle {
    visible: root.info !== null
    x: Theme.launcherColorSwatchX
    y: Theme.launcherColorSwatchY
    width: Theme.launcherColorSwatchSize
    height: Theme.launcherColorSwatchSize
    radius: Theme.radiusCard
    color: root.info ? root.info.hex : "transparent"
    border.width: 1
    border.color: Theme.border
    antialiasing: true
  }

  Text {
    x: Theme.launcherColorNameX
    y: Theme.launcherColorNameY
    width: Theme.launcherColorNameWidth
    height: Theme.launcherColorNameHeight
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
    text: root.info ? root.info.name : ""
    color: Theme.text
    font.family: Theme.titleFontFamily
    font.weight: Font.Normal
    font.pixelSize: Theme.fontLauncherColorName
    font.letterSpacing: 0
  }

  Text {
    x: Theme.launcherColorNameX
    y: Theme.launcherColorOriginY
    width: Theme.launcherColorNameWidth
    height: Theme.launcherColorOriginHeight
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
    text: root.service ? root.service.colorOrigin : ""
    color: Theme.muted
    font.family: Theme.fontFamily
    font.weight: Font.Normal
    font.pixelSize: Theme.fontBody
    font.letterSpacing: 0
  }

  ActionButton {
    x: Theme.launcherColorNameX
    y: Theme.launcherColorButtonY
    width: Theme.launcherColorButtonWidth
    small: true
    text: "Pick another"
    onClicked: root.service.pickAnother()
  }

  Repeater {
    model: [
      { key: "hex", label: "HEX", copyName: "Copy HEX" },
      { key: "rgb", label: "RGB", copyName: "Copy RGB" },
      { key: "hsl", label: "HSL", copyName: "Copy HSL" }
    ]

    delegate: ColorFormatRow {
      required property var modelData
      required property int index
      visible: root.info !== null
      x: Theme.launcherColorFormatX
      y: Theme.launcherColorFormatY + index * Theme.launcherColorFormatStep
      label: modelData.label
      value: root.info ? root.info[modelData.key] : ""
      copyName: modelData.copyName
      copied: root.service.colorCopied === modelData.key
      onCopyRequested: root.service.copyColor(modelData.key)
    }
  }

  ColorHistory {
    width: root.width
    height: root.height
    model: root.service ? root.service.colorHistory : []
    pinned: root.historyHoverIndex
    onPicked: index => root.service.showColor(index)
  }
}
