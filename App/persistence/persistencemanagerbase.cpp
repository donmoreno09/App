#include "persistencemanagerbase.h"
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QUrl>
#include <QDebug>

PersistenceManagerBase::PersistenceManagerBase(QObject *parent)
    : IPersistenceManager(parent)
{
    connect(&m_httpClient, &HttpClient::finished,
            this, &PersistenceManagerBase::onRequestFinished);
}

void PersistenceManagerBase::load()
{
    qDebug() << "[PersistenceManagerBase] Invoking load operation...";
    m_httpClient.get(QUrl(getApiEndpoint()));
}

void PersistenceManagerBase::get(const QString &objectId)
{
    qDebug() << "[PersistenceManagerBase] Invoking get operation...";
    m_httpClient.get(QUrl(getApiEndpoint() + "/" + objectId));
}

void PersistenceManagerBase::save(const IPersistable &object)
{
    qDebug() << "[PersistenceManagerBase] Invoking save operation...";
    qDebug() << QJsonDocument(object.toJson()).toJson();
    m_httpClient.post(QUrl(getApiEndpoint()), QJsonDocument(object.toJson()).toJson());
}

void PersistenceManagerBase::update(const IPersistable &object)
{
    qDebug() << "[PersistenceManagerBase] Invoking update operation...";
    QJsonObject objJson = object.toJson();
    QString objectId = objJson["id"].toString();
    m_httpClient.put(QUrl(getApiEndpoint() + "/" + objectId),
                     QJsonDocument(objJson).toJson());
}

void PersistenceManagerBase::remove(const QString &objectId)
{
    qDebug() << "[PersistenceManagerBase] Invoking remove operation...";
    m_httpClient.deleteResource(QUrl(getApiEndpoint() + "/" + objectId));
}

void PersistenceManagerBase::onRequestFinished(QNetworkReply *reply)
{
    qDebug() << "[PersistenceManagerBase] Request completed. Network error:" << reply->error();

    if (reply->error() != QNetworkReply::NoError) {
        qWarning() << "[PersistenceManagerBase] Network error occurred:" << reply->errorString();
        emitFailed(reply);

        // Attempt to parse error response payload (expected to be JSON)
        QByteArray response = reply->readAll();
        QJsonParseError err;
        QJsonDocument doc = QJsonDocument::fromJson(response, &err);

        if (err.error == QJsonParseError::NoError && doc.isObject()) {
            QJsonObject obj = doc.object();
            qWarning() << "[PersistenceManagerBase] Error response payload:" << obj;
        } else {
            // Response is malformed or not a JSON object
            qWarning() << "[PersistenceManagerBase] Malformed error response:" << response;
        }

        emit objectSaved(false, "");
        reply->deleteLater();
        return;
    }

    QNetworkAccessManager::Operation op = reply->operation();

    switch (op) {
    case QNetworkAccessManager::GetOperation:
        handleGetOrLoadReply(reply);
        break;
    case QNetworkAccessManager::PostOperation:
        handleSaveReply(reply);
        break;
    case QNetworkAccessManager::PutOperation:
        handleUpdateReply(reply);
        break;
    case QNetworkAccessManager::DeleteOperation:
        handleDeleteReply(reply);
        break;
    default:
        qWarning() << "[PersistenceManagerBase] Unsupported HTTP operation:" << static_cast<int>(op);
        break;
    }

    reply->deleteLater();
}

void PersistenceManagerBase::handleGetOrLoadReply(QNetworkReply *reply)
{
    QByteArray response = reply->readAll();
    QJsonParseError error;
    QJsonDocument doc = QJsonDocument::fromJson(response, &error);

    if (error.error != QJsonParseError::NoError) {
        qWarning() << "[PersistenceManagerBase] Failed to parse response JSON:" << error.errorString();
        return;
    }

    if (doc.isArray()) {
        QList<IPersistable*> objects;
        for (const QJsonValue &val : doc.array()) {
            if (!val.isObject()) continue;
            IPersistable* obj = createPersistable();
            obj->fromJson(val.toObject());
            objects.append(obj);
        }
        emit objectsLoaded(objects);
    } else if (doc.isObject()) {
        IPersistable* obj = createPersistable();
        obj->fromJson(doc.object());
        emit objectGot(obj);
    } else {
        qWarning() << "[PersistenceManagerBase] Unexpected response format (neither array nor object)";
    }
}

void PersistenceManagerBase::handleSaveReply(QNetworkReply *reply)
{
    int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    QByteArray response = reply->readAll();

    if (statusCode == 201) {
        // Created — server responded with UUID string
        QString uuid = QString::fromUtf8(response).remove('\"');
        qDebug() << "[PersistenceManagerBase] Object created with UUID =" << uuid;
        emit objectSaved(true, uuid);
    }

    reply->deleteLater();
}

void PersistenceManagerBase::handleUpdateReply(QNetworkReply *reply)
{
    int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    QByteArray response = reply->readAll();

    if (statusCode == 200) {
        // OK — server responded with UUID (or success payload)
        QString uuid = QString::fromUtf8(response);
        qDebug() << "[PersistenceManagerBase] Object updated with UUID =" << uuid;
        emit objectUpdated(true);
    }
}

void PersistenceManagerBase::handleDeleteReply(QNetworkReply *reply)
{
    // In production scenarios, you may want to check for 200/204/etc.
    emit objectRemoved(true);
}

void PersistenceManagerBase::emitFailed(QNetworkReply *reply)
{
    switch (reply->operation()) {
    case QNetworkAccessManager::PostOperation:
        emit objectSaved(false, "");
        break;
    case QNetworkAccessManager::PutOperation:
        emit objectUpdated(false);
        break;
    case QNetworkAccessManager::DeleteOperation:
        emit objectRemoved(false);
        break;
    default:
        break;
    }
}
