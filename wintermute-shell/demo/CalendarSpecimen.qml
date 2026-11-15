import QtQuick
import ".."
import "../calendar" as Calendar

// O calendário de verdade (calendar/Card.qml) com a data fixa em 13 de novembro de 2026,
// o mesmo dia da prévia da ficha 09. `browseMonths` empurra o mês exibido (0 = o do dia fixo).
Item {
  id: root
  property int browseMonths: 0
  implicitWidth: 264
  implicitHeight: 296

  Shadow {
    anchors.fill: card
    cornerRadius: card.radius
    shadows: Theme.glassShadows
  }
  Calendar.Card {
    id: card
    today: new Date(2026, 10, 13, 12)
    Component.onCompleted: if (root.browseMonths !== 0) moveMonth(root.browseMonths)
  }
}
