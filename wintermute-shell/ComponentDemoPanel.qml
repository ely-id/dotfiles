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
      layer.enabled: true
      layer.effect: MultiEffect { colorization: 1; colorizationColor: Theme.text }
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
      layer.enabled: true
      layer.effect: MultiEffect {
        colorization: 1
        colorizationColor: plusSample.hoveredState ? Theme.text : Theme.muted
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
    implicitWidth: Theme.panelWidth
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
      title: "Add network"
      iconName: "plus"
      interactive: listPage.interactive
    }
  }

  component StackDemoJoin: Item {
    id: joinPage
    property var stackController: null
    property bool interactive: false
    property var selection: ({})
    implicitWidth: Theme.panelWidth
    implicitHeight: 228

    Text {
      x: 20; y: 16; width: 276; height: 32
      text: "Join “" + (joinPage.selection.name ?? "Casa_Lima") + "”"
      color: Theme.text
      font.family: Theme.titleFontFamily
      font.weight: Font.Normal
      font.pixelSize: Theme.fontPanelTitle
      font.letterSpacing: 0
      verticalAlignment: Text.AlignVCenter
    }
    Text {
      x: 20; y: 72
      text: "Password"
      color: Theme.text
      font.family: Theme.fontFamily
      font.weight: Font.Medium
      font.pixelSize: Theme.fontLabel
      font.letterSpacing: 0
    }
    Field { x: 20; y: 100; placeholderText: "Password"; password: true }
    ActionButton {
      x: 20; y: 160
      kind: "primary"
      text: "Connect"
      interactive: joinPage.interactive
      onClicked: joinPage.stackController.pop()
    }
  }

  // A pilha de verdade (CardStack) com as páginas fictícias. Fechar pelo X deixa o palco vazio;
  // o chip reabre.
  component StackSpecimen: Item {
    id: stackSpec
    property bool startStacked: false
    width: Theme.cardStackWidth
    height: Theme.cardStackFrontInsetSingle + 306

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
      text: "Reopen"
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
            text: (root.selectedPhaseTab === 5
                ? "6 · Captura de tela · "
                : root.selectedPhaseTab === 4
                ? "5 · Launcher · "
                : root.selectedPhaseTab === 3
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
              text: "F6 · Capture"
              iconName: "scan"
              selected: root.selectedPhaseTab === 5
              onClicked: root.selectedPhaseTab = 5
            }

            Chip {
              text: "F5 · Launcher"
              iconName: "search"
              selected: root.selectedPhaseTab === 4
              onClicked: root.selectedPhaseTab = 4
            }

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
            // Aba F5 — Launcher (ficha 14)
            // =================================================================
            Column {
              visible: root.selectedPhaseTab === 4
              width: parent.width
              spacing: 32

              SectionBlock {
                title: "Launcher (ficha 14, board 13:17120) · peça real com serviço fictício"
                itemGap: 40

                Specimen {
                  caption: "Digitando 640×268 · busca \"ter\" com a sugestão \"minal\" · 4 de folga antes do rodapé (P-68; o board tem 260)"
                  stageWidth: 640; stageHeight: 268
                  Demo.LauncherSpecimen { state: "typing"; selected: 0 }
                }
                Specimen {
                  caption: "Resultados agrupados 640×496 · quatro seções · hover em meeting-notes.md · comando perigoso em dangerText"
                  stageWidth: 640; stageHeight: 496
                  Demo.LauncherSpecimen { state: "grouped"; selected: 0; hovered: 2 }
                }
                Specimen {
                  caption: "Comando perigoso armado 640×496 · Power off now selecionada, depois do primeiro Enter · o detalhe vira \"Press ↵ again to confirm\" (text na selecionada) · o segundo Enter roda e fecha; mudar a seleção ou digitar desarma"
                  stageWidth: 640; stageHeight: 496
                  Demo.LauncherSpecimen { state: "confirm"; selected: 5 }
                }
                Specimen {
                  caption: "Cálculo 640×368 · busca 128*3.5+12 · cartão 624×128 em (8,88) · Copy result selecionada e In hexadecimal · rodapé com Copy ↵ e Actions Ctrl K"
                  stageWidth: 640; stageHeight: 368
                  Demo.LauncherSpecimen { state: "calc"; selected: 0 }
                }
                Specimen {
                  caption: "Cálculo sem hexadecimal 640×324 · busca 10/4, resultado 2.5 (não inteiro: só a linha Copy result)"
                  stageWidth: 640; stageHeight: 324
                  Demo.LauncherSpecimen { state: "calc"; expression: "10/4" }
                }
                Specimen {
                  caption: "Cálculo no locale com vírgula 640×368 · busca (2+3)*4,5+1,5 · resultado 24 · hexadecimal 0x18 selecionado"
                  stageWidth: 640; stageHeight: 368
                  Demo.LauncherSpecimen { state: "calc"; expression: "(2+3)*4,5+1,5"; separator: ","; selected: 1 }
                }
                Specimen {
                  caption: "Vazio 640×352 · placeholder · Recent em y 64 (linhas 88, 132, 176) · Tools em y 228 · chips de 36 em y 256 · divisor em 308"
                  stageWidth: 640; stageHeight: 352
                  Demo.LauncherSpecimen { state: "empty"; selected: 0 }
                }
                Specimen {
                  caption: "Aberto pelo + 640×352 · o vazio com a etiqueta \"On workspace 3\" de 112×24 em y 16, borda direita em x 620 (recuo de 14, raio 12, accentSubtle com accentRing) · o app escolhido abre nesse workspace"
                  stageWidth: 640; stageHeight: 352
                  Demo.LauncherSpecimen { state: "empty"; selected: 0; context: 3 }
                }
                Specimen {
                  caption: "Vazio sem recentes 640×188 · Tools em y 64 · chips em y 92 · divisor em 144 · nada selecionado"
                  stageWidth: 640; stageHeight: 188
                  Demo.LauncherSpecimen { state: "empty-tools" }
                }
                Specimen {
                  caption: "Vazio · chip Emoji em hover (pressed) · chip Screenshot com o foco do teclado (accentSubtle com accentRing); nenhuma linha selecionada"
                  stageWidth: 640; stageHeight: 352
                  Demo.LauncherSpecimen { state: "empty"; chip: 2; chipHovered: 1 }
                }
                Specimen {
                  caption: "Sem resultado 640×332 · busca xyzzy · círculo de 48 em (296,80) · título e dica centrados · ações em 196 (selecionada) e 240 · divisor em 288"
                  stageWidth: 640; stageHeight: 332
                  Demo.LauncherSpecimen { state: "no-result" }
                }
                Specimen {
                  caption: "Sem resultado sem as linhas de ação (a F5-T04 o desenhou assim; o serviço de verdade já não cai nele) 640×240 · divisor em 196"
                  stageWidth: 640; stageHeight: 240
                  Demo.LauncherSpecimen { state: "no-result-bare" }
                }
                Specimen {
                  caption: "Busca profunda (\"Search files\", F5-T11, P-73) · busca notes · uma seção, Files, com seis arquivos, três em pastas ocultas · divisor em 356"
                  stageWidth: 640; stageHeight: 400
                  Demo.LauncherSpecimen { state: "deep-files"; selected: 0 }
                }
                Specimen {
                  caption: "Busca profunda sem resultado · só Search the web (divisor do rodapé em 244) 640×288"
                  stageWidth: 640; stageHeight: 288
                  Demo.LauncherSpecimen { state: "no-result-deep" }
                }
              }

              SectionBlock {
                title: "Menu de ações (Ctrl+K, ficha 14, F5-T05; P-13) · composição sem board (A-05) · peça real com serviço fictício"
                itemGap: 40

                Specimen {
                  caption: "Ações do app 640×268 · voltar de 32 em (12,12) · nome do item em Geist Regular 17 na caixa do campo · \"Actions\" em y 64 · Open, Open on workspace… e Remove from recent em 88, 132 e 176 · divisor do rodapé em 224 · Run ↵ e Back Esc"
                  stageWidth: 640; stageHeight: 268
                  Demo.LauncherSpecimen { state: "actions-app"; selected: 0 }
                }
                Specimen {
                  caption: "Ações do arquivo 640×268 · Open, Show in folder e Copy path · segunda ação selecionada, terceira em hover"
                  stageWidth: 640; stageHeight: 268
                  Demo.LauncherSpecimen { state: "actions-file"; selected: 1; hovered: 2 }
                }
                Specimen {
                  caption: "Ação do comando perigoso 640×180 · uma linha só, Run, com o ícone em dangerText · o primeiro Enter arma"
                  stageWidth: 640; stageHeight: 180
                  Demo.LauncherSpecimen { state: "actions-command"; selected: 0 }
                }
                Specimen {
                  caption: "Run armado 640×180 · depois do primeiro Enter o detalhe vira \"Press ↵ again to confirm\" · o segundo roda; voltar desarma"
                  stageWidth: 640; stageHeight: 180
                  Demo.LauncherSpecimen { state: "actions-command-armed"; selected: 0 }
                }
                Specimen {
                  caption: "Open on workspace… 640×312 · o cabeçalho continua com o nome do app · uma linha por workspace do monitor, com o número do organizador (a quarta, a linha de criação, vale pela posição) · Esc volta às ações do app"
                  stageWidth: 640; stageHeight: 312
                  Demo.LauncherSpecimen { state: "actions-workspaces"; selected: 0 }
                }
                Specimen {
                  caption: "Ações do cálculo 640×224 · o cabeçalho traz a expressão formatada · Copy result e Copy hexadecimal"
                  stageWidth: 640; stageHeight: 224
                  Demo.LauncherSpecimen { state: "actions-calc"; selected: 0 }
                }
              }

              SectionBlock {
                title: "Seletor de cor (ficha 15, board 13:17120, nó 13:17499) · peça real com serviço fictício"
                itemGap: 40

                Specimen {
                  caption: "Resultado em repouso 640×476 · voltar de 32 em (12,12) · amostra de 96 em (20,76) · nome em Serif 24 · origem \"Picked just now · Firefox\" · \"Pick another\" de 120×32 em (136,140) · formatos de 600×44 em y 188, 236 e 284 · histórico de 12 amostras em y 364 · divisor do rodapé em 432"
                  stageWidth: 640; stageHeight: 476
                  Demo.LauncherSpecimen { state: "color" }
                }
                Specimen {
                  caption: "O estado do board: HEX copiado (check e \"Copied\" em successText, botão selecionado em accent) · segunda amostra do histórico em hover, com a borda knob de 2 e a dica de 88×28 em (32,400)"
                  stageWidth: 640; stageHeight: 476
                  Demo.LauncherSpecimen { state: "color"; copied: "hex"; historyHover: 1 }
                }
                Specimen {
                  caption: "Hover na primeira amostra · a dica encosta na margem de 20 do launcher (x 20), em vez de sair para x −8"
                  stageWidth: 640; stageHeight: 476
                  Demo.LauncherSpecimen { state: "color"; historyHover: 0 }
                }
              }

              SectionBlock {
                title: "Seletor de emoji (ficha 16, board 13:17120; grade 13:17552, busca 13:17675) · peça real com serviço fictício e o emoji.json de verdade"
                itemGap: 40

                Specimen {
                  caption: "Grade 640×436 · voltar em (12,12) · campo \"Search emoji\" em (52,16) · abas de 36 em y 64 (a dos recentes ativa) · divisor em 108 · \"Recent\" em y 116 · onze células de 48 em y 140, x 36 a 556 · \"Smileys & emotion\" em 196 · rodapé com a prévia, o nome e Copy ↵"
                  stageWidth: 640; stageHeight: 436
                  Demo.LauncherSpecimen { state: "emoji"; selected: 0 }
                }
                Specimen {
                  caption: "Hover numa célula · o rodapé mostra o emoji sob o ponteiro (🔥 Fire) e não o selecionado"
                  stageWidth: 640; stageHeight: 436
                  Demo.LauncherSpecimen { state: "emoji"; selected: 0; hovered: 3 }
                }
                Specimen {
                  caption: "Sem recentes · a primeira seção é \"Smileys & emotion\" em y 116 · a aba dos recentes a 50% e a dos rostos ativa"
                  stageWidth: 640; stageHeight: 436
                  Demo.LauncherSpecimen { state: "emoji-empty"; selected: 0 }
                }
                Specimen {
                  caption: "Rolado até a aba da natureza (leaf) · a aba ativa acompanha a seção do topo · a primeira célula da seção selecionada"
                  stageWidth: 640; stageHeight: 436
                  Demo.LauncherSpecimen { state: "emoji"; selected: 570; tab: 2 }
                }
                Specimen {
                  caption: "Rolado até a aba dos símbolos (hash)"
                  stageWidth: 640; stageHeight: 436
                  Demo.LauncherSpecimen { state: "emoji"; selected: 1701; tab: 5 }
                }
                Specimen {
                  caption: "Busca \"gato\" (acha pelo português) · as seis abas a 50% e nenhuma ativa · \"Results for “gato” (N)\" com N igual ao número de células da seção"
                  stageWidth: 640; stageHeight: 436
                  Demo.LauncherSpecimen { state: "emoji-search"; selected: 0 }
                }
                Specimen {
                  caption: "Busca \"cat\" (acha pelo inglês) · os resultados pelo nome e, abaixo, \"Related\" com os que só casam nas palavras-chave"
                  stageWidth: 640; stageHeight: 436
                  Demo.LauncherSpecimen { state: "emoji-search"; emojiText: "cat"; selected: 0 }
                }
                Specimen {
                  caption: "Sem resultado · o bloco \"Nothing found\" no lugar da grade · a altura continua 436"
                  stageWidth: 640; stageHeight: 436
                  Demo.LauncherSpecimen { state: "emoji-none" }
                }
              }

              SectionBlock {
                title: "Lupa do seletor de cor (ficha 15, board 13:17120, nó 13:17430) · peça real sobre uma cena fictícia, sem captura"
                itemGap: 40

                Specimen {
                  caption: "Pegando a cor 560×340 · lupa de 112 centrada no ponto (190,166) · grade de 7×7 de 16, pixel do meio com o traço de 2 por dentro · valor de 112×28 a 12 abaixo · dicas de 40 a 16 da base · o degradê varia 1 nível por pixel, então as colunas quase não se distinguem"
                  stageWidth: 560; stageHeight: 340
                  Demo.ColorLoupeSpecimen {}
                }
                Specimen {
                  caption: "Ponto perto da base (190,270) · o valor não cabe embaixo e vai 12 acima da lupa"
                  stageWidth: 560; stageHeight: 340
                  Demo.ColorLoupeSpecimen { pointX: 190; pointY: 270 }
                }
                Specimen {
                  caption: "Ponto no canto (12,12) · os pixels de fora da cena ficam na cor de fundo da lupa · o valor não sai da tela"
                  stageWidth: 560; stageHeight: 340
                  Demo.ColorLoupeSpecimen { pointX: 12; pointY: 12 }
                }
                Specimen {
                  caption: "Ponto na borda direita da imagem (324,166) · a lupa mostra a passagem da imagem para a janela, pixel por pixel"
                  stageWidth: 560; stageHeight: 340
                  Demo.ColorLoupeSpecimen { pointX: 324; pointY: 166 }
                }
              }
            }

            // =================================================================
            // Aba F6 — Captura de tela (ficha 17)
            // =================================================================
            Column {
              visible: root.selectedPhaseTab === 5
              width: parent.width
              spacing: 32

              SectionBlock {
                title: "Janela de captura (ficha 17, board 13:19344) · peça real com serviço fictício, sobre um fundo fictício · clique nos modos e no cursor; com o palco em foco, Espaço troca o modo"
                itemGap: 40

                Specimen {
                  caption: "Início, modo Area 720×450 (13:19354) · véu de 30% · mira de 1 px a 60% em (420,236) · pílula de coordenadas de 24 a (+8,+8) · dica de 40 a 24 do topo · barra de 496×56 a 24 da base, Area selecionado"
                  stageWidth: 720; stageHeight: 450
                  Demo.CaptureSpecimen {}
                }
                Specimen {
                  caption: "Ponteiro perto da borda direita e da de baixo (700,430) · a pílula de coordenadas passa para o outro lado do ponteiro e não sai do palco"
                  stageWidth: 720; stageHeight: 450
                  Demo.CaptureSpecimen { pointX: 700; pointY: 430 }
                }
                Specimen {
                  caption: "\"Mostrar o cursor\" ligado · o botão no estado selecionado do IconButton · hover do modo Window (composição, A-05)"
                  stageWidth: 720; stageHeight: 450
                  Demo.CaptureSpecimen { showCursor: true; hoverMode: 1 }
                }
                Specimen {
                  caption: "Ponteiro sobre a barra (420,396) · a mira e as coordenadas somem e o ponteiro do sistema volta"
                  stageWidth: 720; stageHeight: 450
                  Demo.CaptureSpecimen { pointX: 420; pointY: 396 }
                }
              }

              SectionBlock {
                title: "Modos Window e Screen (ficha 17, board 13:19344, estado \"Modo janela\" 13:19441; o modo Screen não tem board, é composição A-05) · peça real com serviço fictício · com o palco em foco, Espaço troca o modo e Enter escolhe"
                itemGap: 40

                Specimen {
                  caption: "Modo Window (13:19441) · a tela a 45% · o ponteiro (500,200) sobre a janela de 320×300 em (360,56) · anel de 2 no acento, raio 14, 324×304 em (358,54) · pílula de 152×24 em (360,22) com `Browser · 320 × 300` · sem mira, coordenadas nem dica"
                  stageWidth: 720; stageHeight: 450
                  Demo.CaptureSpecimen { mode: "window"; pointX: 500; pointY: 200 }
                }
                Specimen {
                  caption: "Modo Window, sem janela sob o ponteiro (700,120) · só o escurecimento e a barra, nada destacado"
                  stageWidth: 720; stageHeight: 450
                  Demo.CaptureSpecimen { mode: "window"; pointX: 700; pointY: 120 }
                }
                Specimen {
                  caption: "Modo Window, janela encostada no topo (360,0) · sem lugar em cima, a pílula vai para dentro, a 8 do canto de cima à esquerda"
                  stageWidth: 720; stageHeight: 450
                  Demo.CaptureSpecimen { mode: "window"; scene: "top"; pointX: 500; pointY: 200 }
                }
                Specimen {
                  caption: "Modo Window, duas janelas sobrepostas · o ponteiro (400,200) está nas duas e vale a flutuante, que fica acima das lado a lado"
                  stageWidth: 720; stageHeight: 450
                  Demo.CaptureSpecimen { mode: "window"; scene: "overlap"; pointX: 400; pointY: 200 }
                }
                Specimen {
                  caption: "Modo Window, com escala 2 (quadro de 1440×900) · a pílula mostra pixels do monitor: `Browser · 640 × 600`"
                  stageWidth: 720; stageHeight: 450
                  Demo.CaptureSpecimen { mode: "window"; pointX: 500; pointY: 200; frameWidth: 1440; frameHeight: 900 }
                }
                Specimen {
                  caption: "Modo Screen (sem board, A-05) · o monitor do ponteiro sem escurecimento · anel de 2 no acento por dentro da borda, sem raio · pílula a 8 do canto com `eDP-1 · 720 × 450` · Screen selecionado"
                  stageWidth: 720; stageHeight: 450
                  Demo.CaptureSpecimen { mode: "screen" }
                }
                Specimen {
                  caption: "Modo Screen, com escala 2 (quadro de 1440×900) · a pílula mostra os pixels do monitor: `eDP-1 · 1440 × 900`"
                  stageWidth: 720; stageHeight: 450
                  Demo.CaptureSpecimen { mode: "screen"; frameWidth: 1440; frameHeight: 900 }
                }
              }

              SectionBlock {
                title: "Seleção de área (ficha 17, board 13:19344, estado \"Selecionando uma área\" 13:19401) · peça real com serviço fictício · com o mouse: apertar e arrastar cria, por dentro move, uma alça redimensiona, por fora começa outra, e Enter chama Capture"
                itemGap: 40

                Specimen {
                  caption: "Seleção do board, solta · 320×200 em (200,104) · escurecimento de 45% só por fora · borda de 1 no acento · oito alças de 8×8 · pílula de tamanho 88×24 em (200,72) · pílula de ações 208×48 em (312,312) com hover no botão de anotar"
                  stageWidth: 720; stageHeight: 450
                  Demo.CaptureSpecimen { selX: 200; selY: 104; selW: 320; selH: 200; hoverAction: "annotate" }
                }
                Specimen {
                  caption: "Arrastando · sem as alças e sem a pílula de ações; a pílula de tamanho acompanha"
                  stageWidth: 720; stageHeight: 450
                  Demo.CaptureSpecimen { selX: 120; selY: 90; selW: 250; selH: 140; selecting: true }
                }
                Specimen {
                  caption: "Perto do topo (a 20) · a pílula de tamanho vai para dentro, a 8 do canto de cima à esquerda"
                  stageWidth: 720; stageHeight: 450
                  Demo.CaptureSpecimen { selX: 200; selY: 20; selW: 320; selH: 200 }
                }
                Specimen {
                  caption: "Perto da base · embaixo a pílula de ações encostaria na barra e vai para cima, alinhada à direita, a 8"
                  stageWidth: 720; stageHeight: 450
                  Demo.CaptureSpecimen { selX: 160; selY: 150; selW: 400; selH: 190 }
                }
                Specimen {
                  caption: "Encostada na direita e na base (palco de 1000) · embaixo não cabe e em cima cobriria a pílula de tamanho · a pílula de ações vai para dentro, a 8 do canto de baixo à direita"
                  stageWidth: 1000; stageHeight: 450
                  Demo.CaptureSpecimen { stageWidth: 1000; selX: 720; selY: 250; selW: 280; selH: 200 }
                }
                Specimen {
                  caption: "Encostada na direita e na base, no palco de 720 · a pílula de ações por dentro cai sobre a barra (composição, A-05; no monitor real a barra fica longe do canto)"
                  stageWidth: 720; stageHeight: 450
                  Demo.CaptureSpecimen { selX: 440; selY: 250; selW: 280; selH: 200 }
                }
              }

              SectionBlock {
                title: "Prévia depois da captura (ficha 17, estado 4, board 13:19344) · peça real com serviço fictício e uma imagem inventada · com `mouse` o hover e os botões respondem ao ponteiro"
                itemGap: 40

                Specimen {
                  caption: "Repouso 156×112 (13:19531) · raio 12, borda borderStrong de 1, sombra do vidro por baixo, sem véu"
                  stageWidth: 220; stageHeight: 170
                  Demo.ScreenshotPreviewSpecimen { x: 32; y: 24 }
                }
                Specimen {
                  caption: "Hover (13:19557) · véu preto a 50% · quatro botões de 32, raio 16, em x 8, 44, 80 e 116 e y 40: copiar, salvar, anotar, fechar"
                  stageWidth: 220; stageHeight: 170
                  Demo.ScreenshotPreviewSpecimen { x: 32; y: 24; hover: true }
                }
                Specimen {
                  caption: "Hover com o ponteiro no botão de anotar · fundo #F2F3F5 a 20%"
                  stageWidth: 220; stageHeight: 170
                  Demo.ScreenshotPreviewSpecimen { x: 32; y: 24; hoverButton: "annotate" }
                }
                Specimen {
                  caption: "\"Copiado\" · o botão de copiar mostra o check em successText por 1,5 s (Theme.launcherCopiedDuration; composição, A-05)"
                  stageWidth: 220; stageHeight: 170
                  Demo.ScreenshotPreviewSpecimen { x: 32; y: 24; hover: true; copied: true }
                }
                Specimen {
                  caption: "Barra recolhida 48×48 (13:19592) · raio 12, borda, sem sombra"
                  stageWidth: 120; stageHeight: 100
                  Demo.ScreenshotPreviewSpecimen { x: 32; y: 24; collapsed: true }
                }
                Specimen {
                  caption: "Recolhida em hover · véu de 50% e o botão de copiar de 32 centrado (composição, A-05; o board não desenha este estado)"
                  stageWidth: 120; stageHeight: 100
                  Demo.ScreenshotPreviewSpecimen { x: 32; y: 24; collapsed: true; hover: true }
                }
                Specimen {
                  caption: "Com o mouse · passe o ponteiro e clique nos botões (a vitrine só conta os pedidos)"
                  stageWidth: 220; stageHeight: 170
                  Demo.ScreenshotPreviewSpecimen { x: 32; y: 24; mouse: true }
                }
              }

              SectionBlock {
                title: "Aviso de captura salva (ficha 17, aviso de salvo, board 13:19344, nó 13:19610) · peça real com serviço fictício e um caminho inventado · onde aparece e por quanto tempo é composição (A-05)"
                itemGap: 40

                Specimen {
                  caption: "Cartão 280×64, raio 16, vidro padrão com o brilho do acento (13:19610) · bloco de 40×40 em (12,12), raio 10, fundo control · circle-check de 20 em successText · título Medium 13 em x 64 · caminho Medium 11 muted com reticências no fim, sem passar de x 264"
                  stageWidth: 344; stageHeight: 128
                  Demo.SavedToastSpecimen { x: 32; y: 32 }
                }
                Specimen {
                  caption: "Caminho curto · aparece inteiro, sem reticências"
                  stageWidth: 344; stageHeight: 128
                  Demo.SavedToastSpecimen { x: 32; y: 32; path: "~/Pictures/Screenshots/a.png" }
                }
              }

              SectionBlock {
                title: "Editor de anotação (ficha 17, estado 5, board 13:19344, nó 13:19481) · peça real com serviço fictício e uma imagem inventada · com o mouse: escolha a ferramenta e a cor e arraste na imagem; Enter e Esc valem com o campo de texto ou o recorte em andamento"
                itemGap: 40

                Specimen {
                  caption: "Estado do board (13:19481) · vidro de 720×480, raio 24 · seis ferramentas de 32 em x 12 a 192 (o retângulo selecionado) · divisores em x 236 e 436 · cinco cores em x 248 a 392 (a primeira com o anel) · desfazer em x 448 · \"Copy\" e \"Save\" de 88×32 em x 524 e 620 · área da imagem de 688×408 em (16,56) · as quatro marcas de exemplo: faixa de 20 a 35%, contorno de 3 com raio 8, haste de 3 com a ponta de 20 e o texto SemiBold 17"
                  stageWidth: 720; stageHeight: 480
                  Demo.AnnotateSpecimen {}
                }
                Specimen {
                  caption: "Vazio · o lápis e a primeira cor, sem marcas (o desfazer fica no estado desativado)"
                  stageWidth: 720; stageHeight: 480
                  Demo.AnnotateSpecimen { scene: "empty" }
                }
                Specimen {
                  caption: "Um traço de lápis (3, pontas redondas) na cor do acento"
                  stageWidth: 720; stageHeight: 480
                  Demo.AnnotateSpecimen { scene: "pencil" }
                }
                Specimen {
                  caption: "Texto sendo digitado (composição, A-05) · o campo no tamanho da tela, Geist SemiBold 17 na cor escolhida, com o cursor · Enter confirma, Esc cancela só o texto"
                  stageWidth: 720; stageHeight: 480
                  Demo.AnnotateSpecimen { scene: "empty"; tool: "text"; colorIndex: 3; typing: "Look here"; typingX: 420; typingY: 150 }
                }
                Specimen {
                  caption: "Recorte em andamento (composição, A-05) · a borda e o escurecimento por fora da seleção de área da captura, sem as alças · Enter aplica, Esc cancela"
                  stageWidth: 720; stageHeight: 480
                  Demo.AnnotateSpecimen { tool: "crop"; cropX: 120; cropY: 90; cropW: 380; cropH: 220 }
                }
                Specimen {
                  caption: "Imagem menor que a área (400×260) · no tamanho natural e centrada, sem ampliar"
                  stageWidth: 720; stageHeight: 480
                  Demo.AnnotateSpecimen { scene: "small" }
                }
                Specimen {
                  caption: "Imagem maior que a área (1376×816) · reduzida à metade para caber, sem deformar · as marcas estão em pixels da imagem, com o traço de 3 da tela guardado como 6: o desenho sai igual ao do board"
                  stageWidth: 720; stageHeight: 480
                  Demo.AnnotateSpecimen { scene: "large" }
                }
              }

              SectionBlock {
                title: "Histórico da área de transferência (ficha 18, board 13:19344; texto 13:19621, imagem 13:19678, busca 13:19746, fixados 13:19790, vazio 13:19846) · dentro do launcher, peça real com serviço fictício e dados inventados · o espécime não escuta a área de transferência"
                itemGap: 40

                Specimen {
                  caption: "Texto · vidro 640×436 · \"Today\" em y 72 · cinco linhas de 264×52 em x 8 e y 84, 136, 188, 240 e 292, a primeira selecionada (accentSubtle, meta em text) · bloco de 28 em (16,96) · divisor em x 280 · prévia de 328×208 em (296,72), Geist Mono 12 · metadados em y 308, 332 e 356 · rodapé Copy ↵ · Pin Ctrl P · Delete Del"
                  stageWidth: 640; stageHeight: 436
                  Demo.ClipboardSpecimen { state: "text" }
                }
                Specimen {
                  caption: "Hover numa linha · fundo hover (a primeira segue selecionada)"
                  stageWidth: 640; stageHeight: 436
                  Demo.ClipboardSpecimen { state: "text"; hovered: 3 }
                }
                Specimen {
                  caption: "Imagem · a captura selecionada · a imagem inteira dentro da prévia, sem deformar, cortada no raio (composição, A-05) · Source, Copied e \"1920 × 1080 · PNG · 412 KB\""
                  stageWidth: 640; stageHeight: 436
                  Demo.ClipboardSpecimen { state: "image" }
                }
                Specimen {
                  caption: "Busca \"firefox\" · \"2 results\" sem a divisão em seções · prévia de link: bloco de 40 com o globe, título em Medium 15, URL em Mono 11 muted que quebra linha · só Source e Copied"
                  stageWidth: 640; stageHeight: 436
                  Demo.ClipboardSpecimen { state: "search" }
                }
                Specimen {
                  caption: "Fixados · \"Pinned\" em y 72 com o pin de 16 em accentText e o título cortado em 184 · \"Today\" 4 abaixo da última linha · metadado \"Pinned\" no lugar de \"Copied\" · o rodapé diz Unpin (composição, A-05)"
                  stageWidth: 640; stageHeight: 436
                  Demo.ClipboardSpecimen { state: "pinned" }
                }
                Specimen {
                  caption: "Vazio · círculo de 48 em (296,120) · \"Nothing copied yet\" centrado em y 196 · dica de duas linhas a partir de y 212 · sem divisor vertical · rodapé só com Close Esc"
                  stageWidth: 640; stageHeight: 436
                  Demo.ClipboardSpecimen { state: "empty" }
                }
                Specimen {
                  caption: "Busca sem resultado (composição, A-05) · o mesmo bloco, com o search-x e o texto do launcher para a busca digitada"
                  stageWidth: 640; stageHeight: 436
                  Demo.ClipboardSpecimen { state: "no-results" }
                }
                Specimen {
                  caption: "Cinquenta itens (o teto da sessão) · a lista rola e a linha selecionada fica sempre à vista"
                  stageWidth: 640; stageHeight: 436
                  Demo.ClipboardSpecimen { state: "many"; selected: 12 }
                }
              }
            }

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

              SectionBlock {
                title: "Menu suspenso (ficha 13, composição A-05, P-81) · peça real com opções inventadas"
                itemGap: 40

                Specimen {
                  caption: "Lista simples (Lock & sleep) · vidro de pop-up, lista a 8, linhas de 44 raio 12, a atual em accentSubtle"
                  stageWidth: 181; stageHeight: 148
                  Demo.DropdownSpecimen { kind: "list" }
                }
                Specimen {
                  caption: "Com ícones (Orientation) · monitor de 16 em x 12, texto em x 36, hover numa linha"
                  stageWidth: 276; stageHeight: 192
                  Demo.DropdownSpecimen { kind: "icons"; hover: 2 }
                }
                Specimen {
                  caption: "Bandeja · marcada, submenu, separador de 9 (4 + 1 + 4) e desativada a 0,4; o foco do teclado na primeira linha"
                  stageWidth: 236; stageHeight: 245
                  Demo.DropdownSpecimen { kind: "tray"; focused: true }
                }
                Specimen {
                  caption: "Com rolagem (Refresh rate) · altura máxima 280 = 16 + 6 × 44, barra de 2 em dot, a atual à vista"
                  stageWidth: 276; stageHeight: 280
                  Demo.DropdownSpecimen { kind: "scroll" }
                }
              }

              Demo.InformationService { id: demoInformation }

              SectionBlock {
                title: "Informações (ficha 13, board 13:16083) · página real com dados fictícios"
                itemGap: 40

                Specimen {
                  caption: "Information 580×620 · 7 linhas a cada 48, botão Manual 520×64, rodapé com o broto, Wintermute e ARCH (P-58)"
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
                Specimen {
                  caption: "Quatro acrescentadas (P-59) · rolado até o fim, a 02 escolhida e hover na 04: número em Geist Mono 13 em (16,120), sem autor; o lugar depois da última fica vazio"
                  stageWidth: 644; stageHeight: 621
                  Demo.WallpaperSpecimen { selected: "02"; extras: 4; scroll: 9999; hoverIndex: 8 }
                }

                // Cartão Customize e papéis de parede por lugar (F4-T24, P-67): sem board, composição A-05.
                Specimen {
                  caption: "Seletor com o botão Customize (96×32 em x 504, y 26, o Arrange da Tela) · o mesmo seletor dentro da pilha, sem o cartão, para conferir que sai igual"
                  stageWidth: 644; stageHeight: 621
                  Demo.WallpaperSpecimen { selected: "chiba"; stacked: true }
                }
                Specimen {
                  caption: "Customize com as duas chaves desligadas · cartão de 580×228 em y 32, carta de trás de 548 a 16 de cada lado, conteúdo a 50% e desfocado, botão de fechar pendurado"
                  stageWidth: 644; stageHeight: 273
                  Demo.WallpaperSpecimen { selected: "chiba"; customizing: true }
                }
                Specimen {
                  caption: "Follow light and dark mode ligada · Light (Chiba) e Dark (Dynamic, o céu), hover em Dark; cartão de 348"
                  stageWidth: 644; stageHeight: 393
                  Demo.WallpaperSpecimen {
                    selected: "chiba"; customizing: true; followScheme: true
                    places: ({ "light": "chiba", "dark": "dynamic" }); hoverRow: "dark"
                  }
                }
                Specimen {
                  caption: "One wallpaper per display ligada · eDP-1 sem escolha (vale o marcado, Chiba) e DP-1 com Sprawl; cartão de 348"
                  stageWidth: 644; stageHeight: 393
                  Demo.WallpaperSpecimen {
                    selected: "chiba"; customizing: true; perDisplay: true
                    places: ({ "display:DP-1": "sprawl", "display:eDP-1:dark": "freeside" })
                  }
                }
                Specimen {
                  caption: "As duas ligadas · quatro linhas, \"eDP-1 · Light\" a \"DP-1 · Dark\"; cartão de 468; hover em eDP-1 · Dark; uma acrescentada (01) em DP-1 · Light"
                  stageWidth: 644; stageHeight: 513
                  Demo.WallpaperSpecimen {
                    selected: "freeside"; extras: 1; customizing: true; followScheme: true; perDisplay: true
                    places: ({ "display:eDP-1:light": "chiba", "display:eDP-1:dark": "dynamic", "display:DP-1:light": "01" })
                    hoverRow: "display:eDP-1:dark"
                  }
                }
                Specimen {
                  caption: "Cartão com erro · a mensagem em dangerText depois da última linha, com quebra"
                  stageWidth: 644; stageHeight: 417
                  Demo.WallpaperSpecimen {
                    selected: "chiba"; customizing: true; followScheme: true; error: "Could not apply appearance settings"
                  }
                }
                Specimen {
                  caption: "A grade escolhendo para um lugar · título \"eDP-1 · Dark\", sem o botão Customize, anel e marca no Sprawl, que vale ali (o marcado na grade é o Chiba)"
                  stageWidth: 644; stageHeight: 621
                  Demo.WallpaperSpecimen {
                    selected: "chiba"; followScheme: true; perDisplay: true
                    places: ({ "display:eDP-1:dark": "sprawl" }); choosing: "display:eDP-1:dark"
                  }
                }
                Specimen {
                  caption: "A grade escolhendo para um lugar sem escolha · título \"Light\", anel e marca no que o marcado na grade vale (Dynamic)"
                  stageWidth: 644; stageHeight: 621
                  Demo.WallpaperSpecimen { selected: "dynamic"; followScheme: true; choosing: "light" }
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
                  stageWidth: Theme.cardStackWidth; stageHeight: Theme.cardStackFrontInsetSingle + 306
                  StackSpecimen {}
                }
                Specimen {
                  caption: "Frente 316 sobre verso 284 em (16, 0) · folga 32 · o X volta"
                  stageWidth: Theme.cardStackWidth; stageHeight: Theme.cardStackFrontInsetSingle + 306
                  StackSpecimen { startStacked: true }
                }
              }

              SectionBlock {
                title: "Wi-Fi (ficha 05, board 13:13604) · pilha real com dados fictícios"
                itemGap: 40

                Specimen {
                  caption: "Lista 316×306 · rede conectada, cadeados e rodapé"
                  stageWidth: Theme.cardStackWidth; stageHeight: 328
                  Demo.WifiSpecimen { page: "drawer"; height: 328 }
                }
                Specimen {
                  caption: "Entrar 316×228 · “Conectar” desativado sem senha"
                  stageWidth: Theme.cardStackWidth; stageHeight: 260
                  Demo.WifiSpecimen {
                    page: "join"; height: 260
                    selection: ({ ssid: "Casa_Lima", locked: true })
                  }
                }
                Specimen {
                  caption: "Adicionar rede 316×436 · SSID em foco"
                  stageWidth: Theme.cardStackWidth; stageHeight: 468
                  Demo.WifiSpecimen { page: "add"; height: 468 }
                }
                Specimen {
                  caption: "Detalhes 316×424 · 6 linhas de 48 com divisor"
                  stageWidth: Theme.cardStackWidth; stageHeight: 456
                  Demo.WifiSpecimen {
                    page: "details"; height: 456
                    selection: ({ ssid: "Wintermute-5G", bars: 3, uuids: ["demo-1"] })
                  }
                }
                Specimen {
                  caption: "Status 316×112 · conectando"
                  stageWidth: Theme.cardStackWidth; stageHeight: 144
                  Demo.WifiSpecimen {
                    page: "status"; height: 144
                    phase: "connecting"; statusText: "Connecting to Casa_Lima…"
                  }
                }
                Specimen {
                  caption: "Status · conectado (fecha sozinho em 1,5 s no painel real)"
                  stageWidth: Theme.cardStackWidth; stageHeight: 144
                  Demo.WifiSpecimen {
                    page: "status"; height: 144
                    phase: "complete"; statusText: "Connected"
                  }
                }
                Specimen {
                  caption: "Status · senha incorreta"
                  stageWidth: Theme.cardStackWidth; stageHeight: 144
                  Demo.WifiSpecimen {
                    page: "status"; height: 144
                    phase: "failed"; statusText: "Incorrect password"
                  }
                }
              }

              SectionBlock {
                title: "Bluetooth (ficha 06, board 13:13604) · pilha real com dados fictícios"
                itemGap: 40

                Specimen {
                  caption: "Lista 316×306 · conectado, bateria, conectando e rodapé"
                  stageWidth: Theme.cardStackWidth; stageHeight: 328
                  Demo.BluetoothSpecimen { page: "drawer"; height: 328 }
                }
                Specimen {
                  caption: "Próximos 316×236 · procurando"
                  stageWidth: Theme.cardStackWidth; stageHeight: 268
                  Demo.BluetoothSpecimen { page: "nearby"; searching: true; height: 268 }
                }
                Specimen {
                  caption: "Pareamento 316×236 · código em Serif 32 accentText"
                  stageWidth: Theme.cardStackWidth; stageHeight: 268
                  Demo.BluetoothSpecimen { page: "pair"; height: 268 }
                }
                Specimen {
                  caption: "Desligado 316×156"
                  stageWidth: Theme.cardStackWidth; stageHeight: 178
                  Demo.BluetoothSpecimen { page: "drawer"; bluetoothEnabled: false; height: 178 }
                }
                Specimen {
                  caption: "Rádio bloqueado 316×156 · a chave desbloqueia ao ligar"
                  stageWidth: Theme.cardStackWidth; stageHeight: 178
                  Demo.BluetoothSpecimen {
                    page: "drawer"; bluetoothEnabled: false; bluetoothBlocked: true; height: 178
                  }
                }
                Specimen {
                  caption: "Rádio bloqueado · erro ao desbloquear (rfkill indisponível)"
                  stageWidth: Theme.cardStackWidth; stageHeight: 222
                  Demo.BluetoothSpecimen {
                    page: "drawer"; bluetoothEnabled: false; bluetoothBlocked: true; height: 222
                    errorMessage: "Could not unblock Bluetooth: rfkill is not installed"
                  }
                }
                Specimen {
                  caption: "Detalhes · mesmo layout do Wi-Fi"
                  stageWidth: Theme.cardStackWidth; stageHeight: 380
                  Demo.BluetoothSpecimen { page: "details"; height: 380 }
                }
              }

              SectionBlock {
                title: "Som (ficha 07, board 13:14610) · pop-up real com dispositivos fictícios"
                itemGap: 40

                Specimen {
                  caption: "Saída 316×236 · slider com o valor na alça"
                  stageWidth: Theme.cardStackWidth; stageHeight: 258
                  Demo.AudioSpecimen { tab: "output"; height: 258 }
                }
                Specimen {
                  caption: "Entrada 316×236"
                  stageWidth: Theme.cardStackWidth; stageHeight: 258
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
                  caption: "Brilho indisponível · alerta e 0 pontos (P-62)"
                  stageWidth: 156; stageHeight: 36
                  OsdCard { iconName: "circle-alert"; value: 0 }
                }
                Specimen {
                  caption: "Teclado 156×76 · layout atual com rádio marcado"
                  stageWidth: 156; stageHeight: 76
                  KeyboardLayoutCard { layouts: ["Português (BR)", "English (US)"]; activeIndex: 0 }
                }
              }

              SectionBlock {
                title: "Aparência (ficha 11, board 13:14610) · modal 580×576 com as três variações"
                itemGap: 40

                Specimen {
                  caption: "Escolher um disco troca o acento (e grava em theme.json, como no cabeçalho)"
                  stageWidth: 600; stageHeight: 589
                  Settings.Modal {
                    x: 0; y: 13
                    title: "Appearance"
                    bodyTop: 0
                    contentHeight: appearanceBody.contentHeight
                    Appearance.Body {
                      id: appearanceBody
                      brightnessAvailable: true
                      onAppsDarkToggled: dark => appsDark = dark
                      onAppsAutomaticToggled: automatic => appsAutomatic = automatic
                      onThemeSelected: key => Appearance.State.selectTheme(key)
                      onBrightnessToggled: brightnessExpanded = !brightnessExpanded
                      onBrightnessMoved: value => brightness = Math.max(0, Math.min(1, value))
                    }
                  }
                }
                Specimen {
                  caption: "Brilho indisponível · linha desligada com “Indisponível” e o motivo no texto de erro (dangerText); o modal cresce 25"
                  stageWidth: 600; stageHeight: 614
                  Demo.AppearanceBodySpecimen {
                    brightnessAvailable: false
                    error: "No permission to control this display. Add your user to the i2c group."
                  }
                }
                Specimen {
                  caption: "Brilho indisponível · sem o ddcutil instalado"
                  stageWidth: 600; stageHeight: 614
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
                    previewVolume: 0.6
                  }
                }
                Specimen {
                  caption: "Hover Som · mudo (156×80)"; stageWidth: 156; stageHeight: 80
                  BottomControls {
                    previewReveal: "sound"
                    previewHoverSlot: 1
                    previewVolume: 0.6
                    previewMuted: true
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
                ActionButton { kind: "primary"; text: "Connect"; visualState: "rest" }
              }
              Specimen {
                caption: "Primário · hover"; stageWidth: 276; stageHeight: 48
                ActionButton { kind: "primary"; text: "Connect"; visualState: "hover" }
              }
              Specimen {
                caption: "Primário · desativado"; stageWidth: 276; stageHeight: 48
                ActionButton { kind: "primary"; text: "Connect"; visualState: "disabled" }
              }
              Specimen {
                caption: "Secundário"; stageWidth: 146; stageHeight: 40
                ActionButton { kind: "secondary"; text: "Disconnect"; visualState: "rest" }
              }
              Specimen {
                caption: "Secundário · hover"; stageWidth: 146; stageHeight: 40
                ActionButton { kind: "secondary"; text: "Disconnect"; visualState: "hover" }
              }
              Specimen {
                caption: "Secundário · desativado"; stageWidth: 146; stageHeight: 40
                ActionButton { kind: "secondary"; text: "Disconnect"; visualState: "disabled" }
              }
              Specimen {
                caption: "Perigo"; stageWidth: 146; stageHeight: 40
                ActionButton { kind: "danger"; text: "Forget network"; visualState: "rest" }
              }
              Specimen {
                caption: "Perigo · hover"; stageWidth: 146; stageHeight: 40
                ActionButton { kind: "danger"; text: "Forget network"; visualState: "hover" }
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
                Field { placeholderText: "Network name"; visualState: "empty" }
              }
              Specimen {
                caption: "Hover"; stageWidth: 276; stageHeight: 44
                Field { placeholderText: "Network name"; visualState: "hover" }
              }
              Specimen {
                caption: "Foco"; stageWidth: 276; stageHeight: 44
                Field { placeholderText: "Network name"; visualState: "focus" }
              }
              Specimen {
                caption: "Preenchido"; stageWidth: 276; stageHeight: 44
                Field { text: "Casa_Lima"; visualState: "filled" }
              }
              Specimen {
                caption: "Senha"; stageWidth: 276; stageHeight: 44
                Field { text: "Password"; password: true; visualState: "password" }
              }
              Specimen {
                caption: "Erro"; stageWidth: 276; stageHeight: 44
                Field { text: "Password"; password: true; error: true; visualState: "error" }
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
                  detail: "Connected"
                  iconName: "wifi"
                  visualState: "selected"
                }
              }

              Specimen {
                caption: "Ajuste · navega"; stageWidth: 520; stageHeight: 52
                SettingsRow {
                  title: "Keyboard language"
                  value: "Português (BR)"
                  navigation: true
                  visualState: "rest"
                }
              }
              Specimen {
                caption: "Ajuste · hover"; stageWidth: 520; stageHeight: 52
                SettingsRow {
                  title: "Scale"
                  value: "125%"
                  navigation: false
                  visualState: "hover"
                }
              }
              Specimen {
                caption: "Ajuste · chave"; stageWidth: 520; stageHeight: 52
                SettingsRow {
                  title: "Mouse acceleration"
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
                Tag { kind: "accent"; text: "Connected" }
              }
              Specimen {
                caption: "Neutra"; stageWidth: 46; stageHeight: 20
                Tag { kind: "neutral"; text: "Saved" }
              }
              Specimen {
                caption: "Sucesso"; stageWidth: 78; stageHeight: 20
                Tag { kind: "success"; text: "Charging" }
              }
              Specimen {
                caption: "Perigo"; stageWidth: 52; stageHeight: 20
                Tag { kind: "danger"; text: "Failed" }
              }

              Specimen {
                caption: "Chip"; stageWidth: 138; stageHeight: 36
                Chip { text: "Color picker"; iconName: "pipette"; visualState: "rest" }
              }
              Specimen {
                caption: "Chip · hover"; stageWidth: 86; stageHeight: 36
                Chip { text: "Emoji"; iconName: "smile"; visualState: "hover" }
              }
              Specimen {
                caption: "Chip · selecionado"; stageWidth: 146; stageHeight: 36
                Chip { text: "Screenshot"; iconName: "scan"; visualState: "selected" }
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
