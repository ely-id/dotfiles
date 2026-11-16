pragma ComponentBehavior: Bound
import QtQuick
import "." as Display
import ".." as Settings
import "../.." as Shell
import "Geometry.js" as Geometry

// Organizar monitores (ficha 13; Figma 13:16062): modal de 580×500. Área de arraste de 520×320, raio 16,
// em cardHover com borda border, em (30,84); os monitores encostam uns nos outros, sem folga. O
// arrastado fica em accentSubtle com anel accentRing de 2, sombra do vidro, legenda "Dragging" e glifo
// move. Enquanto arrasto, a borda em comum com o vizinho aparece como guia de encaixe de 1 px em
// accentText, a 24 das bordas da área. Embaixo, a dica 13 Regular em muted (ou o erro, em dangerText) e
// os botões "Cancel" e "Done" de 104×40. O encaixe e a validação continuam os da origem (Geometry.js).
// Lê o estado por `service` (decisão 0011).
Settings.Modal {
  id: root
  objectName: "displayArrangePanel"

  property var service: Display.State
  // Só para a vitrine: mostra um monitor como se estivesse sendo arrastado.
  property int demoDragIndex: -1

  title: "Arrange displays"
  closeLabel: "Cancel arrangement and return to Display"
  bodyTop: 0
  contentHeight: Math.max(footer.y + footer.height, hint.y + hint.height) + Shell.Theme.settingsArrangeBottomPadding

  property var baselineSnapshot: []
  property var draft: []
  property var viewport: Geometry.fit(baselineSnapshot, area.width, area.height, 56, 230)
  property int draggingIndex: -1
  readonly property int activeIndex: draggingIndex >= 0 ? draggingIndex : demoDragIndex
  readonly property bool stale: JSON.stringify(baselineSnapshot) !== JSON.stringify(service.geometry)

  Component.onCompleted: {
    baselineSnapshot = JSON.parse(JSON.stringify(service.geometry));
    draft = JSON.parse(JSON.stringify(baselineSnapshot));
  }

  function cancel() { if (!service.busy) Settings.State.back(); }
  function save() { if (!done.isDisabled) service.arrange(baselineSnapshot, draft); }
  onBackRequested: cancel()
  Keys.onEscapePressed: cancel()

  Connections {
    target: root.service
    function onArrangementApplied() { if (Settings.State.page === "arrange") Settings.State.back(); }
  }

  function moveMonitor(index, x, y) {
    if (stale || service.busy) return;
    const next = draft.slice();
    next[index] = Geometry.snap(draft, index, x, y, 10 / viewport.scale);
    draft = next;
  }
  function fitDraft() { viewport = Geometry.fit(draft, area.width, area.height, 56, 230); }
  function px(value) { return Math.round(viewport.x + value * viewport.scale); }
  function py(value) { return Math.round(viewport.y + value * viewport.scale); }

  // Borda em comum entre o monitor ativo e um vizinho: vertical ("x") ou horizontal ("y").
  readonly property var guide: {
    const moving = activeIndex >= 0 ? draft[activeIndex] : null;
    if (!moving) return null;
    for (let i = 0; i < draft.length; ++i) {
      if (i === activeIndex) continue;
      const b = draft[i];
      if (!Geometry.adjacent(moving, b)) continue;
      if (moving.x === b.x + b.width) return { axis: "x", at: moving.x };
      if (moving.x + moving.width === b.x) return { axis: "x", at: b.x };
      if (moving.y === b.y + b.height) return { axis: "y", at: moving.y };
      if (moving.y + moving.height === b.y) return { axis: "y", at: b.y };
    }
    return null;
  }

  Rectangle {
    id: area
    objectName: "arrangeCanvas"
    x: Shell.Theme.settingsBodyInset
    y: Shell.Theme.settingsBodyTop
    width: Shell.Theme.settingsRowWidth
    height: Shell.Theme.settingsArrangeAreaHeight
    radius: Shell.Theme.radiusCard
    color: Shell.Theme.cardHover
    border.width: 1
    border.color: Shell.Theme.border
    antialiasing: true
    clip: true

    Rectangle {
      objectName: "arrangeGuide"
      readonly property int inset: Shell.Theme.settingsArrangeGuideInset
      visible: !!root.guide
      color: Shell.Theme.accentText
      x: root.guide && root.guide.axis === "x" ? root.px(root.guide.at) : inset
      y: root.guide && root.guide.axis === "y" ? root.py(root.guide.at) : inset
      width: root.guide && root.guide.axis === "x" ? 1 : area.width - 2 * inset
      height: root.guide && root.guide.axis === "y" ? 1 : area.height - 2 * inset
    }

    Repeater {
      model: root.draft.length
      delegate: Display.Monitor {
        id: tile
        required property int index
        readonly property var rect: root.draft[index]
        readonly property var monitor: root.service.monitors.find(m => m.name === rect.name) || null
        objectName: "arrangeMonitor" + rect.name
        x: root.px(rect.x)
        y: root.py(rect.y)
        width: Math.max(20, root.px(rect.x + rect.width) - x)
        height: Math.max(20, root.py(rect.y + rect.height) - y)
        label: monitor ? monitor.number + " · " + monitor.label : rect.name
        detail: rect.name
        dragging: root.activeIndex === index
        hovered: dragArea.containsMouse
        z: dragging ? 2 : 1
        enabled: !root.stale && !root.service.busy
        activeFocusOnTab: enabled
        Accessible.role: Accessible.Button
        Accessible.name: label + ". Drag to arrange, or use arrow keys."

        function nudge(dx, dy) {
          const others = root.draft.filter((r, i) => i !== index);
          if (!others.length) return;
          const anchor = others.sort((a, b) => Math.hypot(a.x - rect.x, a.y - rect.y) - Math.hypot(b.x - rect.x, b.y - rect.y))[0];
          const x = dx < 0 ? anchor.x - rect.width : dx > 0 ? anchor.x + anchor.width : rect.x;
          const y = dy < 0 ? anchor.y - rect.height : dy > 0 ? anchor.y + anchor.height : rect.y;
          root.moveMonitor(index, x, y);
          root.fitDraft();
        }
        Keys.onLeftPressed: nudge(-1, 0)
        Keys.onRightPressed: nudge(1, 0)
        Keys.onUpPressed: nudge(0, -1)
        Keys.onDownPressed: nudge(0, 1)

        MouseArea {
          id: dragArea
          anchors.fill: parent
          hoverEnabled: true
          preventStealing: true
          cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
          property point origin
          property point startPosition
          onPressed: mouse => {
            tile.forceActiveFocus();
            root.draggingIndex = tile.index;
            origin = mapToItem(area, mouse.x, mouse.y);
            startPosition = Qt.point(tile.rect.x, tile.rect.y);
          }
          onPositionChanged: mouse => {
            if (!pressed) return;
            const p = mapToItem(area, mouse.x, mouse.y);
            // A vista fica parada durante o arraste, para o ponteiro não pular.
            root.moveMonitor(tile.index, startPosition.x + (p.x - origin.x) / root.viewport.scale,
                             startPosition.y + (p.y - origin.y) / root.viewport.scale);
          }
          onReleased: { root.draggingIndex = -1; root.fitDraft(); }
          onCanceled: { root.draggingIndex = -1; root.fitDraft(); }
        }
      }
    }
  }

  Text {
    id: hint
    objectName: "arrangeHint"
    x: Shell.Theme.settingsBodyInset
    y: Shell.Theme.settingsArrangeFooterTop
    width: Shell.Theme.settingsArrangeHintWidth
    readonly property bool warning: root.stale || root.service.error !== ""
    text: root.stale ? "Displays changed. Close and reopen Arrange to use the current layout."
        : root.service.error !== "" ? root.service.error
        : "Drag to position. Edges snap into place."
    wrapMode: Text.Wrap
    lineHeight: Shell.Theme.settingsDisplayLineHeight
    lineHeightMode: Text.FixedHeight
    color: warning ? Shell.Theme.dangerText : Shell.Theme.muted
    font.family: Shell.Theme.fontFamily
    font.weight: Font.Normal
    font.pixelSize: Shell.Theme.fontBody
    font.letterSpacing: 0
  }

  Row {
    id: footer
    x: Shell.Theme.settingsBodyInset + Shell.Theme.settingsRowWidth - width
    y: Shell.Theme.settingsArrangeFooterTop
    spacing: Shell.Theme.settingsEdgeMargin

    Shell.ActionButton {
      objectName: "arrangeCancel"
      width: Shell.Theme.settingsArrangeButtonWidth
      compact: true
      text: "Cancel"
      interactive: !root.service.busy
      activeFocusOnTab: !isDisabled
      Accessible.role: Accessible.Button
      Accessible.name: "Cancel arrangement"
      Accessible.onPressAction: root.cancel()
      Keys.onReturnPressed: root.cancel()
      Keys.onSpacePressed: root.cancel()
      onClicked: root.cancel()
    }

    Shell.ActionButton {
      id: done
      objectName: "arrangeDone"
      width: Shell.Theme.settingsArrangeButtonWidth
      kind: "primary"
      compact: true
      text: root.service.busy ? "Applying…" : "Done"
      interactive: !root.stale && !root.service.busy && Geometry.valid(root.draft)
      activeFocusOnTab: !isDisabled
      Accessible.role: Accessible.Button
      Accessible.name: "Apply display arrangement"
      Accessible.onPressAction: root.save()
      Keys.onReturnPressed: root.save()
      Keys.onSpacePressed: root.save()
      onClicked: root.save()
    }
  }
}
