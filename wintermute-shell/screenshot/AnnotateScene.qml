pragma ComponentBehavior: Bound

import QtQuick
import "." as Screenshot

// A imagem com as marcas, em pixels da imagem (ficha 17, estado 5, F6-T14): o `Image` do arquivo e, por cima, uma `AnnotateMark` para
// cada marca do documento. Tem o tamanho da imagem (depois do recorte), sem nenhuma escala: quem a mostra reduzida é a tela
// (AnnotateCanvas.qml, que a põe dentro de um item com `scale`), e quem a exporta é o FrameCropper.qml, que lê esta cena do jeito que
// ela é, em pixels da imagem. Por isso a mesma cena serve à tela e ao arquivo.
//
// Antes de o documento existir (`state` nulo) a cena tem tamanho zero, mas o `Image` já carrega: é ele que diz à peça o tamanho da imagem.
// O recorte é só uma janela sobre a imagem inteira: o `Image` fica no tamanho dele, deslocado pela origem, e a cena recorta o resto.
Item {
  id: root

  property string imageSource: ""
  // O documento do Annotate.js (`state`), ou null.
  property var state: null
  // A marca que o arraste ainda está desenhando, ou null.
  property var draft: null

  readonly property alias image: image

  width: state ? state.width : 0
  height: state ? state.height : 0
  clip: true

  Image {
    id: image
    x: root.state ? -root.state.origin.x : 0
    y: root.state ? -root.state.origin.y : 0
    source: root.imageSource
    // Sem o `sourceSize`, a imagem carrega no tamanho dela. Sem cache: a captura de agora não pode vir de uma de antes com o mesmo nome.
    cache: false
    asynchronous: false
    smooth: true
    mipmap: true
  }

  Repeater {
    model: root.state ? (root.draft ? root.state.marks.concat([root.draft]) : root.state.marks) : []

    delegate: Screenshot.AnnotateMark {
      required property var modelData
      mark: modelData
    }
  }
}
