import QtQuick

// Cartão do OSD de brilho e volume (ficha 10): 156×36, raio 16. Ícone Lucide de 16 em (12,10) e 10
// pontos 6×6 a cada 10 px, a partir de x 42, y 15. Acesos em `text`, apagados em `dot`.
// P-08: brilho e volume não têm 10 níveis reais, então o valor é arredondado para o ponto mais
// próximo e, se for maior que zero, acende pelo menos 1 ponto (1% a 4% não pode parecer mudo).
Card {
  id: root
  property string iconName: "sun"
  property real value: 0
  // O padrão é o percentual; o OSD de brilho que falhou (P-62) troca por um texto de alerta.
  property string accessibleName: Math.round(Theme.clamp01(value) * 100) + "%"
  readonly property int litDots: value <= 0 ? 0 : Math.max(1, Math.round(Theme.clamp01(value) * 10))

  width: Theme.sidebarCardExpandedWidth
  height: 36
  radius: Theme.radiusCard
  hoverEnabled: false
  Accessible.role: Accessible.ProgressBar
  Accessible.name: accessibleName

  Image {
    x: 12; y: 10
    width: 16; height: 16
    source: Qt.resolvedUrl("icons/" + root.iconName + ".svg")
    sourceSize: Qt.size(32, 32)
    fillMode: Image.PreserveAspectFit
    smooth: true
  }

  Repeater {
    model: 10
    Rectangle {
      required property int index
      x: 42 + index * 10
      y: 15
      width: 6
      height: 6
      radius: 3
      color: index < root.litDots ? Theme.text : Theme.dot
      antialiasing: true
    }
  }
}
