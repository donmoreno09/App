const routes = {
  language: "qrc:/App/Features/Language/LanguagePanel.qml",
  mission: "qrc:/App/Features/Mission/MissionPanel.qml",
  notifications: "qrc:/App/Features/Notifications/NotificationsPanel.qml",
  "datetime-test": "qrc:/App/Playground/DateTimePickerPanel.qml",
  "*":      "qrc:/App/Features/SidePanel/NotFoundPanel.qml",
};

function resolve(path) {
  return routes[path] ?? routes["*"];
}
