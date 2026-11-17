pragma ComponentBehavior: Bound
import QtQuick
import "." as Notifications
import ".." as Shell

// Painel da central de notificações (ficha 10), 280 de largura. Com 2 ou mais notificações é uma
// lista de vidro r16 com cabeçalho de 60 ("N notificações" em Serif 20 em (16,16) e "Limpar tudo"
// muted à direita), divisor de largura total em y 60 e respiro de 22 embaixo; com 1, é só o cartão.
// `service` é o estado das notificações; a vitrine troca por um fictício.
Item {
  id: root

  property var service: Notifications.State
  property var items: service.historyNotifications
  property real reveal: 1
  readonly property int itemCount: items.length
  readonly property bool listMode: itemCount >= 2
  // Altura da lista que o ListView mediu por último. Zero só até a primeira medida existir.
  // Antes eu só aceitava a medida quando `measuredItemCount === itemCount`. Só que, quando o número de
  // itens muda, o ListView atualiza o `contentHeight` antes de o `itemCount` ser reavaliado, então por
  // um passo a medida nova não "batia" com a contagem e a altura caía na estimativa `itens × rowHeight`
  // (88, bem acima das linhas reais) e depois descia para a medida: o painel crescia e encolhia a cada
  // item removido, e o `CenterWindow` ainda recentrava o `panelTop` junto. Agora a estimativa só vale
  // enquanto nunca houve medida; depois disso a medida anterior fica de pé até a nova chegar, e o painel
  // vai da altura antiga direto para a nova. Sem itens a lista não ocupa nada, então esse caso não olha a
  // medida. A mesma troca corrige o "limpar tudo": a medida só era guardada com a contagem batendo, então
  // a primeira notificação depois de limpar deixava o painel preso em 88 (a estimativa) em vez dos 72 medidos.
  property real measuredListHeight: 0
  readonly property real effectiveListHeight: itemCount === 0 ? 0
      : measuredListHeight > 0 ? measuredListHeight : itemCount * Notifications.Style.rowHeight
  readonly property real panelHeight: listMode
      ? Math.min(Notifications.Style.panelHeaderHeight + effectiveListHeight
                 + Notifications.Style.panelBottomPadding,
                 Notifications.Style.panelMaxHeight)
      : effectiveListHeight
  readonly property alias background: panelBackground

  width: Notifications.Style.panelWidth
  height: panelHeight
  opacity: reveal

  Shell.Shadow {
    anchors.fill: panelBackground
    cornerRadius: panelBackground.radius
    shadows: Shell.Theme.glassShadows
    visible: root.itemCount > 0
  }

  Rectangle {
    id: panelBackground
    width: root.width
    height: root.panelHeight
    radius: Notifications.Style.radius
    color: "transparent"
    antialiasing: true
    visible: root.listMode
    Shell.GradientFill { radius: panelBackground.radius }
    Shell.PanelBorder { radius: panelBackground.radius }
  }

  Text {
    x: Notifications.Style.contentPadding
    y: Notifications.Style.contentPadding
    height: 28
    text: root.itemCount + " notifications"
    color: Shell.Theme.text
    font.family: Shell.Theme.titleFontFamily
    font.weight: Font.Normal
    font.pixelSize: Shell.Theme.fontPanelTitle
    font.letterSpacing: 0
    visible: root.listMode
    z: 3
  }

  Text {
    id: clearAll
    x: root.width - Notifications.Style.contentPadding - width
    y: 21
    height: 19
    text: "Clear all"
    color: clearPointer.containsMouse ? Shell.Theme.text : Shell.Theme.muted
    font.family: Shell.Theme.fontFamily
    font.weight: Font.Medium
    font.pixelSize: Shell.Theme.fontBody
    font.letterSpacing: 0
    visible: root.listMode
    z: 4

    Behavior on color { ColorAnimation { duration: Shell.Theme.hoverDuration } }

    MouseArea {
      id: clearPointer
      anchors.fill: parent
      anchors.margins: -8
      hoverEnabled: true
      acceptedButtons: Qt.LeftButton
      cursorShape: Qt.PointingHandCursor
      onClicked: root.service.clearAll()
    }
  }

  Rectangle {
    x: 0
    y: Notifications.Style.panelHeaderHeight
    width: root.width
    height: 1
    color: Notifications.Style.divider
    visible: root.listMode
    z: 3
  }

  Item {
    id: listClip
    y: root.listMode ? Notifications.Style.panelHeaderHeight : 0
    width: root.width
    height: root.panelHeight - y - (root.listMode ? Notifications.Style.panelBottomPadding : 0)
    clip: true
    z: 3

    ListView {
      id: notificationList
      clip: true
      boundsBehavior: Flickable.StopAtBounds
      Shell.ScrollWheel { view: notificationList }
      width: root.width
      height: listClip.height
      model: root.items
      interactive: contentHeight > height
      onContentHeightChanged: {
        if (contentHeight > 0) root.measuredListHeight = contentHeight;
      }

      delegate: Notifications.Card {
        id: row
        required property var modelData
        required property int index

        service: root.service
        width: root.width
        height: implicitHeight
        notification: modelData
        // Uso `count` do próprio ListView, sem olhar `listMode` nem `itemCount`: os dois derivam de
        // `items` e ainda estão com o valor velho na hora em que a linha nasce. Com o `itemCount` velho,
        // a última linha nascia com divisor e o perdia logo depois; com o `listMode` velho (1 para 2,
        // 0 para 3), a linha nascia sem divisor e ganhava 1 px depois. Nos dois casos a animação de
        // altura do cartão (180 ms) fazia o painel encolher ou crescer 1 px (243,88 para 243; 226 para
        // 227) depois de já ter assentado, e o `panelTop` recentrava junto. `index < count - 1` já
        // exige 2 itens ou mais, então o `listMode` não faz falta.
        showDivider: index < notificationList.count - 1
        panelRow: root.listMode
        onActivated: root.service.activate(modelData)
        onDismissed: root.service.remove(modelData)
      }
    }
  }
}
