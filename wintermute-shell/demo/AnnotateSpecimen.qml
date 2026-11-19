import QtQuick
import ".."
import "../screenshot" as Screenshot

// O editor de anotação de verdade (screenshot/Annotate.qml) com um serviço fictício (ficha 17, estado 5, board 13:19344, nó 13:19481): o
// vidro de 720×480 com a barra e a área da imagem. A imagem é um desenho inventado (uma tela com duas janelas, as do board), e as quatro
// marcas de exemplo são as do board: a faixa de marca-texto, o retângulo, a seta e o texto. Nada disto é desenho da peça: são dados de exemplo.
// As marcas do espécime estão em pixels da imagem, como as de verdade.
//   scene     "board" (o estado do board: 688×408, retângulo selecionado, a primeira cor e as quatro marcas), "empty" (a mesma imagem, sem
//             marcas, com o lápis), "pencil" (um traço de lápis na cor do acento), "small" (uma imagem de 400×260, menor que a área, no
//             tamanho natural e centrada) ou "large" (a imagem de 1376×816, reduzida à metade para caber, com as quatro marcas do board
//             em pixels da imagem: o traço sai com a espessura da tela dividida pela escala)
//   tool      a ferramenta à abertura: "pencil", "highlighter", "rectangle", "arrow", "text" ou "crop" (padrão: a da cena)
//   colorIndex  a cor à abertura (0 a 4; padrão: a da cena)
//   typing    um texto em andamento (o campo de texto da tela, com o cursor), no ponto (typingX, typingY) da área da imagem
//   cropX, cropY, cropW, cropH  um recorte em andamento, em pixels da área da imagem (cropW 0: nenhum); a ferramenta é a de recorte
Item {
  id: root

  property string scene: "board"
  property string tool: ""
  property int colorIndex: -1
  property string typing: ""
  property real typingX: 330
  property real typingY: 20
  property real cropX: 0
  property real cropY: 0
  property real cropW: 0
  property real cropH: 0

  implicitWidth: Theme.captureAnnotateWidth
  implicitHeight: Theme.captureAnnotateHeight

  // Para o teste de comportamento.
  readonly property alias piece: piece
  readonly property alias service: demoService

  // A escala da cena: a de 1376×816 é o dobro da de 688×408.
  readonly property real k: scene === "large" ? 2 : 1

  // O texto de exemplo mede aqui, no mesmo tipo de letra da marca, para a marca do board terminar onde o board a termina: o texto do board
  // é alinhado à direita, com a borda direita em x 232 e o meio da altura em y 302.
  Text {
    id: probe
    visible: false
    text: "Look here"
    font.family: Theme.fontFamily
    font.weight: Font.DemiBold
    font.pixelSize: Theme.captureAnnotateFontSize
  }

  function boardMarks(f) {
    const orange = String(Theme.captureAnnotateColors[0]);
    const yellow = String(Theme.captureAnnotateColors[1]);
    const textWidth = probe.implicitWidth;
    const textHeight = probe.implicitHeight;
    return [
      // 13:19521: faixa de 200×20 em (48,116), amarela a 35%.
      { type: "highlight", color: yellow, opacity: Theme.captureAnnotateHighlightOpacity, thickness: Theme.captureAnnotateThickness * f,
          radius: Theme.captureAnnotateStripRadius * f, a: { x: 48 * f, y: 126 * f }, b: { x: 248 * f, y: 126 * f } },
      // 13:19522: contorno de 3 em (360,96), 284×148, raio 8.
      { type: "rect", color: orange, strokeWidth: Theme.captureAnnotateStrokeWidth * f, radius: Theme.captureAnnotateRectRadius * f,
          x: 360 * f, y: 96 * f, width: 284 * f, height: 148 * f },
      // 13:19523 e 13:19524: haste de 104×3 em (236,300) e a ponta de 20 centrada no fim dela.
      { type: "arrow", color: orange, strokeWidth: Theme.captureAnnotateStrokeWidth * f, radius: Theme.captureAnnotateStripRadius * f,
          head: Theme.captureAnnotateHeadSize * f, a: { x: 236 * f, y: 301.5 * f }, b: { x: 340 * f, y: 301.5 * f } },
      // 13:19525: texto de 17 SemiBold, à direita de x 232 e centrado em y 302.
      { type: "text", color: orange, size: Theme.captureAnnotateFontSize * f, text: probe.text,
          x: (232 - textWidth) * f, y: (302 - textHeight / 2) * f, width: textWidth * f, height: textHeight * f }
    ];
  }

  // Um traço de lápis inventado: uma linha ondulada sobre o texto de uma das janelas, na cor do acento.
  function squiggle() {
    const points = [];
    for (let x = 372; x <= 628; x += 4)
      points.push({ x: x, y: 262 + 6 * Math.sin(x / 9) });
    return [{ type: "pencil", color: String(Theme.captureAnnotateColors[2]), width: Theme.captureAnnotatePencilWidth, points: points }];
  }

  // A imagem inventada de 688×408 do board, em SVG: o degradê linear de 156° e os cinco brilhos radiais do fundo, e as duas janelas
  // (Ghostty e Firefox) com a barra de título, o texto e os blocos. Sem a sombra das janelas: o SVG do Qt não tem filtros.
  function boardSvg(width, height) {
    const blob = (cx, cy, rx, ry, color, alpha) => "<ellipse cx='" + cx + "' cy='" + cy + "' rx='" + rx + "' ry='" + ry + "' fill='url(#b" + color.replace(/,/g, "") + ")'/>";
    const grad = (rgb, alpha) => "<radialGradient id='b" + rgb.replace(/,/g, "") + "'><stop offset='0' stop-color='rgb(" + rgb + ")' stop-opacity='" + alpha + "'/><stop offset='1' stop-color='rgb(" + rgb + ")' stop-opacity='0'/></radialGradient>";
    const mono = (x, y, text, fill) => "<text x='" + x + "' y='" + (y + 4) + "' font-family='Geist Mono' font-weight='500' font-size='11' fill='" + fill + "' xml:space='preserve'>" + text + "</text>";
    const label = (x, y, text) => "<text x='" + x + "' y='" + (y + 4) + "' font-family='Geist' font-weight='500' font-size='11' fill='#C2C4C7'>" + text + "</text>";
    const win = (id, x, y, w, h) => "<clipPath id='" + id + "'><rect x='" + x + "' y='" + y + "' width='" + w + "' height='" + h + "' rx='12'/></clipPath>"
        + "<rect x='" + x + "' y='" + y + "' width='" + w + "' height='" + h + "' rx='12' fill='#16181D'/>"
        + "<rect x='" + x + "' y='" + y + "' width='" + w + "' height='32' fill='#1E2026' clip-path='url(#" + id + ")'/>"
        + "<rect x='" + (x + 0.5) + "' y='" + (y + 0.5) + "' width='" + (w - 1) + "' height='" + (h - 1) + "' rx='11.5' fill='none' stroke='#FFFFFF' stroke-opacity='0.1'/>";
    return "<svg xmlns='http://www.w3.org/2000/svg' width='" + width + "' height='" + height + "' viewBox='0 0 688 408'>"
        + "<defs>"
        + "<linearGradient id='bg' gradientUnits='userSpaceOnUse' x1='211.1' y1='-94.4' x2='476.9' y2='502.4'>"
        + "<stop offset='0' stop-color='rgb(7,8,11)'/><stop offset='0.714' stop-color='rgb(16,19,28)'/></linearGradient>"
        + grad("18,59,68", 0.9) + grad("58,35,80", 0.85) + grad("26,38,80", 0.9) + grad("74,46,28", 0.55) + grad("90,140,168", 0.35)
        + "<linearGradient id='shot' x1='0' y1='0' x2='1' y2='0'><stop offset='0' stop-color='#12283E'/><stop offset='0.5' stop-color='#3FA9D9'/><stop offset='1' stop-color='#F4A846'/></linearGradient>"
        + "</defs>"
        + "<rect width='688' height='408' fill='url(#bg)'/>"
        + blob(550.4, 346.8, 240.8, 224.4, "18,59,68") + blob(584.8, 40.8, 206.4, 183.6, "58,35,80") + blob(103.2, 326.4, 240.8, 204, "26,38,80")
        + blob(288.96, 114.24, 110.08, 102, "74,46,28") + blob(577.92, 285.6, 55.04, 48.96, "90,140,168")
        // Ghostty: (36,36) 296×216.
        + win("w1", 36, 36, 296, 216) + label(48, 52, "Ghostty")
        + mono(52, 90, "~ ❯ niri msg workspaces", "#F2F3F5") + mono(52, 110, "  1  2* 3", "#C2C4C7") + mono(52, 130, "~ ❯ fastfetch", "#F2F3F5")
        + mono(52, 150, "  CachyOS · niri", "#C2C4C7") + mono(52, 170, "~ ❯ _", "#F2F3F5")
        // Firefox: (352,48) 300×312.
        + win("w2", 352, 48, 300, 312) + label(364, 64, "Firefox")
        + "<rect x='368' y='96' width='268' height='140' rx='8' fill='url(#shot)'/>"
        + "<rect x='368' y='252' width='240' height='8' rx='2' fill='#1F2023'/><rect x='368' y='268' width='200' height='8' rx='2' fill='#1F2023'/>"
        + "<rect x='368' y='284' width='160' height='8' rx='2' fill='#1F2023'/>"
        + "</svg>";
  }

  // A imagem pequena: 400×260, uma janela só sobre o degradê.
  function smallSvg() {
    return "<svg xmlns='http://www.w3.org/2000/svg' width='400' height='260' viewBox='0 0 400 260'>"
        + "<defs><linearGradient id='bg' x1='0' y1='0' x2='1' y2='1'><stop offset='0' stop-color='#1A2650'/><stop offset='1' stop-color='#4A2E1C'/></linearGradient></defs>"
        + "<rect width='400' height='260' fill='url(#bg)'/>"
        + "<rect x='40' y='40' width='240' height='150' rx='12' fill='#16181D'/><rect x='40' y='40' width='240' height='32' rx='12' fill='#1E2026'/>"
        + "<rect x='56' y='92' width='208' height='8' rx='2' fill='#1F2023'/><rect x='56' y='108' width='160' height='8' rx='2' fill='#1F2023'/>"
        + "</svg>";
  }

  function dataUri(svg) {
    return "data:image/svg+xml;utf8," + encodeURIComponent(svg);
  }

  AnnotateService {
    id: demoService
    imageSource: root.scene === "small" ? root.dataUri(root.smallSvg())
        : root.scene === "large" ? root.dataUri(root.boardSvg(688 * 2, 408 * 2))
        : root.dataUri(root.boardSvg(688, 408))
    initialMarks: root.scene === "board" ? root.boardMarks(1)
        : root.scene === "large" ? root.boardMarks(2)
        : root.scene === "pencil" ? root.squiggle() : []
    tool: root.tool !== "" ? root.tool
        : root.scene === "board" || root.scene === "large" ? "rectangle" : "pencil"
    colorIndex: root.colorIndex >= 0 ? root.colorIndex : root.scene === "pencil" ? 2 : 0
  }

  Screenshot.Annotate {
    id: piece
    service: demoService
  }

  // O texto e o recorte em andamento são do ponteiro, e a vitrine os fixa depois de a imagem carregar.
  Connections {
    target: demoService.document
    function onReadyChanged() {
      if (demoService.document.ready)
        Qt.callLater(root.applyFixtures);
    }
  }

  function applyFixtures() {
    if (cropW > 0) {
      demoService.document.setTool("crop");
      piece.canvas.cropRect = { x: cropX, y: cropY, width: cropW, height: cropH };
    }
    if (typing !== "") {
      demoService.document.setTool("text");
      piece.canvas.beginText(typingX, typingY);
      piece.canvas.input.text = typing;
    }
  }
}
