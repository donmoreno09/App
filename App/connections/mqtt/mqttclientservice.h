#ifndef MQTTCLIENTSERVICE_H
#define MQTTCLIENTSERVICE_H

#include <QObject>
#include <QMqttClient>
#include <QMap>
#include <QVariantList>

class TrackMapLayer;
class IMessageParser;

class MqttClientService : public QObject {
    Q_OBJECT
public:
    static MqttClientService* getInstance();

    void initialize(const QString& configPath);
    Q_INVOKABLE void registerLayer(const QString& name, QObject* layer); // <-- AGGIUNGI QUESTO
    void registerParser(const QString& topic, IMessageParser* parser);
    Q_INVOKABLE QString getTopicFromLayer(const QString& layer);

private slots:
    void handleMessage(const QByteArray &message, const QMqttTopicName &topic);
    void onConnected();
    void onDisconnected();

private:
    explicit MqttClientService(QObject* parent = nullptr);
    void loadConfiguration(const QString& path);
    void connectToBroker();

    QMqttClient* client;
    QMap<QString, QString> topicToLayer;
    QMap<QString, QString> layerToTopic;
    QMap<QString, IMessageParser*> topicToParser;
    QMap<QString, TrackMapLayer*> layerInstances;
};
#endif // MQTTCLIENTSERVICE_H
