#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDir>
#include <App/Logger/app_logger.h>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QCoreApplication::setOrganizationName("IRIDESS");
    QCoreApplication::setApplicationName("IRIDESS_FE");
    QCoreApplication::setApplicationVersion("1.0.0");

    QQmlApplicationEngine engine;

    auto& logger = AppLogger::get();
    logger.info("App start", {kv("version", "1.0.0")});

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    engine.addImportPath("qrc:/"); // For more info: https://doc.qt.io/qt-6/qt-add-qml-module.html#resource-prefix
    engine.loadFromModule("App", "Main");

    return app.exec();
}
