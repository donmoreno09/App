#include "mqttclientservice.h"
#include "parser/imessageparser.h"
#include "../../layers/trackmaplayer.h"
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QDebug>

MqttClientService* MqttClientService::getInstance() {
    static MqttClientService instance;
    return &instance;
}

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
    for (const QString &topic : topics.keys()) {
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
    for (const QString &topic : topicToLayer.keys()) {
        client->subscribe(topic);
        qDebug() << "[MQTT] Subscribed to topic:" << topic;
    }
}

void MqttClientService::onDisconnected() {
    qDebug() << "[MQTT] Disconnected from broker";
}

void MqttClientService::registerLayer(const QString& name, QObject* layer) {
    auto* casted = qobject_cast<TrackMapLayer*>(layer);
    if (casted) {
        layerInstances[name] = casted;
        qDebug() << "[MQTT] Layer registered:" << name;
    } else {
        qWarning() << "[MQTT] Error: provided object is not a valid TrackMapLayer instance";
    }
}

void MqttClientService::registerParser(const QString& topic, IMessageParser* parser) {
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
    if (!topicToLayer.contains(topic)) {
        qWarning() << "[MQTT] No layer associated with topic:" << topic;
        return;
    }
    QString layerName = topicToLayer.value(topic);
    if (!layerInstances.contains(layerName)) {
        qWarning() << "[MQTT] Target layer not registered:" << layerName;
        return;
    }
    IMessageParser* parser = topicToParser.value(topic);
    QVariantList data = parser->parse(message);
    layerInstances[layerName]->setTracks(data);
}
