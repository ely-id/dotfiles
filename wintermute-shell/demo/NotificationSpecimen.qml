import QtQuick
import ".."
import "../notifications" as Notifications

// As peças de notificação de verdade com dados fictícios (ficha 10). `kind`: "center" (central com
// 3 itens), "single" (uma notificação sozinha), "toast" (288×88) ou "arrival" (cartão da barra com a
// prévia, 156×156).
Item {
  id: root
  property string kind: "center"
  implicitWidth: kind === "toast" ? 288 : kind === "arrival" ? 156 : 280
  implicitHeight: kind === "center" ? 316 : kind === "arrival" ? 156 : 88

  NotificationService { id: demoService }

  Notifications.Panel {
    visible: root.kind === "center" || root.kind === "single"
    service: demoService
    items: root.kind === "single" ? [demoService.historyNotifications[1]]
                                  : demoService.historyNotifications
  }

  Item {
    visible: root.kind === "toast"
    width: 288
    height: toast.height
    Shadow {
      anchors.fill: toast
      cornerRadius: toast.surface.radius
      shadows: Theme.glassShadows
    }
    Notifications.Card {
      id: toast
      service: demoService
      width: 288
      height: implicitHeight
      notification: demoService.historyNotifications[1]
    }
  }

  Notifications.SidebarCard {
    visible: root.kind === "arrival"
    service: demoService
    previewCount: 0
    demoArrival: true
  }
}
