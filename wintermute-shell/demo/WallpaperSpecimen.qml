import QtQuick
import "../settings/appearance" as Appearance

// O seletor de papel de parede (settings/appearance/WallpaperPicker.qml) de verdade, com o serviço
// fictício de demo/AppearanceService.qml, no quadro do board 13:16208 (modal de 624×608; o botão de
// fechar pendura 13 acima e 20 à direita, então o quadro tem 644×621).
// `selected`: "dynamic" ou o nome da imagem em minúsculas ("chiba", "freeside", "sprawl").
// `hoverIndex`: miniatura em hover (0 Choose an image, 1 Dynamic, 2 Chiba, 3 Freeside, 4 Sprawl; -1 nenhuma).
// `error`: texto de erro; vazio não mostra a mensagem.
Item {
  id: root
  property string selected: "dynamic"
  property int hoverIndex: -1
  property string error: ""

  implicitWidth: 644
  implicitHeight: 621

  AppearanceService {
    id: demoService
    error: root.error
    wallpaperMode: root.selected === "dynamic" ? "dynamic" : "custom"
    wallpaperPath: root.selected === "dynamic" ? "" : demoService.pathOf(root.selected)
  }

  Appearance.WallpaperPicker {
    y: 13
    service: demoService
    hoverIndex: root.hoverIndex
  }
}
