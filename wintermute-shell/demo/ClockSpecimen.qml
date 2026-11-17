import QtQuick
import "../calendar" as Calendar

// O relógio de verdade (calendar/Clock.qml), aberto (156 de largura), com bateria fictícia.
// `time` é a hora em texto ("23:33") e vira o previewTime; serve para gravar o pior caso,
// a hora mais larga, na bancada. O dia é fixo (13 de novembro de 2026, o da prévia da ficha).
Item {
  id: root
  property string time: "23:33"
  readonly property var parts: time.split(":")

  implicitWidth: 156
  implicitHeight: clock.height

  Calendar.Clock {
    id: clock
    width: 156
    previewBattery: true
    previewTime: new Date(2026, 10, 13, Number(root.parts[0]), Number(root.parts[1]))
  }
}
