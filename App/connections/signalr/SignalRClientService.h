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

/**
 * @brief SignalRClientService
 *
 * Manages WebSocket connection to ASP.NET Core SignalR hub.
 * Implements SignalR protocol manually using Qt native WebSocket.
 * Follows the same pattern as MqttClientService for consistency.
 *
 * Usage:
 * 1. initialize(appConfig) - Connect to SignalR hub
 * 2. registerHandler(methodName, handler) - Register message handlers
 * 3. invoke(methodName, args) - Call server methods
 */
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

    /**
     * @brief Initialize SignalR connection
     * @param appConfig Application configuration with SignalR settings
     */
    void initialize(const AppConfig& appConfig);

    /**
     * @brief Register parser for specific EventType (MQTT-style)
     * @param eventType Notification EventType (0, 1, 2)
     * @param parser Parser instance to handle this EventType
     *
     * Example:
     *   signalR->registerParser(0, new TruckNotificationSignalRParser());
     *   signalR->registerParser(2, new AlertZoneNotificationParser());
     */
    void registerParser(int eventType, class IBaseSignalRMessageParser* parser);

    /**
     * @brief Register handler for specific server method
     * @param methodName Server method name (e.g., "ReceiveNotification")
     * @param handler Callback function to handle message
     *
     * Example:
     *   signalR->registerHandler("ReceiveNotification", [](const QVariantList& args) {
     *       // Process notification
     *   });
     */
    void registerHandler(const QString& methodName, MessageHandler handler);

    /**
     * @brief Handle notification envelope (routes to parsers)
     * @param args Arguments from server (envelope)
     *
     * This is called automatically by the ReceiveNotification handler.
     */
    void handleNotification(const QVariantList& args);

    /**
     * @brief Invoke method on server
     * @param methodName Server method name (e.g., "ConfirmRead", "GetUnreadNotifications")
     * @param args Arguments to pass to method
     *
     * Examples:
     *   signalR->invoke("ConfirmRead", QVariantList() << notificationId);
     *   signalR->invoke("GetUnreadNotifications", QVariantList() << userId);
     */
    Q_INVOKABLE void invoke(const QString& methodName, const QVariantList& args = QVariantList());

    /**
     * @brief Check if connected to hub
     */
    Q_INVOKABLE bool connected() const;

    /**
     * @brief Get current connection state
     */
    Q_INVOKABLE QString connectionState() const;

signals:
    // Connection state changes
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

    QWebSocket* m_webSocket;
    QTimer* m_pingTimer;
    QString m_hubUrl;
    bool m_connected;
    int m_invocationCounter;
    QString m_connectionState;
    QString m_userId;

    // Message handlers (like parsers in MQTT)
    QMap<QString, MessageHandler> m_methodHandlers;

    // EventType parsers (MQTT-style)
    QMap<int, class IBaseSignalRMessageParser*> m_eventTypeParsers;

    QMap<QString, QString> m_pendingInvocations;

    static constexpr int PING_INTERVAL_MS = 15000;  // 15 seconds
    static constexpr char RECORD_SEPARATOR = '\x1e';
};

#endif // SIGNALRCLIENTSERVICE_H
