pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import "calendar" as Calendar
import "demo" as Demo
import "media" as Media
import "minimap" as Minimap
import "notifications" as Notifications
import "installs" as Installs
import "settings" as Settings
import "settings/appearance" as Appearance
import "settings/system" as System
import "settings/display" as Display
import "settings/information" as Information
import "settings/manual" as Manual

// Painel de demonstração visual da F1, da F2 e da F3 (fichas 00 a 05, boards 13:11217, 13:11463, 13:12277, 13:11395 e 13:13604).
// Abre com: qs -p ~/Projects/dotfiles/wintermute-shell ipc call demo toggle
PanelWindow {
  id: root
  required property var panelScreen
  property bool opened: false
  property bool sidebarDemoCards: false
  property int selectedPhaseTab: 3 // 0 = F2 (Barra e organizador), 1 = F1 (Componentes base), 2 = F3 (Pop-ups e painéis), 3 = F4 (Ajustes)
  signal toggleSidebarDemoCards
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

  // Quadro explicativo do IdleFade (ficha 12): um papel de parede fictício com o véu preto no mesmo
  // percurso linear que o IdleFade.qml percorre em 5 s (a opacidade do véu = tempo / 5 s).
  component IdleFadeFrame: Item {
    id: frame
    property real progress: 0
    width: 216
    height: 136
    Rectangle {
      anchors.fill: parent
      radius: 12
      gradient: Gradient {
        GradientStop { position: 0.0; color: "#0b1226" }
        GradientStop { position: 0.6; color: "#1d2347" }
        GradientStop { position: 1.0; color: "#3a1f4a" }
      }
      Rectangle {
        x: 12; y: 12; width: 36; height: 112; radius: 8
        color: Theme.control
        border.width: 1
        border.color: Theme.border
      }
      Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: "black"
        opacity: frame.progress
      }
      Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: "transparent"
        border.width: 1
        border.color: Theme.border
      }
    }
  }

  // Páginas fictícias da pilha de cartões (ficha 05). Usam só o que a ficha mede: título
  // Serif 20 em (20,16), chave em (242,18), linhas 300×44 em x 8 a partir de y 64, e na página
  // de senha o rótulo em (20,72), o campo em (20,100) e o botão em (20,160). O conteúdo real
  // do Wi-Fi entra na F3-T02. Dados fictícios.
  component StackDemoList: Item {
    id: listPage
    property var stackController: null
    property bool interactive: false
    property var selection: ({})
    implicitWidth: PanelStyle.width
    implicitHeight: 306

    Text {
      x: 20; y: 16; width: 200; height: 32
      text: "Wi-Fi"
      color: Theme.text
      font.family: Theme.titleFontFamily
      font.weight: Font.Normal
      font.pixelSize: Theme.fontPanelTitle
      font.letterSpacing: 0
      verticalAlignment: Text.AlignVCenter
    }
    Toggle { x: 242; y: 18; checked: true }

    Repeater {
      model: [
        { name: "Wintermute-5G", icon: "wifi", lock: false, current: true },
        { name: "Casa_Lima", icon: "wifi", lock: true, current: false },
        { name: "Biblioteca", icon: "wifi-low", lock: false, current: false },
        { name: "Café Lume", icon: "wifi-low", lock: true, current: false }
      ]
      delegate: ListRow {
        id: networkRow
        required property int index
        required property var modelData
        x: 8
        y: 64 + 44 * index
        width: 300
        title: modelData.name
        iconName: modelData.icon
        trailingIconName: modelData.lock ? "lock" : ""
        selected: modelData.current
        interactive: listPage.interactive
        onClicked: {
          if (modelData.lock)
            listPage.stackController.push("join", modelData);
        }
      }
    }
    ListRow {
      x: 8; y: 254; width: 300
      title: "Adicionar rede"
      iconName: "plus"
      interactive: listPage.interactive
    }
  }

  component StackDemoJoin: Item {
    id: joinPage
    property var stackController: null
    property bool interactive: false
    property var selection: ({})
    implicitWidth: PanelStyle.width
    implicitHeight: 228

    Text {
      x: 20; y: 16; width: 276; height: 32
      text: "Entrar em “" + (joinPage.selection.name ?? "Casa_Lima") + "”"
      color: Theme.text
      font.family: Theme.titleFontFamily
      font.weight: Font.Normal
      font.pixelSize: Theme.fontPanelTitle
      font.letterSpacing: 0
      verticalAlignment: Text.AlignVCenter
    }
    Text {
      x: 20; y: 72
      text: "Senha"
      color: Theme.text
      font.family: Theme.fontFamily
      font.weight: Font.Medium
      font.pixelSize: Theme.fontLabel
      font.letterSpacing: 0
    }
    Field { x: 20; y: 100; placeholderText: "Senha"; password: true }
    ActionButton {
      x: 20; y: 160
      kind: "primary"
      text: "Conectar"
      interactive: joinPage.interactive
      onClicked: joinPage.stackController.pop()
    }
  }

  // A pilha de verdade (CardStack) com as páginas fictícias. Fechar pelo X deixa o palco vazio;
  // o chip reabre.
  component StackSpecimen: Item {
    id: stackSpec
    property bool startStacked: false
    width: PanelStyle.stackWidth
    height: PanelStyle.frontInsetSingle + 306

    Component { id: listComponent; StackDemoList {} }
    Component { id: joinComponent; StackDemoJoin {} }

    CardStack {
      id: demoStack
      anchors.bottom: parent.bottom
      pageComponents: ({ drawer: listComponent, join: joinComponent })
      Component.onCompleted: {
        open();
        if (stackSpec.startStacked)
          Qt.callLater(() => demoStack.push("join", { name: "Casa_Lima" }));
      }
    }

    Chip {
      anchors.centerIn: parent
      visible: !demoStack.visible
      text: "Abrir de novo"
      iconName: "panel-left-open"
      onClicked: demoStack.open()
    }
  }

  // Amostra estática dos 12 estados do organizador (ficha 02, boards 13:12277 e 13:11395)
  component OrganizerStateSpecimen: Item {
    id: orgSpec
    required property int stateNumber
    readonly property bool isCollapsedState: stateNumber === 9 || stateNumber === 10
    readonly property bool showPills: (stateNumber >= 2 && stateNumber <= 4)
        || stateNumber === 7 || stateNumber === 8
    width: isCollapsedState ? 48 : 164
    height: isCollapsedState ? 168 : 160

    // Modo recolhido (estados 9 e 10)
    Card {
      visible: orgSpec.isCollapsedState
      width: 48
      height: 168
      radius: Theme.sidebarCardRadius

      // Linha 01 (ativa): fundo pressed 40×113 r12 em x 4, y 4
      Rectangle {
        x: 4
        y: 4
        width: 40
        height: 113
        radius: 12
        color: Theme.pressed
      }

      Text {
        x: 4
        y: 10
        width: 40
        height: 20
        text: "01"
        color: Theme.text
        font.family: Theme.monoFontFamily
        font.weight: Font.Normal
        font.pixelSize: Theme.fontMonoNumber
        font.letterSpacing: 0
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
      }

      // Janela focada no recolhido (F2-T08, 13:11395): 32×32 + anel accent 1,5 px em x = 8
      Minimap.WindowIcon {
        x: 8
        y: 41
        controlSize: 32
        interactive: false
        windowData: ({ lucideIcon: "terminal", isFocused: true })
      }

      Minimap.WindowIcon {
        x: 8
        y: 81
        controlSize: 32
        interactive: false
        windowData: ({ lucideIcon: "globe", isFocused: false })
      }

      Rectangle {
        x: 16
        y: 121
        width: 16
        height: 1
        color: Theme.border
      }

      // Linha 02 (inativa; em hover no estado 10)
      Rectangle {
        x: 4
        y: 125
        width: 40
        height: 39
        radius: 12
        color: Theme.hover
        visible: orgSpec.stateNumber === 10
      }

      Text {
        x: 4
        y: 129
        width: 40
        height: 20
        text: "02"
        color: orgSpec.stateNumber === 10 ? Theme.text : Theme.muted
        font.family: Theme.monoFontFamily
        font.weight: Font.Normal
        font.pixelSize: Theme.fontMonoNumber
        font.letterSpacing: 0
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
      }

      Row {
        y: 153
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 2
        Repeater {
          model: 2
          delegate: Rectangle {
            width: 4
            height: 4
            radius: 2
            color: Theme.muted
          }
        }
      }
    }

    // Modo aberto (estados 1 a 8, 11 e 12): palco 164 com pílula em x 1 e cartão 156 em x 8
    Card {
      id: openOrgCard
      visible: !orgSpec.isCollapsedState
      x: 8
      y: 0
      width: 156
      height: 160
      radius: Theme.sidebarCardRadius
      contentClipped: false
      forceHovered: orgSpec.showPills

      // Fundo da linha 1 (x 5, y 5, 146×50 r10)
      Rectangle {
        visible: orgSpec.stateNumber !== 6 && orgSpec.stateNumber !== 7 && orgSpec.stateNumber !== 8
        x: 5
        y: 5
        width: 146
        height: 50
        radius: 10
        color: Theme.accentSubtle
        border.width: 1
        border.color: Theme.accentRing
      }

      // Fundo da linha 2 (hover no estado 4, ativo no estado 6, alvo de arraste no estado 7)
      Rectangle {
        visible: orgSpec.stateNumber === 4 || orgSpec.stateNumber === 6 || orgSpec.stateNumber === 7
        x: 5
        y: 55
        width: 146
        height: 50
        radius: 10
        color: orgSpec.stateNumber === 4 ? Theme.hover : Theme.accentSubtle
        border.width: orgSpec.stateNumber === 6 ? 1 : 0
        border.color: Theme.accentRing
      }

      // Estados 1 a 4: linha 1 com 2 janelas + ponto ou "+"
      Item {
        visible: orgSpec.stateNumber >= 1 && orgSpec.stateNumber <= 4
        anchors.fill: parent

        Minimap.WindowIcon {
          x: 10; y: 10
          interactive: false
          windowData: ({ lucideIcon: "terminal", isFocused: true })
        }
        Minimap.WindowIcon {
          x: 58; y: 10
          interactive: false
          forceHovered: orgSpec.stateNumber === 3
          windowData: ({ lucideIcon: "globe", isFocused: false })
        }
        Rectangle {
          visible: orgSpec.stateNumber === 1 || orgSpec.stateNumber === 4
          x: 124; y: 28; width: 4; height: 4; radius: 2; color: Theme.dot
        }
        Minimap.PlusButton {
          x: 106; y: 10; width: 40; height: 40
          revealed: orgSpec.stateNumber === 2 || orgSpec.stateNumber === 3
          forceHovered: orgSpec.stateNumber === 3
        }

        // Linha 2
        Minimap.WindowIcon {
          x: 10; y: 60
          interactive: false
          windowData: ({ lucideIcon: "hash", isFocused: false })
        }
        Rectangle {
          visible: orgSpec.stateNumber !== 4
          x: 76; y: 78; width: 4; height: 4; radius: 2; color: Theme.dot
        }
        Minimap.PlusButton {
          x: 58; y: 60; width: 40; height: 40
          revealed: orgSpec.stateNumber === 4
        }
        Rectangle { x: 124; y: 78; width: 4; height: 4; radius: 2; color: Theme.dot }

        // Linha 3 (3 pontos)
        Rectangle { x: 28; y: 128; width: 4; height: 4; radius: 2; color: Theme.dot }
        Rectangle { x: 76; y: 128; width: 4; height: 4; radius: 2; color: Theme.dot }
        Rectangle { x: 124; y: 128; width: 4; height: 4; radius: 2; color: Theme.dot }
      }

      // Estado 5: Carrossel (> 3 janelas)
      Item {
        visible: orgSpec.stateNumber === 5
        anchors.fill: parent

        Item {
          x: 10; y: 10; width: 136; height: 40
          clip: true
          Item {
            x: -48; width: 192; height: 40
            Minimap.WindowIcon { x: 0; y: 0; interactive: false; windowData: ({ lucideIcon: "terminal" }) }
            Minimap.WindowIcon { x: 48; y: 0; interactive: false; windowData: ({ lucideIcon: "globe" }) }
            Minimap.WindowIcon { x: 96; y: 0; interactive: false; windowData: ({ lucideIcon: "hash" }) }
            Minimap.WindowIcon { x: 144; y: 0; interactive: false; windowData: ({ lucideIcon: "mail", isFocused: true }) }
          }
        }
        Minimap.WindowIcon { x: 10; y: 60; interactive: false; windowData: ({ lucideIcon: "terminal" }) }
        Rectangle { x: 76; y: 78; width: 4; height: 4; radius: 2; color: Theme.dot }
        Rectangle { x: 124; y: 78; width: 4; height: 4; radius: 2; color: Theme.dot }
        Rectangle { x: 28; y: 128; width: 4; height: 4; radius: 2; color: Theme.dot }
        Rectangle { x: 76; y: 128; width: 4; height: 4; radius: 2; color: Theme.dot }
        Rectangle { x: 124; y: 128; width: 4; height: 4; radius: 2; color: Theme.dot }
      }

      // Estado 6: Workspace ativo vazio
      Item {
        visible: orgSpec.stateNumber === 6
        anchors.fill: parent

        Minimap.WindowIcon { x: 10; y: 10; interactive: false; windowData: ({ lucideIcon: "terminal" }) }
        Minimap.WindowIcon { x: 58; y: 10; interactive: false; windowData: ({ lucideIcon: "globe" }) }
        Rectangle { x: 124; y: 28; width: 4; height: 4; radius: 2; color: Theme.dot }

        Minimap.PlusButton {
          x: 10; y: 60; width: 40; height: 40
          revealed: true
          accentStyle: true
        }
        Rectangle { x: 76; y: 78; width: 4; height: 4; radius: 2; color: Theme.dot }
        Rectangle { x: 124; y: 78; width: 4; height: 4; radius: 2; color: Theme.dot }

        Rectangle { x: 28; y: 128; width: 4; height: 4; radius: 2; color: Theme.dot }
        Rectangle { x: 76; y: 128; width: 4; height: 4; radius: 2; color: Theme.dot }
        Rectangle { x: 124; y: 128; width: 4; height: 4; radius: 2; color: Theme.dot }
      }

      // Estado 7: Arrastando uma janela
      Item {
        visible: orgSpec.stateNumber === 7
        anchors.fill: parent

        Minimap.WindowIcon { x: 10; y: 10; interactive: false; windowData: ({ lucideIcon: "terminal" }) }
        Rectangle { x: 76; y: 28; width: 4; height: 4; radius: 2; color: Theme.dot }
        Rectangle { x: 124; y: 28; width: 4; height: 4; radius: 2; color: Theme.dot }

        Minimap.WindowIcon { x: 10; y: 60; interactive: false; windowData: ({ lucideIcon: "hash" }) }
        // Alvo de soltar 40×40 r20 em (58,60)
        Rectangle {
          x: 58; y: 60; width: 40; height: 40; radius: 20
          color: Theme.accentSubtle
          border.width: 1
          border.color: Theme.accentRing
        }
        Rectangle { x: 124; y: 78; width: 4; height: 4; radius: 2; color: Theme.dot }

        Rectangle { x: 28; y: 128; width: 4; height: 4; radius: 2; color: Theme.dot }
        Rectangle { x: 76; y: 128; width: 4; height: 4; radius: 2; color: Theme.dot }
        Rectangle { x: 124; y: 128; width: 4; height: 4; radius: 2; color: Theme.dot }

        // Janela levantada seguindo o cursor
        Minimap.WindowIcon {
          x: 50; y: 36; z: 20
          interactive: false
          lifted: true
          windowData: ({ lucideIcon: "globe", isFocused: true })
        }
      }

      // Estado 8: Reordenando workspaces
      Item {
        visible: orgSpec.stateNumber === 8
        anchors.fill: parent

        // Linha 2 deslocada para o topo (y 10)
        Minimap.WindowIcon { x: 10; y: 10; interactive: false; windowData: ({ lucideIcon: "hash" }) }
        Rectangle { x: 76; y: 28; width: 4; height: 4; radius: 2; color: Theme.dot }
        Rectangle { x: 124; y: 28; width: 4; height: 4; radius: 2; color: Theme.dot }

        // Linha 3 (y 110)
        Rectangle { x: 28; y: 128; width: 4; height: 4; radius: 2; color: Theme.dot }
        Rectangle { x: 76; y: 128; width: 4; height: 4; radius: 2; color: Theme.dot }
        Rectangle { x: 124; y: 128; width: 4; height: 4; radius: 2; color: Theme.dot }

        // Linha 1 levantada em y = 55 (146×50 r10, raised + borderStrong + sombra)
        Item {
          x: 0; y: 50; width: 156; height: 50; z: 20

          Shadow {
            x: 5; y: 5; width: 146; height: 50
            cornerRadius: 10
            shadows: Theme.glassShadows
            strength: 0.7
          }
          Rectangle {
            x: 5; y: 5; width: 146; height: 50; radius: 10
            color: Theme.raised
            border.width: 1
            border.color: Theme.borderStrong
          }
          Minimap.WindowIcon { x: 10; y: 10; interactive: false; windowData: ({ lucideIcon: "terminal", isFocused: true }) }
          Minimap.WindowIcon { x: 58; y: 10; interactive: false; windowData: ({ lucideIcon: "globe" }) }
          Rectangle { x: 124; y: 28; width: 4; height: 4; radius: 2; color: Theme.dot }
        }
      }

      // Estado 11: Terminais com agente (4 ícones Lucide de P-05)
      Item {
        visible: orgSpec.stateNumber === 11
        anchors.fill: parent

        Minimap.WindowIcon { x: 10; y: 10; interactive: false; windowData: ({ dotState: "working", isFocused: true }) }
        Minimap.WindowIcon { x: 58; y: 10; interactive: false; windowData: ({ dotState: "attention" }) }
        Minimap.WindowIcon { x: 106; y: 10; interactive: false; windowData: ({ dotState: "unread" }) }

        Minimap.WindowIcon { x: 10; y: 60; interactive: false; windowData: ({ dotState: "read" }) }
        Rectangle { x: 76; y: 78; width: 4; height: 4; radius: 2; color: Theme.dot }
        Rectangle { x: 124; y: 78; width: 4; height: 4; radius: 2; color: Theme.dot }

        Rectangle { x: 28; y: 128; width: 4; height: 4; radius: 2; color: Theme.dot }
        Rectangle { x: 76; y: 128; width: 4; height: 4; radius: 2; color: Theme.dot }
        Rectangle { x: 124; y: 128; width: 4; height: 4; radius: 2; color: Theme.dot }
      }

      // Estado 12: Monitor sem janelas
      Item {
        visible: orgSpec.stateNumber === 12
        anchors.fill: parent

        Minimap.PlusButton {
          x: 10; y: 10; width: 40; height: 40
          revealed: true
          accentStyle: true
        }
        Rectangle { x: 76; y: 28; width: 4; height: 4; radius: 2; color: Theme.dot }
        Rectangle { x: 124; y: 28; width: 4; height: 4; radius: 2; color: Theme.dot }

        Rectangle { x: 28; y: 78; width: 4; height: 4; radius: 2; color: Theme.dot }
        Rectangle { x: 76; y: 78; width: 4; height: 4; radius: 2; color: Theme.dot }
        Rectangle { x: 124; y: 78; width: 4; height: 4; radius: 2; color: Theme.dot }

        Rectangle { x: 28; y: 128; width: 4; height: 4; radius: 2; color: Theme.dot }
        Rectangle { x: 76; y: 128; width: 4; height: 4; radius: 2; color: Theme.dot }
        Rectangle { x: 124; y: 128; width: 4; height: 4; radius: 2; color: Theme.dot }
      }

      // Pílulas na borda esquerda (x = -7 do cartão)
      WorkspacePillSample {
        visible: orgSpec.showPills
        x: -7
        y: 20
        z: 30
        stateMode: orgSpec.stateNumber === 8 ? "rest" : "active"
        numberText: orgSpec.stateNumber === 8 ? "2" : "1"
      }
      WorkspacePillSample {
        visible: orgSpec.showPills
        x: -7
        y: 70
        z: 30
        stateMode: orgSpec.stateNumber === 4 ? "hover"
            : orgSpec.stateNumber === 8 ? "dragging" : "rest"
        numberText: "2"
      }
      WorkspacePillSample {
        visible: orgSpec.showPills
        x: -7
        y: 120
        z: 30
        stateMode: "rest"
        numberText: "3"
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
            text: (root.selectedPhaseTab === 3
                ? "4 · Ajustes · "
                : root.selectedPhaseTab === 2
                ? "3 · Pop-ups e painéis · "
                : root.selectedPhaseTab === 0
                ? "2 · Barra lateral e organizador · "
                : "1 · Componentes base · ") + Theme.displayName
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

            Chip {
              text: "F4 · Ajustes"
              iconName: "settings"
              selected: root.selectedPhaseTab === 3
              onClicked: root.selectedPhaseTab = 3
            }

            Chip {
              text: "F3 · Painéis"
              iconName: "app-window"
              selected: root.selectedPhaseTab === 2
              onClicked: root.selectedPhaseTab = 2
            }

            Chip {
              text: "F2 · Barra"
              iconName: "panel-left-open"
              selected: root.selectedPhaseTab === 0
              onClicked: root.selectedPhaseTab = 0
            }

            Chip {
              text: "F1 · Base"
              iconName: "settings"
              selected: root.selectedPhaseTab === 1
              onClicked: root.selectedPhaseTab = 1
            }

            Rectangle {
              width: 1
              height: 24
              anchors.verticalCenter: parent.verticalCenter
              color: Theme.border
            }

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

            // =================================================================
            // Aba F4 — Ajustes (ficha 13)
            // =================================================================
            Column {
              visible: root.selectedPhaseTab === 3
              width: parent.width
              spacing: 32

              SectionBlock {
                title: "Tela inicial (ficha 13, board 13:15787) · tela real com dados fictícios"
                itemGap: 40

                Specimen {
                  caption: "Repouso · hover no cartão Appearance · composição 672×536, cartões 264 em passo 272, sessão 128 em passo 136"
                  stageWidth: 1120; stageHeight: 680
                  Demo.SettingsHomeSpecimen { hover: "appearance" }
                }
                Specimen {
                  caption: "Hover em Power off · danger e o nome em dangerText 60 ms depois"
                  stageWidth: 1120; stageHeight: 680
                  Demo.SettingsHomeSpecimen { hover: "shutdown" }
                }
                Specimen {
                  caption: "Hover em Restart · o mesmo padrão com o acento · selo no estado \"Restart recommended\""
                  stageWidth: 1120; stageHeight: 680
                  Demo.SettingsHomeSpecimen { hover: "reboot"; updateStatus: "restart" }
                }
              }

              Demo.SystemService { id: demoSystem }
              Demo.IdleService { id: demoIdle }

              SectionBlock {
                title: "Sistema (ficha 13, board 13:15787) · páginas reais com dados fictícios"
                itemGap: 40

                Specimen {
                  caption: "System 580×288 · três linhas com seta a cada 60 (o Fuso horário saiu, P-34)"
                  stageWidth: 600; stageHeight: 301
                  System.Panel { y: 13; service: demoSystem; idle: demoIdle }
                }
                Specimen {
                  caption: "Mouse & touchpad 580×452 · 9 passos por aparelho, rolagem natural por aparelho (P-47)"
                  stageWidth: 600; stageHeight: 465
                  System.Mouse { y: 13; service: demoSystem }
                }
                Specimen {
                  caption: "Lock & sleep 580×420 · tomada e bateria, chave da senha ao acordar (vale na F7)"
                  stageWidth: 600; stageHeight: 433
                  System.Lock { y: 13; idle: demoIdle; batteryPresent: true }
                }
                Specimen {
                  caption: "Keyboard language · busca 520×44 e opções de 44, escolhida em accentSubtle com check"
                  stageWidth: 600; stageHeight: 361
                  System.Picker {
                    y: 13
                    title: "Keyboard language"; placeholder: "Search languages"; multiple: true
                    options: demoSystem.languages; selected: demoSystem.selectedLanguages
                    onPicked: id => demoSystem.toggleLanguage(id)
                  }
                }
              }

              Demo.DisplayService { id: demoDisplay }
              Demo.DisplayService {
                id: demoDisplayArrange
                // O externo mais alto que a tela embutida, encostado à direita, como no board 13:16062.
                geometry: [
                  { name: "DP-1", identity: "Fictitious DP-1", x: 2048, y: 0, width: 2560, height: 1440 },
                  { name: "eDP-1", identity: "Fictitious eDP-1", x: 0, y: 560, width: 2048, height: 1280 }
                ]
              }

              SectionBlock {
                title: "Tela (ficha 13, boards 13:16041 e 13:16062) · páginas reais com dados fictícios"
                itemGap: 40

                Specimen {
                  caption: "Display 580×704 · desenho 520×280 em (30,84), selecionado em accentSubtle + accentRing 2, Orientation no topo (P-49), hover em Refresh rate"
                  stageWidth: 600; stageHeight: 717
                  Display.Panel { y: 13; service: demoDisplay; hoverRow: "refresh" }
                }
                Specimen {
                  caption: "Arrange displays 580×500 · área 520×320, monitor arrastado com guia de encaixe em accentText"
                  stageWidth: 600; stageHeight: 513
                  Display.Arrange { y: 13; service: demoDisplayArrange; demoDragIndex: 0 }
                }
              }

              Demo.InformationService { id: demoInformation }

              SectionBlock {
                title: "Informações (ficha 13, board 13:16083) · página real com dados fictícios"
                itemGap: 40

                Specimen {
                  caption: "Information 580×620 · 7 linhas a cada 48, botão Manual 520×64, rodapé com a grade de + (contatos: P-50)"
                  stageWidth: 600; stageHeight: 633
                  Information.Panel { y: 13; service: demoInformation }
                }
                Specimen {
                  caption: "Hover no botão Manual · fundo pressed, como as linhas dos Ajustes"
                  stageWidth: 600; stageHeight: 633
                  Information.Panel { y: 13; service: demoInformation; manualHovered: true }
                }
              }

              SectionBlock {
                title: "Papel de parede (ficha 13, board 13:16208) · seletor real com imagens minhas"
                itemGap: 40

                Specimen {
                  caption: "Wallpaper 624×608 · Dynamic escolhido, hover no Chiba (título em (16,108), autor em muted), sexto lugar vazio (P-59)"
                  stageWidth: 644; stageHeight: 621
                  Demo.WallpaperSpecimen { selected: "dynamic"; hoverIndex: 2 }
                }
                Specimen {
                  caption: "Imagem escolhida (anel accent a 4 px e marca de 24) · hover em Choose an image, fundo pressed"
                  stageWidth: 644; stageHeight: 621
                  Demo.WallpaperSpecimen { selected: "freeside"; hoverIndex: 0 }
                }
                Specimen {
                  caption: "Com erro · a mensagem em dangerText em y 58 e a grade desce 28"
                  stageWidth: 644; stageHeight: 621
                  Demo.WallpaperSpecimen { selected: "sprawl"; error: "Could not open the image picker" }
                }
              }

              SectionBlock {
                title: "Manual (ficha 13, board 13:16155) · página real, tutorial parado"
                itemGap: 40

                Specimen {
                  caption: "Manual 500×656 · aba Touchpad como no Figma: touchpad 200×128, 3 dedos e 4 setas em accentText, lista em linhas de 44"
                  stageWidth: 520; stageHeight: 669
                  Manual.Panel { y: 13; mode: "touchpad"; animated: false }
                }
                Specimen {
                  caption: "Aba Keyboard (P-53) · mini teclado 209×86 e mouse 40×56 da origem em (84,69), Super contornada em accentText"
                  stageWidth: 520; stageHeight: 669
                  Manual.Panel { y: 13; mode: "keyboard"; animated: false }
                }
                Specimen {
                  caption: "Lista rolada (P-52) · a área das seis linhas rola e o botão Got it fica fixo"
                  stageWidth: 520; stageHeight: 669
                  Manual.Panel { y: 13; mode: "keyboard"; animated: false; firstRow: 27 }
                }
              }
            }

            // =================================================================
            // Aba F3 — Pop-ups e painéis (fichas 05 a 12)
            // =================================================================
            Column {
              visible: root.selectedPhaseTab === 2
              width: parent.width
              spacing: 32

              SectionBlock {
                title: "Pilha de cartões (ficha 05, board 13:13604)"
                itemGap: 40

                Specimen {
                  caption: "Frente 316 · folga 22 · clique em Casa_Lima para empilhar"
                  stageWidth: PanelStyle.stackWidth; stageHeight: PanelStyle.frontInsetSingle + 306
                  StackSpecimen {}
                }
                Specimen {
                  caption: "Frente 316 sobre verso 284 em (16, 0) · folga 32 · o X volta"
                  stageWidth: PanelStyle.stackWidth; stageHeight: PanelStyle.frontInsetSingle + 306
                  StackSpecimen { startStacked: true }
                }
              }

              SectionBlock {
                title: "Wi-Fi (ficha 05, board 13:13604) · pilha real com dados fictícios"
                itemGap: 40

                Specimen {
                  caption: "Lista 316×306 · rede conectada, cadeados e rodapé"
                  stageWidth: PanelStyle.stackWidth; stageHeight: 328
                  Demo.WifiSpecimen { page: "drawer"; height: 328 }
                }
                Specimen {
                  caption: "Entrar 316×228 · “Conectar” desativado sem senha"
                  stageWidth: PanelStyle.stackWidth; stageHeight: 260
                  Demo.WifiSpecimen {
                    page: "join"; height: 260
                    selection: ({ ssid: "Casa_Lima", locked: true })
                  }
                }
                Specimen {
                  caption: "Adicionar rede 316×436 · SSID em foco"
                  stageWidth: PanelStyle.stackWidth; stageHeight: 468
                  Demo.WifiSpecimen { page: "add"; height: 468 }
                }
                Specimen {
                  caption: "Detalhes 316×424 · 6 linhas de 48 com divisor"
                  stageWidth: PanelStyle.stackWidth; stageHeight: 456
                  Demo.WifiSpecimen {
                    page: "details"; height: 456
                    selection: ({ ssid: "Wintermute-5G", bars: 3, uuids: ["demo-1"] })
                  }
                }
                Specimen {
                  caption: "Status 316×112 · conectando"
                  stageWidth: PanelStyle.stackWidth; stageHeight: 144
                  Demo.WifiSpecimen {
                    page: "status"; height: 144
                    phase: "connecting"; statusText: "Conectando a Casa_Lima…"
                  }
                }
                Specimen {
                  caption: "Status · conectado (fecha sozinho em 1,5 s no painel real)"
                  stageWidth: PanelStyle.stackWidth; stageHeight: 144
                  Demo.WifiSpecimen {
                    page: "status"; height: 144
                    phase: "complete"; statusText: "Conectado"
                  }
                }
                Specimen {
                  caption: "Status · senha incorreta"
                  stageWidth: PanelStyle.stackWidth; stageHeight: 144
                  Demo.WifiSpecimen {
                    page: "status"; height: 144
                    phase: "failed"; statusText: "Senha incorreta"
                  }
                }
              }

              SectionBlock {
                title: "Bluetooth (ficha 06, board 13:13604) · pilha real com dados fictícios"
                itemGap: 40

                Specimen {
                  caption: "Lista 316×306 · conectado, bateria, conectando e rodapé"
                  stageWidth: PanelStyle.stackWidth; stageHeight: 328
                  Demo.BluetoothSpecimen { page: "drawer"; height: 328 }
                }
                Specimen {
                  caption: "Próximos 316×236 · procurando"
                  stageWidth: PanelStyle.stackWidth; stageHeight: 268
                  Demo.BluetoothSpecimen { page: "nearby"; searching: true; height: 268 }
                }
                Specimen {
                  caption: "Pareamento 316×236 · código em Serif 32 accentText"
                  stageWidth: PanelStyle.stackWidth; stageHeight: 268
                  Demo.BluetoothSpecimen { page: "pair"; height: 268 }
                }
                Specimen {
                  caption: "Desligado 316×156"
                  stageWidth: PanelStyle.stackWidth; stageHeight: 178
                  Demo.BluetoothSpecimen { page: "drawer"; bluetoothEnabled: false; height: 178 }
                }
                Specimen {
                  caption: "Rádio bloqueado 316×156 · a chave desbloqueia ao ligar"
                  stageWidth: PanelStyle.stackWidth; stageHeight: 178
                  Demo.BluetoothSpecimen {
                    page: "drawer"; bluetoothEnabled: false; bluetoothBlocked: true; height: 178
                  }
                }
                Specimen {
                  caption: "Rádio bloqueado · erro ao desbloquear (rfkill indisponível)"
                  stageWidth: PanelStyle.stackWidth; stageHeight: 222
                  Demo.BluetoothSpecimen {
                    page: "drawer"; bluetoothEnabled: false; bluetoothBlocked: true; height: 222
                    errorMessage: "Could not unblock Bluetooth: rfkill is not installed"
                  }
                }
                Specimen {
                  caption: "Detalhes · mesmo layout do Wi-Fi"
                  stageWidth: PanelStyle.stackWidth; stageHeight: 380
                  Demo.BluetoothSpecimen { page: "details"; height: 380 }
                }
              }

              SectionBlock {
                title: "Som (ficha 07, board 13:14610) · pop-up real com dispositivos fictícios"
                itemGap: 40

                Specimen {
                  caption: "Saída 316×236 · slider com o valor na alça"
                  stageWidth: PanelStyle.stackWidth; stageHeight: 258
                  Demo.AudioSpecimen { tab: "output"; height: 258 }
                }
                Specimen {
                  caption: "Entrada 316×236"
                  stageWidth: PanelStyle.stackWidth; stageHeight: 258
                  Demo.AudioSpecimen { tab: "input"; height: 258 }
                }
              }

              SectionBlock {
                title: "Bateria (ficha 08, board 13:14610) · cartão real com estado fictício"
                itemGap: 40

                Specimen {
                  caption: "Pop-up 280×232 · carregando, perfil Equilibrado"
                  stageWidth: 280; stageHeight: 232
                  Demo.BatterySpecimen { kind: "popup" }
                }
                Specimen {
                  caption: "Pop-up · 9% na bateria, perfil Economia"
                  stageWidth: 280; stageHeight: 232
                  Demo.BatterySpecimen { kind: "popup"; percentage: 9; charging: false; profile: "power-saver" }
                }
                Specimen {
                  caption: "Alerta de bateria baixa 176×40 (só com a barra recolhida)"
                  stageWidth: 176; stageHeight: 40
                  Demo.BatterySpecimen { kind: "alert"; percentage: 9; charging: false }
                }
              }

              SectionBlock {
                title: "Calendário (ficha 09, board 13:14610) · cartão real em 13 de novembro de 2026"
                itemGap: 40

                Specimen {
                  caption: "264×296 · hoje em accent, semana atual em faixa, dias de outro mês a 50%"
                  stageWidth: 264; stageHeight: 296
                  Demo.CalendarSpecimen {}
                }
                Specimen {
                  caption: "Mês seguinte (sem hoje nem faixa)"
                  stageWidth: 264; stageHeight: 296
                  Demo.CalendarSpecimen { browseMonths: 1 }
                }
              }

              SectionBlock {
                title: "Notificações (ficha 10, board 13:14610) · peças reais com dados fictícios"
                itemGap: 40

                Specimen {
                  caption: "Central 280 · 3 itens (passe o mouse num item para ver o X)"
                  stageWidth: 280; stageHeight: 316
                  Demo.NotificationSpecimen { kind: "center" }
                }
                Specimen {
                  caption: "Notificação sozinha 280×88"
                  stageWidth: 280; stageHeight: 88
                  Demo.NotificationSpecimen { kind: "single" }
                }
                Specimen {
                  caption: "Toast (barra recolhida) 288×88"
                  stageWidth: 288; stageHeight: 88
                  Demo.NotificationSpecimen { kind: "toast" }
                }
                Specimen {
                  caption: "Chegando no cartão da barra 156×156 · prévia 140×104"
                  stageWidth: 156; stageHeight: 156
                  Demo.NotificationSpecimen { kind: "arrival" }
                }
              }

              SectionBlock {
                title: "OSDs (ficha 10, board 13:14610) · 10 pontos, 1200 ms depois do último evento"
                itemGap: 40

                Specimen {
                  caption: "Brilho 70% · 7 pontos"
                  stageWidth: 156; stageHeight: 36
                  OsdCard { iconName: "sun"; value: 0.7 }
                }
                Specimen {
                  caption: "Volume 60% · 6 pontos"
                  stageWidth: 156; stageHeight: 36
                  OsdCard { iconName: "volume-2"; value: 0.6 }
                }
                Specimen {
                  caption: "Brilho 3% · mínimo de 1 ponto (P-08)"
                  stageWidth: 156; stageHeight: 36
                  OsdCard { iconName: "sun"; value: 0.03 }
                }
                Specimen {
                  caption: "Volume no mudo · 0 pontos"
                  stageWidth: 156; stageHeight: 36
                  OsdCard { iconName: "volume-x"; value: 0 }
                }
                Specimen {
                  caption: "Teclado 156×76 · layout atual com rádio marcado"
                  stageWidth: 156; stageHeight: 76
                  KeyboardLayoutCard { layouts: ["Português (BR)", "English (US)"]; activeIndex: 0 }
                }
              }

              SectionBlock {
                title: "Aparência (ficha 11, board 13:14610) · modal 580×456 com as três variações"
                itemGap: 40

                Specimen {
                  caption: "Escolher um disco troca o acento (e grava em theme.json, como no cabeçalho)"
                  stageWidth: 600; stageHeight: 469
                  Settings.Modal {
                    x: 0; y: 13
                    title: "Aparência"
                    bodyTop: 0
                    contentHeight: appearanceBody.contentHeight
                    Appearance.Body {
                      id: appearanceBody
                      brightnessAvailable: true
                      onThemeSelected: key => Appearance.State.selectTheme(key)
                      onBrightnessToggled: brightnessExpanded = !brightnessExpanded
                      onBrightnessMoved: value => brightness = Math.max(0, Math.min(1, value))
                    }
                  }
                }
                Specimen {
                  caption: "Brilho indisponível · linha desligada com “Indisponível” e o motivo no texto de erro (dangerText); o modal cresce 25"
                  stageWidth: 600; stageHeight: 494
                  Demo.AppearanceBodySpecimen {
                    brightnessAvailable: false
                    error: "No permission to control this display. Add your user to the i2c group."
                  }
                }
                Specimen {
                  caption: "Brilho indisponível · sem o ddcutil instalado"
                  stageWidth: 600; stageHeight: 494
                  Demo.AppearanceBodySpecimen {
                    brightnessAvailable: false
                    error: "Brightness for this display needs ddcutil, which is not installed."
                  }
                }
              }

              SectionBlock {
                title: "IdleFade (ficha 12, board 13:14610) · véu linear em 5 s, depois desliga os monitores"
                itemGap: 24

                Specimen {
                  caption: "0 s · tempo de tela esgotado"
                  stageWidth: 216; stageHeight: 136
                  IdleFadeFrame { progress: 0 }
                }
                Specimen {
                  caption: "2,5 s · escurecendo (50%)"
                  stageWidth: 216; stageHeight: 136
                  IdleFadeFrame { progress: 0.5 }
                }
                Specimen {
                  caption: "5 s · preto, desliga os monitores"
                  stageWidth: 216; stageHeight: 136
                  IdleFadeFrame { progress: 1 }
                }
              }
            }

            // =================================================================
            // Aba F2 — Barra lateral e organizador (fichas 01 a 04)
            // =================================================================
            Column {
              visible: root.selectedPhaseTab === 0
              width: parent.width
              spacing: 32

              Row {
                spacing: 12
                Chip {
                  text: root.sidebarDemoCards
                      ? "Barra ao vivo: cartões simulados ativos"
                      : "Simular cartões na barra ao vivo (Mídia + Instalações + Notificações)"
                  iconName: "sparkles"
                  selected: root.sidebarDemoCards
                  onClicked: root.toggleSidebarDemoCards()
                }
              }

              SectionBlock {
                title: "Organizador de workspaces · 12 estados (ficha 02, boards 13:12277 e 13:11395)"
                itemGap: 20

                Specimen {
                  caption: "1 · Aberto · repouso"; stageWidth: 164; stageHeight: 160
                  OrganizerStateSpecimen { stateNumber: 1 }
                }
                Specimen {
                  caption: "2 · Hover na linha 1 (+)"; stageWidth: 164; stageHeight: 160
                  OrganizerStateSpecimen { stateNumber: 2 }
                }
                Specimen {
                  caption: "3 · Hover no círculo e no +"; stageWidth: 164; stageHeight: 160
                  OrganizerStateSpecimen { stateNumber: 3 }
                }
                Specimen {
                  caption: "4 · Hover na pílula (puxador)"; stageWidth: 164; stageHeight: 160
                  OrganizerStateSpecimen { stateNumber: 4 }
                }
                Specimen {
                  caption: "5 · Mais de 3 janelas (carrossel)"; stageWidth: 164; stageHeight: 160
                  OrganizerStateSpecimen { stateNumber: 5 }
                }
                Specimen {
                  caption: "6 · Workspace ativo vazio"; stageWidth: 164; stageHeight: 160
                  OrganizerStateSpecimen { stateNumber: 6 }
                }
                Specimen {
                  caption: "7 · Arrastando uma janela"; stageWidth: 164; stageHeight: 160
                  OrganizerStateSpecimen { stateNumber: 7 }
                }
                Specimen {
                  caption: "8 · Reordenando workspaces"; stageWidth: 164; stageHeight: 160
                  OrganizerStateSpecimen { stateNumber: 8 }
                }
                Specimen {
                  caption: "9 · Recolhido (foco 32 px)"; stageWidth: 48; stageHeight: 168
                  OrganizerStateSpecimen { stateNumber: 9 }
                }
                Specimen {
                  caption: "10 · Recolhido · hover inativo"; stageWidth: 48; stageHeight: 168
                  OrganizerStateSpecimen { stateNumber: 10 }
                }
                Specimen {
                  caption: "11 · Terminais com agente"; stageWidth: 164; stageHeight: 160
                  OrganizerStateSpecimen { stateNumber: 11 }
                }
                Specimen {
                  caption: "12 · Monitor sem janelas"; stageWidth: 164; stageHeight: 160
                  OrganizerStateSpecimen { stateNumber: 12 }
                }
              }

              SectionBlock {
                title: "Cartões da barra lateral · abertos e recolhidos (ficha 04)"
                itemGap: 20

                Specimen {
                  caption: "Relógio · aberto (156×76)"; stageWidth: 156; stageHeight: 76
                  Calendar.Clock { width: 156; previewBattery: true }
                }
                Specimen {
                  caption: "Relógio · 23:33, a hora mais larga (cabe na caixa de 88)"; stageWidth: 156; stageHeight: 76
                  Demo.ClockSpecimen { time: "23:33" }
                }
                Specimen {
                  caption: "Relógio · hover na hora"; stageWidth: 156; stageHeight: 76
                  Calendar.Clock { width: 156; previewBattery: true; forceTimeHovered: true }
                }
                Specimen {
                  caption: "Relógio · recolhido (48×156)"; stageWidth: 48; stageHeight: 156
                  Calendar.Clock { width: 48; collapseProgress: 1; previewBattery: true }
                }

                Specimen {
                  caption: "Mídia · repouso (156×64)"; stageWidth: 156; stageHeight: 64
                  Media.Player { previewActive: true }
                }
                Specimen {
                  caption: "Mídia · hover (156×92)"; stageWidth: 156; stageHeight: 92
                  Media.Player { previewActive: true; previewRevealed: true }
                }
                Specimen {
                  caption: "Mídia · recolhido (48×48)"; stageWidth: 48; stageHeight: 48
                  Media.Player { collapseProgress: 1; previewActive: true }
                }

                Specimen {
                  caption: "Notificações · vazio (156×48)"; stageWidth: 156; stageHeight: 48
                  Notifications.SidebarCard { width: 156; previewCount: 0 }
                }
                Specimen {
                  caption: "Notificações · 3 itens (156×48)"; stageWidth: 156; stageHeight: 48
                  Notifications.SidebarCard {
                    width: 156
                    previewCount: 3
                    previewIcons: ["hash", "mail", "terminal"]
                  }
                }
                Specimen {
                  caption: "Notificações · recolhido (48×48)"; stageWidth: 48; stageHeight: 48
                  Notifications.SidebarCard {
                    width: 48
                    collapseProgress: 1
                    previewCount: 3
                  }
                }

                Specimen {
                  caption: "Instalações · aberto (156×88)"; stageWidth: 156; stageHeight: 88
                  Installs.SidebarCard {
                    width: 156
                    customModel: [
                      { jobId: "1", name: "Firefox", status: "installing", progress: 0.65, icon: "globe" },
                      { jobId: "2", name: "Blender", status: "installed", progress: 1.0, icon: "app-window" }
                    ]
                  }
                }
                Specimen {
                  caption: "Instalações · recolhido (48×88)"; stageWidth: 48; stageHeight: 88
                  Installs.SidebarCard {
                    width: 48
                    collapseProgress: 1
                    customModel: [
                      { jobId: "1", name: "Firefox", status: "installing", progress: 0.65, icon: "globe" },
                      { jobId: "2", name: "Blender", status: "installed", progress: 1.0, icon: "app-window" }
                    ]
                  }
                }
              }

              SectionBlock {
                title: "Controles de baixo · 4 botões (ficha 03)"
                itemGap: 20

                Specimen {
                  caption: "Aberto · repouso (156×48)"; stageWidth: 156; stageHeight: 48
                  BottomControls {}
                }
                Specimen {
                  caption: "Aberto · Wi-Fi selecionado"; stageWidth: 156; stageHeight: 48
                  BottomControls { previewSelectedSlot: 0 }
                }
                Specimen {
                  caption: "Hover Wi-Fi · taxas (156×80)"; stageWidth: 156; stageHeight: 80
                  BottomControls {
                    previewReveal: "wifi"
                    previewHoverSlot: 0
                    previewDownloadRate: "12 MB/s"
                    previewUploadRate: "1,2 MB/s"
                  }
                }
                Specimen {
                  caption: "Hover Som · slider (156×80)"; stageWidth: 156; stageHeight: 80
                  BottomControls {
                    previewReveal: "sound"
                    previewHoverSlot: 1
                    previewVolume: 0.61
                  }
                }
                Specimen {
                  caption: "Recolhido (48×168)"; stageWidth: 48; stageHeight: 168
                  BottomControls { collapseProgress: 1 }
                }
              }
            }

            // =================================================================
            // Aba F1 — Componentes base (ficha 00)
            // =================================================================
            Column {
              visible: root.selectedPhaseTab === 1
              width: parent.width
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
