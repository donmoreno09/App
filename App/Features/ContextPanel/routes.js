.pragma library

// Top-level constants for autocomplete in QML
const MapTools = "map-tools";

// Build the map using the constants
const routes = {
  [MapTools]: "qrc:/App/Features/Map/MapToolsPanel.qml",
};

// Resolver utility
function resolve(path) {
  return routes[path] ?? routes[NotFound];
}
