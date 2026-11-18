import QtQuick
import ".."
import "../launcher" as Launcher

// A lupa do seletor de cor de verdade (launcher/ColorLoupe.qml) sobre uma cena fictícia, sem janela e sem captura de
// tela (ficha 15, estado "pegando a cor", board 13:17430). A cena é a do board, 560×340: um fundo escuro e uma
// "janela" de 300×220 em (40,40) com uma "imagem" de 268×156 em (56,88) num degradê horizontal de #12283E a #3FA9D9
// a #F4A846. As cores da cena são dado de exemplo do board, não desenho da peça. A lupa lê os pixels da cena pelo
// mesmo caminho da de verdade (launcher/PixelReader.qml); só o `source` muda: lá é o quadro congelado do monitor.
//   pointX, pointY  o ponto sob a lupa, em pixels da cena. O padrão é o meio da imagem, (190,166), onde a cor é a do
//                   #3FA9D9 do degradê, ou muito perto. Perto da base a pílula do valor vai para cima da lupa; num
//                   canto, os pixels de fora da cena ficam na cor de fundo da lupa.
Item {
  id: root

  property real pointX: 190
  property real pointY: 166

  implicitWidth: 560
  implicitHeight: 340
  // Como no board (overflow clip) e como um monitor: o que passa da cena, a lupa e as sombras, não aparece.
  clip: true

  // Para o teste de comportamento: a lupa e a cena.
  readonly property alias loupe: loupe
  readonly property alias scene: scene

  Item {
    id: scene
    anchors.fill: parent

    // O fundo do board: o linear de 155,5° de rgb(7,8,11) a rgb(16,19,28). As cinco manchas radiais do board ficam
    // de fora: são cenário, e a lupa só precisa de uma cena com cores conhecidas.
    Rectangle {
      anchors.fill: parent
      radius: 16
      gradient: Gradient {
        orientation: Gradient.Vertical
        GradientStop { position: 0; color: Qt.rgba(7 / 255, 8 / 255, 11 / 255, 1) }
        GradientStop { position: 1; color: Qt.rgba(16 / 255, 19 / 255, 28 / 255, 1) }
      }
    }

    // A janela de app genérica (13:17431): #1b1d22, raio 12, borda de 1 e a barra de 32.
    Rectangle {
      x: 40
      y: 40
      width: 300
      height: 220
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
    }

    // A "imagem" (13:17433): 268×156 em (56,88), raio 8, com o degradê horizontal.
    Rectangle {
      x: 56
      y: 88
      width: 268
      height: 156
      radius: 8
      gradient: Gradient {
        orientation: Gradient.Horizontal
        GradientStop { position: 0; color: "#12283E" }
        GradientStop { position: 0.5; color: "#3FA9D9" }
        GradientStop { position: 1; color: "#F4A846" }
      }
    }
  }

  Launcher.ColorLoupe {
    id: loupe
    anchors.fill: parent
    source: scene
    pointX: root.pointX
    pointY: root.pointY
  }
}
