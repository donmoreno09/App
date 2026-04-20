#ifndef APP_CONFIG_H
#define APP_CONFIG_H

#include <QGuiApplication>
#include <QFile>
#include <QSettings>
#include <QDir>

struct AppConfig {
    QString mqttHost;
    int     mqttPort;
    QString portName;
    QString restBaseUrl;
    QString vesselFinderBaseUrl;
    bool    useVesselFinderSim;

    // Used for testing purposes. Expected string if used: {simulationId}/vessels?any-potential-options
    QString vesselsOverrideUri;
    int vfSimSpeed;

    // SignalR settings
    QString signalRBaseUrl;
};

static void ensureUserConfigExists()
{
    const QString appDir         = QCoreApplication::applicationDirPath();
    const QString userCfgPath    = appDir + "/config.ini";
    const QString defaultCfgPath = appDir + "/config.default.ini";

    if (!QFile::exists(userCfgPath) && QFile::exists(defaultCfgPath)) {
        QFile::copy(defaultCfgPath, userCfgPath);
        QFile::setPermissions(userCfgPath,
                              QFile::permissions(userCfgPath) | QFile::WriteOwner);
    }
}

static AppConfig loadConfig()
{
    const QString appDir      = QCoreApplication::applicationDirPath();
    const QString userCfgPath = appDir + "/config.ini";

    QSettings s(userCfgPath, QSettings::IniFormat);

    AppConfig cfg;
    cfg.mqttHost            = s.value("mqtt/host", "localhost").toString();
    cfg.mqttPort            = s.value("mqtt/port", 1883).toInt();
    cfg.portName            = s.value("mqtt/portName", "unknown").toString();
    cfg.restBaseUrl         = s.value("rest/baseUrl", "http://localhost:7000").toString();
    cfg.vesselFinderBaseUrl = s.value("rest/vesselFinderBaseUrl", "http://localhost:8000").toString();
    cfg.useVesselFinderSim  = s.value("rest/useVesselFinderSim", false).toBool();
    cfg.vesselsOverrideUri  = s.value("rest/vesselsOverrideUri", "").toString(); // Expected string if used: {simulationId}/vessels?any-potential-options
    cfg.vfSimSpeed          = s.value("rest/vfSimSpeed", 1).toInt();

    // Load SignalR settings
    cfg.signalRBaseUrl   = s.value("signalr/baseUrl", "ws://localhost:7000/hubs/notifications").toString();

    return cfg;
}

#endif // APP_CONFIG_H
