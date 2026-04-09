#ifndef MQTTCLIENTSERVICE_H
#define MQTTCLIENTSERVICE_H

#include <QObject>
#include <QMqttClient>
#include <QMap>
#include <QVariantList>
#include <QQmlEngine>

#include "App/config.h"
#include "AuthManager.h"
#include "layers/BaseTrackMapLayer.h"
#include "interfaces/IMessageParser.h"

class MqttClientService : public QObject {
    Q_OBJECT
    QML_SINGLETON
    QML_ELEMENT

public:
    explicit MqttClientService(QObject* parent = nullptr);

    void initialize(const QString& configPath, const AppConfig& appConfig, AuthManager* authManager);
    Q_INVOKABLE void registerLayer(const QString& name, QObject* layer);

    void registerParser(const QString& topic, IBaseMessageParser* parser);
    Q_INVOKABLE QString getTopicFromLayer(const QString& layer);

    void connectToBroker();

private slots:
    void handleMessage(const QByteArray &message, const QMqttTopicName &topic);
    void onConnected();
    void onDisconnected();

private:
    void loadConfiguration(const QString& path, const AppConfig& appConfig);

    QMqttClient* client = nullptr;
    AuthManager* authManager = nullptr;
    QMap<QString, QString> topicToLayer;
    QMap<QString, QString> layerToTopic;
    QMap<QString, IBaseMessageParser*> topicToParser;
    QMap<QString, BaseTrackMapLayer*> layerInstances;
};

#endif // MQTTCLIENTSERVICE_H
