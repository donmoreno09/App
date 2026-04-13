#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDir>
#include <QFontDatabase>
#include <QIcon>
#include <QtWebEngineQuick/qtwebenginequickglobal.h>
#include <QtQml/qqmlextensionplugin.h>

#include "App/config.h"
#include "core/TrackManager.h"
#include "Auth/AuthManager.h"
#include "Auth/PermissionManager.h"
#include "Auth/SecureTokenStorage.h"
#include "Networking/apis/AuthApi.h"
#include "models/AlertZoneModel.h"
#include "models/PoiModel.h"
#include "core/PoiOptions.h"
#include "ViGateController.h"
#include "connections/ApiEndpoints.h"
#include "connections/http/VesselFinderHttpService.h"
#include "connections/http/parser/HttpVesselParser.h"
#include "connections/mqtt/MqttClientService.h"
#include "connections/mqtt/parser/TrackParser.h"
#include "connections/mqtt/parser/TirParser.h"
#include "connections/signalr/SignalRClientService.h"
#include "connections/signalr/parser/TruckNotificationSignalRParser.h"
#include "connections/signalr/parser/AlertZoneNotificationParser.h"
#include "AppLogger.h"

Q_IMPORT_QML_PLUGIN(App_LoggerPlugin)
Q_IMPORT_QML_PLUGIN(App_NetworkingPlugin)
Q_IMPORT_QML_PLUGIN(App_Features_LanguagePlugin)
Q_IMPORT_QML_PLUGIN(App_Features_TruckArrivalsPlugin)
Q_IMPORT_QML_PLUGIN(App_Features_TrailerPredictionsPlugin)
Q_IMPORT_QML_PLUGIN(App_Features_ViGateServicesPlugin)

#include "HttpClient.h"

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
    if (appConfig.useVesselFinderSim) ApiEndpoints::BaseClustersUrl = appConfig.vesselFinderBaseUrl + "/clusters";

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
            logger.info("Failed to load font: " + fontFile, { kv("file", fontFile) });
        } else {
            QStringList families = QFontDatabase::applicationFontFamilies(fontId);
        }
    }

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    engine.addImportPath("qrc:/"); // For more info: https://doc.qt.io/qt-6/qt-add-qml-module.html#resource-prefix

    // --- Auth Service ---

    auto* authHttpClient = new HttpClient(&app);
    auto* appHttpClient  = new HttpClient(QUrl(appConfig.restBaseUrl), &app); // shared authenticated client for all protected APIs

    auto* authApi      = new AuthApi(authHttpClient, &app);
    auto* tokenStorage = new SecureTokenStorage(&app);

    auto* authManager    = engine.singletonInstance<AuthManager*>("App.Auth", "AuthManager");
    auto* permManager    = engine.singletonInstance<PermissionManager*>("App.Auth", "PermissionManager");
    auto* alertZoneModel  = engine.singletonInstance<AlertZoneModel*>("App", "AlertZoneModel");
    auto* poiModel        = engine.singletonInstance<PoiModel*>("App", "PoiModel");
    auto* poiOptions      = engine.singletonInstance<PoiOptions*>("App", "PoiOptions");
    auto* trackManager    = engine.singletonInstance<TrackManager*>("App", "TrackManager");
    auto* viGateController = engine.singletonInstance<ViGateController*>("App.Features.ViGateServices", "ViGateController");
    auto *signalR = engine.singletonInstance<SignalRClientService*>("App", "SignalRClientService");

    QObject::connect(authManager, &AuthManager::tokenChanged, appHttpClient, [appHttpClient](const QByteArray& token) {
        if (token.isEmpty())
            appHttpClient->clearBearerToken();
        else
            appHttpClient->setBearerToken(token);
    });

    // Inject the shared client
    alertZoneModel->initialize(appHttpClient);
    poiModel->initialize(appHttpClient);
    poiOptions->initialize(appHttpClient);
    trackManager->initialize(appHttpClient);
    viGateController->initialize(appHttpClient);

    // --- SignalR Setup ---

    signalR->registerParser(0, new TruckNotificationSignalRParser());  // TirAppIssueCreated
    signalR->registerParser(1, new TruckNotificationSignalRParser());  // TirAppIssueResolved
    signalR->registerParser(2, new AlertZoneNotificationParser());     // ControlRoomAlertZoneIntrusion

    signalR->registerHandler("ReceiveNotification", [signalR](const QVariantList& args) {
        signalR->handleNotification(args);
    });

    // --- MQTT Client Service ---

    auto *mqtt = engine.singletonInstance<MqttClientService*>("App", "MqttClientService");
    mqtt->registerParser("ais", new TrackParser());
    mqtt->registerParser("doc-space", new TrackParser());
    mqtt->registerParser("tir", new TirParser());
    mqtt->registerParser("vesselfinder", new HttpVesselParser());

    // Wire all loginSucceeded/loggedOut connections BEFORE tryAutoLogin()
    // so auto-login (which fires loginSucceeded synchronously) is caught correctly.
    QObject::connect(authManager, &AuthManager::loginSucceeded, alertZoneModel,   &AlertZoneModel::fetch);
    QObject::connect(authManager, &AuthManager::loginSucceeded, poiModel,         &PoiModel::fetch);
    QObject::connect(authManager, &AuthManager::loginSucceeded, poiOptions,       &PoiOptions::fetchAll);
    QObject::connect(authManager, &AuthManager::loginSucceeded, viGateController, &ViGateController::loadActiveGates);
    QObject::connect(authManager, &AuthManager::loginSucceeded, signalR, [signalR, appConfig, authManager]() {
        signalR->initialize(appConfig, authManager->accessToken(), authManager->userId());
    });
    QObject::connect(authManager, &AuthManager::loginSucceeded, mqtt, [mqtt, appConfig, authManager]() {
        mqtt->initialize(":/App/config/mqtt_config.json", appConfig, authManager);
    });
    QObject::connect(authManager, &AuthManager::loginSucceeded, trackManager, &TrackManager::deactivateAll);

    QObject::connect(authManager, &AuthManager::loggedOut, signalR, &SignalRClientService::disconnectFromHub);

    authManager->initialize(authApi, tokenStorage, permManager);
    authManager->tryAutoLogin();

    // If MqttClientService for some reason didn't connect or was disconnected,
    // reconnect when a track has been activated.
    QObject::connect(trackManager, &TrackManager::activated, mqtt, [mqtt]{
        mqtt->connectToBroker();
    });

    // // --- HTTP VesselFinder Service ---
    auto* vesselHttp = engine.singletonInstance<VesselFinderHttpService*>("App", "VesselFinderHttpService");
    vesselHttp->registerParser(new HttpVesselParser());
    if (!appConfig.useVesselFinderSim) {
        vesselHttp->initialize(appConfig.vesselFinderBaseUrl, 2000);
    } else if (appConfig.vesselsOverrideUri != "") {
        vesselHttp->initialize(appConfig.vesselFinderBaseUrl + "/simulation/" + appConfig.vesselsOverrideUri, 2000);
    } else {
        HttpClient* httpClient = new HttpClient(&engine);
        httpClient->post(appConfig.vesselFinderBaseUrl + "/simulation", QByteArray{}, [&vesselHttp, &engine, &appConfig, &logger](QRestReply& reply) {
            if (!reply.isSuccess()) {
                logger.withService("VESSELFINDER").warn("Could not create simulation", { kv("url", appConfig.vesselFinderBaseUrl) });
                return;
            }

            auto doc = reply.readJson();
            if (!doc || !doc->isObject()) {
                logger.withService("VESSELFINDER").warn("Unexpected JSON type while creating simulation", { kv("url", appConfig.vesselFinderBaseUrl) });
                return;
            }

            auto obj = doc->object();
            QString simulationId = obj["simulationId"].toString();
            logger.withService("VESSELFINDER").warn("Created simulation", { kv("id", simulationId), kv("url", appConfig.vesselFinderBaseUrl) });

            QString url = appConfig.vesselFinderBaseUrl + "/simulation/" + simulationId + "/vessels";
            if (appConfig.vfSimSpeed != 1) url += QString("?speed=%1").arg(appConfig.vfSimSpeed);
            vesselHttp->initialize(url, 2000);
        });
    }

    engine.loadFromModule("App", "Main");

    return app.exec();
}
