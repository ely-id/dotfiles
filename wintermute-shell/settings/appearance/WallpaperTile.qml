import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell.Widgets
import "../../wallpaper/daylight" as Daylight
import "../.." as Shell

// Miniatura do seletor de papel de parede (ficha 13; Figma 13:16208): 276×156, raio 12, conteúdo
// recortado e borda `border` de 1 por cima da imagem. Há quatro formas: a imagem nativa (com título e
// autor sobre um degradê preto no hover ou no foco), o Dinâmico (o céu da Daylight, com "Dynamic" sempre
// visível), "Choose an image" (contorno tracejado em borderStrong sobre cardHover) e a imagem
// acrescentada, que leva só o número (`number` > 0, P-59): no hover ou no foco o mesmo degradê e o
// número em Geist Mono, na posição do título único do "Dynamic". Essa quarta não tem board; é composição
// (ajuste A-05) com a miniatura que já existe.
// A selecionada ganha o anel accent de 1 a 4 px da miniatura e a marca de 24 em accent no canto.
// O foco pelo teclado desenha o mesmo anel, como na origem; o Figma não desenha foco.
// Escolha minha: o Figma não desenha hover em "Choose an image". Uso o fundo `pressed`, como no botão
// Manual das Informações, com a duração dos Ajustes.
Item {
  id: root
  property bool adding: false
  property bool dynamic: false
  property bool selected: false
  property string title
  property string subtitle
  property url source
  // Posição da imagem acrescentada na ordem de entrada (1, 2, ...); 0 quando a miniatura não é uma.
  property int number: 0
  readonly property string numberLabel: number < 10 ? "0" + number : String(number)
  // Só para a vitrine: fixa o hover na miniatura.
  property bool forceHovered: false
  readonly property bool highlighted: forceHovered || hover.hovered || activeFocus
  signal clicked
  implicitWidth: Shell.Theme.settingsWallpaperTileWidth
  implicitHeight: Shell.Theme.settingsWallpaperTileHeight
  activeFocusOnTab: true
  Accessible.role: adding ? Accessible.Button : Accessible.RadioButton
  Accessible.name: number > 0 ? "Wallpaper " + numberLabel : [title, subtitle].filter(Boolean).join(", ")
  Accessible.checked: selected
  Accessible.onPressAction: clicked()
  Keys.onReturnPressed: clicked()
  Keys.onSpacePressed: clicked()

  ClippingRectangle {
    anchors.fill: parent
    radius: Shell.Theme.radiusRow
    color: root.adding ? (root.highlighted ? Shell.Theme.pressed : Shell.Theme.cardHover) : Shell.Theme.control
    Behavior on color {
      ColorAnimation { duration: Shell.Theme.settingsHoverDuration; easing.type: Easing.OutCubic }
    }

    Image {
      anchors.fill: parent
      visible: !root.adding && !root.dynamic
      source: root.source
      sourceSize: Qt.size(Math.ceil(width * Screen.devicePixelRatio), Math.ceil(height * Screen.devicePixelRatio))
      fillMode: Image.PreserveAspectCrop
      asynchronous: true
      autoTransform: true
    }
    Loader {
      anchors.fill: parent
      active: root.dynamic
      sourceComponent: Daylight.Sky {}
    }

    // "Choose an image": ícone de 20 em (128,52) e o texto centrado numa caixa de 276×24 em y 80.
    Image {
      visible: root.adding
      x: Shell.Theme.settingsWallpaperAddIconX; y: Shell.Theme.settingsWallpaperAddIconY
      width: 20; height: 20
      source: Qt.resolvedUrl("../../icons/image-plus.svg")
      sourceSize: Qt.size(40, 40)
      smooth: true
      layer.enabled: root.adding
      layer.effect: MultiEffect { colorization: 1; colorizationColor: Shell.Theme.text }
    }
    Text {
      visible: root.adding
      y: Shell.Theme.settingsWallpaperAddLabelY
      width: parent.width; height: Shell.Theme.settingsWallpaperAddLabelHeight
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      elide: Text.ElideRight
      text: root.title
      color: Shell.Theme.text
      font.family: Shell.Theme.fontFamily
      font.weight: Font.Medium
      font.pixelSize: Shell.Theme.fontBody
      font.letterSpacing: 0
    }

    // Dinâmico: só o título, sem autor e sem degradê (o board só desenha o título).
    Text {
      visible: root.dynamic
      x: Shell.Theme.settingsWallpaperTextX; y: Shell.Theme.settingsWallpaperDynamicTitleY
      width: Shell.Theme.settingsWallpaperDynamicTitleWidth; height: Shell.Theme.settingsWallpaperTitleHeight
      verticalAlignment: Text.AlignVCenter
      elide: Text.ElideRight
      text: root.title
      color: Shell.Theme.text
      font.family: Shell.Theme.fontFamily
      font.weight: Font.Medium
      font.pixelSize: Shell.Theme.fontBody
      font.letterSpacing: 0
    }

    // Imagem: degradê preto de 276×80 na base e, por cima, título e autor (ou só o número, na acrescentada).
    Item {
      anchors.fill: parent
      visible: !root.adding && !root.dynamic && root.highlighted
      Rectangle {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: Shell.Theme.settingsWallpaperGradientHeight
        gradient: Gradient {
          GradientStop { position: 0; color: "transparent" }
          GradientStop { position: 1; color: Qt.rgba(0, 0, 0, Shell.Theme.settingsWallpaperGradientOpacity) } // proveniencia: ficha 13, degradê preto 0→80%
        }
      }
      Text {
        visible: root.number === 0
        x: Shell.Theme.settingsWallpaperTextX; y: Shell.Theme.settingsWallpaperTitleY
        width: Shell.Theme.settingsWallpaperTextWidth; height: Shell.Theme.settingsWallpaperTitleHeight
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        text: root.title
        color: Shell.Theme.text
        font.family: Shell.Theme.fontFamily
        font.weight: Font.Medium
        font.pixelSize: Shell.Theme.fontBody
        font.letterSpacing: 0
      }
      Text {
        visible: root.number === 0
        x: Shell.Theme.settingsWallpaperTextX; y: Shell.Theme.settingsWallpaperAuthorY
        width: Shell.Theme.settingsWallpaperTextWidth; height: Shell.Theme.settingsWallpaperAuthorHeight
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        text: root.subtitle
        color: Shell.Theme.muted
        font.family: Shell.Theme.fontFamily
        font.weight: Font.Medium
        font.pixelSize: Shell.Theme.fontCaption
        font.letterSpacing: 0
      }
      // Acrescentada: uma linha só, onde o "Dynamic" põe o título (A-05), em Geist Mono 13 Regular.
      Text {
        visible: root.number > 0
        x: Shell.Theme.settingsWallpaperTextX; y: Shell.Theme.settingsWallpaperDynamicTitleY
        width: Shell.Theme.settingsWallpaperDynamicTitleWidth; height: Shell.Theme.settingsWallpaperTitleHeight
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
        text: root.numberLabel
        color: Shell.Theme.text
        font.family: Shell.Theme.monoFontFamily
        font.weight: Font.Normal
        font.pixelSize: Shell.Theme.fontMonoNumber
        font.letterSpacing: 0
      }
    }
  }

  // Borda de 1 por cima da imagem; "Choose an image" troca por um contorno tracejado [4,4].
  Rectangle {
    anchors.fill: parent
    visible: !root.adding
    radius: Shell.Theme.radiusRow
    color: "transparent"
    border.width: 1
    border.color: Shell.Theme.border
    antialiasing: true
  }
  // O Rectangle não traceja. O traço de 1 px fica por dentro da miniatura (meio pixel de folga),
  // então o dashPattern, medido em larguras de traço, dá segmentos de 4 px com 4 de vão.
  Shape {
    anchors.fill: parent
    visible: root.adding
    preferredRendererType: Shape.CurveRenderer
    ShapePath {
      strokeColor: Shell.Theme.borderStrong
      strokeWidth: 1
      fillColor: "transparent"
      strokeStyle: ShapePath.DashLine
      dashPattern: [4, 4]
      PathRectangle {
        x: 0.5; y: 0.5
        width: root.width - 1; height: root.height - 1
        radius: Shell.Theme.radiusRow - 0.5
      }
    }
  }

  // Marca da selecionada: círculo accent de 24 em (240,12) com o check de 16 em (4,4).
  Rectangle {
    visible: root.selected
    x: Shell.Theme.settingsWallpaperMarkX; y: Shell.Theme.settingsWallpaperMarkY
    width: Shell.Theme.settingsWallpaperMarkSize; height: width
    radius: width / 2
    color: Shell.Theme.accent
    antialiasing: true
    Image {
      x: 4; y: 4
      width: 16; height: 16
      sourceSize: Qt.size(32, 32)
      source: Qt.resolvedUrl("../../icons/check.svg")
      smooth: true
      layer.enabled: root.selected
      layer.effect: MultiEffect { colorization: 1; colorizationColor: Shell.Theme.textOnAccent }
    }
  }
  // Anel da selecionada (e do foco): accent de 1, 4 px para fora da miniatura.
  Rectangle {
    anchors { fill: parent; margins: -Shell.Theme.settingsWallpaperRingGap }
    visible: root.selected || root.activeFocus
    radius: Shell.Theme.settingsWallpaperRingRadius
    color: "transparent"
    border.width: 1
    border.color: Shell.Theme.accent
    antialiasing: true
  }
  HoverHandler { id: hover; cursorShape: Qt.PointingHandCursor }
  TapHandler { onTapped: root.clicked() }
}
