#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDir>
#include <App/Logger/app_logger.h>
#include <App/Features/Map/PluginProbe.h>
#include <QFontDatabase>
#include <QDebug>
#include <core/TrackManager.h>
#include <connections/mqtt/MqttClientService.h>
#include <connections/mqtt/parser/TrackParser.h>
#include <connections/mqtt/parser/TirParser.h>
#include <QtWebEngineQuick/qtwebenginequickglobal.h>

int main(int argc, char *argv[])
{

    // CRITICAL: Configure WebEngine BEFORE creating QGuiApplication
    // This tells Chromium to handle GPU gracefully
    QCoreApplication::setAttribute(Qt::AA_ShareOpenGLContexts);

    // Fix GPU issues by running GPU in main process instead of separate process
    // This prevents the "Failed to create command buffer" error
    qputenv("QTWEBENGINE_CHROMIUM_FLAGS",
            "--disable-gpu-process-crash-limit "
            "--in-process-gpu "
            "--disable-dev-shm-usage "
            "--no-sandbox");

    // Initialize WebEngine BEFORE QGuiApplication
    // This ensures proper setup of Chromium backend
    QtWebEngineQuick::initialize();

    QGuiApplication app(argc, argv);

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
    mqtt->initialize(":/App/config/mqtt_config.json");
    mqtt->registerParser("ais", new TrackParser());
    mqtt->registerParser("doc-space", new TrackParser());
    mqtt->registerParser("tir", new TirParser());

    auto *trackManager = engine.singletonInstance<TrackManager*>("App", "TrackManager");
    trackManager->deactivate("ais");
    trackManager->deactivate("doc-space");
    trackManager->deactivate("tir");

    engine.loadFromModule("App", "Main");

    // Uncomment the block below to list available map plugins to use
    // const auto& plugins = probeGeoPlugins();
    // qDebug() << "Listing available map plugins:";
    // for (const auto& plugin : plugins) {
    //     qDebug() << plugin.name;
    // }

    return app.exec();
}
