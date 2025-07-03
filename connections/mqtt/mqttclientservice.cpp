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
        qWarning() << "Errore apertura file config" << path;
        return;
    }

    QJsonParseError err;
    QJsonDocument doc = QJsonDocument::fromJson(file.readAll(), &err);
    if (err.error != QJsonParseError::NoError) {
        qWarning() << "Errore parsing config JSON:" << err.errorString();
        return;
    }

    QJsonObject root = doc.object();
    QJsonObject mqttConfig = root["mqtt"].toObject();
    client->setHostname(mqttConfig["host"].toString());
    client->setPort(mqttConfig["port"].toInt());

    QJsonObject topics = root["topics"].toObject();
    for (const QString &topic : topics.keys()) {
        topicToLayer[topic] = topics[topic].toString();
    }
}

void MqttClientService::connectToBroker() {
    client->setClientId("RaiseMqttClient");
    client->connectToHost();
}

void MqttClientService::onConnected() {
    qDebug() << "[MQTT] Connesso";
    for (const QString &topic : topicToLayer.keys()) {
        client->subscribe(topic);
        qDebug() << "[MQTT] Sottoscritto a" << topic;
    }
}

void MqttClientService::onDisconnected() {
    qDebug() << "[MQTT] Disconnesso dal broker";
}

void MqttClientService::registerLayer(const QString& name, QObject* layer) {
    auto* casted = qobject_cast<TrackMapLayer*>(layer);
    if (casted) {
        layerInstances[name] = casted;
        qDebug() << "[MQTT] Registrato layer" << name;
    } else {
        qWarning() << "[MQTT] Errore: oggetto non è un TrackMapLayer valido";
    }
}

void MqttClientService::registerParser(const QString& topic, IMessageParser* parser) {
    topicToParser[topic] = parser;
    qDebug() << "[MQTT] Parser registrato per topic" << topic;
}

void MqttClientService::handleMessage(const QByteArray& message, const QMqttTopicName& topicName) {
    QString topic = topicName.name();
    if (!topicToParser.contains(topic)) {
        qWarning() << "[MQTT] Nessun parser per topic" << topic;
        return;
    }
    if (!topicToLayer.contains(topic)) {
        qWarning() << "[MQTT] Nessun layer associato per topic" << topic;
        return;
    }
    QString layerName = topicToLayer.value(topic);
    if (!layerInstances.contains(layerName)) {
        qWarning() << "[MQTT] Layer" << layerName << "non registrato.";
        return;
    }
    IMessageParser* parser = topicToParser.value(topic);
    QVariantList data = parser->parse(message);
    layerInstances[layerName]->setTracks(data);
}
