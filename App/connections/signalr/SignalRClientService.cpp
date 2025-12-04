#include "SignalRClientService.h"
#include "parser/ISignalRMessageParser.h"
#include <models/TruckNotificationModel.h>
#include <models/AlertZoneNotificationModel.h>
#include <QUrlQuery>
#include <QDebug>

SignalRClientService::SignalRClientService(QObject* parent)
    : QObject(parent)
    , m_webSocket(new QWebSocket(QString(), QWebSocketProtocol::VersionLatest, this))
    , m_pingTimer(new QTimer(this))
    , m_connected(false)
    , m_invocationCounter(0)
    , m_connectionState("Disconnected")
{
    // Connect WebSocket signals
    connect(m_webSocket, &QWebSocket::connected,
            this, &SignalRClientService::onWebSocketConnected);

    connect(m_webSocket, &QWebSocket::disconnected,
            this, &SignalRClientService::onWebSocketDisconnected);

    connect(m_webSocket, &QWebSocket::textMessageReceived,
            this, &SignalRClientService::onTextMessageReceived);

    connect(m_webSocket, &QWebSocket::errorOccurred,
            this, &SignalRClientService::onWebSocketError);

    // Setup ping timer (keep-alive)
    m_pingTimer->setInterval(PING_INTERVAL_MS);
    connect(m_pingTimer, &QTimer::timeout,
            this, &SignalRClientService::sendPing);
}

SignalRClientService::~SignalRClientService()
{
    if (m_connected) {
        m_webSocket->close();
    }
}

void SignalRClientService::initialize(const AppConfig& appConfig)
{
    qDebug() << "[SignalR] Initializing...";

    if (m_connected) {
        qWarning() << "[SignalR] Already connected";
        return;
    }

    m_userId = appConfig.signalRUserId;

    // Build WebSocket URL
    QString hubUrl = QString("ws://%1:%2/hubs/notifications")
                         .arg(appConfig.signalRHost)
                         .arg(appConfig.signalRPort);

    QUrl url(hubUrl);
    QUrlQuery query;
    query.addQueryItem("apiKey", appConfig.signalRApiKey);
    query.addQueryItem("userId", appConfig.signalRUserId);
    url.setQuery(query);

    m_hubUrl = hubUrl;
    m_connectionState = "Connecting";
    emit connectionStateChanged();

    qDebug() << "[SignalR] Connecting to:" << url.toString();
    m_webSocket->open(url);
}

void SignalRClientService::registerHandler(const QString& methodName, MessageHandler handler)
{
    m_methodHandlers[methodName] = handler;
    qDebug() << "[SignalR] Handler registered for method:" << methodName;
}

void SignalRClientService::registerParser(int eventType, IBaseSignalRMessageParser* parser)
{
    m_eventTypeParsers[eventType] = parser;
    qDebug() << "[SignalR] Parser registered for EventType:" << eventType;
}

void SignalRClientService::handleNotification(const QVariantList& args)
{
    if (args.size() < 4) {
        qWarning() << "[SignalR] handleNotification: expected 4 args, got" << args.size();
        return;
    }

    // Backend sends: (Id, Payload, EventTypeName, Timestamp)
    QString id = args[0].toString();
    QString payloadStr = args[1].toString();
    QString eventTypeName = args[2].toString();
    QString timestamp = args[3].toString();

    qDebug() << "[SignalR] Processing notification:";
    qDebug() << "[SignalR]   ID:" << id;
    qDebug() << "[SignalR]   EventType:" << eventTypeName;
    qDebug() << "[SignalR]   Payload:" << payloadStr;
    qDebug() << "[SignalR]   Timestamp:" << timestamp;

    // Map EventTypeName to EventType number
    int eventType = -1;
    if (eventTypeName == "TirAppIssueCreated") {
        eventType = 0;
    } else if (eventTypeName == "TirAppIssueResolved") {
        eventType = 1;
    } else if (eventTypeName == "ControlRoomAlertZoneIntrusion") {
        eventType = 2;
    } else {
        qWarning() << "[SignalR] Unknown EventTypeName:" << eventTypeName;
        return;
    }

    qDebug() << "[SignalR]   Mapped EventType:" << eventType;

    // Find parser for this EventType
    if (!m_eventTypeParsers.contains(eventType)) {
        qWarning() << "[SignalR] No parser registered for EventType:" << eventType;
        return;
    }

    // Build envelope for parser (to keep parser interface consistent)
    QVariantMap envelope;
    envelope["Id"] = id;
    envelope["EventType"] = eventType;
    envelope["Payload"] = payloadStr;
    envelope["Timestamp"] = timestamp;
    envelope["UserId"] = "control-room-user";  // Default, since backend doesn't send it

    auto* baseParser = m_eventTypeParsers.value(eventType);

    // Get QML engine (for accessing singletons)
    auto* engine = qmlEngine(this);
    if (!engine) {
        qWarning() << "[SignalR] QML engine not available";
        return;
    }

    // Route by EventType (MQTT-style!)
    if (eventType == 0 || eventType == 1) {
        // Truck notifications
        auto* parser = dynamic_cast<ISignalRMessageParser<TruckNotification>*>(baseParser);
        if (!parser) {
            qWarning() << "[SignalR] Invalid parser type for EventType:" << eventType;
            return;
        }

        QVector<TruckNotification> notifications = parser->parse(envelope);

        auto* model = engine->singletonInstance<TruckNotificationModel*>("App", "TruckNotificationModel");
        if (model) {
            model->upsert(notifications);
            qDebug() << "[SignalR] ✅ Truck notification added to model";
        } else {
            qWarning() << "[SignalR] TruckNotificationModel singleton not found";
        }

    } else if (eventType == 2) {
        // Alert zone notifications
        auto* parser = dynamic_cast<ISignalRMessageParser<AlertZoneNotification>*>(baseParser);
        if (!parser) {
            qWarning() << "[SignalR] Invalid parser type for EventType:" << eventType;
            return;
        }

        QVector<AlertZoneNotification> notifications = parser->parse(envelope);

        auto* model = engine->singletonInstance<AlertZoneNotificationModel*>("App", "AlertZoneNotificationModel");
        if (model) {
            model->upsert(notifications);
            qDebug() << "[SignalR] ✅ AlertZone notification added to model";
        } else {
            qWarning() << "[SignalR] AlertZoneNotificationModel singleton not found";
        }
    }
}

void SignalRClientService::invoke(const QString& methodName, const QVariantList& args)
{
    if (!m_connected) {
        qWarning() << "[SignalR] Cannot invoke - not connected";
        return;
    }

    QString invocationId = generateInvocationId();

    QJsonObject message;
    message["type"] = 1;  // Invocation
    message["target"] = methodName;
    message["invocationId"] = invocationId;

    // Convert QVariantList to QJsonArray
    QJsonArray jsonArgs;
    for (const QVariant& arg : args) {
        jsonArgs.append(QJsonValue::fromVariant(arg));
    }
    message["arguments"] = jsonArgs;

    m_pendingInvocations.insert(invocationId, methodName);

    sendMessage(message);

    qDebug() << "[SignalR] Invoked:" << methodName << "with args:" << args;
}

bool SignalRClientService::connected() const
{
    return m_connected;
}

QString SignalRClientService::connectionState() const
{
    return m_connectionState;
}

// ─────────────────────────────────────────────────────
// Private Slots
// ─────────────────────────────────────────────────────

void SignalRClientService::onWebSocketConnected()
{
    qDebug() << "[SignalR] ✅ WebSocket connected";

    m_connectionState = "Handshaking";
    emit connectionStateChanged();

    // Send SignalR handshake
    sendHandshake();
}

void SignalRClientService::onWebSocketDisconnected()
{
    qDebug() << "[SignalR] ❌ Disconnected";

    m_connected = false;
    m_connectionState = "Disconnected";
    m_pingTimer->stop();

    emit connectedChanged();
    emit connectionStateChanged();
}

void SignalRClientService::onTextMessageReceived(const QString& message)
{
    // qDebug() << "[SignalR] 📨 Message received:" << message;

    // SignalR messages end with \x1e
    // Can receive multiple messages concatenated
    QStringList messages = message.split(QChar(RECORD_SEPARATOR), Qt::SkipEmptyParts);

    for (int i = 0; i < messages.size(); ++i) {
        parseMessage(messages[i]);
    }

}

void SignalRClientService::onWebSocketError(QAbstractSocket::SocketError error)
{
    QString errorString = m_webSocket->errorString();
    qWarning() << "[SignalR] ❌ Error:" << errorString << "Code:" << error;

    m_connectionState = "Error";
    emit connectionStateChanged();
    emit connectionError(errorString);
}

void SignalRClientService::sendPing()
{
    if (!m_connected) {
        return;
    }

    QJsonObject ping;
    ping["type"] = 6;  // Ping

    sendMessage(ping);
    // qDebug() << "[SignalR] 🏓 Ping sent";
}

// ─────────────────────────────────────────────────────
// Private Methods - SignalR Protocol
// ─────────────────────────────────────────────────────

void SignalRClientService::sendHandshake()
{
    QJsonObject handshake;
    handshake["protocol"] = "json";
    handshake["version"] = 1;

    sendMessage(handshake);

    qDebug() << "[SignalR] 🤝 Handshake sent";
}

void SignalRClientService::sendMessage(const QJsonObject& message)
{
    if (m_webSocket->state() != QAbstractSocket::ConnectedState) {
        qWarning() << "[SignalR] Cannot send - not connected";
        return;
    }

    QJsonDocument doc(message);
    QString jsonString = doc.toJson(QJsonDocument::Compact);

    // SignalR messages end with \x1e (record separator)
    jsonString.append(QChar(RECORD_SEPARATOR));

    qint64 bytesSent = m_webSocket->sendTextMessage(jsonString);

    if (bytesSent == -1) {
        qWarning() << "[SignalR] Failed to send message";
    }
}

void SignalRClientService::parseMessage(const QString& message)
{
    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(message.toUtf8(), &parseError);

    if (parseError.error != QJsonParseError::NoError) {
        qWarning() << "[SignalR] JSON parse error:" << parseError.errorString();
        return;
    }

    if (!doc.isObject()) {
        qWarning() << "[SignalR] Expected JSON object";
        return;
    }

    QJsonObject obj = doc.object();

    // Check if this is handshake response (empty object = success)
    if (obj.isEmpty()) {
        qDebug() << "[SignalR] ✅ Handshake successful";
        m_connected = true;
        m_connectionState = "Connected";
        m_pingTimer->start();

        emit connectedChanged();
        emit connectionStateChanged();

        fetchUnreadNotifications();
        return;
    }

    int type = obj["type"].toInt();

    switch (type) {
    case 1: {  // Invocation (server calling client method)
        QString target = obj["target"].toString();
        QJsonArray argsArray = obj["arguments"].toArray();

        QVariantList args;
        args.reserve(argsArray.size()); // migliora prestazioni

        for (int i = 0; i < argsArray.size(); ++i) {
            args.append(argsArray[i].toVariant());
        }
        qDebug() << "[SignalR] 📞 Server invoked:" << target;

        // Route to registered handler (like MQTT parser routing)
        if (m_methodHandlers.contains(target)) {
            m_methodHandlers[target](args);
        } else {
            qWarning() << "[SignalR] No handler registered for method:" << target;
        }
        break;
    }

    case 3: {  // Completion (response to our invocation)
        QString invocationId = obj["invocationId"].toString();
        QString methodName = m_pendingInvocations.take(invocationId);

        qDebug() << "[SignalR] ✅ Invocation completed:" << methodName;

        if (methodName == "GetUnreadNotifications" && obj.contains("result")) {
            QJsonArray resultArray = obj["result"].toArray();
            qDebug() << "[SignalR] Received" << resultArray.size() << "unread notifications";

            auto* engine = qmlEngine(this);
            if (!engine) {
                qWarning() << "[SignalR] QML engine not available";
                break;
            }

            // Process each notification
            for (const QJsonValue& val : resultArray) {
                QJsonObject notifObj = val.toObject();

                // Extract fields from backend format
                QString id = notifObj["id"].toString();
                QString eventTypeString = notifObj["eventType"].toString();
                QString payload = notifObj["payload"].toString();
                QString userId = notifObj["userId"].toString();

                // Map EventTypeName to EventType number (same as handleNotification)
                int eventType = -1;
                if (eventTypeString == "TirAppIssueCreated") {
                    eventType = 0;
                } else if (eventTypeString == "TirAppIssueResolved") {
                    eventType = 1;
                } else if (eventTypeString == "ControlRoomAlertZoneIntrusion") {
                    eventType = 2;
                } else {
                    qWarning() << "[SignalR] Unknown EventTypeName:" << eventTypeString;
                    continue;
                }

                qDebug() << "[SignalR] Processing unread notification ID:" << id << "EventType:" << eventType;

                // Build envelope for parser (to match handleNotification format)
                QVariantMap envelope;
                envelope["Id"] = id;
                envelope["EventType"] = eventType;
                envelope["Payload"] = payload;
                envelope["UserId"] = userId;
                // Note: We don't set Timestamp since parsers don't use it from envelope

                // Find parser for this EventType
                if (!m_eventTypeParsers.contains(eventType)) {
                    qWarning() << "[SignalR] No parser registered for EventType:" << eventType;
                    continue;
                }

                auto* baseParser = m_eventTypeParsers.value(eventType);

                // Route by EventType (same as handleNotification)
                if (eventType == 0 || eventType == 1) {
                    auto* parser = dynamic_cast<ISignalRMessageParser<TruckNotification>*>(baseParser);
                    if (parser) {
                        QVector<TruckNotification> notifications = parser->parse(envelope);
                        auto* model = engine->singletonInstance<TruckNotificationModel*>("App", "TruckNotificationModel");
                        if (model) {
                            model->upsert(notifications);
                            qDebug() << "[SignalR] ✅ Added truck notification to model";
                        }
                    }
                } else if (eventType == 2) {
                    auto* parser = dynamic_cast<ISignalRMessageParser<AlertZoneNotification>*>(baseParser);
                    if (parser) {
                        QVector<AlertZoneNotification> notifications = parser->parse(envelope);
                        auto* model = engine->singletonInstance<AlertZoneNotificationModel*>("App", "AlertZoneNotificationModel");
                        if (model) {
                            model->upsert(notifications);
                            qDebug() << "[SignalR] ✅ Added alert zone notification to model";
                        }
                    }
                }
            }

            qDebug() << "[SignalR] ✅ Finished loading unread notifications into models";

            auto* truckModel = engine->singletonInstance<TruckNotificationModel*>("App", "TruckNotificationModel");
            if (truckModel) {
                truckModel->setInitialLoadComplete(true);
            }

            auto* alertModel = engine->singletonInstance<AlertZoneNotificationModel*>("App", "AlertZoneNotificationModel");
            if (alertModel) {
                alertModel->setInitialLoadComplete(true);
            }
        }
        break;
    }

    case 6: {  // Ping
        // qDebug() << "[SignalR] 🏓 Ping received";
        break;
    }

    case 7: {  // Close
        QString error = obj["error"].toString();
        qDebug() << "[SignalR] 🔒 Close received:" << error;
        m_webSocket->close();
        break;
    }

    default:
        qWarning() << "[SignalR] Unknown message type:" << type;
        break;
    }
}

void SignalRClientService::fetchUnreadNotifications()
{
    // Get userId from the connection (we stored it during initialize)
    if (m_userId.isEmpty()) {
        qWarning() << "[SignalR] Cannot fetch unread notifications - userId not set";
        return;
    }

    qDebug() << "[SignalR] Fetching unread notifications for user:" << m_userId;
    invoke("GetUnreadNotifications", QVariantList() << m_userId);
}

QString SignalRClientService::generateInvocationId()
{
    return QString::number(++m_invocationCounter);
}
