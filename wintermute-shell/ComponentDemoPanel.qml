pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import "calendar" as Calendar
import "media" as Media
import "minimap" as Minimap
import "notifications" as Notifications
import "installs" as Installs
import "settings/appearance" as Appearance

// Painel de demonstração visual da F1 e da F2 (fichas 00 a 04, boards 13:11217, 13:11463, 13:12277 e 13:11395).
// Abre com: qs -p ~/Projects/dotfiles/wintermute-shell ipc call demo toggle
PanelWindow {
  id: root
  required property var panelScreen
  property bool opened: false
  property bool sidebarDemoCards: false
  property int selectedPhaseTab: 0 // 0 = F2 (Barra e organizador), 1 = F1 (Componentes base)
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
          windowData: ({ lucideIcon: "message-square", isFocused: false })
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
            Minimap.WindowIcon { x: 96; y: 0; interactive: false; windowData: ({ lucideIcon: "message-square" }) }
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

        Minimap.WindowIcon { x: 10; y: 60; interactive: false; windowData: ({ lucideIcon: "message-square" }) }
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
        Minimap.WindowIcon { x: 10; y: 10; interactive: false; windowData: ({ lucideIcon: "message-square" }) }
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
            text: (root.selectedPhaseTab === 0
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
              text: "F2 · Barra"
              iconName: "panel-left-open"
              selected: root.selectedPhaseTab === 0
              onClicked: root.selectedPhaseTab = 0
            }

            Chip {
              text: "F1 · Base"
              iconName: "sliders-horizontal"
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
                    previewIcons: ["message-square", "mail", "terminal"]
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
                      { jobId: "2", name: "Blender", status: "installed", progress: 1.0, icon: "box" }
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
                      { jobId: "2", name: "Blender", status: "installed", progress: 1.0, icon: "box" }
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
