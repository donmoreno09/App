#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "core/layermanager.h"
#include "core/interactionmodemanager.h"
#include "core/popupmanager.h"
#include "events/selectionboxbus.h"
#include "layers/baselayer.h"
#include "layers/basemaplayer.h"
#include "layers/trackmaplayer.h"
#include "layers/staticpoimaplayer.h"
#include "layers/annotationmaplayer.h"
#include "core/thirdparty/ShipArrivalController.h"
#include "core/thirdparty/TrailersPredictionsController.h"
#include "controllers/poicontroller.h"
#include "controllers/poioptionscontroller.h"
#include "controllers/shapecontroller.h"
#include "controllers/radialmenucontroller.h"
#include "core/variantlistmodel.h"
#include "connections/mqtt/mqttclientservice.h"
#include "connections/mqtt/parser/simpletrackparser.h"
#include <QDir>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    qmlRegisterSingletonType<InteractionModeManager>("raise.singleton.interactionmanager", 1, 0, "InteractionModeManager", [](QQmlEngine*, QJSEngine*) -> QObject* {
        return InteractionModeManager::getInstance();
    });

    qmlRegisterSingletonType<LayerManager>("raise.singleton.layermanager", 1, 0, "LayerManager", [](QQmlEngine*, QJSEngine*) -> QObject* {
       return LayerManager::getInstance();
    });

    qmlRegisterSingletonType<PopupManager>("raise.singleton.popupmanager", 1, 0, "PopupManager", &PopupManager::singletonProvider);
    qmlRegisterSingletonType<SelectionBoxBus>("raise.singleton.selectionboxbus", 1, 0, "SelectionBoxBus", &SelectionBoxBus::singletonProvider);

    qmlRegisterUncreatableType<BaseLayer>("raise.map.layers", 1, 0, "BaseLayer", "BaseLayer is abstract");
    qmlRegisterUncreatableType<BaseMapLayer>("raise.map.layers", 1, 0, "BaseMapLayer", "BaseMapLayer is abstract");

    qmlRegisterType<TrackMapLayer>("raise.map.layers", 1, 0, "TrackMapLayer");
    qmlRegisterType<StaticPoiMapLayer>("raise.map.layers", 1, 0, "StaticPoiMapLayer");
    qmlRegisterType<AnnotationMapLayer>("raise.map.layers", 1, 0, "AnnotationMapLayer");
    qmlRegisterType<ShipArrivalController>("ShipArrivalController", 1, 0, "ShipArrivalController");
    qmlRegisterType<TrailersPredictionsController>("TrailersPredictionsController", 1, 0, "TrailersPredictionsController");

    qmlRegisterType<VariantListModel>("raise.core.models", 1, 0, "VariantListModel");

    qRegisterMetaType<BaseLayer*>("BaseLayer*");

    // Registry Controllers
    qmlRegisterSingletonInstance("raise.singleton.controllers", 1, 0, "PoiController", new PoiController());
    qmlRegisterSingletonInstance("raise.singleton.controllers", 1, 0, "PoiOptionsController", new PoiOptionsController());
    qmlRegisterSingletonInstance("raise.singleton.controllers", 1, 0, "ShapeController", new ShapeController());
    qmlRegisterSingletonInstance("raise.singleton.radialmenucontroller", 1, 0, "RadialMenuController", new RadialMenuController());

    qmlRegisterSingletonInstance("raise.singleton.mqtt", 1, 0, "MqttClientService", MqttClientService::getInstance());

    QString configPath = QDir(QCoreApplication::applicationDirPath()).filePath("config/mqtt_config.json");

    MqttClientService::getInstance()->initialize(":/config/mqtt_config.json");
    MqttClientService::getInstance()->registerParser("ais", new SimpleTrackParser());
    // MqttClientService::getInstance()->registerParser("doc-space", new SimpleTrackParser());

    QQmlApplicationEngine engine;
    qDebug() << "QML import paths:" << engine.importPathList();
    engine.load(QUrl(QStringLiteral("qrc:/components/main.qml")));

    if (engine.rootObjects().isEmpty())
        return -1;

    int result = app.exec();
    // delete wmsBaseMapLayer;

    return result;
}
