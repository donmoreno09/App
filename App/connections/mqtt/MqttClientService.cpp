#include "MqttClientService.h"

#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QVector>
#include "layers/TrackMapLayer.h"
#include "layers/TirMapLayer.h"
#include "layers/VesselMapLayer.h"
#include "parser/TrackParser.h"
#include "parser/TirParser.h"
#include "AppLogger.h"

// Anonymous namespace to make _logger exclusive for this file
namespace {
Logger& _logger()
{
    static Logger logger = AppLogger::get().child({
        {"service", "MQTT-CLIENT"}
    });
    return logger;
}
}

MqttClientService::MqttClientService(QObject* parent)
    : QObject(parent), client(new QMqttClient(this)) {
    connect(client, &QMqttClient::messageReceived, this, &MqttClientService::handleMessage);
    connect(client, &QMqttClient::connected, this, &MqttClientService::onConnected);
    connect(client, &QMqttClient::disconnected, this, &MqttClientService::onDisconnected);
}

void MqttClientService::initialize(const QString& configPath, const AppConfig& appConfig,  AuthManager* authManager) {
    this->authManager = authManager;
    loadConfiguration(configPath, appConfig);
    connectToBroker();
}

void MqttClientService::loadConfiguration(const QString& path, const AppConfig& appConfig) {
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly)) {
        _logger().warn("Failed to open configuration file: " + path, { kv("path", path) });
        return;
    }

    QJsonParseError err;
    QJsonDocument doc = QJsonDocument::fromJson(file.readAll(), &err);
    if (err.error != QJsonParseError::NoError) {
        _logger().warn("JSON parsing error in configuration: " + err.errorString(), { kv("error", err.errorString()) });
        return;
    }

    client->setHostname(appConfig.mqttHost);
    client->setPort(appConfig.mqttPort);

    QJsonObject root = doc.object();
    QJsonObject topics = root["topics"].toObject();
    for (auto it = topics.begin(); it != topics.end(); it++) {
        const QString &topic = it.key();
        QString layer = topics[topic].toString();
        topicToLayer[topic] = layer;
        layerToTopic[layer] = topic;
    }
}

void MqttClientService::connectToBroker() {
    if (!client) return;

    const auto s = client->state();
    if (s == QMqttClient::Connected || s == QMqttClient::Connecting)
        return; // already connected / in progress

    client->setClientId("RaiseMqttClient");
    client->connectToHost();
}

void MqttClientService::onConnected() {
    _logger().info("Connected to broker");
    for (auto it = topicToLayer.begin(); it != topicToLayer.end(); it++) {
        const QString &topic = it.key();
        if (this->authManager == nullptr) {
            _logger().warn("authManager uninitialized; subscribing without user id", {
                kv("topic", topic)
            });
            client->subscribe(topic);
            _logger().info("Subscribed to topic: " + topic, { kv("topic", topic) });
        } else {
            QString userTopic = this->authManager->userId() + "/" + topic;
            client->subscribe(userTopic);
            _logger().info("Subscribed to topic", {
                kv("topic", userTopic)
            });
        }

    }
}

void MqttClientService::onDisconnected() {
    _logger().info("Disconnected from broker");
}

void MqttClientService::registerLayer(const QString& name, QObject* layer) {
    auto* casted = qobject_cast<BaseTrackMapLayer*>(layer);
    if (casted) {
        layerInstances[name] = casted;
        _logger().info("Layer registered: " + name, { kv("layer", name) });
    } else {
        _logger().warn("Provided object is not a valid BaseTrackMapLayer instance");
    }
}

void MqttClientService::registerParser(const QString& topic, IBaseMessageParser* parser) {
    topicToParser[topic] = parser;
    _logger().info("Parser registered for topic: " + topic, { kv("topic", topic) });
}

QString MqttClientService::getTopicFromLayer(const QString &layer)
{
    return layerToTopic.value(layer);
}

void MqttClientService::handleMessage(const QByteArray& message, const QMqttTopicName& topicName) {
    // Extract topic if authenticated from: <user-id>/topic
    QString topic = topicName.name().section("/", 1, 1);
    if (topic.isEmpty()) {
        // If, for whatever reason, the topic's name from MQTT isn't
        // <user-id>/topic, then just use topic directly.
        topic = topicName.name();
    }

    if (!topicToParser.contains(topic)) {
        _logger().warn("No parser available for topic: " + topic, { kv("topic", topic) });
        return;
    }

    if (!topicToLayer.contains(topic)) {
        _logger().warn("No layer associated for topic: " + topic, { kv("topic", topic) });
        return;
    }
    QString layerName = topicToLayer.value(topic);
    if (!layerInstances.contains(layerName)) {
        _logger().warn("Target layer not registered: " + layerName, { kv("layer", layerName) });
        return;
    }

    auto* targetLayer = layerInstances.value(layerName);
    if (!targetLayer || !targetLayer->active()) {
        return;
    }

    auto* baseParser = topicToParser.value(topic);

    if (auto* trackParser = dynamic_cast<TrackParser*>(baseParser)) {
        const ClusteredPayload<Track> payload = trackParser->parse(message);
        auto* layer = static_cast<TrackMapLayer*>(targetLayer);
        if (payload.hasTracks) {
            layer->trackModel()->upsert(payload.tracks);
        }

        if (payload.hasClusters) {
            layer->clusterModel()->upsert(payload.clusters);
        }
    } else if (auto* tirParser = dynamic_cast<TirParser*>(baseParser)) {
        const ClusteredPayload<Tir> payload = tirParser->parse(message);
        auto* layer = static_cast<TirMapLayer*>(targetLayer);
        if (payload.hasTracks) {
            layer->tirModel()->upsert(payload.tracks);
        }

        if (payload.hasClusters) {
            layer->clusterModel()->upsert(payload.clusters);
        }
    } else if (auto* vesselParser = dynamic_cast<IMessageParser<ClusteredPayload<Vessel>>*>(baseParser)) {
        auto* layer = static_cast<VesselMapLayer*>(targetLayer);
        const ClusteredPayload<Vessel> payload = vesselParser->parse(message);

        // During the current migration phase, VesselFinder tracks still come
        // from HTTP polling while MQTT only owns the cluster overlay.
        if (payload.hasClusters) {
            layer->clusterModel()->upsert(payload.clusters);
        }
    }
}
