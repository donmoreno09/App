const routes = {
  language: "qrc:/App/Features/Language/LanguagePanel.qml",
  mission: "qrc:/App/Features/Mission/MissionPanel.qml",
  notifications: "qrc:/App/Features/Notifications/NotificationsPanel.qml",
  maptilesets: "qrc:/App/Features/Map/MapTilesetsPanel.qml",
  maplayers: "qrc:/App/layers/LayersPanel.qml",
  "datetime-test": "qrc:/App/Playground/DateTimePickerPanel.qml",
  "toggle-test": "qrc:/App/Playground/TogglePanel.qml",
  "textarea-test": "qrc:/App/Playground/TextAreaPanel.qml",
  "overlay-test": "qrc:/App/Playground/OverlayPanel.qml",
  "switcher-test": "qrc:/App/Playground/SwitcherPanel.qml",
  "slider-test": "qrc:/App/Playground/SliderPanel.qml",
  "modal-test": "qrc:/App/Playground/ModalPanel.qml",
  "button-test": "qrc:/App/Playground/ButtonPanel.qml",
  "arrival-content-test":        "qrc:/App/Features/TruckArrivals/panels/ArrivalsCountPanel.qml",
  "arrival-date-content-test":   "qrc:/App/Features/TruckArrivals/panels/ArrivalsDatePanel.qml",
  "arrival-date-time-content-test": "qrc:/App/Features/TruckArrivals/panels/ArrivalsDateTimePanel.qml",
  "*":      "qrc:/App/Features/SidePanel/NotFoundPanel.qml",
};

function resolve(path) {
  return routes[path] ?? routes["*"];
}
