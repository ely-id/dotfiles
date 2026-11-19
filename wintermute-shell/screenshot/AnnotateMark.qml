pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import "Annotate.js" as Ann
import ".."

// Uma marca do editor de anotação (ficha 17, estado 5; board 13:19481, marcas 13:19521 a 13:19525), desenhada em pixels da imagem. A
// mesma peça desenha a marca na tela (dentro da cena reduzida) e no PNG exportado: o que eu vejo é o que sai. Os formatos da marca
// são os do Annotate.js; as espessuras, o raio e o tamanho da fonte já chegam divididos pela escala, então aqui só se desenha.
//   lápis       traço livre, pontas e junções redondas; um clique é um círculo
//   marca-texto faixa reta de `a` até `b`, na cor escolhida a `opacity`
//   retângulo   só o contorno, por dentro do retângulo
//   seta        a haste de `a` até `b` e, centrada em `b` e girada na direção dela, a ponta: o `chevron-right`
//   texto       Geist SemiBold, com o canto de cima à esquerda em (x, y)
Item {
  id: root

  required property var mark

  Loader {
    sourceComponent: root.mark.type === "pencil" ? pencil
        : root.mark.type === "highlight" ? strip
        : root.mark.type === "rect" ? rectangle
        : root.mark.type === "arrow" ? arrow
        : root.mark.type === "text" ? label : null
  }

  Component {
    id: pencil
    Loader { sourceComponent: Ann.isDot(root.mark) ? dot : stroke }
  }

  // Um clique do lápis: um círculo do diâmetro do traço, centrado no ponto.
  Component {
    id: dot
    Rectangle {
      x: root.mark.points[0].x - root.mark.width / 2
      y: root.mark.points[0].y - root.mark.width / 2
      width: root.mark.width
      height: root.mark.width
      radius: root.mark.width / 2
      color: root.mark.color
      antialiasing: true
    }
  }

  Component {
    id: stroke
    Shape {
      preferredRendererType: Shape.CurveRenderer
      ShapePath {
        strokeColor: root.mark.color
        strokeWidth: root.mark.width
        fillColor: "transparent"
        capStyle: ShapePath.RoundCap
        joinStyle: ShapePath.RoundJoin
        PathPolyline { path: root.mark.points.map(p => Qt.point(p.x, p.y)) }
      }
    }
  }

  // A faixa de `a` até `b`: um retângulo da largura da distância e da altura da espessura, girado em torno do ponto `a`, com o meio da
  // espessura em cima do traço. Serve ao marca-texto e à haste da seta.
  component Band: Rectangle {
    required property var p0
    required property var p1
    required property real thickness

    x: p0.x
    y: p0.y - thickness / 2
    width: Math.hypot(p1.x - p0.x, p1.y - p0.y)
    height: thickness
    rotation: Ann.angle(p0, p1)
    transformOrigin: Item.Left
    antialiasing: true
  }

  Component {
    id: strip
    Band {
      p0: root.mark.a
      p1: root.mark.b
      thickness: root.mark.thickness
      radius: root.mark.radius
      color: root.mark.color
      opacity: root.mark.opacity
    }
  }

  Component {
    id: rectangle
    Rectangle {
      x: root.mark.x
      y: root.mark.y
      width: root.mark.width
      height: root.mark.height
      radius: root.mark.radius
      color: "transparent"
      border.width: root.mark.strokeWidth
      border.color: root.mark.color
      antialiasing: true
    }
  }

  Component {
    id: arrow
    Item {
      Band {
        p0: root.mark.a
        p1: root.mark.b
        thickness: root.mark.strokeWidth
        radius: root.mark.radius
        color: root.mark.color
      }
      Image {
        x: root.mark.b.x - width / 2
        y: root.mark.b.y - height / 2
        width: root.mark.head
        height: root.mark.head
        rotation: Ann.angle(root.mark.a, root.mark.b)
        source: Qt.resolvedUrl("../icons/chevron-right.svg")
        // Rasterizo com o dobro dos pixels do lado: a ponta tem de continuar nítida quando a imagem sai em tamanho natural.
        sourceSize: Qt.size(Math.ceil(root.mark.head * 2), Math.ceil(root.mark.head * 2))
        fillMode: Image.PreserveAspectFit
        smooth: true
        // Os ícones de icons/ são brancos e a cor vem da colorização.
        layer.enabled: true
        layer.effect: MultiEffect {
          colorization: 1
          colorizationColor: root.mark.color
        }
      }
    }
  }

  Component {
    id: label
    Text {
      x: root.mark.x
      y: root.mark.y
      text: root.mark.text
      color: root.mark.color
      font.family: Theme.fontFamily
      font.weight: Font.DemiBold
      font.pixelSize: root.mark.size
      font.letterSpacing: 0
    }
  }
}
