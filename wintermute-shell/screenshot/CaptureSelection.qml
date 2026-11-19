import QtQuick
import "Selection.js" as Selection
import ".."

// O retângulo da seleção de área (ficha 17, board 13:19344, estado "Selecionando uma área" 13:19401): a borda de 1 px no
// acento, por dentro do retângulo, e as oito alças de 8×8 (raio 2, `knob` com borda de acento) centradas nos cantos e no meio
// de cada borda, de modo que o centro de cada alça cai em cima da linha. Só desenha: quem arrasta é a Capture.qml, que
// responde ao ponteiro em cima da área de cada alça (Theme.captureHandleHit).
//
// `rect` é { x, y, width, height } em pixels lógicos da peça. `showHandles` é falso enquanto a seleção ainda está sendo
// arrastada: as alças só aparecem depois de soltar.
Item {
  id: root

  property var rect: ({ x: 0, y: 0, width: 0, height: 0 })
  property bool showHandles: true

  x: rect.x
  y: rect.y
  width: rect.width
  height: rect.height

  Rectangle {
    anchors.fill: parent
    color: "transparent"
    border.width: Theme.captureSelectionBorder
    border.color: Theme.accent
  }

  Repeater {
    model: root.showHandles ? Selection.HANDLES : []

    delegate: Rectangle {
      id: handle

      required property string modelData

      // O centro da alça, em coordenadas da seleção.
      readonly property point center: {
        const c = Selection.handleCenter({ x: 0, y: 0, width: root.width, height: root.height }, modelData);
        return Qt.point(c.x, c.y);
      }

      x: center.x - Theme.captureHandleSize / 2
      y: center.y - Theme.captureHandleSize / 2
      width: Theme.captureHandleSize
      height: Theme.captureHandleSize
      radius: Theme.captureHandleRadius
      antialiasing: true
      color: Theme.knob
      border.width: Theme.captureHandleBorder
      border.color: Theme.accent
    }
  }
}
