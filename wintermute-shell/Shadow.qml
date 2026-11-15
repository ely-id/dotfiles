pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects

// Sombras de duas camadas do vidro Armitage (0,2 blur 6 α 0,30 + 0,12 blur 32 α 0,45).
Item {
  id: root

  property real cornerRadius: Theme.radiusCard
  property var shadows: Theme.glassShadows
  property real strength: 1.0

  Repeater {
    model: root.shadows

    delegate: RectangularShadow {
      required property var modelData

      anchors.fill: parent
      offset: Qt.vector2d(modelData.x, modelData.y)
      radius: root.cornerRadius
      blur: modelData.blur
      spread: 0
      color: Qt.rgba(0, 0, 0, modelData.alpha * root.strength)
      antialiasing: true
      cached: false
    }
  }
}
