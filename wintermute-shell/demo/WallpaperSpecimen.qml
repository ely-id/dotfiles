import QtQuick
import "../settings/appearance" as Appearance

// O seletor de papel de parede (settings/appearance/WallpaperPicker.qml) de verdade, com o serviço
// fictício de demo/AppearanceService.qml, no quadro do board 13:16208 (modal de 624×608; o botão de
// fechar pendura 13 acima e 20 à direita, então o quadro tem 644×621).
// `selected`: "dynamic", o nome da imagem em minúsculas ("chiba", "freeside", "sprawl") ou o número de
// uma acrescentada com duas casas ("01").
// `hoverIndex`: miniatura em hover (0 Choose an image, 1 Dynamic, 2 Chiba, 3 Freeside, 4 Sprawl,
// 5 em diante as acrescentadas, 5 é a 01; -1 nenhuma).
// `extras`: quantas acrescentadas numeradas o serviço fictício devolve (padrão 0).
// `scroll`: rolagem inicial da grade em px, só para a vitrine e a bancada; um valor grande para no fim.
// `error`: texto de erro; vazio não mostra a mensagem.
Item {
  id: root
  property string selected: "dynamic"
  property int hoverIndex: -1
  property int extras: 0
  property real scroll: 0
  property string error: ""

  implicitWidth: 644
  implicitHeight: 621

  AppearanceService {
    id: demoService
    error: root.error
    extras: root.extras
    wallpaperMode: root.selected === "dynamic" ? "dynamic" : "custom"
    wallpaperPath: root.selected === "dynamic" ? "" : demoService.pathOf(root.selected)
  }

  Appearance.WallpaperPicker {
    id: picker
    y: 13
    service: demoService
    hoverIndex: root.hoverIndex
  }
  // Rolagem inicial, limitada ao fim da grade.
  Binding {
    target: picker.scrollItem
    property: "contentY"
    value: Math.min(root.scroll, Math.max(0, picker.contentHeight - picker.scrollItem.height))
    when: root.scroll > 0
  }
}
