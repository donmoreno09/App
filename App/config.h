#ifndef APP_CONFIG_H
#define APP_CONFIG_H

#include <QGuiApplication>
#include <QFile>
#include <QSettings>
#include <QDir>

struct AppConfig {
    QString mqttHost;
    int     mqttPort;
    QString restBaseUrl;

    // SignalR settings
    QString signalRHost;
    int     signalRPort;
    QString signalRApiKey;
    QString signalRUserId;
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
    cfg.mqttHost      = s.value("mqtt/host", "localhost").toString();
    cfg.mqttPort      = s.value("mqtt/port", 1883).toInt();
    cfg.restBaseUrl   = s.value("rest/baseUrl", "http://localhost:7000").toString();

    // Load SignalR settings
    cfg.signalRHost   = s.value("signalr/host", "localhost").toString();
    cfg.signalRPort   = s.value("signalr/port", 7007).toInt();
    cfg.signalRApiKey = s.value("signalr/apiKey", "IRIDESS_CONTROL_ROOM").toString();
    cfg.signalRUserId = s.value("signalr/userId", "control-room-user").toString();

    return cfg;
}

#endif // APP_CONFIG_H
