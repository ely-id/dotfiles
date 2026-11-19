import QtQuick

// O serviço fictício da prévia da captura (decisão 0011, ficha 17, estado 4): a mesma superfície de screenshot/State.qml
// (`imageSource`, `outputName`, `generation`, `copied`, `dragging`, `hovered`, `receive`, `copy`, `save`, `annotate`, `dismiss`),
// sem ler arquivo, sem área de transferência e sem relógio de sumir. Copiar, salvar, anotar e fechar só contam, porque a vitrine
// não copia, não salva nem apaga a prévia. `copied` é do espécime (é ele que mostra o "copiado").
QtObject {
  id: root

  // Um desenho inventado, nada da máquina: um céu em degradê, um sol e duas colinas, na proporção da miniatura (312×224, o dobro
  // de 156×112). É dado de exemplo, não desenho da peça.
  readonly property string drawing:
      "<svg xmlns='http://www.w3.org/2000/svg' width='312' height='224' viewBox='0 0 312 224'>"
      + "<defs><linearGradient id='g' x1='0' y1='0' x2='0' y2='1'>"
      + "<stop offset='0' stop-color='#2B3A67'/><stop offset='1' stop-color='#E8A87C'/></linearGradient></defs>"
      + "<rect width='312' height='224' fill='url(#g)'/>"
      + "<circle cx='226' cy='84' r='30' fill='#FBE7C6'/>"
      + "<path d='M0 170 Q70 110 150 160 T312 150 V224 H0Z' fill='#41506B'/>"
      + "<path d='M0 196 Q90 150 190 192 T312 184 V224 H0Z' fill='#1F2A44'/>"
      + "</svg>"
  property string imageSource: "data:image/svg+xml;utf8," + encodeURIComponent(drawing)
  property string outputName: "demo"
  property int generation: 0
  property bool copied: false
  property bool dragging: false
  property bool hovered: false

  // Quantas vezes pediram cada coisa (para o teste de comportamento).
  property int receiveCount: 0
  property int copyCount: 0
  property int saveCount: 0
  property int annotateCount: 0
  property int dismissCount: 0

  function receive(path, output) { ++receiveCount; }
  function copy() { ++copyCount; }
  function save() { ++saveCount; }
  function annotate() { ++annotateCount; }
  function dismiss() { ++dismissCount; }
}
