import QtQuick

// Estado de notificações fictício para a vitrine da F3 (ficha 10), com a superfície que o painel e os
// cartões usam. Nenhuma notificação real da máquina. A hora vem pronta em `timestamp` ("10 min").
QtObject {
  id: root
  readonly property var historyNotifications: [
    { id: "1", appName: "Calendário", body: "Revisão do portfólio às 15:00.",
      timestamp: "10 min", iconName: "calendar" },
    { id: "2", appName: "Mensagens", body: "Elo: o mercado chega às 18h, alguém em casa?",
      timestamp: "now", iconName: "mail" },
    { id: "3", appName: "Instalações", body: "Steam foi atualizado.",
      timestamp: "1 h", iconName: "download" }
  ]
  readonly property int notificationCount: historyNotifications.length
  readonly property var recentApps: []
  readonly property var currentTransient: historyNotifications[1]
  readonly property bool transientVisible: false

  function title(notification) { return notification ? notification.appName : ""; }
  function message(notification) { return notification ? notification.body : ""; }
  function relativeTimeLabel(timestamp) { return String(timestamp); }
  function iconSource(notification) {
    return Qt.resolvedUrl("../icons/" + notification.iconName + ".svg");
  }
  function activate(notification) {}
  function remove(notification) {}
  function clearAll() {}
}
