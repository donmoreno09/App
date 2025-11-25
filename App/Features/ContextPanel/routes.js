.pragma library

// Top-level constants for autocomplete in QML
const MapTools = "map-tools";
const NotFound = "*";

// Build the map using the constants
const routes = {
  [MapTools]: "qrc:/App/Features/Map/MapToolsPanel.qml",
  [NotFound]: "qrc:/App/Features/SidePanel/NotFoundPanel.qml",
};

// Resolver utility
function resolve(path) {
  return routes[path] ?? routes[NotFound];
}
