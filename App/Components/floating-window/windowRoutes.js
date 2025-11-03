// windowRoutes.js
.pragma library

const STOWAGE   = "stowage";
const REPORTS   = "reports";
const ANALYTICS = "analytics";
const NOTFOUND  = "*";
const GOLIATH = "goliath";
const GOLIATHCSV = "goliath-csv";
const GOLIATHLIFTEDLOADS = "goliath-lifted-loads";

var routes = Object.freeze({
    [STOWAGE]: {
        url: "qrc:/App/Features/ShipStowage/components/WebViewContainer.qml",
        singleton: true,
        defaultProps: { title: "Ship Stowage" },
        initialGeometry: { x: 96, y: 72, width: 1100, height: 720 },
        modal: false,
        resizable: true
    },
    [GOLIATH]: {
       url: "qrc:/App/Features/Poi/GoliathVideoContainer.qml",
       singleton: false,
       defaultProps: { title: "Goliath Video" },
       initialGeometry: { x: 120, y: 96, width: 1000, height: 680 },
       modal: false,
       resizable: true
    },
   [GOLIATHCSV]: {
        url: "qrc:/App/Features/Poi/GoliathDataCsv.qml",
        singleton: false,
        defaultProps: { title: "Goliath Data Csv" },
        initialGeometry: { x: 120, y: 96, width: 1000, height: 680 },
        modal: false,
        resizable: true
    },
    [GOLIATHLIFTEDLOADS]: {
        url: "qrc:/App/Features/Poi/GoliathLiftedLoads.qml",
        singleton: false,
        defaultProps: { title: "Goliath Lifted Loads" },
        initialGeometry: { x: 120, y: 96, width: 1000, height: 680 },
        modal: false,
        resizable: true
    },
    [ANALYTICS]: {
        url: "qrc:/App/Features/Analytics/AnalyticsWindow.qml",
        singleton: false,
        defaultProps: { title: "Analytics" },
        initialGeometry: { x: 140, y: 110, width: 1200, height: 740 },
        modal: false,
        resizable: true
    },
    [NOTFOUND]: {
        url: "qrc:/App/Features/Generic/NotFoundWindow.qml",
        singleton: true,
        defaultProps: { title: "Not Found" },
        initialGeometry: { x: 80, y: 60, width: 800, height: 500 },
        modal: false,
        resizable: false
    }
});

function has(name) { return routes.hasOwnProperty(name); }
function get(name) { return routes[name] || routes[NOTFOUND]; }
function list()    { return Object.keys(routes); }

var Names = Object.freeze({
    STOWAGE, REPORTS, ANALYTICS, NOTFOUND
});
