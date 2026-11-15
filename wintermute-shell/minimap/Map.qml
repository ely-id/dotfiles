pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "." as Minimap
import ".." as Shell

// Organizador de workspaces da barra lateral (ficha 02, boards 13:12277 e 13:11395):
// Aberto (cartão 156, r16):
//   Padding 10; altura = 50 × max(linhas, 3) + 10 (mínimo 3 linhas = 160 px).
//   Círculo 40, gap 8, passo H 48, passo V 50.
//   Fundo da linha (146×50 r10 em x 5, y -5):
//     Ativo: accentSubtle + borda accentRing 1 px.
//     Hover: hover (6%).
//     Alvo de arraste: accentSubtle.
//     Linha levantada (reordenar): raised + borda borderStrong 1 px + sombra.
//   Pílula 14×20 r7 na borda (x -7 do cartão): Repouso, Hover (puxador 3 pontos), Ativa, Arrastando.
// Recolhido (cartão 48, r16):
//   Número Geist Mono Regular 13 em (4, y+6) 40×20 (text no ativo/hover, muted nos inativos).
//   Ativo (fundo pressed r12 em x 4, w 40): empilha janelas de 32 px em x 8, y+37, passo 40.
//   Janela focada no recolhido (F2-T08): círculo de 32 px com anel accent 1,5 px no mesmo centro (x 8).
//   Inativos: até 4 pontos 4×4 centrados em y+30; hover acende número e fundo hover (6%).
//   Divisor 16×1 border em x 16 entre linhas.
Shell.Card {
  id: root

  property var screen: null
  property real collapseProgress: 0
  readonly property real widthProgress: Shell.Theme.collapseWidth(collapseProgress)
  readonly property real heightProgress: Shell.Theme.collapseHeight(collapseProgress)
  property real maximumHeight: 10000
  readonly property alias dragSession: dragSession
  signal focusRequested(int workspaceIndex)
  signal windowRequested(var windowId)
  signal addRequested(var workspaceId)

  readonly property real expandedOpacity: collapseProgress < 0.56 ? 1 : 0
  readonly property real collapsedOpacity: collapseProgress >= 0.56 ? 1 : 0
  readonly property int expandedVisibleRowCount: expandedColumn.height > 0
      ? Math.round((expandedColumn.height + Shell.Theme.workspaceRowGap)
                   / Shell.Theme.workspaceRowPitch)
      : 0
  readonly property int expandedRenderedRowCount: Math.max(
      Shell.Theme.workspaceGridMinimumRows, expandedVisibleRowCount)
  readonly property real expandedNaturalHeight:
      expandedVisibleRowCount <= Shell.Theme.workspaceGridMinimumRows
      ? Shell.Theme.workspaceGridMinimumHeight
      : Shell.Theme.workspaceContentPadding * 2
        + expandedVisibleRowCount * Shell.Theme.workspaceControlSize
        + (expandedVisibleRowCount - 1) * Shell.Theme.workspaceRowGap
  readonly property real collapsedNaturalHeight: collapsedColumn.children.reduce(
      (height, row) => height + (row.targetHeight ?? 0), 0)
  readonly property real naturalHeight: Shell.Theme.lerp(
      expandedNaturalHeight, collapsedNaturalHeight,
      Shell.Theme.collapseHeight(collapseProgress))
  readonly property bool workspaceNumbersRevealed: expandedLayer.enabled
      && (expandedComponentHover.hovered || root.forceHovered || dragSession.active)

  focus: dragSession.active
  Keys.onEscapePressed: dragSession.cancel()
  onCollapseProgressChanged: if (collapseProgress >= 0.56) dragSession.cancel()

  Minimap.DragSession {
    id: dragSession
    parent: root.Window.window?.contentItem ?? root
  }

  function windowIndex(workspaceId, items, index) {
    if (!dragSession.windowDrag || !dragSession.active)
      return index;
    const sourceIndex = items.findIndex(w => w.winId === dragSession.source.windowData.winId);
    const compact = index - (sourceIndex >= 0 && index > sourceIndex ? 1 : 0);
    return compact + (dragSession.destination?.workspaceId === workspaceId
        && compact >= dragSession.destination.slot ? 1 : 0);
  }

  function rowOffset(workspaceId, number) {
    if (!dragSession.active || dragSession.windowDrag || number < 1)
      return 0;
    const source = dragSession.source;
    if (source.workspaceId === workspaceId)
      return dragSession.rowOffset;
    const target = dragSession.destination?.number ?? source.number;
    if (number > source.number && number <= target) return -Shell.Theme.workspaceRowPitch;
    if (number < source.number && number >= target) return Shell.Theme.workspaceRowPitch;
    return 0;
  }

  function numberedWorkspaceCount() {
    let count = 0;
    for (let i = 0; i < Shell.NiriMsg.workspaceRows.count; i++) {
      const row = Shell.NiriMsg.workspaceRows.get(i);
      if (!root.screen || row.outputName === "" || row.outputName === root.screen.name)
        count = Math.max(count, row.sidebarWorkspaceNumber);
    }
    return count;
  }

  width: Shell.Theme.lerp(Shell.Theme.sidebarCardExpandedWidth,
      Shell.Theme.sidebarCardCollapsedWidth, widthProgress)
  height: Math.min(maximumHeight, naturalHeight)
  radius: Shell.Theme.sidebarCardRadius
  forceHovered: dragSession.active || expandedComponentHover.hovered
  // A pílula se projeta 7 px para fora da borda esquerda no modo expandido;
  // o recorte volta no modo recolhido.
  contentClipped: collapseProgress >= 0.56

  Item {
    id: expandedLayer
    x: -10
    width: root.width - x
    height: root.height
    clip: true
    opacity: root.expandedOpacity
    visible: opacity > 0.001
    enabled: root.collapseProgress < 0.56

    HoverHandler {
      id: expandedComponentHover
      enabled: expandedLayer.enabled
    }

    Column {
      id: expandedColumn
      x: 0
      y: Shell.Theme.workspaceContentPadding
      width: expandedLayer.width
      spacing: Shell.Theme.workspaceRowGap

      Repeater {
        model: Shell.NiriMsg.workspaceRows

        delegate: Item {
          id: expandedWorkspace

          required property int index
          required property var model

          readonly property bool matchesOutput: !expandedWorkspace.model
              ? false
              : (expandedWorkspace.model.outputName === ""
                 || !root.screen
                 || expandedWorkspace.model.outputName === root.screen.name)
          readonly property var windowItems: {
            try {
              return JSON.parse(expandedWorkspace.model?.windowsJson || "[]");
            } catch (e) {
              return [];
            }
          }
          readonly property var activeWindowId: model ? model.activeWindowId : -1
          property int windowStart: 0
          property var firstWindowId: null

          onWindowItemsChanged: Qt.callLater(updateWindowStart)
          onActiveWindowIdChanged: Qt.callLater(updateWindowStart)

          Connections {
            target: dragSession
            function onActiveChanged() {
              if (!dragSession.active) Qt.callLater(expandedWorkspace.updateWindowStart);
            }
          }

          function updateWindowStart() {
            if (dragSession.windowDrag) return;
            const columns = Shell.Theme.workspaceGridColumns;
            const first = windowItems.findIndex(w => w.winId === firstWindowId);
            let start = first < 0 ? windowStart : first;
            const active = windowItems.findIndex(w => w.winId === activeWindowId);
            if (active >= 0)
              start = Math.max(active - columns + 1, Math.min(start, active));
            windowStart = Math.max(0, Math.min(start, windowItems.length - columns));
            firstWindowId = windowItems[windowStart]?.winId ?? null;
          }

          readonly property int carouselSlotCount: Math.max(
              Shell.Theme.workspaceGridColumns, windowItems.length + 1)
          readonly property int workspaceNumber:
              Number(expandedWorkspace.model?.sidebarWorkspaceNumber) || 0
          readonly property bool isRowActive: Boolean(expandedWorkspace.model?.isActive)
          readonly property bool dragTarget: dragSession.windowDrag
              && dragSession.destination?.workspaceId === Number(model?.workspaceId)
          readonly property bool isLiftedRow: dragSession.active && !dragSession.windowDrag
              && dragSession.source?.workspaceId === Number(model?.workspaceId)
          readonly property int remainingWindows: windowItems.filter(w =>
              !dragSession.windowDrag || w.winId !== dragSession.source.windowData.winId).length
          property real dragOffset: root.rowOffset(Number(model?.workspaceId), workspaceNumber)

          visible: matchesOutput
          width: expandedColumn.width
          height: matchesOutput ? Shell.Theme.workspaceControlSize : 0
          z: isLiftedRow ? 20 : 0
          transform: Translate { y: expandedWorkspace.dragOffset }
          Behavior on dragOffset {
            enabled: !dragSession.resetting && !dragSession.committing
                && !(dragSession.held && expandedWorkspace.z === 20)
            Shell.HoverAnimation { duration: Shell.Theme.workspaceDragSnapDuration }
          }

          // Sombra da linha levantada ao reordenar workspaces (estado 8)
          Shell.Shadow {
            x: Shell.Theme.workspaceActiveIndicatorInset - expandedLayer.x
            y: -Shell.Theme.workspaceRowGap / 2
            width: Shell.Theme.workspaceActiveIndicatorWidth
            height: Shell.Theme.workspaceActiveIndicatorHeight
            cornerRadius: Shell.Theme.workspaceActiveIndicatorRadius
            visible: expandedWorkspace.isLiftedRow
            shadows: Shell.Theme.glassShadows
            strength: 0.7
          }

          // Indicador de fundo da linha: ativo, hover, alvo de arraste ou levantada (146×50 r10 em x 5, y -5)
          Rectangle {
            x: Shell.Theme.workspaceActiveIndicatorInset - expandedLayer.x
            y: -Shell.Theme.workspaceRowGap / 2
            width: Shell.Theme.workspaceActiveIndicatorWidth
            height: Shell.Theme.workspaceActiveIndicatorHeight
            radius: Shell.Theme.workspaceActiveIndicatorRadius
            antialiasing: true
            color: expandedWorkspace.isLiftedRow ? Shell.Theme.raised
                : expandedWorkspace.dragTarget ? Shell.Theme.accentSubtle
                : (expandedWorkspace.isRowActive && !dragSession.windowDrag) ? Shell.Theme.accentSubtle
                : (rowHover.hovered && !dragSession.active) ? Shell.Theme.hover
                : Qt.rgba(0, 0, 0, 0)
            border.width: expandedWorkspace.isLiftedRow
                || (expandedWorkspace.isRowActive && !dragSession.windowDrag && !expandedWorkspace.dragTarget)
                ? 1 : 0
            border.color: expandedWorkspace.isLiftedRow
                ? Shell.Theme.borderStrong : Shell.Theme.accentRing

            Behavior on color {
              ColorAnimation {
                duration: Shell.Theme.sidebarWorkspaceSwitchDuration
                easing.type: Easing.OutCubic
              }
            }
          }

          MouseArea {
            x: -expandedLayer.x
            y: -Shell.Theme.workspaceRowGap / 2
            width: Shell.Theme.sidebarCardExpandedWidth
            height: Shell.Theme.workspaceRowPitch
            acceptedButtons: Qt.LeftButton
            cursorShape: Qt.PointingHandCursor
            onClicked: if (expandedWorkspace.model) root.focusRequested(
                expandedWorkspace.model.workspaceIndex)
          }

          HoverHandler { id: rowHover; enabled: expandedLayer.enabled }

          Item {
            id: windowViewport
            x: Shell.Theme.lerp(Shell.Theme.workspaceContentPadding, 8, root.widthProgress) - expandedLayer.x
            width: Shell.Theme.workspaceGridColumns * Shell.Theme.workspaceControlSize
                + (Shell.Theme.workspaceGridColumns - 1)
                  * Shell.Theme.workspaceControlGap
            height: parent.height
            clip: true

            Item {
              id: windowCarousel
              x: -expandedWorkspace.windowStart
                  * Shell.Theme.workspaceControlPitch * (1 - root.widthProgress)
              width: expandedWorkspace.carouselSlotCount
                  * Shell.Theme.workspaceControlSize
                  + (expandedWorkspace.carouselSlotCount - 1)
                    * Shell.Theme.workspaceControlGap
              height: parent.height

              Behavior on x {
                enabled: root.collapseProgress === 0
                Shell.Motion { duration: Shell.Theme.carouselDuration }
              }

              Repeater {
                model: expandedWorkspace.carouselSlotCount

                delegate: Item {
                  id: workspaceSlot

                  required property int index

                  readonly property bool hasWindow:
                      index < expandedWorkspace.windowItems.length
                  readonly property bool addSlot: index === expandedWorkspace.windowItems.length
                  readonly property bool emptyWorkspaceActive: index === 0
                      && expandedWorkspace.windowItems.length === 0
                      && expandedWorkspace.isRowActive
                  readonly property int visualIndex: root.windowIndex(
                      Number(expandedWorkspace.model?.workspaceId),
                      expandedWorkspace.windowItems, index)
                  readonly property bool dropTargetSlot: expandedWorkspace.dragTarget
                      && visualIndex === dragSession.destination?.slot
                  readonly property bool plusRevealed: addSlot && root.collapseProgress === 0
                      && expandedWorkspace.matchesOutput && !dragSession.active && !dropTargetSlot
                      && (emptyWorkspaceActive
                          || rowHover.hovered
                          || Boolean(expandedWorkspace.model && !expandedWorkspace.model.outputHasWindows && expandedWorkspace.model.isCreationRow))
                  readonly property var windowData: hasWindow
                      ? expandedWorkspace.windowItems[index] : ({})

                  visible: root.collapseProgress === 0 || (index >= expandedWorkspace.windowStart
                      && index < expandedWorkspace.windowStart + Shell.Theme.workspaceGridColumns)
                  x: visualIndex * Shell.Theme.workspaceControlPitch * (1 - root.widthProgress)
                  width: Shell.Theme.lerp(Shell.Theme.workspaceControlSize,
                      Shell.Theme.workspaceCollapsedControlSize, root.widthProgress)
                  height: width
                  Behavior on x {
                    enabled: root.collapseProgress === 0 && workspaceSlot.hasWindow && !dragSession.resetting && !dragSession.committing
                    Shell.HoverAnimation { duration: Shell.Theme.workspaceDragSnapDuration }
                  }

                  Rectangle {
                    anchors.centerIn: parent
                    visible: root.collapseProgress === 0 && !workspaceSlot.hasWindow
                        && !workspaceSlot.emptyWorkspaceActive && !workspaceSlot.dropTargetSlot
                    width: Shell.Theme.workspacePlaceholderDotSize
                    height: Shell.Theme.workspacePlaceholderDotSize
                    radius: width / 2
                    color: Shell.Theme.dot
                    opacity: workspaceSlot.plusRevealed ? 0 : 1
                    Behavior on opacity { Shell.HoverAnimation {} }
                  }

                  Minimap.WindowIcon {
                    id: windowIcon
                    anchors.fill: parent
                    visible: workspaceSlot.hasWindow
                    opacity: dragSession.windowDrag
                        && dragSession.source.windowData.winId === workspaceSlot.windowData.winId ? 0 : 1
                    controlSize: workspaceSlot.width
                    windowData: workspaceSlot.windowData
                    onActivated: windowId => root.windowRequested(windowId)

                    DragHandler {
                      id: windowDrag
                      target: null
                      enabled: expandedLayer.enabled && workspaceSlot.hasWindow
                          && (!dragSession.active || active)
                      acceptedButtons: Qt.LeftButton
                      dragThreshold: 6
                      cursorShape: active ? Qt.ClosedHandCursor : Qt.PointingHandCursor
                      onActiveChanged: {
                        if (active) dragSession.begin({ kind: "window",
                            windowData: Object.assign({}, workspaceSlot.windowData),
                            slot: workspaceSlot.index,
                            workspaceId: Number(expandedWorkspace.model?.workspaceId) },
                            windowIcon, centroid.scenePressPosition, centroid.scenePosition);
                        else dragSession.release();
                      }
                      onCentroidChanged: if (active) dragSession.move(centroid.scenePosition)
                      onCanceled: dragSession.cancel()
                    }
                  }

                  Minimap.PlusButton {
                    anchors.fill: parent
                    revealed: workspaceSlot.plusRevealed
                    accentStyle: workspaceSlot.emptyWorkspaceActive
                    enabled: expandedLayer.enabled && !dragSession.active
                    onActivated: root.addRequested(Number(expandedWorkspace.model?.workspaceId))
                  }
                }
              }

              DropArea {
                id: windowDrop
                parent: expandedLayer
                readonly property int workspaceId: Number(expandedWorkspace.model?.workspaceId)
                property int slot: 0
                readonly property int lastStart: Math.max(0,
                    expandedWorkspace.remainingWindows + 1 - Shell.Theme.workspaceGridColumns)
                readonly property real viewportX: drag.x - windowViewport.x
                readonly property int scrollDirection:
                    viewportX < 12 && expandedWorkspace.windowStart > 0 ? -1
                    : viewportX > windowViewport.width - 12 && expandedWorkspace.windowStart < lastStart ? 1 : 0
                x: 0
                y: expandedColumn.y + expandedWorkspace.y - Shell.Theme.workspaceRowGap / 2
                width: expandedWorkspace.width
                height: Shell.Theme.workspaceRowPitch
                keys: ["pond-window"]
                enabled: expandedLayer.enabled && expandedWorkspace.matchesOutput
                onEntered: { updateSlot(); dragSession.destination = windowDrop; }
                onPositionChanged: updateSlot()
                onExited: if (dragSession.held && dragSession.destination === windowDrop) dragSession.destination = null
                onDropped: drop => drop.acceptProposedAction()
                function updateSlot() {
                  if (!dragSession.held) return;
                  slot = Math.max(0, Math.min(expandedWorkspace.remainingWindows,
                      Math.floor((drag.x - windowViewport.x - windowCarousel.x + Shell.Theme.workspaceControlGap / 2)
                                 / Shell.Theme.workspaceControlPitch)));
                }
                function snapPosition() {
                  return windowViewport.mapToItem(dragSession.parent,
                      (slot - expandedWorkspace.windowStart) * Shell.Theme.workspaceControlPitch, 0);
                }

                Connections {
                  target: windowCarousel
                  function onXChanged() { if (windowDrop.containsDrag) windowDrop.updateSlot(); }
                }
                Timer {
                  interval: 300
                  repeat: true
                  running: dragSession.held && windowDrop.containsDrag && windowDrop.scrollDirection !== 0
                  onTriggered: {
                    expandedWorkspace.windowStart += windowDrop.scrollDirection;
                    expandedWorkspace.firstWindowId =
                        expandedWorkspace.windowItems[expandedWorkspace.windowStart]?.winId ?? null;
                  }
                }
              }

              // Alvo de soltar janela (estado 7): 40×40 r20, accentSubtle + accentRing 1 px
              Rectangle {
                visible: expandedWorkspace.dragTarget
                x: (dragSession.destination?.slot ?? 0) * Shell.Theme.workspaceControlPitch
                width: Shell.Theme.workspaceControlSize
                height: width
                radius: width / 2
                color: Shell.Theme.accentSubtle
                border.width: 1
                border.color: Shell.Theme.accentRing
                antialiasing: true
                Behavior on x { Shell.HoverAnimation { duration: Shell.Theme.workspaceDragSnapDuration } }
              }
            }
          }

          // Pílula do workspace (14×20 r7 em x = -7 do cartão, ficha 02)
          Item {
            anchors.verticalCenter: parent.verticalCenter
            z: 30
            width: 20
            height: Shell.Theme.workspaceRowPitch
            visible: root.workspaceNumbersRevealed && expandedWorkspace.workspaceNumber > 0

            readonly property bool isPillDragging: workspaceDrag.active || expandedWorkspace.isLiftedRow
            readonly property bool isPillHovered: (numberPointer.containsMouse || numberPointer.pressed)
                && !isPillDragging
            readonly property bool isPillActive: expandedWorkspace.isRowActive && !isPillHovered && !isPillDragging

            Shell.Shadow {
              anchors.fill: pillRect
              cornerRadius: pillRect.radius
              visible: parent.isPillDragging
              shadows: Shell.Theme.glassShadows
              strength: 0.5
            }

            Rectangle {
              id: pillRect
              x: 3
              anchors.verticalCenter: parent.verticalCenter
              width: Shell.Theme.workspacePillWidth
              height: Shell.Theme.workspacePillHeight
              radius: 7
              color: parent.isPillDragging ? Shell.Theme.accentHover
                  : parent.isPillActive ? Shell.Theme.accent
                  : Shell.Theme.raised
              border.width: parent.isPillDragging || parent.isPillActive ? 0 : 1
              border.color: Shell.Theme.borderStrong
              antialiasing: true

              Behavior on color {
                ColorAnimation { duration: Shell.Theme.hoverDuration; easing.type: Easing.OutCubic }
              }

              Text {
                anchors.fill: parent
                visible: !parent.parent.isPillHovered && !parent.parent.isPillDragging
                text: String(expandedWorkspace.workspaceNumber)
                color: parent.parent.isPillActive ? Shell.Theme.textOnAccent : Shell.Theme.text
                font.family: Shell.Theme.monoFontFamily
                font.weight: Font.Medium
                font.pixelSize: Shell.Theme.fontMonoCaption
                font.letterSpacing: 0
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
              }

              // Puxador de 3 pontos (estados 4 e 8)
              Column {
                anchors.centerIn: parent
                spacing: 2
                visible: parent.parent.isPillHovered || parent.parent.isPillDragging
                Repeater {
                  model: 3
                  delegate: Rectangle {
                    width: 2
                    height: 2
                    radius: 1
                    color: pillRect.parent.isPillDragging
                        ? Shell.Theme.textOnAccent : Shell.Theme.text
                  }
                }
              }
            }

            MouseArea {
              id: numberPointer
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: workspaceDrag.active ? Qt.ClosedHandCursor : Qt.OpenHandCursor
              onClicked: if (expandedWorkspace.model) root.focusRequested(expandedWorkspace.model.workspaceIndex)
            }

            DragHandler {
              id: workspaceDrag
              target: null
              enabled: expandedLayer.enabled && (!dragSession.active || active)
              acceptedButtons: Qt.LeftButton
              dragThreshold: 6
              xAxis.enabled: false
              onActiveChanged: {
                if (active) dragSession.begin({ kind: "workspace",
                    workspaceId: Number(expandedWorkspace.model?.workspaceId),
                    number: expandedWorkspace.workspaceNumber,
                    count: root.numberedWorkspaceCount() }, expandedWorkspace,
                    centroid.scenePressPosition, centroid.scenePosition);
                else dragSession.release();
              }
              onCentroidChanged: if (active) dragSession.move(centroid.scenePosition)
              onCanceled: dragSession.cancel()
            }
          }

          DropArea {
            id: workspaceDrop
            parent: expandedLayer
            readonly property int workspaceId: Number(expandedWorkspace.model?.workspaceId)
            readonly property int number: expandedWorkspace.workspaceNumber
            x: 0
            y: expandedColumn.y + expandedWorkspace.y - Shell.Theme.workspaceRowGap / 2
            width: 20
            height: Shell.Theme.workspaceRowPitch
            keys: ["pond-workspace"]
            enabled: expandedLayer.enabled && number > 0 && expandedWorkspace.matchesOutput
            onEntered: dragSession.destination = workspaceDrop
            onExited: if (dragSession.held && dragSession.destination === workspaceDrop) dragSession.destination = null
            onDropped: drop => drop.acceptProposedAction()
            function snapPosition() {
              return expandedColumn.mapToItem(dragSession.parent, 0, expandedWorkspace.y);
            }
          }
        }
      }
    }

    // Linhas de pontos para completar o mínimo de 3 linhas (estado 12)
    Column {
      visible: root.collapseProgress === 0
      x: Shell.Theme.workspaceContentPadding - expandedLayer.x
      y: Shell.Theme.workspaceContentPadding
          + root.expandedVisibleRowCount * Shell.Theme.workspaceRowPitch
      spacing: Shell.Theme.workspaceRowGap

      Repeater {
        model: Math.max(0, root.expandedRenderedRowCount
                        - root.expandedVisibleRowCount)

        delegate: Row {
          required property int index
          spacing: Shell.Theme.workspaceControlGap

          Repeater {
            model: Shell.Theme.workspaceGridColumns

            delegate: Item {
              required property int index
              width: Shell.Theme.workspaceControlSize
              height: Shell.Theme.workspaceControlSize

              Rectangle {
                anchors.centerIn: parent
                width: Shell.Theme.workspacePlaceholderDotSize
                height: Shell.Theme.workspacePlaceholderDotSize
                radius: width / 2
                color: Shell.Theme.dot
              }
            }
          }
        }
      }
    }
  }

  Item {
    id: collapsedLayer
    width: Shell.Theme.sidebarCardCollapsedWidth
    height: collapsedColumn.height
    opacity: root.collapsedOpacity
    visible: opacity > 0.001
    enabled: root.collapseProgress >= 0.56

    Column {
      id: collapsedColumn
      y: Shell.Theme.lerp(Shell.Theme.workspaceContentPadding, 4, root.heightProgress)
      width: Shell.Theme.sidebarCardCollapsedWidth

      Repeater {
        model: Shell.NiriMsg.workspaceRows

        delegate: Item {
          id: collapsedWorkspace

          required property var model

          readonly property bool matchesOutput: !collapsedWorkspace.model
              ? false
              : (collapsedWorkspace.model.outputName === ""
                 || !root.screen
                 || collapsedWorkspace.model.outputName === root.screen.name)
          readonly property bool active: Boolean(collapsedWorkspace.model?.isActive)
          readonly property int workspaceNumber:
              Number(collapsedWorkspace.model?.sidebarWorkspaceNumber) || 0
          readonly property int displayNumber: workspaceNumber > 0
              ? workspaceNumber
              : (Number(collapsedWorkspace.model?.sidebarRowOrdinal) || 0) + 1
          readonly property var windowItems: {
            try {
              return JSON.parse(collapsedWorkspace.model?.windowsJson || "[]");
            } catch (e) {
              return [];
            }
          }
          readonly property int activeHeight:
              Shell.Theme.workspaceCollapsedHeaderHeight
              + windowItems.length * Shell.Theme.workspaceCollapsedControlPitch
              - (windowItems.length > 0 ? Shell.Theme.workspaceCollapsedControlGap : 0)
              + 4

          visible: matchesOutput
          width: Shell.Theme.sidebarCardCollapsedWidth
          property real targetHeight: !matchesOutput ? 0
              : (active && windowItems.length > 0 ? activeHeight : 41) + Shell.Theme.workspaceCollapsedControlGap
          height: matchesOutput ? Shell.Theme.lerp(Shell.Theme.workspaceRowPitch,
              targetHeight, root.heightProgress) : 0

          Behavior on targetHeight {
            enabled: root.collapseProgress === 1
            NumberAnimation {
              duration: Shell.Theme.sidebarWorkspaceSwitchDuration
              easing.type: Easing.OutCubic
            }
          }

          // Fundo da linha no recolhido: pressed (10%) no ativo, hover (6%) no hover inativo (estados 9 e 10)
          Rectangle {
            x: 4
            width: 40
            height: Math.max(0, parent.height - Shell.Theme.workspaceCollapsedControlGap)
            radius: 12
            color: collapsedWorkspace.active ? Shell.Theme.pressed : Shell.Theme.hover
            opacity: collapsedWorkspace.active || collapsedRowPointer.containsMouse ? 1 : 0

            Behavior on opacity {
              NumberAnimation {
                duration: Shell.Theme.sidebarWorkspaceSwitchDuration
                easing.type: Easing.OutCubic
              }
            }
          }

          MouseArea {
            id: collapsedRowPointer
            y: 0
            width: parent.width
            height: Math.max(0, parent.height - Shell.Theme.workspaceCollapsedControlGap)
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: if (collapsedWorkspace.model) root.focusRequested(
                collapsedWorkspace.model.workspaceIndex)
          }

          // Número em Geist Mono Regular 13, caixa 40×20 em (4,6) (estados 9 e 10)
          Text {
            id: collapsedNumber
            x: 4
            y: 6
            width: 40
            height: 20
            text: collapsedWorkspace.displayNumber < 10
                ? "0" + collapsedWorkspace.displayNumber
                : String(collapsedWorkspace.displayNumber)
            color: collapsedWorkspace.active || collapsedRowPointer.containsMouse
                ? Shell.Theme.text : Shell.Theme.muted
            font.family: Shell.Theme.monoFontFamily
            font.weight: Font.Normal
            font.pixelSize: Shell.Theme.fontMonoNumber
            font.letterSpacing: 0
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            Behavior on color {
              ColorAnimation {
                duration: Shell.Theme.hoverDuration
                easing.type: Easing.OutCubic
              }
            }
          }

          // Janelas de 32 px empilhadas em x = 8, y = 37, passo 40 (F2-T08: focada = 32 px + anel accent)
          Item {
            visible: collapsedWorkspace.active
            x: 8
            y: Shell.Theme.workspaceCollapsedHeaderHeight * root.heightProgress
            width: Shell.Theme.workspaceCollapsedControlSize
            height: Math.max(0, collapsedWorkspace.windowItems.length
                * Shell.Theme.workspaceCollapsedControlPitch - Shell.Theme.workspaceCollapsedControlGap)

            Repeater {
              model: collapsedWorkspace.windowItems.length

              delegate: Minimap.WindowIcon {
                required property int index
                x: 0
                y: index * Shell.Theme.workspaceCollapsedControlPitch * root.heightProgress
                controlSize: Shell.Theme.workspaceCollapsedControlSize
                windowData: collapsedWorkspace.windowItems[index] || ({})
                onActivated: windowId => root.windowRequested(windowId)
              }
            }
          }

          // Até 4 pontos 4×4 centrados em y = 30 nos workspaces inativos
          Row {
            id: windowDots
            visible: !collapsedWorkspace.active
                && collapsedWorkspace.windowItems.length > 0
            y: 30
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 2

            Repeater {
              model: Math.min(4, collapsedWorkspace.windowItems.length)

              delegate: Rectangle {
                required property int index
                width: 4
                height: 4
                radius: 2
                antialiasing: true
                readonly property string dotState: collapsedWorkspace.windowItems[index]?.dotState || ""
                color: dotState === "working" ? Shell.Theme.accentText
                    : dotState === "attention" ? Shell.Theme.attentionText
                    : dotState === "unread" ? Shell.Theme.warning
                    : dotState === "read" ? Shell.Theme.successText
                    : Shell.Theme.muted
              }
            }
          }

          Rectangle {
            x: 16
            y: parent.height - Shell.Theme.workspaceCollapsedControlGap / 2
            width: 16
            height: 1
            color: Shell.Theme.border
            visible: collapsedWorkspace.y + collapsedWorkspace.height < collapsedColumn.height - 0.5
          }
        }
      }
    }
  }
}
