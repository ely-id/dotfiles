import QtQuick
import ".."
import "../screenshot" as Screenshot

// A prévia da captura de verdade (screenshot/Preview.qml) com um serviço fictício (ficha 17, estado 4, board 13:19344): a miniatura
// de 156×112, ou o quadrado de 48×48 com a barra recolhida. A imagem é um desenho inventado, não uma captura.
//   hover        o ponteiro está sobre a prévia (o véu e os botões). Padrão: não, para os prints saírem fixos
//   hoverButton  o botão sob o ponteiro: "copy", "save", "annotate" ou "dismiss" (recolhida, só "copy")
//   copied       o botão de copiar mostra o `check` em `successText` (o "copiado")
//   collapsed    a barra recolhida: 48×48, sem sombra, e no hover só o botão de copiar
//   mouse        deixa o ponteiro de verdade mandar (o hover e os botões respondem ao mouse); sem isso o hover é o fixado
Item {
  id: root

  property bool hover: false
  property string hoverButton: ""
  property bool copied: false
  property bool collapsed: false
  property bool mouse: false

  implicitWidth: preview.width
  implicitHeight: preview.height

  // Para o teste de comportamento.
  readonly property alias preview: preview
  readonly property alias service: demoService

  ScreenshotService {
    id: demoService
    copied: root.copied
  }

  Screenshot.Preview {
    id: preview
    outputName: demoService.outputName
    service: demoService
    collapsed: root.collapsed
    hoverPinned: !root.mouse && (root.hover || root.hoverButton !== "")
    hoverButton: root.hoverButton
  }
}
