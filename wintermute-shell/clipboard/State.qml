pragma Singleton

import QtQuick
import Quickshell

// O estado do histórico da área de transferência (ficha 18). É a superfície que a peça lê (decisão 0011); demo/ClipboardService.qml
// tem os mesmos nomes. Por enquanto ele existe vazio: `items` não tem nada e as três funções só avisam no log, para o chip
// "Clipboard" do launcher já abrir a página, no estado vazio. Escutar a área de transferência, guardar os 50 itens da sessão, o
// Super+V e o "Clear history" são da F6-T16.
//
// Cada item é { id, kind, title, text, source, time, pinned, pinnedTime, image: { url, width, height, format, bytes }, color,
// linkTitle }, do mais novo para o mais antigo. `now` é o relógio da peça para o tempo relativo ("2 min"), em milissegundos.
Singleton {
  id: root

  property var items: []
  readonly property real now: clock.now

  // Devolve o item à área de transferência (Enter na peça, e o launcher fecha).
  function copy(item) {
    console.info("clipboard: copiar ainda é da F6-T16:", item ? item.id : "");
  }

  // Fixa o item, ou solta se já estava fixo (Ctrl+P).
  function togglePin(item) {
    console.info("clipboard: fixar ainda é da F6-T16:", item ? item.id : "");
  }

  // Tira o item do histórico (Del).
  function remove(item) {
    console.info("clipboard: apagar ainda é da F6-T16:", item ? item.id : "");
  }

  // Um relógio que avança de minuto em minuto, para o "2 min" não ficar parado com a página aberta.
  QtObject {
    id: clock
    property real now: Date.now()
  }

  Timer {
    interval: 60 * 1000
    running: true
    repeat: true
    onTriggered: clock.now = Date.now()
  }
}
