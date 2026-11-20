import QtQuick
import ".."

// Uma janela de aplicativo inventada, dado de exemplo e não peça da shell. É o desenho único que o espécime da captura
// (demo/CaptureSpecimen.qml) e o espécime do desktop (demo/DesktopSpecimen.qml) usam para ter o que a shell mostra por cima do
// fundo: o corpo é #1B1D22, a barra de título #24262C, raio 12 e borda de 1 em Theme.border. Os valores padrão são os das janelas
// do palco da captura; o desktop passa os do board dos desktops (ficha 19, 13:20899). Sem texto: nada de dado da máquina.
//   name         o nome fictício ("Browser" ou "Terminal"); só o "Browser" ganha a imagem de degradê
//   titleHeight  a altura da barra de título, abaixo da borda de cima de 1 (padrão 32; o board do desktop tem 40 contando a borda: 39)
//   imageInset   o recuo da imagem nas duas laterais (padrão 16) e o x das linhas
//   imageTop     o y da imagem (padrão 52)
//   imageHeight  a altura da imagem (padrão 120)
//   imageRadius  o raio da imagem (padrão 8)
//   lines        as linhas de texto de mentira abaixo da imagem, como [{ y, width }] (padrão: nenhuma); altura 10, raio 5 e cor Theme.raised (a do board, medida no PNG: #1F2023)
Rectangle {
  id: root

  property string name: ""
  property real titleHeight: 32
  property real imageInset: 16
  property real imageTop: 52
  property real imageHeight: 120
  property real imageRadius: 8
  property var lines: []

  radius: 12
  color: "#1B1D22"
  border.width: 1
  border.color: Theme.border

  Rectangle {
    x: 1
    y: 1
    width: parent.width - 2
    height: root.titleHeight
    topLeftRadius: 11
    topRightRadius: 11
    color: "#24262C"
  }

  Rectangle {
    visible: root.name === "Browser"
    x: root.imageInset
    y: root.imageTop
    width: parent.width - 2 * root.imageInset
    height: root.imageHeight
    radius: root.imageRadius
    gradient: Gradient {
      orientation: Gradient.Horizontal
      GradientStop { position: 0; color: "#12283E" }
      GradientStop { position: 0.5; color: "#3FA9D9" }
      GradientStop { position: 1; color: "#F4A846" }
    }
  }

  Repeater {
    model: root.name === "Browser" ? root.lines : []

    delegate: Rectangle {
      required property var modelData

      x: root.imageInset
      y: modelData.y
      width: modelData.width
      height: 10
      radius: 5
      color: Theme.raised
    }
  }
}
