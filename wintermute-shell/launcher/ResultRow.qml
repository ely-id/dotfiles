import QtQuick
import QtQuick.Effects
import ".."

// Linha de resultado do launcher (ficha 14): 624×44, raio 12. Sem fundo no repouso, `hover` sob o ponteiro
// e `accentSubtle` na selecionada (a selecionada vence o hover). Bloco de 28 com o ícone de 16, título e
// detalhe lado a lado, tipo à direita e a tecla ↵ só na selecionada.
//
// Não usei o AppTile de 28: ele desenha uma borda `border` que o bloco do board não tem, e a cor do ícone
// dele é sempre `text`, sem o `dangerText` do comando perigoso.
Item {
  id: root

  property string title: ""
  property string detail: ""
  property string kind: ""
  // Nome de um ícone de icons/ (branco, colorizado aqui) ou um ícone de aplicativo (caminho ou nome do tema,
  // que mantém as próprias cores: ficha 00, "Cor dos ícones").
  property string iconName: ""
  property string iconSource: ""
  property bool danger: false
  property bool selected: false
  // Para fixar o hover na vitrine.
  property bool forceHovered: false
  readonly property bool hovered: forceHovered || pointer.hovered

  signal clicked

  implicitWidth: Theme.launcherRowWidth
  implicitHeight: Theme.launcherResultHeight

  // Os títulos e os detalhes cortam com reticências antes da caixa do tipo (que começa em 576 − 140 = 436).
  readonly property real textLimit: Theme.launcherTypeRight - Theme.launcherTypeWidth - Theme.launcherRowTextX
  readonly property color secondaryColor: selected ? Theme.text : Theme.muted

  Rectangle {
    anchors.fill: parent
    radius: Theme.radiusRow
    color: root.selected ? Theme.accentSubtle
        : root.hovered ? Theme.hover
        : "transparent"
    antialiasing: true

    Behavior on color {
      ColorAnimation {
        duration: Theme.controlDuration
        easing.type: Easing.OutCubic
      }
    }
  }

  Rectangle {
    x: Theme.launcherBlockOffset
    y: Theme.launcherBlockOffset
    width: Theme.launcherBlockSize
    height: Theme.launcherBlockSize
    radius: Theme.launcherBlockRadius
    color: Theme.control
    antialiasing: true

    Image {
      x: Theme.launcherBlockIconOffset
      y: Theme.launcherBlockIconOffset
      width: Theme.launcherBlockIconSize
      height: Theme.launcherBlockIconSize
      source: root.iconName !== "" ? Qt.resolvedUrl("../icons/" + root.iconName + ".svg")
          : root.iconSource !== "" ? AppIcon.path(root.iconSource, "application-x-executable") : ""
      sourceSize: Qt.size(width * 2, height * 2)
      fillMode: Image.PreserveAspectFit
      smooth: true
      antialiasing: true
      layer.enabled: root.iconName !== ""
      layer.effect: MultiEffect {
        colorization: 1
        colorizationColor: root.danger ? Theme.dangerText : Theme.text
      }
    }
  }

  Text {
    id: titleText
    x: Theme.launcherRowTextX
    y: Theme.launcherRowTextY
    width: Math.min(implicitWidth, root.textLimit)
    height: Theme.launcherRowTextHeight
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
    text: root.title
    color: Theme.text
    font.family: Theme.fontFamily
    font.weight: Font.Medium
    font.pixelSize: Theme.fontBody
    font.letterSpacing: 0
  }

  Text {
    x: titleText.x + titleText.width + Theme.launcherRowTextGap
    y: Theme.launcherRowTextY
    width: Math.max(0, root.textLimit - titleText.width - Theme.launcherRowTextGap)
    height: Theme.launcherRowTextHeight
    visible: root.detail !== "" && width > 0
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
    text: root.detail
    color: root.secondaryColor
    font.family: Theme.fontFamily
    font.weight: Font.Normal
    font.pixelSize: Theme.fontBody
    font.letterSpacing: 0
  }

  // Tipo: caixa de 140×44 alinhada à direita, terminando em x 576 (as medidas dos filhos são relativas à linha).
  Text {
    x: Theme.launcherTypeRight - Theme.launcherTypeWidth
    width: Theme.launcherTypeWidth
    height: root.height
    horizontalAlignment: Text.AlignRight
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
    text: root.kind
    color: root.secondaryColor
    font.family: Theme.fontFamily
    font.weight: Font.Medium
    font.pixelSize: Theme.fontCaption
    font.letterSpacing: 0
  }

  KeyCap {
    x: Theme.launcherEnterKeyX
    y: Theme.launcherEnterKeyY
    text: "↵"
    visible: root.selected
  }

  HoverHandler {
    id: pointer
    cursorShape: Qt.PointingHandCursor
  }

  TapHandler {
    onTapped: root.clicked()
  }
}
