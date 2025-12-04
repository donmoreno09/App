#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDir>
#include <App/config.h>
#include <App/Logger/app_logger.h>
#include <App/Features/Map/PluginProbe.h>
#include <QFontDatabase>
#include <QDebug>
#include <QIcon>
#include <core/TrackManager.h>
#include <connections/ApiEndpoints.h>
#include <connections/mqtt/MqttClientService.h>
#include <connections/mqtt/parser/TrackParser.h>
#include <connections/mqtt/parser/TirParser.h>
#include <connections/signalr/SignalRClientService.h>
#include <connections/signalr/parser/TruckNotificationSignalRParser.h>
#include <connections/signalr/parser/AlertZoneNotificationParser.h>

#include <QtWebEngineQuick/qtwebenginequickglobal.h>

int main(int argc, char *argv[])
{
    // Set QSG_RHI_BACKEND (rendering backend) to OpenGL in order for MapLibre to work.
    qputenv("QSG_RHI_BACKEND", "opengl");

    qputenv("QML_XHR_ALLOW_FILE_READ", "1");

    // This tells Chromium to handle GPU gracefully
    // This flag tells Qt to share OpenGL contexts between different components of the application.
    QCoreApplication::setAttribute(Qt::AA_ShareOpenGLContexts);

    qputenv("QTWEBENGINE_CHROMIUM_FLAGS",
            "--disable-gpu-shader-disk-cache " // Might reduce mismatches
            "--enable-gpu-rasterization " // Chromium creates a dedicated process for GPU rendering
            "--enable-zero-copy "         // Reduces data copying between CPU and GPU
            "--enable-hardware-overlays " // Uses hardware layers for faster composition
            "--num-raster-threads=4 "   // Parallelizes rendering across multiple threads
            "--disable-logging");

    QtWebEngineQuick::initialize();

    QGuiApplication app(argc, argv);
    app.setWindowIcon(QIcon(":/App/assets/logo-app.ico"));

    ensureUserConfigExists();
    AppConfig appConfig = loadConfig();

    ApiEndpoints::BaseUrl = appConfig.restBaseUrl;

    QCoreApplication::setOrganizationName("IRIDESS");
    QCoreApplication::setApplicationName("IRIDESS_FE");
    QCoreApplication::setApplicationVersion("1.0.0");

    auto& logger = AppLogger::get();
    logger.info("App start", {kv("version", "1.0.0")});

    QQmlApplicationEngine engine;

    const QStringList fontFiles = {
        ":/App/assets/fonts/PPFraktionSans-Light.otf",
        ":/App/assets/fonts/PPFraktionSans-LightItalic.otf",
        ":/App/assets/fonts/PPFraktionSans-Bold.otf",
        ":/App/assets/fonts/PPFraktionSans-BoldItalic.otf",
        ":/App/assets/fonts/PPFraktionMono-Regular.otf",
        ":/App/assets/fonts/PPFraktionMono-RegularItalic.otf",
        ":/App/assets/fonts/PPFraktionMono-Bold.otf",
        ":/App/assets/fonts/PPFraktionMono-BoldItalic.ttf"
    };

    for (const QString& fontFile : fontFiles) {
        int fontId = QFontDatabase::addApplicationFont(fontFile);
        if (fontId == -1) {
            // qWarning() << "Failed to load font:" << fontFile;
        } else {
            QStringList families = QFontDatabase::applicationFontFamilies(fontId);
            // qDebug() << "Loaded font:" << fontFile << "-> Families:" << families;
        }
    }

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    engine.addImportPath("qrc:/"); // For more info: https://doc.qt.io/qt-6/qt-add-qml-module.html#resource-prefix

    auto *mqtt = engine.singletonInstance<MqttClientService*>("App", "MqttClientService");
    mqtt->initialize(":/App/config/mqtt_config.json", appConfig);
    mqtt->registerParser("ais", new TrackParser());
    mqtt->registerParser("doc-space", new TrackParser());
    mqtt->registerParser("tir", new TirParser());

    auto *trackManager = engine.singletonInstance<TrackManager*>("App", "TrackManager");
    trackManager->deactivate("ais");
    trackManager->deactivate("doc-space");
    trackManager->deactivate("tir");

    // SIGNALR SETUP

    auto *signalR = engine.singletonInstance<SignalRClientService*>("App", "SignalRClientService");

    // Register parsers for each EventType
    signalR->registerParser(0, new TruckNotificationSignalRParser());  // TirAppIssueCreated
    signalR->registerParser(1, new TruckNotificationSignalRParser());  // TirAppIssueResolved
    signalR->registerParser(2, new AlertZoneNotificationParser());     // ControlRoomAlertZoneIntrusion

    // Register handler
    signalR->registerHandler("ReceiveNotification", [signalR](const QVariantList& args) {
        signalR->handleNotification(args);
    });

    // Initialize connection
    signalR->initialize(appConfig);

    qDebug() << "[Main] ✅ SignalR service initialized";

    engine.loadFromModule("App", "Main");

    // Uncomment the block below to list available map plugins to use
    // const auto& plugins = probeGeoPlugins();
    // qDebug() << "Listing available map plugins:";
    // for (const auto& plugin : plugins) {
    //     qDebug() << plugin.name;
    // }

    return app.exec();
}
