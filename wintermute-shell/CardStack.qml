pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

// Keep page instances alive while they move behind the front card, preserving
// entered text and selections when the user goes back.
Item {
  id: root

  property var pageComponents: ({})
  signal panelOpened
  signal panelClosed
  signal pagePopping(string page)
  readonly property Region blurRegion: Region {
    Region {
      item: root.opened && root.opacity > Theme.blurRevealOpacity ? frontBounds : null
      radius: Theme.radiusPanel
    }
    Region {
      item: root.opened && root.depth > 1 ? backBounds : null
      radius: backBounds.radius
    }
  }
  onXChanged: blurRegion.changed()
  onYChanged: blurRegion.changed()
  onScaleChanged: blurRegion.changed()

  property bool opened: false
  property bool transitionRunning: false
  property string transitionOperation: ""
  property real transitionProgress: 1
  property real transitionFromHeight: 0
  property real transitionToHeight: 0
  property real transitionFromInset: Theme.cardStackFrontInsetSingle
  property real transitionToInset: Theme.cardStackFrontInsetSingle

  readonly property int collapseAllDuration: 200
  readonly property int depth: stackModel.count
  readonly property var currentEntry: depth > 0
      ? stackModel.get(depth - 1) : null
  readonly property string currentPage: currentEntry
      ? String(currentEntry.entryPage) : ""
  readonly property var currentSelection: currentEntry ? currentEntry.entrySelection : ({})
  readonly property real frontHeight: depth > 0
      && layerRepeater.itemAt(depth - 1)
      ? layerRepeater.itemAt(depth - 1).naturalHeight : 0
  readonly property real frontInset: transitionRunning
      ? Theme.lerp(transitionFromInset, transitionToInset,
                   transitionProgress)
      : insetForDepth(depth)
  readonly property real frontScale: transitionOperation === "push"
      ? 0.92 + 0.08 * transitionProgress
      : transitionOperation === "pop" ? Math.max(0, 1 - 2 * transitionProgress) : 1

  width: Theme.cardStackWidth
  height: transitionRunning
      ? Theme.lerp(transitionFromHeight, transitionToHeight,
                   transitionProgress)
      : frontHeight + insetForDepth(depth)
  visible: opened || closeCleanup.running
  opacity: opened ? 1 : 0
  scale: opened ? 1 : 0.9
  transformOrigin: Item.BottomLeft

  Behavior on opacity {
    NumberAnimation {
      duration: root.opened ? Theme.panelOpenDuration
                            : root.collapseAllDuration
      easing.type: root.opened ? Easing.InOutCubic : Easing.Bezier
      easing.bezierCurve: [0.19, 1, 0.22, 1, 1, 1]
    }
  }
  Behavior on scale {
    NumberAnimation {
      duration: root.opened ? Theme.panelOpenDuration
                            : root.collapseAllDuration
      easing.type: root.opened ? Easing.InOutCubic : Easing.Bezier
      easing.bezierCurve: [0.19, 1, 0.22, 1, 1, 1]
    }
  }

  ListModel {
    id: stackModel
    dynamicRoles: true
  }

  function insetForDepth(cardDepth) {
    return cardDepth > 1 ? Theme.cardStackFrontInsetStacked : Theme.cardStackFrontInsetSingle;
  }

  function open() {
    if (opened) {
      closeAll();
      return;
    }
    closeCleanup.stop();
    transitionAnimation.stop();
    transitionRunning = false;
    transitionOperation = "";
    transitionProgress = 1;
    stackModel.clear();
    stackModel.append({ entryPage: "drawer", entrySelection: ({}) });
    opened = true;
    panelOpened();
  }

  function push(page, selection) {
    if (transitionRunning)
      return;


    transitionFromInset = insetForDepth(depth);
    transitionFromHeight = frontHeight + transitionFromInset;
    transitionToInset = insetForDepth(depth + 1);
    transitionToHeight = transitionFromHeight;
    transitionOperation = "push";
    transitionProgress = 0;
    transitionRunning = true;
    stackModel.append({ entryPage: page,
                        entrySelection: selection || ({}) });
    transitionStart.restart();
  }

  function beginPush() {
    const incoming = layerRepeater.itemAt(depth - 1);
    if (!incoming || !incoming.ready || incoming.naturalHeight <= 0) {
      transitionStart.restart();
      return;
    }
    transitionToHeight = incoming.naturalHeight + transitionToInset;
    transitionAnimation.restart();
  }

  function pop(userInitiated) {
    if (transitionRunning)
      return;
    if (userInitiated !== false) pagePopping(currentPage);
    if (depth <= 1) {
      closeAll();
      return;
    }


    const returning = layerRepeater.itemAt(depth - 2);
    if (!returning || returning.naturalHeight <= 0)
      return;
    transitionFromInset = insetForDepth(depth);
    transitionFromHeight = frontHeight + transitionFromInset;
    transitionToInset = insetForDepth(depth - 1);
    transitionToHeight = returning.naturalHeight + transitionToInset;
    transitionOperation = "pop";
    transitionProgress = 0;
    transitionRunning = true;
    transitionAnimation.restart();
  }

  function finishTransition() {
    if (transitionOperation === "pop" && depth > 0)
      stackModel.remove(depth - 1);
    transitionOperation = "";
    transitionProgress = 1;
    transitionRunning = false;
  }

  function closeAll() {
    if ((!opened && !closeCleanup.running) || !visible)
      return;
    transitionAnimation.stop();
    transitionStart.stop();
    transitionRunning = false;
    transitionOperation = "";
    opened = false;
    panelClosed();
    closeCleanup.restart();
  }

  Timer {
    id: transitionStart
    interval: 1
    onTriggered: root.beginPush()
  }

  Timer {
    id: closeCleanup
    interval: root.collapseAllDuration
    onTriggered: {
      if (!root.opened)
        stackModel.clear();
    }
  }

  Item {
    id: frontBounds
    y: root.frontInset
    width: Theme.panelWidth
    height: root.height - y
  }
  Item {
    id: backBounds
    readonly property var card: root.depth > 1 ? layerRepeater.itemAt(root.depth - 2) : null
    readonly property real radius: Theme.radiusPanel
    x: card ? card.x : Theme.panelBackOffset
    y: card ? card.y : Theme.cardStackBackOffsetY
    width: card ? card.width : Theme.panelBackWidth
    height: card ? card.height : 0
  }

  Repeater {
    id: layerRepeater
    model: stackModel

    delegate: CardLayer {
      id: stackLayer
      required property int index
      required property string entryPage
      required property var entrySelection

      readonly property int relativeIndex: root.depth - 1 - index
      readonly property bool pushFront: root.transitionOperation === "push"
          && relativeIndex === 0
      readonly property bool pushBack: root.transitionOperation === "push"
          && relativeIndex === 1
      readonly property bool popFront: root.transitionOperation === "pop"
          && relativeIndex === 0
      readonly property bool popBack: root.transitionOperation === "pop"
          && relativeIndex === 1

      selection: entrySelection
      cardComponent: root.pageComponents[entryPage] || null
      stackController: root
      interactive: !root.transitionRunning && relativeIndex === 0

      x: Theme.panelBackOffset * backingAmount
      y: Theme.lerp(pushBack ? root.transitionFromInset
          : popBack ? root.transitionToInset : root.frontInset,
          Theme.cardStackBackOffsetY, backingAmount)
      width: Theme.lerp(Theme.panelWidth, Theme.panelBackWidth, backingAmount)
      // A carta de trás fica rente à base do cartão da frente (como na origem); o
      // conteúdo que passa disso é cortado. No Figma ela mantém a altura natural e
      // aparece abaixo da frente: pendência P-40.
      height: relativeIndex === 0 ? naturalHeight : root.height - y
      backingAmount: pushBack ? root.transitionProgress
          : popBack ? 1 - root.transitionProgress
          : relativeIndex === 0 ? 0 : 1
      opacity: pushFront ? root.transitionProgress
          : popFront ? 1
          : relativeIndex <= 1 ? 1 : 0
      scale: relativeIndex === 0 ? root.frontScale : 1
      transformOrigin: Item.Bottom
      visible: opacity > 0.001
      z: index
    }
  }

  PanelCloseButton {
    z: 100
    x: Theme.cardStackCloseButtonX
    y: root.frontInset - Theme.cardStackCloseButtonOverhang
    enabled: !root.transitionRunning
    onClicked: root.pop()
  }

  NumberAnimation {
    id: transitionAnimation
    target: root
    property: "transitionProgress"
    from: 0
    to: 1
    duration: Theme.pageDuration
    easing.type: Easing.Bezier
    easing.bezierCurve: [0.19, 1, 0.22, 1, 1, 1]
    onFinished: root.finishTransition()
  }

}
