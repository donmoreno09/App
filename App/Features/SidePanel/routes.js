.pragma library

// Top-level constants for autocomplete in QML
const Languages = "languages";
const Mission = "mission";
const Pod = "pod";
const Notifications = "notifications";
const MapTilesets = "maptilesets";
const MapLayers = "maplayers";
const DateTimeTest = "datetime-test";
const ToggleTest = "toggle-test";
const TextAreaTest = "textarea-test";
const OverlayTest = "overlay-test";
const SwitcherTest = "switcher-test";
const SliderTest = "slider-test";
const ModalTest = "modal-test";
const ButtonTest = "button-test";
const ArrivalContentTest = "arrival-content-test";
const ArrivalDateContentTest = "arrival-date-content-test";
const ArrivalDateTimeContentTest = "arrival-date-time-content-test";
const NotFound = "*";

// Build the map using the constants
const routes = {
  [Languages]: "qrc:/App/Features/Language/LanguagePanel.qml",
  [Mission]: "qrc:/App/Features/Mission/MissionPanel.qml",
  [Notifications]: "qrc:/App/Features/Notifications/NotificationsPanel.qml",
  [MapTilesets]: "qrc:/App/Features/Map/MapTilesetsPanel.qml",
  [MapLayers]: "qrc:/App/layers/LayersPanel.qml",
  [DateTimeTest]: "qrc:/App/Playground/DateTimePickerPanel.qml",
  [ToggleTest]: "qrc:/App/Playground/TogglePanel.qml",
  [TextAreaTest]: "qrc:/App/Playground/TextAreaPanel.qml",
  [OverlayTest]: "qrc:/App/Playground/OverlayPanel.qml",
  [SwitcherTest]: "qrc:/App/Playground/SwitcherPanel.qml",
  [SliderTest]: "qrc:/App/Playground/SliderPanel.qml",
  [ModalTest]: "qrc:/App/Playground/ModalPanel.qml",
  [ButtonTest]: "qrc:/App/Playground/ButtonPanel.qml",
  [ArrivalContentTest]: "qrc:/App/Features/TruckArrivals/panels/ArrivalsCountPanel.qml",
  [ArrivalDateContentTest]: "qrc:/App/Features/TruckArrivals/panels/ArrivalsDatePanel.qml",
  [ArrivalDateTimeContentTest]: "qrc:/App/Features/TruckArrivals/panels/ArrivalsDateTimePanel.qml",
  [NotFound]: "qrc:/App/Features/SidePanel/NotFoundPanel.qml",
};

// Resolver utility
function resolve(path) {
  return routes[path] ?? routes[NotFound];
}
