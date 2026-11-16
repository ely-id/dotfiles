pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "." as Settings
import ".." as Shell

// Bandeja do sistema no topo da tela inicial dos Ajustes (ficha 13; Figma 13:15799).
// Faixa de raio 8 com borda `border` e sem vidro, a 16 do topo. Botões de 36, raio 6,
// a cada 40, com ícone de 16 a 80%; hover de controle (`hover`). Com cinco itens a faixa
// tem 204×44. `items` é a lista do SystemTray; a vitrine passa itens fictícios.
Item {
  id: root

  property var items: SystemTray.items

  property var menuItem: null
  property var menuPath: []
  property real menuCenter: 0
  readonly property var entries: {
    const level = openers.instances[openers.instances.length - 1];
    return level ? level.children.values : [];
  }
  readonly property var options: {
    const rows = entries.map((entry, index) => ({
      value: index, label: entry.text, separator: entry.isSeparator,
      disabled: entry.isSeparator || !entry.enabled,
      checked: entry.checkState === Qt.Checked, submenu: entry.hasChildren
    }));
    return menuPath.length > 1 ? [{value: -1, label: "Back"}].concat(rows) : rows;
  }
  readonly property bool menuOpen: options.length > 0

  onEnabledChanged: if (!enabled) closeMenu()
  Keys.onEscapePressed: Settings.State.close()

  function openMenu(item, button) {
    if (!item.hasMenu) return;
    menuCenter = button.mapToItem(root, button.width / 2, 0).x;
    menuItem = item;
    menuPath = [item.menu];
  }

  function closeMenu() {
    menuItem = null;
    menuPath = [];
    forceActiveFocus();
  }

  function back() {
    if (menuPath.length > 1) menuPath = menuPath.slice(0, -1);
    else closeMenu();
  }

  function choose(index) {
    const entry = entries[index];
    if (!entry) {
      back();
    } else if (entry.hasChildren) {
      menuPath = menuPath.concat(entry);
    } else {
      entry.triggered();
      closeMenu();
      Settings.State.close();
    }
  }

  // One opener per level. Releasing a parent tears down the menus under it.
  Variants {
    id: openers
    model: root.menuPath
    delegate: QsMenuOpener {
      required property var modelData
      menu: modelData
    }
  }

  Rectangle {
    id: bar
    anchors.horizontalCenter: parent.horizontalCenter
    y: Shell.Theme.settingsEdgeMargin
    width: buttons.width + Shell.Theme.settingsTrayPadding * 2
    height: Shell.Theme.settingsTrayHeight
    radius: Shell.Theme.settingsTrayRadius
    color: "transparent"
    border.width: 1
    border.color: Shell.Theme.border
    antialiasing: true
    visible: items.count > 0

    MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons }

    Row {
      id: buttons
      anchors.centerIn: parent
      spacing: Shell.Theme.settingsTrayPadding

      Repeater {
        id: items
        model: root.items

        delegate: Rectangle {
          id: button
          required property var modelData
          readonly property bool highlighted: pointer.containsMouse || activeFocus
              || (root.menuOpen && root.menuItem === modelData)

          function activate() {
            if (modelData.onlyMenu) {
              root.openMenu(modelData, button);
              return;
            }
            modelData.activate();
            Settings.State.close();
          }

          width: Shell.Theme.settingsTrayButton
          height: Shell.Theme.settingsTrayButton
          radius: Shell.Theme.settingsTrayButtonRadius
          color: highlighted ? Shell.Theme.hover : Qt.alpha(Shell.Theme.hover, 0)
          activeFocusOnTab: true
          Accessible.role: Accessible.Button
          Accessible.name: modelData.tooltipTitle || modelData.title || modelData.id
          Accessible.onPressAction: activate()
          Keys.onReturnPressed: activate()
          Keys.onEnterPressed: activate()
          Keys.onSpacePressed: activate()
          Keys.onMenuPressed: root.openMenu(modelData, button)

          Behavior on color {
            ColorAnimation {
              duration: Shell.Theme.settingsHoverDuration
              easing.type: Easing.InOutCubic
            }
          }

          IconImage {
            anchors.centerIn: parent
            implicitSize: width
            width: 16
            height: 16
            source: button.modelData.icon
            asynchronous: true
            opacity: Shell.Theme.settingsTrayIconOpacity
          }

          MouseArea {
            id: pointer
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
            onClicked: mouse => {
              if (mouse.button === Qt.RightButton) {
                root.openMenu(button.modelData, button);
              } else if (mouse.button === Qt.MiddleButton) {
                button.modelData.secondaryActivate();
                Settings.State.close();
              } else {
                button.activate();
              }
            }
          }
        }
      }
    }
  }

  // Hovering and clicking outside the menu must not reach what's underneath.
  MouseArea {
    anchors.fill: parent
    visible: root.menuOpen
    hoverEnabled: true
    acceptedButtons: Qt.AllButtons
    onClicked: root.closeMenu()
    onWheel: event => { event.accepted = true; }
  }

  Loader {
    id: menu
    active: root.menuOpen
    x: root.menuCenter - width / 2
    y: bar.y + bar.height + 6
    onLoaded: item.forceActiveFocus()
    sourceComponent: Component {
      Settings.Dropdown {
        objectName: "trayDropdown"
        width: 236
        maximumHeight: root.height - menu.y - 10
        options: root.options
        onDismissed: root.back()
        onSelected: value => root.choose(Number(value))
      }
    }
  }
}
