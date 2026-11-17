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
// Os papéis de parede por lugar (F4-T24, P-67):
// `customizing`: o cartão Customize na frente do seletor, a pilha parada (sem animar). O quadro cresce
//   para a pilha caber: 13 acima + 32 da carta de trás + a altura do cartão (228, 348 ou 468 com 0, 2 ou 4
//   linhas); o botão de fechar do cartão fica dentro do quadro. `scroll` não vale na pilha.
// `stacked`: o seletor dentro da pilha, sem o cartão; sai igual ao seletor sozinho (serve para conferir).
// `followScheme` e `perDisplay`: as duas chaves do cartão. Os monitores fictícios são o eDP-1 e o DP-1.
// `places`: a escolha de cada lugar, por chave ("light", "dark", "display:eDP-1", "display:DP-1:dark") e
//   com os mesmos nomes de imagem que `selected` aceita ("dynamic", "chiba", "01"...); lugar sem entrada
//   usa o marcado na grade (`selected`).
// `choosing`: a chave do lugar para o qual a grade está escolhendo ("" nenhum): título com o nome do
//   lugar, sem o botão "Customize", anel e marca no que vale ali.
// `hoverRow`: hover fixo numa linha do cartão ("follow", "per-display" ou a chave de um lugar).
Item {
  id: root
  property string selected: "dynamic"
  property int hoverIndex: -1
  property int extras: 0
  property real scroll: 0
  property string error: ""
  property bool customizing: false
  property bool stacked: false
  property bool followScheme: false
  property bool perDisplay: false
  property var places: ({})
  property string choosing: ""
  property string hoverRow: ""

  readonly property bool useStack: customizing || stacked

  implicitWidth: 644
  implicitHeight: useStack ? 13 + (stackLoader.item ? stackLoader.item.implicitHeight : 608) : 621

  AppearanceService {
    id: demoService
    error: root.error
    extras: root.extras
    wallpaperMode: root.selected === "dynamic" ? "dynamic" : "custom"
    wallpaperPath: root.selected === "dynamic" ? "" : demoService.pathOf(root.selected)
    followScheme: root.followScheme
    perDisplay: root.perDisplay
    choosingPlace: root.choosing
    places: {
      const result = {};
      Object.keys(root.places).forEach(key => { result[key] = demoService.entryOf(root.places[key]); });
      return result;
    }
  }

  Loader {
    id: pickerLoader
    y: 13
    active: !root.useStack
    sourceComponent: Appearance.WallpaperPicker {
      service: demoService
      hoverIndex: root.hoverIndex
    }
  }
  Loader {
    id: stackLoader
    y: 13
    active: root.useStack
    sourceComponent: Appearance.WallpaperStack {
      service: demoService
      customizing: root.customizing
      hoverRow: root.hoverRow
      hoverIndex: root.hoverIndex
    }
  }
  // Rolagem inicial, limitada ao fim da grade.
  Binding {
    target: pickerLoader.item ? pickerLoader.item.scrollItem : null
    property: "contentY"
    value: pickerLoader.item
        ? Math.min(root.scroll, Math.max(0, pickerLoader.item.contentHeight - pickerLoader.item.scrollItem.height)) : 0
    when: root.scroll > 0 && !!pickerLoader.item
  }
}
