#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDir>
#include <App/Logger/app_logger.h>
#include <QFontDatabase>
#include <QDebug>

int main(int argc, char *argv[])
{
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
    engine.loadFromModule("App", "Main");

    return app.exec();
}
