import QtQuick
import ".."
import "../wallpaper/desktop" as Wallpaper
import "../calendar" as Calendar
import "../minimap" as Minimap
import "../media" as Media
import "../notifications" as Notifications
import "../screenshot" as Screenshot

// O desktop completo num palco de 1440×900, na composição do board dos desktops (ficha 19, board 13:20899; quadros da variação
// Chiba: barra aberta 13:20907, recolhida 13:20986, launcher 13:21063, captura 13:21208). É o aceite visual da F6 fora do Niri: o
// desktop de verdade (janelas, zona da barra, anel de foco) só existe na sessão do Niri.
//
// O que é peça de verdade: o papel de parede (wallpaper/desktop/Content.qml, com o véu de 40% a 0 à esquerda, o céu fixo em 13 de
// novembro de 2026, 14:32, e sem imagem), os cartões da barra lateral (calendar/Clock.qml, minimap/Map.qml, media/Player.qml,
// notifications/SidebarCard.qml e BottomControls.qml, com as propriedades de prévia que a Sidebar.qml usa com `demoCards`), o
// launcher (demo/LauncherSpecimen.qml, que monta launcher/Panel.qml) e a captura (screenshot/Capture.qml com o
// demo/CaptureService.qml). O cartão de instalações fica de fora: o board não o mostra.
// O que é dado de exemplo: as duas janelas de aplicativo (demo/SampleWindow.qml), o anel de foco (quem o desenha é o Niri) e a
// seleção da captura. O organizador (Minimap.Map) lê o NiriMsg, que fora do Niri não tem workspaces: aparece como vier, e o
// espécime não escreve no NiriMsg.
//   state  "open" (barra aberta, padrão), "collapsed" (barra recolhida), "launcher" (o véu de 20% e o launcher no estado dos
//          resultados agrupados, sobre a barra aberta) ou "capture" (a captura em modo Area com a seleção de 640×400 em (560,180),
//          sobre a barra aberta: na shell o fundo da captura é o quadro congelado do monitor, com a barra e as janelas dentro)
Item {
  id: root

  property string state: "open"

  implicitWidth: 1440
  implicitHeight: 900
  clip: true

  readonly property bool collapsed: state === "collapsed"
  readonly property real cardWidth: collapsed ? Theme.sidebarCardCollapsedWidth : Theme.sidebarCardExpandedWidth

  // A zona da barra é a que a Sidebar.qml reserva no Niri: a margem, o cartão e a margem de novo (176 aberta, 68 recolhida).
  readonly property real zone: Theme.sidebarOuterMargin + cardWidth + Theme.sidebarOuterMargin
  // Folgas das janelas, da tabela da ficha 19 ("Zona da barra e folga das janelas"): 12 nas bordas e 16 entre as colunas.
  readonly property real edgeGap: 12
  readonly property real columnGap: 16
  // A segunda coluna tem a largura do board (480 com a barra aberta, 524 recolhida) e termina a 12 da direita; a primeira ocupa o resto.
  readonly property real secondWidth: collapsed ? 524 : 480
  readonly property real secondX: width - edgeGap - secondWidth
  readonly property real firstX: zone + edgeGap
  readonly property real firstWidth: secondX - columnGap - firstX
  readonly property real windowsTop: edgeGap
  readonly property real windowsHeight: height - 2 * edgeGap

  // O céu fixo: a hora e o dia das prévias, e sem o relógio ligado para os prints saírem sempre iguais.
  Wallpaper.Content {
    anchors.fill: parent
    dimmed: true
    custom: false
    live: false
    now: new Date(2026, 10, 13, 14, 32)
  }

  Column {
    id: topStack
    x: Theme.sidebarOuterMargin
    y: Theme.sidebarOuterMargin
    spacing: Theme.sidebarCardGap

    Calendar.Clock {
      id: clock
      width: root.cardWidth
      collapseProgress: root.collapsed ? 1 : 0
      previewBattery: true
      previewTime: new Date(2026, 10, 13, 14, 32)
    }

    Minimap.Map {
      id: organizer
      screen: null
      collapseProgress: root.collapsed ? 1 : 0
      // A mesma conta da Sidebar.qml (sem o cartão de instalações): o que sobra entre a pilha de cima e os controles de baixo.
      maximumHeight: Math.max(64, controls.y - Theme.sidebarCardGap - topStack.y
          - clock.height - media.height - notifications.height
          - Theme.sidebarCardGap * 3)
    }

    Media.Player {
      id: media
      collapseProgress: root.collapsed ? 1 : 0
      previewActive: true
    }

    Notifications.SidebarCard {
      id: notifications
      width: root.cardWidth
      collapseProgress: root.collapsed ? 1 : 0
      previewCount: 3
      previewIcons: ["hash", "mail", "terminal"]
    }
  }

  // Os controles de baixo encostam na base da pilha: terminam a uma margem da base (y 890).
  BottomControls {
    id: controls
    x: Theme.sidebarOuterMargin
    y: root.height - Theme.sidebarOuterMargin - height
    collapseProgress: root.collapsed ? 1 : 0
  }

  // Duas janelas de aplicativo de exemplo, na geometria do board. A tabela da ficha 19 dá a barra de título de 40, a imagem em
  // (24,64) com a largura da janela menos 48 e 368 de altura (raio 12) e cinco linhas de 10 em y 464, 488, 512, 536 e 560.
  DesktopWindow {
    id: browser
    name: "Browser"
    x: root.firstX
    y: root.windowsTop
    width: root.firstWidth
    height: root.windowsHeight
  }

  DesktopWindow {
    name: "Terminal"
    x: root.secondX
    y: root.windowsTop
    width: root.secondWidth
    height: root.windowsHeight
  }

  // O anel de foco de exemplo, só na janela "Browser": 2 px no acento, por fora da janela (como o focus-ring do Niri desenha; o
  // board o põe por dentro, P-90), com o raio da janela mais a largura do anel, como o anel da captura da ficha 17.
  Rectangle {
    x: browser.x - 2
    y: browser.y - 2
    width: browser.width + 4
    height: browser.height + 4
    radius: 14
    color: "transparent"
    border.width: 2
    border.color: Theme.accent
  }

  // Launcher: o véu preto de 20% nos 1440×900, por cima da barra e das janelas, e o painel de verdade no estado dos resultados
  // agrupados, na conta da launcher/Window.qml (centrado na largura, com o topo a 160/900 da altura, em pixel inteiro).
  Item {
    anchors.fill: parent
    visible: root.state === "launcher"

    Rectangle {
      anchors.fill: parent
      color: Theme.launcherScrim
    }

    LauncherSpecimen {
      x: Math.round((root.width - Theme.launcherWidth) / 2)
      y: Math.round(root.height * Theme.launcherTopRatio)
      state: "grouped"
    }
  }

  // Captura: a peça de verdade por cima do desktop, com o serviço fictício, em modo Area e a seleção de 640×400 em (560,180).
  // O escurecimento, a borda, as alças e as três pílulas saem da peça, não daqui.
  CaptureService {
    id: captureService
    mode: "area"
    selection: ({ x: 560, y: 180, width: 640, height: 400 })
  }

  Screenshot.Capture {
    anchors.fill: parent
    visible: root.state === "capture"
    service: captureService
  }

  // O desenho de uma janela do desktop: o de demo/SampleWindow.qml com as medidas do board dos desktops.
  component DesktopWindow: SampleWindow {
    titleHeight: 39
    imageInset: 24
    imageTop: 64
    imageHeight: 368
    imageRadius: 12
    lines: [
      { y: 464, width: 520 },
      { y: 488, width: 460 },
      { y: 512, width: 500 },
      { y: 536, width: 380 },
      { y: 560, width: 300 }
    ]
  }
}
