pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import "settings/appearance" as Appearance

// Página de demonstração da F1 (ficha 00, boards 13:11217 e 13:11463).
// Abre com: qs -p ~/Projects/dotfiles/wintermute-shell ipc call demo toggle
PanelWindow {
  id: root
  required property var panelScreen
  property bool opened: false
  signal closeRequested

  screen: panelScreen
  visible: opened
  color: "transparent"

  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.namespace: "pond-settings-demo-" + (screen ? screen.name : "unknown")
  WlrLayershell.keyboardFocus: opened ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
  WlrLayershell.exclusionMode: ExclusionMode.Ignore
  anchors { top: true; bottom: true; left: true; right: true }

  BackgroundEffect.blurRegion: root.opened ? mainGlass.blurRegion : null

  property bool interactiveToggleChecked: true
  property bool interactiveCheckChecked: true
  property int interactiveRadioIndex: 1
  property real interactiveSliderValue: 0.60

  component Specimen: Column {
    id: specRoot
    default property alias stageData: stage.data
    property string caption: ""
    property real stageWidth: childrenRect.width
    property real stageHeight: childrenRect.height
    spacing: 8

    Item {
      id: stage
      width: specRoot.stageWidth
      height: specRoot.stageHeight
    }

    Text {
      text: specRoot.caption
      color: Theme.muted
      font.family: Theme.fontFamily
      font.weight: Font.Medium
      font.pixelSize: Theme.fontCaption
      font.letterSpacing: 0
    }
  }

  component SectionBlock: Column {
    id: secRoot
    default property alias itemsData: flow.data
    property string title: ""
    property int itemGap: 24
    width: parent ? parent.width : 1120
    spacing: 16

    Text {
      text: secRoot.title
      color: Theme.text
      font.family: Theme.titleFontFamily
      font.weight: Font.Normal
      font.pixelSize: Theme.fontPanelTitle
      font.letterSpacing: 0
    }

    Flow {
      id: flow
      width: parent.width
      spacing: secRoot.itemGap
    }
  }

  // Peças soltas do organizador (resumo da biblioteca em 00-componentes-base.md)
  component WorkspacePillSample: Rectangle {
    id: pill
    property string stateMode: "rest" // "rest" | "hover" | "active" | "dragging"
    property string numberText: stateMode === "active" ? "1" : "2"
    width: Theme.workspacePillWidth
    height: Theme.workspacePillHeight
    radius: 7
    color: stateMode === "active" ? Theme.accent
        : stateMode === "dragging" ? Theme.accentHover
        : Theme.raised
    border.width: stateMode === "active" || stateMode === "dragging" ? 0 : 1
    border.color: Theme.borderStrong
    antialiasing: true

    Text {
      anchors.centerIn: parent
      visible: pill.stateMode === "rest" || pill.stateMode === "active"
      text: pill.numberText
      color: pill.stateMode === "active" ? Theme.textOnAccent : Theme.text
      font.family: Theme.monoFontFamily
      font.weight: Font.Medium
      font.pixelSize: Theme.fontMonoCaption
      font.letterSpacing: 0
    }

    Column {
      anchors.centerIn: parent
      spacing: 2
      visible: pill.stateMode === "hover" || pill.stateMode === "dragging"
      Repeater {
        model: 3
        delegate: Rectangle {
          width: 2
          height: 2
          radius: 1
          color: pill.stateMode === "dragging" ? Theme.textOnAccent : Theme.text
        }
      }
    }
  }

  component WorkspaceWindowSample: Rectangle {
    id: winSample
    // "rest" | "hover" | "focus" | "lifted" | "collapsed" | "collapsedFocused"
    property string stateMode: "rest"
    readonly property bool isCollapsed: stateMode === "collapsed" || stateMode === "collapsedFocused"
    readonly property bool hasAccentRing: stateMode === "focus" || stateMode === "lifted" || stateMode === "collapsedFocused"
    width: isCollapsed ? Theme.workspaceCollapsedControlSize : Theme.workspaceControlSize
    height: width
    radius: width / 2
    color: stateMode === "hover" ? Theme.pressed
        : stateMode === "lifted" ? Theme.raised
        : Theme.control
    border.width: stateMode === "hover" ? 0 : (hasAccentRing ? 1.5 : 1)
    border.color: hasAccentRing ? Theme.accent : Theme.border
    antialiasing: true

    Shadow {
      anchors.fill: parent
      visible: winSample.stateMode === "lifted"
      cornerRadius: parent.radius
      strength: 0.5
    }

    Image {
      x: Math.round((parent.width - width) / 2)
      y: Math.round((parent.height - height) / 2)
      width: Theme.workspaceIconSize
      height: Theme.workspaceIconSize
      source: Qt.resolvedUrl("icons/terminal.svg")
      sourceSize: Qt.size(32, 32)
      smooth: true
      antialiasing: true
    }
  }

  component WorkspacePlusSample: Item {
    id: plusSample
    property bool hoveredState: false
    width: Theme.workspaceControlSize
    height: Theme.workspaceControlSize

    Rectangle {
      anchors.fill: parent
      radius: width / 2
      color: plusSample.hoveredState ? Theme.pressed : "transparent"
      antialiasing: true
    }

    Shape {
      anchors.fill: parent
      preferredRendererType: Shape.CurveRenderer
      ShapePath {
        strokeWidth: 1
        strokeColor: Theme.borderStrong
        strokeStyle: ShapePath.DashLine
        dashPattern: [4, 4]
        fillColor: "transparent"
        PathAngleArc {
          centerX: plusSample.width / 2
          centerY: plusSample.height / 2
          radiusX: (plusSample.width - 1) / 2
          radiusY: (plusSample.height - 1) / 2
          startAngle: 0
          sweepAngle: 360
        }
      }
    }

    Image {
      x: 12
      y: 12
      width: 16
      height: 16
      source: Qt.resolvedUrl("icons/plus.svg")
      sourceSize: Qt.size(32, 32)
      smooth: true
      antialiasing: true
      layer.enabled: !plusSample.hoveredState
      layer.effect: MultiEffect {
        colorization: 1
        colorizationColor: Theme.muted
      }
    }
  }

  Rectangle {
    anchors.fill: parent
    color: Theme.scrim
    focus: root.opened
    Keys.onEscapePressed: root.closeRequested()

    MouseArea {
      anchors.fill: parent
      onClicked: root.closeRequested()
    }

    Item {
      id: modalContainer
      anchors.centerIn: parent
      width: Math.min(1220, parent.width - 48)
      height: Math.min(820, parent.height - 48)

      GlassSurface {
        id: mainGlass
        x: 0
        y: 20
        width: parent.width - 20
        height: parent.height - 20
        surfaceType: "modal"

        MouseArea {
          anchors.fill: parent
          acceptedButtons: Qt.AllButtons
        }

        // Cabeçalho fixo
        Item {
          id: header
          x: 32
          y: 20
          width: parent.width - 64
          height: 52

          Text {
            x: 0
            anchors.verticalCenter: parent.verticalCenter
            text: "1 · Componentes base · " + Theme.displayName
            color: Theme.text
            font.family: Theme.titleFontFamily
            font.weight: Font.Normal
            font.pixelSize: Theme.fontModalTitle
            font.letterSpacing: 0
          }

          Row {
            anchors.right: parent.right
            anchors.rightMargin: 24
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            Repeater {
              model: [
                { key: "chiba", label: "Chiba" },
                { key: "freeside", label: "Freeside" },
                { key: "sprawl", label: "Sprawl" }
              ]

              delegate: Chip {
                required property var modelData
                text: modelData.label
                iconName: "palette"
                selected: Theme.name === modelData.key
                onClicked: Appearance.State.selectTheme(modelData.key)
              }
            }
          }
        }

        Rectangle {
          x: 32
          y: 80
          width: parent.width - 64
          height: 1
          color: Theme.border
        }

        Flickable {
          id: scrollArea
          x: 32
          y: 92
          width: parent.width - 64
          height: parent.height - 112
          contentWidth: width
          contentHeight: contentColumn.height + 24
          clip: true
          boundsBehavior: Flickable.StopAtBounds
          ScrollWheel { view: scrollArea }

          Column {
            id: contentColumn
            width: scrollArea.width
            spacing: 32

            // 1. Botões de ícone e fechar
            SectionBlock {
              title: "Botões de ícone · 32 (sidebar) e 40 (painéis)"

              Specimen {
                caption: "Repouso · 32"; stageWidth: 32; stageHeight: 32
                IconButton { buttonSize: 32; iconName: "wifi"; visualState: "rest" }
              }
              Specimen {
                caption: "Hover · 32"; stageWidth: 32; stageHeight: 32
                IconButton { buttonSize: 32; iconName: "volume-2"; visualState: "hover" }
              }
              Specimen {
                caption: "Pressionado · 32"; stageWidth: 32; stageHeight: 32
                IconButton { buttonSize: 32; iconName: "settings"; visualState: "pressed" }
              }
              Specimen {
                caption: "Selecionado · 32"; stageWidth: 32; stageHeight: 32
                IconButton { buttonSize: 32; iconName: "panel-left-close"; visualState: "selected" }
              }
              Specimen {
                caption: "Desativado · 32"; stageWidth: 32; stageHeight: 32
                IconButton { buttonSize: 32; iconName: "bell"; visualState: "disabled" }
              }

              Specimen {
                caption: "Repouso · 40"; stageWidth: 40; stageHeight: 40
                IconButton { buttonSize: 40; iconName: "wifi"; visualState: "rest" }
              }
              Specimen {
                caption: "Hover · 40"; stageWidth: 40; stageHeight: 40
                IconButton { buttonSize: 40; iconName: "volume-2"; visualState: "hover" }
              }
              Specimen {
                caption: "Pressionado · 40"; stageWidth: 40; stageHeight: 40
                IconButton { buttonSize: 40; iconName: "settings"; visualState: "pressed" }
              }
              Specimen {
                caption: "Selecionado · 40"; stageWidth: 40; stageHeight: 40
                IconButton { buttonSize: 40; iconName: "panel-left-close"; visualState: "selected" }
              }
              Specimen {
                caption: "Desativado · 40"; stageWidth: 40; stageHeight: 40
                IconButton { buttonSize: 40; iconName: "bell"; visualState: "disabled" }
              }

              Specimen {
                caption: "Fechar"; stageWidth: 40; stageHeight: 40
                PanelCloseButton { forceHovered: false }
              }
              Specimen {
                caption: "Fechar · hover"; stageWidth: 40; stageHeight: 40
                PanelCloseButton { forceHovered: true }
              }
            }

            // 2. Botões de texto
            SectionBlock {
              title: "Botões de texto"

              Specimen {
                caption: "Primário"; stageWidth: 276; stageHeight: 48
                ActionButton { kind: "primary"; text: "Conectar"; visualState: "rest" }
              }
              Specimen {
                caption: "Primário · hover"; stageWidth: 276; stageHeight: 48
                ActionButton { kind: "primary"; text: "Conectar"; visualState: "hover" }
              }
              Specimen {
                caption: "Primário · desativado"; stageWidth: 276; stageHeight: 48
                ActionButton { kind: "primary"; text: "Conectar"; visualState: "disabled" }
              }
              Specimen {
                caption: "Secundário"; stageWidth: 146; stageHeight: 40
                ActionButton { kind: "secondary"; text: "Desconectar"; visualState: "rest" }
              }
              Specimen {
                caption: "Secundário · hover"; stageWidth: 146; stageHeight: 40
                ActionButton { kind: "secondary"; text: "Desconectar"; visualState: "hover" }
              }
              Specimen {
                caption: "Secundário · desativado"; stageWidth: 146; stageHeight: 40
                ActionButton { kind: "secondary"; text: "Desconectar"; visualState: "disabled" }
              }
              Specimen {
                caption: "Perigo"; stageWidth: 146; stageHeight: 40
                ActionButton { kind: "danger"; text: "Esquecer rede"; visualState: "rest" }
              }
              Specimen {
                caption: "Perigo · hover"; stageWidth: 146; stageHeight: 40
                ActionButton { kind: "danger"; text: "Esquecer rede"; visualState: "hover" }
              }
            }

            // 3. Chaves, seleção e slider
            SectionBlock {
              title: "Chaves, seleção e slider"

              Specimen {
                caption: "Desligada"; stageWidth: 54; stageHeight: 28
                Toggle { checked: false; forceHovered: false }
              }
              Specimen {
                caption: "Desligada · hover"; stageWidth: 54; stageHeight: 28
                Toggle { checked: false; forceHovered: true }
              }
              Specimen {
                caption: "Ligada"; stageWidth: 54; stageHeight: 28
                Toggle { checked: true; forceHovered: false }
              }
              Specimen {
                caption: "Ligada · hover"; stageWidth: 54; stageHeight: 28
                Toggle { checked: true; forceHovered: true }
              }
              Specimen {
                caption: "Interativa"; stageWidth: 54; stageHeight: 28
                Toggle {
                  checked: root.interactiveToggleChecked
                  onToggled: next => root.interactiveToggleChecked = next
                }
              }

              Specimen {
                caption: "Caixa"; stageWidth: 20; stageHeight: 20
                CheckBox { checked: false }
              }
              Specimen {
                caption: "Caixa marcada"; stageWidth: 20; stageHeight: 20
                CheckBox {
                  checked: root.interactiveCheckChecked
                  onToggled: next => root.interactiveCheckChecked = next
                }
              }

              Specimen {
                caption: "Rádio"; stageWidth: 16; stageHeight: 16
                RadioButton {
                  checked: root.interactiveRadioIndex === 0
                  onClicked: root.interactiveRadioIndex = 0
                }
              }
              Specimen {
                caption: "Rádio marcado"; stageWidth: 16; stageHeight: 16
                RadioButton {
                  checked: root.interactiveRadioIndex === 1
                  onClicked: root.interactiveRadioIndex = 1
                }
              }

              Specimen {
                caption: "Seletor segmentado"; stageWidth: 168; stageHeight: 40
                SegmentedSelector { firstLabel: "Touchpad"; secondLabel: "Mouse" }
              }

              Specimen {
                caption: "Slider · repouso"; stageWidth: 276; stageHeight: 60
                Slider { y: 28; externalValue: 0.60; visualState: "rest" }
              }
              Specimen {
                caption: "Slider · hover"; stageWidth: 276; stageHeight: 60
                Slider { y: 28; externalValue: 0.60; visualState: "hover" }
              }
              Specimen {
                caption: "Slider · arrastando"; stageWidth: 276; stageHeight: 60
                Slider { y: 28; externalValue: 0.60; visualState: "dragging" }
              }
              Specimen {
                caption: "Slider · mudo"; stageWidth: 276; stageHeight: 60
                Slider { y: 28; externalValue: 0.60; visualState: "muted" }
              }
              Specimen {
                caption: "Slider · interativo"; stageWidth: 276; stageHeight: 60
                Slider {
                  y: 28
                  externalValue: root.interactiveSliderValue
                  onMoved: root.interactiveSliderValue = value
                }
              }
            }

            // 4. Campos
            SectionBlock {
              title: "Campos"

              Specimen {
                caption: "Vazio"; stageWidth: 276; stageHeight: 44
                Field { placeholderText: "Nome da rede"; visualState: "empty" }
              }
              Specimen {
                caption: "Hover"; stageWidth: 276; stageHeight: 44
                Field { placeholderText: "Nome da rede"; visualState: "hover" }
              }
              Specimen {
                caption: "Foco"; stageWidth: 276; stageHeight: 44
                Field { placeholderText: "Nome da rede"; visualState: "focus" }
              }
              Specimen {
                caption: "Preenchido"; stageWidth: 276; stageHeight: 44
                Field { text: "Casa_Lima"; visualState: "filled" }
              }
              Specimen {
                caption: "Senha"; stageWidth: 276; stageHeight: 44
                Field { text: "Senha"; password: true; visualState: "password" }
              }
              Specimen {
                caption: "Erro"; stageWidth: 276; stageHeight: 44
                Field { text: "Senha"; password: true; error: true; visualState: "error" }
              }
            }

            // 5. Linhas
            SectionBlock {
              title: "Linhas"

              Specimen {
                caption: "Lista · repouso"; stageWidth: 300; stageHeight: 44
                ListRow {
                  title: "Biblioteca"
                  iconName: "wifi-low"
                  visualState: "rest"
                }
              }
              Specimen {
                caption: "Lista · hover"; stageWidth: 300; stageHeight: 44
                ListRow {
                  title: "Casa_Lima"
                  iconName: "wifi-high"
                  trailingIconName: "lock"
                  visualState: "hover"
                }
              }
              Specimen {
                caption: "Lista · pressionada"; stageWidth: 300; stageHeight: 44
                ListRow {
                  title: "Café Lume"
                  iconName: "wifi-low"
                  trailingIconName: "lock"
                  visualState: "pressed"
                }
              }
              Specimen {
                caption: "Lista · selecionada"; stageWidth: 300; stageHeight: 44
                ListRow {
                  title: "Wintermute-5G"
                  detail: "Conectado"
                  iconName: "wifi"
                  visualState: "selected"
                }
              }

              Specimen {
                caption: "Ajuste · navega"; stageWidth: 520; stageHeight: 52
                SettingsRow {
                  title: "Idioma do teclado"
                  value: "Português (BR)"
                  navigation: true
                  visualState: "rest"
                }
              }
              Specimen {
                caption: "Ajuste · hover"; stageWidth: 520; stageHeight: 52
                SettingsRow {
                  title: "Escala"
                  value: "125%"
                  navigation: false
                  visualState: "hover"
                }
              }
              Specimen {
                caption: "Ajuste · chave"; stageWidth: 520; stageHeight: 52
                SettingsRow {
                  title: "Aceleração do mouse"
                  toggle: true
                  checked: root.interactiveToggleChecked
                  onToggled: next => root.interactiveToggleChecked = next
                }
              }
            }

            // 6. Organizador · peças
            SectionBlock {
              title: "Organizador · peças"

              Specimen {
                caption: "Pílula · repouso"; stageWidth: 14; stageHeight: 20
                WorkspacePillSample { stateMode: "rest"; numberText: "2" }
              }
              Specimen {
                caption: "Pílula · hover (puxador)"; stageWidth: 14; stageHeight: 20
                WorkspacePillSample { stateMode: "hover" }
              }
              Specimen {
                caption: "Pílula · ativa"; stageWidth: 14; stageHeight: 20
                WorkspacePillSample { stateMode: "active"; numberText: "1" }
              }
              Specimen {
                caption: "Pílula · arrastando"; stageWidth: 14; stageHeight: 20
                WorkspacePillSample { stateMode: "dragging" }
              }

              Specimen {
                caption: "Janela · repouso"; stageWidth: 40; stageHeight: 40
                WorkspaceWindowSample { stateMode: "rest" }
              }
              Specimen {
                caption: "Janela · hover"; stageWidth: 40; stageHeight: 40
                WorkspaceWindowSample { stateMode: "hover" }
              }
              Specimen {
                caption: "Janela · foco"; stageWidth: 40; stageHeight: 40
                WorkspaceWindowSample { stateMode: "focus" }
              }
              Specimen {
                caption: "Janela · levantada"; stageWidth: 40; stageHeight: 40
                WorkspaceWindowSample { stateMode: "lifted" }
              }
              Specimen {
                caption: "Janela · recolhida"; stageWidth: 32; stageHeight: 32
                WorkspaceWindowSample { stateMode: "collapsed" }
              }
              Specimen {
                caption: "Janela · recolhida focada"; stageWidth: 32; stageHeight: 32
                WorkspaceWindowSample { stateMode: "collapsedFocused" }
              }

              Specimen {
                caption: "+ · repouso"; stageWidth: 40; stageHeight: 40
                WorkspacePlusSample { hoveredState: false }
              }
              Specimen {
                caption: "+ · hover"; stageWidth: 40; stageHeight: 40
                WorkspacePlusSample { hoveredState: true }
              }

              Specimen {
                caption: "Alvo de soltar"; stageWidth: 40; stageHeight: 40
                Rectangle {
                  width: 40; height: 40; radius: 20
                  color: Theme.accentSubtle
                  border.width: 1
                  border.color: Theme.accentRing
                }
              }
              Specimen {
                caption: "Slot vazio"; stageWidth: 40; stageHeight: 40
                Item {
                  width: 40; height: 40
                  Rectangle {
                    anchors.centerIn: parent
                    width: 4; height: 4; radius: 2
                    color: Theme.dot
                  }
                }
              }

              Specimen {
                caption: "Agente · trabalhando"; stageWidth: 16; stageHeight: 16
                Image {
                  width: 16; height: 16
                  source: Qt.resolvedUrl("icons/hourglass.svg")
                  sourceSize: Qt.size(32, 32)
                  layer.enabled: true
                  layer.effect: MultiEffect { colorization: 1; colorizationColor: Theme.accentText }
                }
              }
              Specimen {
                caption: "Agente · atenção"; stageWidth: 16; stageHeight: 16
                Image {
                  width: 16; height: 16
                  source: Qt.resolvedUrl("icons/circle-alert.svg")
                  sourceSize: Qt.size(32, 32)
                  layer.enabled: true
                  layer.effect: MultiEffect { colorization: 1; colorizationColor: Theme.attentionText }
                }
              }
              Specimen {
                caption: "Agente · não lido"; stageWidth: 16; stageHeight: 16
                Image {
                  width: 16; height: 16
                  source: Qt.resolvedUrl("icons/sprout.svg")
                  sourceSize: Qt.size(32, 32)
                  layer.enabled: true
                  layer.effect: MultiEffect { colorization: 1; colorizationColor: Theme.warning }
                }
              }
              Specimen {
                caption: "Agente · lido"; stageWidth: 16; stageHeight: 16
                Image {
                  width: 16; height: 16
                  source: Qt.resolvedUrl("icons/circle-check.svg")
                  sourceSize: Qt.size(32, 32)
                  layer.enabled: true
                  layer.effect: MultiEffect { colorization: 1; colorizationColor: Theme.successText }
                }
              }
            }

            // 7. Etiquetas, chips, teclas e blocos de app
            SectionBlock {
              title: "Etiquetas, chips e teclas"

              Specimen {
                caption: "Etiqueta · acento"; stageWidth: 75; stageHeight: 20
                Tag { kind: "accent"; text: "Conectado" }
              }
              Specimen {
                caption: "Neutra"; stageWidth: 46; stageHeight: 20
                Tag { kind: "neutral"; text: "Salva" }
              }
              Specimen {
                caption: "Sucesso"; stageWidth: 78; stageHeight: 20
                Tag { kind: "success"; text: "Carregando" }
              }
              Specimen {
                caption: "Perigo"; stageWidth: 52; stageHeight: 20
                Tag { kind: "danger"; text: "Falhou" }
              }

              Specimen {
                caption: "Chip"; stageWidth: 138; stageHeight: 36
                Chip { text: "Seletor de cor"; iconName: "pipette"; visualState: "rest" }
              }
              Specimen {
                caption: "Chip · hover"; stageWidth: 86; stageHeight: 36
                Chip { text: "Emoji"; iconName: "smile"; visualState: "hover" }
              }
              Specimen {
                caption: "Chip · selecionado"; stageWidth: 146; stageHeight: 36
                Chip { text: "Captura de tela"; iconName: "scan"; visualState: "selected" }
              }

              Specimen {
                caption: "Tecla"; stageWidth: 34; stageHeight: 20
                KeyCap { text: "Esc" }
              }
              Specimen {
                caption: "Tecla"; stageWidth: 46; stageHeight: 20
                KeyCap { text: "Ctrl K" }
              }
              Specimen {
                caption: "Tecla"; stageWidth: 24; stageHeight: 20
                KeyCap { text: "↵" }
              }

              Specimen {
                caption: "App · 48"; stageWidth: 48; stageHeight: 48
                AppTile { tileSize: 48; iconName: "terminal"; visualState: "rest" }
              }
              Specimen {
                caption: "App · foco"; stageWidth: 48; stageHeight: 48
                AppTile { tileSize: 48; iconName: "terminal"; visualState: "focus" }
              }
              Specimen {
                caption: "App · 28"; stageWidth: 28; stageHeight: 28
                AppTile { tileSize: 28; iconName: "terminal"; visualState: "rest" }
              }
              Specimen {
                caption: "App · 28 foco"; stageWidth: 28; stageHeight: 28
                AppTile { tileSize: 28; iconName: "terminal"; visualState: "focus" }
              }
            }

            // 8. Vidro (superfícies)
            SectionBlock {
              title: "Vidro (superfícies)"

              Specimen {
                caption: "Cartão 156 · r16"; stageWidth: 156; stageHeight: 64
                GlassSurface {
                  width: 156; height: 64
                  surfaceType: "card"
                  hoverable: false
                }
              }
              Specimen {
                caption: "Cartão · hover (+4%)"; stageWidth: 156; stageHeight: 64
                GlassSurface {
                  width: 156; height: 64
                  surfaceType: "card"
                  forceHovered: true
                }
              }
              Specimen {
                caption: "Pop-up · r20"; stageWidth: 280; stageHeight: 120
                GlassSurface {
                  width: 280; height: 120
                  surfaceType: "popup"
                  hoverable: true
                }
              }
              Specimen {
                caption: "Painel 316 · r16"; stageWidth: 316; stageHeight: 160
                GlassSurface {
                  width: 316; height: 160
                  surfaceType: "panel"
                  hoverable: true
                }
              }
              Specimen {
                caption: "Modal 580 · r32"; stageWidth: 580; stageHeight: 200
                GlassSurface {
                  width: 580; height: 200
                  surfaceType: "modal"
                  hoverable: true
                }
              }
            }
          }
        }
      }

      PanelCloseButton {
        x: mainGlass.width - 20
        y: 7
        z: 5
        onClicked: root.closeRequested()
      }
    }
  }
}
