import QtQuick
import ".."

// Fila de chips da seção "Tools" do launcher (ficha 14, estado vazio): chips do componente Chip da ficha 00
// lado a lado, 8 entre eles, cada um com a largura do próprio conteúdo. `model` é a lista de
// { key, label, icon } que o serviço oferece. O chip com o foco do teclado usa o estado selecionado do Chip
// (P-72); `hoverIndex` fixa o hover na vitrine (o Chip trava o próprio ponteiro quando recebe um estado).
Row {
  id: root

  property var model: []
  // Chip com o foco do teclado, ou -1.
  property int selectedIndex: -1
  // Para fixar o hover na vitrine.
  property int hoverIndex: -1

  signal activated(string key)

  spacing: Theme.launcherChipSpacing

  Repeater {
    model: root.model

    delegate: Chip {
      required property var modelData
      required property int index
      text: modelData.label
      iconName: modelData.icon
      selected: index === root.selectedIndex
      visualState: index === root.hoverIndex ? "hover" : ""
      onClicked: root.activated(modelData.key)
    }
  }
}
