#ifndef SIGNALRCLIENTSERVICE_H
#define SIGNALRCLIENTSERVICE_H

#include <QObject>
#include <QWebSocket>
#include <QTimer>
#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonArray>
#include <QQmlEngine>
#include <functional>
#include <App/config.h>

class SignalRClientService : public QObject
{
    Q_OBJECT
    QML_SINGLETON
    QML_ELEMENT

    Q_PROPERTY(bool connected READ connected NOTIFY connectedChanged)
    Q_PROPERTY(QString connectionState READ connectionState NOTIFY connectionStateChanged)

public:
    using MessageHandler = std::function<void(const QVariantList& arguments)>;

    explicit SignalRClientService(QObject* parent = nullptr);
    ~SignalRClientService();

    void initialize(const AppConfig& appConfig);
    void registerParser(int eventType, class IBaseSignalRMessageParser* parser);
    void registerHandler(const QString& methodName, MessageHandler handler);
    void handleNotification(const QVariantList& args);


    Q_INVOKABLE void invoke(const QString& methodName, const QVariantList& args = QVariantList());
    Q_INVOKABLE bool connected() const;
    Q_INVOKABLE QString connectionState() const;

signals:
    void connectedChanged();
    void connectionStateChanged();
    void connectionError(const QString& error);

private slots:
    void onWebSocketConnected();
    void onWebSocketDisconnected();
    void onTextMessageReceived(const QString& message);
    void onWebSocketError(QAbstractSocket::SocketError error);
    void sendPing();

private:
    // SignalR protocol methods
    void sendHandshake();
    void sendMessage(const QJsonObject& message);
    void parseMessage(const QString& message);
    void fetchUnreadNotifications();
    QString generateInvocationId();
    void processNotificationInternal(const QString& id, const QVariant& payloadVar,
                                     const QString& eventTypeName, const QString& timestamp);

    QWebSocket* m_webSocket;
    QTimer* m_pingTimer;
    QString m_hubUrl;
    bool m_connected;
    int m_invocationCounter;
    QString m_connectionState;
    QString m_userId;

    QMap<QString, MessageHandler> m_methodHandlers;
    QMap<int, class IBaseSignalRMessageParser*> m_eventTypeParsers;
    QMap<QString, QString> m_pendingInvocations;

    static constexpr int PING_INTERVAL_MS = 15000;
    static constexpr char RECORD_SEPARATOR = '\x1e';
};

#endif // SIGNALRCLIENTSERVICE_H
