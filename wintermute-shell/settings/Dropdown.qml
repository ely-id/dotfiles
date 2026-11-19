pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import QtQuick.Controls
import ".." as Shell

// Menu suspenso dos Ajustes (Tela, Bloqueio e suspensão, bandeja). Não tem board no Figma: é composição
// pelo ajuste A-05 (P-81), com as peças do menu do Wi-Fi (wifi/SecurityMenu.qml): vidro de pop-up sem o brilho
// do acento, lista a 8 das bordas, linhas de 44 com raio 12, a opção atual em `accentSubtle`, hover e foco
// do teclado em `hover`. Os valores e as contas estão na ficha 13 e nos tokens `settingsDropdown*`.
//
// Cada opção de `options` aceita: label, value, icon (nome em icons/), iconRotation, checked, submenu,
// disabled e separator.
FocusScope {
  id: root
  property var options: []
  property real maximumHeight: Shell.Theme.settingsDropdownMaxHeight
  property string currentValue
  // Só para a vitrine: fixa o hover na linha de índice `pinnedHover`, sem ponteiro.
  property int pinnedHover: -1
  signal selected(string value)
  signal dismissed

  // Separador e opção desativada não se escolhem, nem por clique nem pelo teclado.
  function selectable(option) { return !!option && !option.disabled && !option.separator; }
  function pick(option) { if (selectable(option)) selected(String(option.value)); }

  width: Shell.Theme.panelFieldWidth
  height: Math.min(maximumHeight, options.reduce(
      (total, option) => total + (option.separator ? Shell.Theme.settingsDropdownSeparatorHeight : Shell.Theme.settingsDropdownRowHeight),
      2 * Shell.Theme.settingsDropdownInset))

  // O clique no vidro não passa para o que está atrás do menu.
  Shell.GlassSurface {
    anchors.fill: parent
    surfaceType: "popup"
    showGlow: false

    MouseArea { anchors.fill: parent }

    ListView {
      id: list
      clip: true
      boundsBehavior: Flickable.StopAtBounds
      Shell.ScrollWheel { view: list }
      objectName: "displayOptions"
      x: Shell.Theme.settingsDropdownInset
      y: Shell.Theme.settingsDropdownInset
      width: parent.width - 2 * Shell.Theme.settingsDropdownInset
      height: parent.height - 2 * Shell.Theme.settingsDropdownInset
      model: root.options
      focus: true; keyNavigationEnabled: true
      currentIndex: Math.max(0, root.options.findIndex(o => String(o.value) === root.currentValue))
      onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)
      Component.onCompleted: positionViewAtIndex(currentIndex, ListView.Contain)
      // Ando até a próxima opção que se escolhe, pulando as desativadas e os separadores. Sem nenhuma
      // adiante, fico onde estou (o laço antigo parava em cima de uma desativada no fim da lista).
      function step(direction) {
        for (let i = currentIndex + direction; i >= 0 && i < count; i += direction) {
          if (root.selectable(root.options[i])) { currentIndex = i; return; }
        }
      }
      Keys.onEscapePressed: root.dismissed()
      Keys.onReturnPressed: root.pick(root.options[currentIndex])
      Keys.onEnterPressed: root.pick(root.options[currentIndex])
      Keys.onSpacePressed: root.pick(root.options[currentIndex])
      Keys.onUpPressed: step(-1)
      Keys.onDownPressed: step(1)
      // Como a barra do menu do Wi-Fi: 2 de largura, sem fundo, só quando há o que rolar.
      ScrollBar.vertical: ScrollBar {
        width: Shell.Theme.settingsDropdownScrollbarWidth
        padding: 0
        policy: size < 1 ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
        contentItem: Rectangle { radius: width / 2; color: Shell.Theme.dot }
        background: null
      }
      delegate: Rectangle {
        id: option
        required property var modelData
        required property int index
        readonly property bool active: root.selectable(modelData)
        readonly property bool current: String(modelData.value) === root.currentValue
        objectName: "displayOption" + modelData.value
        width: list.width
        height: modelData.separator ? Shell.Theme.settingsDropdownSeparatorHeight : Shell.Theme.settingsDropdownRowHeight
        radius: Shell.Theme.radiusRow
        // A atual fica em `accentSubtle`; o ponteiro e o foco do teclado, em `hover`. A desativada e o
        // separador não ganham nenhum dos dois.
        color: !active ? "transparent"
            : current ? Shell.Theme.accentSubtle
            : hover.hovered || index === root.pinnedHover || (list.activeFocus && list.currentIndex === index)
              ? Shell.Theme.hover : "transparent"
        Accessible.role: modelData.separator ? Accessible.Separator : Accessible.MenuItem; Accessible.name: modelData.label
        Accessible.checked: !!modelData.checked
        Accessible.onPressAction: root.pick(modelData)
        // Ícone opcional à esquerda (a linha Orientation da Tela usa o monitor girado, P-49).
        Image {
          id: leading
          visible: !!option.modelData.icon
          x: Shell.Theme.settingsDropdownTextX; anchors.verticalCenter: parent.verticalCenter
          width: Shell.Theme.settingsDropdownIconSize; height: width; sourceSize: Qt.size(2 * width, 2 * height)
          rotation: option.modelData.iconRotation || 0
          opacity: option.modelData.disabled ? Shell.Theme.settingsDropdownDisabledOpacity : 1
          source: option.modelData.icon ? Qt.resolvedUrl("../icons/" + option.modelData.icon + ".svg") : ""
          layer.enabled: true
          layer.effect: MultiEffect { colorization: 1; colorizationColor: Shell.Theme.text }
        }
        Text {
          x: leading.visible ? Shell.Theme.settingsDropdownIconTextX : Shell.Theme.settingsDropdownTextX
          // Termina a 12 da borda direita; com o ícone da direita, 8 antes dele.
          width: parent.width - x - (trailing.visible
              ? Shell.Theme.settingsDropdownTextX + Shell.Theme.settingsDropdownIconSize + Shell.Theme.settingsDropdownIconGap
              : Shell.Theme.settingsDropdownTextX)
          anchors.verticalCenter: parent.verticalCenter
          visible: !option.modelData.separator
          text: option.modelData.label; elide: Text.ElideRight; maximumLineCount: 1
          color: Shell.Theme.text
          opacity: option.modelData.disabled ? Shell.Theme.settingsDropdownDisabledOpacity : 1
          font.family: Shell.Theme.fontFamily; font.pixelSize: Shell.Theme.fontBody; font.weight: Font.Medium
          font.letterSpacing: 0
        }
        // O `check` da opção marcada, ou o `chevron-down` girado do submenu.
        Image {
          id: trailing
          visible: !!option.modelData.submenu || !!option.modelData.checked
          x: parent.width - Shell.Theme.settingsDropdownTextX - width; anchors.verticalCenter: parent.verticalCenter
          width: Shell.Theme.settingsDropdownIconSize; height: width; sourceSize: Qt.size(2 * width, 2 * height)
          rotation: option.modelData.submenu ? -90 : 0
          opacity: option.modelData.disabled ? Shell.Theme.settingsDropdownDisabledOpacity : 1
          source: Qt.resolvedUrl(option.modelData.submenu ? "../icons/chevron-down.svg" : "../icons/check.svg")
          layer.enabled: true
          layer.effect: MultiEffect { colorization: 1; colorizationColor: Shell.Theme.text }
        }
        // 4 acima, 1 de linha e 4 abaixo (9 no total), recuada 12 de cada lado.
        Rectangle {
          visible: !!option.modelData.separator
          anchors.centerIn: parent
          width: parent.width - 2 * Shell.Theme.settingsDropdownTextX; height: Shell.Theme.settingsDropdownSeparatorLine
          color: Shell.Theme.border
        }
        HoverHandler { id: hover; cursorShape: option.active ? Qt.PointingHandCursor : Qt.ArrowCursor }
        TapHandler { onTapped: root.pick(option.modelData) }
      }
    }
  }
}
