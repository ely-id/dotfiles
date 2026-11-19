import QtQuick
import ".."
import "../screenshot" as Screenshot

// A peça da janela de captura de verdade (screenshot/Capture.qml) com um serviço fictício, num palco de 720×450 como o do
// board (ficha 17, board 13:19344, estado "Início (modo área)" 13:19354), sobre um fundo fictício. Não captura a tela: na
// shell o fundo é o quadro congelado do monitor (screenshot/CaptureWindow.qml). O fundo e as "janelas" são dado de exemplo, não
// desenho da peça: os valores deles são só para o véu ter o que escurecer. As mesmas janelas são a foto do serviço fictício (com o
// `layout` no formato do Niri), que é onde o modo Window as procura.
//   mode        "area" (a mira, as coordenadas e a dica), "window" (a janela sob o ponteiro com o anel e a pílula) ou "screen" (o monitor
//               inteiro, sem escurecimento, com o anel e a pílula)
//   scene       as janelas do palco: "board" (300×220 em (40,40) e 320×300 em (360,56), as do board), "top" (a segunda encostada no
//               topo, em (360,0)), "overlap" (uma lado a lado e uma flutuante por cima dela) ou "none" (nenhuma janela)
//   monitorName o nome do monitor do palco (padrão eDP-1, fictício); a pílula do modo Screen o mostra
//   frameWidth, frameHeight  o tamanho do quadro em pixels (padrão 0: sem escala); as pílulas mostram pixels do monitor
//   pointX, pointY  o ponto do ponteiro, em pixels do palco (padrão 420,236, o do board). Perto da borda direita ou de baixo
//               a pílula de coordenadas passa para o outro lado do ponteiro
//   showCursor  "mostrar o cursor" ligado (o botão no estado selecionado)
//               Com o ponto sobre a barra ou sobre a dica (ex.: 420,396), a mira e as coordenadas somem, como na shell
//   hoverMode   o modo sob o ponteiro (0 a 2), para fixar o hover; -1 o ponteiro de verdade
//   follow      o ponto acompanha o ponteiro do mouse no palco (padrão: não, para os prints saírem fixos)
//   selX, selY, selW, selH  a seleção de área, em pixels do palco (selW 0: sem seleção). A do board é 200, 104, 320, 200
//   selecting   a seleção ainda está sendo arrastada (sem as alças e sem a pílula de ações)
//   hoverAction o botão da pílula de ações sob o ponteiro ("copy", "save" ou "annotate"; o board mostra o de anotar)
//   stageWidth  a largura do palco (padrão 720, a do board); só para mostrar a seleção encostada na direita sem a barra por cima
// Com o mouse: apertar e arrastar cria a seleção, por dentro a move, uma alça a redimensiona, por fora começa outra.
// As teclas valem com o palco em foco: Espaço troca o modo, Esc só conta o pedido de fechar, Enter chama capture().
Item {
  id: root

  property string mode: "area"
  property real pointX: 420
  property real pointY: 236
  property bool showCursor: false
  property int hoverMode: -1
  property bool follow: false
  property real selX: 0
  property real selY: 0
  property real selW: 0
  property real selH: 0
  property bool selecting: false
  property string hoverAction: ""
  property int stageWidth: 720
  property string scene: "board"
  property string monitorName: "eDP-1"
  property int frameWidth: 0
  property int frameHeight: 0

  implicitWidth: stageWidth
  implicitHeight: 450
  // Como no board (overflow clip) e como um monitor: o que passa do palco, a pílula e as sombras, não aparece.
  clip: true
  focus: true

  // Para o teste de comportamento.
  readonly property alias capture: capture
  readonly property alias service: demoService

  Keys.onPressed: event => { event.accepted = capture.handleKey(event.key, event.modifiers); }

  CaptureService {
    id: demoService
    mode: root.mode
    showCursor: root.showCursor
    selection: root.selW > 0 ? ({ x: root.selX, y: root.selY, width: root.selW, height: root.selH }) : null
    selecting: root.selecting
    selectionOutput: root.monitorName
    windowSnapshot: root.scene === "none" ? ({}) : ({ [root.monitorName]: root.windows })
  }

  // Uma janela inventada, no formato do NiriMsg.activeWorkspaceWindows: o `layout` é o do IPC do Niri, com a janela sem decorações
  // (o bloco tem o tamanho dela e o deslocamento é 0) e a posição na vista do workspace.
  function windowData(id, name, x, y, width, height, floating) {
    return {
      id: id,
      appId: "demo." + name.toLowerCase(),
      title: name + " - demo",
      entryName: name,
      isFloating: floating,
      layout: {
        tile_size: [width, height],
        window_size: [width, height],
        tile_pos_in_workspace_view: [x, y],
        window_offset_in_tile: [0, 0]
      }
    };
  }

  // As janelas da cena, em ordem de desenho: as lado a lado antes das flutuantes.
  readonly property var windows: {
    switch (scene) {
    case "top":
      return [windowData(1, "Terminal", 40, 40, 300, 220, false), windowData(2, "Browser", 360, 0, 320, 300, false)];
    case "overlap":
      return [windowData(1, "Terminal", 40, 60, 400, 300, false), windowData(2, "Browser", 260, 100, 320, 240, true)];
    case "none":
      return [];
    }
    return [windowData(1, "Terminal", 40, 40, 300, 220, false), windowData(2, "Browser", 360, 56, 320, 300, false)];
  }

  // O fundo fictício: o linear de 155,5° de rgb(7,8,11) a rgb(16,19,28) do board da lupa e duas janelas de aplicativo.
  Item {
    anchors.fill: parent

    Rectangle {
      anchors.fill: parent
      gradient: Gradient {
        orientation: Gradient.Vertical
        GradientStop { position: 0; color: Qt.rgba(7 / 255, 8 / 255, 11 / 255, 1) }
        GradientStop { position: 1; color: Qt.rgba(16 / 255, 19 / 255, 28 / 255, 1) }
      }
    }

    Repeater {
      model: root.windows

      delegate: Rectangle {
        id: windowBox

        required property var modelData

        x: modelData.layout.tile_pos_in_workspace_view[0] + modelData.layout.window_offset_in_tile[0]
        y: modelData.layout.tile_pos_in_workspace_view[1] + modelData.layout.window_offset_in_tile[1]
        width: modelData.layout.window_size[0]
        height: modelData.layout.window_size[1]
        radius: 12
        color: "#1B1D22"
        border.width: 1
        border.color: Theme.border

        Rectangle {
          x: 1
          y: 1
          width: parent.width - 2
          height: 32
          topLeftRadius: 11
          topRightRadius: 11
          color: "#24262C"
        }

        Rectangle {
          visible: windowBox.modelData.entryName === "Browser"
          x: 16
          y: 52
          width: parent.width - 32
          height: 120
          radius: 8
          gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0; color: "#12283E" }
            GradientStop { position: 0.5; color: "#3FA9D9" }
            GradientStop { position: 1; color: "#F4A846" }
          }
        }
      }
    }
  }

  Screenshot.Capture {
    id: capture
    anchors.fill: parent
    service: demoService
    outputName: root.monitorName
    frameWidth: root.frameWidth
    frameHeight: root.frameHeight
    hoverMode: root.hoverMode
    hoverAction: root.hoverAction
    pointX: root.pointX
    pointY: root.pointY
  }

  HoverHandler {
    enabled: root.follow
    onPointChanged: {
      root.pointX = point.position.x;
      root.pointY = point.position.y;
    }
  }

  TapHandler {
    onTapped: root.forceActiveFocus()
  }
}
