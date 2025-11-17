#include "MqttClientService.h"
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QDebug>
#include <QVector>
#include <layers/TrackMapLayer.h>
#include <layers/TirMapLayer.h>
#include "parser/TrackParser.h"
#include "parser/TruckNotificationParser.h"
#include "parser/TirParser.h"

MqttClientService::MqttClientService(QObject* parent)
    : QObject(parent), client(new QMqttClient(this)) {
    connect(client, &QMqttClient::messageReceived, this, &MqttClientService::handleMessage);
    connect(client, &QMqttClient::connected, this, &MqttClientService::onConnected);
    connect(client, &QMqttClient::disconnected, this, &MqttClientService::onDisconnected);
}

void MqttClientService::initialize(const QString& configPath) {
    loadConfiguration(configPath);
    connectToBroker();
}

void MqttClientService::loadConfiguration(const QString& path) {
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "[MQTT] Failed to open configuration file:" << path;
        return;
    }

    QJsonParseError err;
    QJsonDocument doc = QJsonDocument::fromJson(file.readAll(), &err);
    if (err.error != QJsonParseError::NoError) {
        qWarning() << "[MQTT] JSON parsing error in configuration:" << err.errorString();
        return;
    }

    QJsonObject root = doc.object();
    QJsonObject mqttConfig = root["mqtt"].toObject();
    client->setHostname(mqttConfig["host"].toString());
    client->setPort(mqttConfig["port"].toInt());

    QJsonObject topics = root["topics"].toObject();
    for (auto it = topics.begin(); it != topics.end(); it++) {
        const QString &topic = it.key();
        QString layer = topics[topic].toString();
        topicToLayer[topic] = layer;
        layerToTopic[layer] = topic;
    }
}

void MqttClientService::connectToBroker() {
    client->setClientId("RaiseMqttClient");
    client->connectToHost();
}

void MqttClientService::onConnected() {
    qDebug() << "[MQTT] Connected to broker";
    for (auto it = topicToLayer.begin(); it != topicToLayer.end(); it++) {
        const QString &topic = it.key();
        client->subscribe(topic);
        qDebug() << "[MQTT] Subscribed to topic:" << topic;
    }
}

void MqttClientService::onDisconnected() {
    qDebug() << "[MQTT] Disconnected from broker";
}

void MqttClientService::registerLayer(const QString& name, QObject* layer) {
    auto* casted = qobject_cast<BaseTrackMapLayer*>(layer);
    if (casted) {
        layerInstances[name] = casted;
        qDebug() << "[MQTT] Layer registered:" << name;
    } else {
        qWarning() << "[MQTT] Error: provided object is not a valid BaseTrackMapLayer instance";
    }
}

void MqttClientService::registerParser(const QString& topic, IBaseMessageParser* parser) {
    topicToParser[topic] = parser;
    qDebug() << "[MQTT] Parser registered for topic:" << topic;
}

QString MqttClientService::getTopicFromLayer(const QString &layer)
{
    return layerToTopic.value(layer);
}

void MqttClientService::handleMessage(const QByteArray& message, const QMqttTopicName& topicName) {
    QString topic = topicName.name();
    if (!topicToParser.contains(topic)) {
        qWarning() << "[MQTT] No parser available for topic:" << topic;
        return;
    }

    // Special handling for notifications topic
    if (topic == "trucknotifications") {
        auto* baseParser = topicToParser.value(topic);
        if (auto* notificationParser = dynamic_cast<TruckNotificationParser*>(baseParser)) {
            QVector<TruckNotification> data = notificationParser->parse(message);

            // Get the singleton model instance
            auto* engine = qmlEngine(this);
            if (engine) {
                auto* model = engine->singletonInstance<TruckNotificationModel*>("App", "TruckNotificationModel");
                if (model) {
                    model->upsert(data);
                    // qDebug() << "[MQTT] Updated" << data.size() << "truck notifications";
                } else {
                    qWarning() << "[MQTT] TruckNotificationModel singleton not found";
                }
            }
        }
        return;
    }

    if (!topicToLayer.contains(topic)) {
        qWarning() << "[MQTT] No layer associated with topic:" << topic;
        return;
    }
    QString layerName = topicToLayer.value(topic);
    if (!layerInstances.contains(layerName)) {
        qWarning() << "[MQTT] Target layer not registered:" << layerName;
        return;
    }

    auto* baseParser = topicToParser.value(topic);

    if (auto* trackParser = dynamic_cast<TrackParser*>(baseParser)) {
        QVector<Track> data = trackParser->parse(message);
        auto* layer = static_cast<TrackMapLayer*>(layerInstances[layerName]);
        layer->trackModel()->upsert(data);
    } else if (auto* tirParser = dynamic_cast<TirParser*>(baseParser)) {
        QVector<Tir> data = tirParser->parse(message);
        auto* layer = static_cast<TirMapLayer*>(layerInstances[layerName]);
        layer->tirModel()->upsert(data);
    }
}
