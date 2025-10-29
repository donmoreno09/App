.pragma library

// Top-level constants for autocomplete in QML
const Languages = "languages";
const Mission = "mission";
const Pod = "pod";
const Notifications = "notifications";
const MapTilesets = "maptilesets";
const MapLayers = "maplayers";
const Poi = "poi";
const DateTimeTest = "datetime-test";
const ToggleTest = "toggle-test";
const TextAreaTest = "textarea-test";
const OverlayTest = "overlay-test";
const SwitcherTest = "switcher-test";
const SliderTest = "slider-test";
const ModalTest = "modal-test";
const ButtonTest = "button-test";
const ComboBoxTest = "combobox-test";
const ArrivalContent = "arrival-content";
const ArrivalDateContent = "arrival-date-content";
const ArrivalDateTimeContent = "arrival-date-time-content";
const TrailerPrediction = "trailer-prediction"
const ViGateServices = "viGate-services"
const TrackPanel = "trackpanel"
const TirPanel = "tirpanel"
const NotFound = "*";

// Build the map using the constants
const routes = {
  [Languages]: "qrc:/App/Features/Language/LanguagePanel.qml",
  [Mission]: "qrc:/App/Features/Mission/MissionPanel.qml",
  [Notifications]: "qrc:/App/Features/Notifications/NotificationsPanel.qml",
  [MapTilesets]: "qrc:/App/Features/Map/MapTilesetsPanel.qml",
  [MapLayers]: "qrc:/App/layers/LayersPanel.qml",
  [Poi]: "qrc:/App/Features/Poi/PoiPanel.qml",
  [TrackPanel]: "qrc:/App/Features/TrackPanel/TrackPanel.qml",
  [TirPanel]: "qrc:/App/Features/TrackPanel/TrackPanel.qml",
  [DateTimeTest]: "qrc:/App/Playground/DateTimePickerPanel.qml",
  [ToggleTest]: "qrc:/App/Playground/TogglePanel.qml",
  [TextAreaTest]: "qrc:/App/Playground/TextAreaPanel.qml",
  [OverlayTest]: "qrc:/App/Playground/OverlayPanel.qml",
  [SwitcherTest]: "qrc:/App/Playground/SwitcherPanel.qml",
  [SliderTest]: "qrc:/App/Playground/SliderPanel.qml",
  [ModalTest]: "qrc:/App/Playground/ModalPanel.qml",
  [ButtonTest]: "qrc:/App/Playground/ButtonPanel.qml",
  [ComboBoxTest] : "qrc:/App/Playground/ComboBoxPanel.qml",
  [ArrivalContent]: "qrc:/App/Features/TruckArrivals/panels/ArrivalsCountPanel.qml",
  [ArrivalDateContent]: "qrc:/App/Features/TruckArrivals/panels/ArrivalsDatePanel.qml",
  [ArrivalDateTimeContent]: "qrc:/App/Features/TruckArrivals/panels/ArrivalsDateTimePanel.qml",
  [TrailerPrediction] : "qrc:/App/Features/TrailerPredictions/panels/TrailersPredictionsPanel.qml",
  [ViGateServices] : "qrc:/App/Features/ViGateServices/panels/ViGatePanel.qml",
  [NotFound]: "qrc:/App/Features/SidePanel/NotFoundPanel.qml",
};

// Resolver utility
function resolve(path) {
  return routes[path] ?? routes[NotFound];
}
