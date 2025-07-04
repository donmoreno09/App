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
    qDebug() << "[PersistenceManagerBase] calling load...";
    m_httpClient.get(QUrl(getApiEndpoint()));
}

void PersistenceManagerBase::get(const QString &objectId)
{
    qDebug() << "[PersistenceManagerBase] calling get...";
    m_httpClient.get(QUrl(getApiEndpoint() + "/" + objectId));
}

void PersistenceManagerBase::save(const IPersistable &object)
{
    qDebug() << "[PersistenceManagerBase] calling save...";
    qDebug() << QJsonDocument(object.toJson()).toJson();
    m_httpClient.post(QUrl(getApiEndpoint()), QJsonDocument(object.toJson()).toJson());
}

void PersistenceManagerBase::update(const IPersistable &object)
{
    qDebug() << "[PersistenceManagerBase] calling update...";
    QJsonObject objJson = object.toJson();
    QString objectId = objJson["id"].toString();
    m_httpClient.put(QUrl(getApiEndpoint() + "/" + objectId),
                     QJsonDocument(objJson).toJson());
}

void PersistenceManagerBase::remove(const QString &objectId)
{
    qDebug() << "[PersistenceManagerBase] calling remove...";
    m_httpClient.deleteResource(QUrl(getApiEndpoint() + "/" + objectId));
}

void PersistenceManagerBase::onRequestFinished(QNetworkReply *reply)
{
    qDebug() << "[PersistenceManagerBase] Richiesta completata. Errore:" << reply->error();

    if (reply->error() != QNetworkReply::NoError) {
        qWarning() << "[PersistenceManagerBase] Errore di rete:" << reply->errorString();
        emitFailed(reply);

        // ERRORE: response contiene un JSON
        QByteArray response = reply->readAll();
        QJsonParseError err;
        QJsonDocument doc = QJsonDocument::fromJson(response, &err);

        if (err.error == QJsonParseError::NoError && doc.isObject()) {
            QJsonObject obj = doc.object();
            qWarning() << "[PersistenceManagerBase] Errore nel salvataggio:"
                       << obj;
        } else {
            // se JSON malformato o non oggetto
            qWarning() << "[PersistenceManagerBase] Errore nel salvataggio, risposta:"
                       << response;
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
        qWarning() << "[PersistenceManagerBase] Operazione HTTP non gestita:" << static_cast<int>(op);
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
        qWarning() << "[PersistenceManagerBase] Errore parsing JSON:" << error.errorString();
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
        qWarning() << "[PersistenceManagerBase] Risposta inattesa (né array né oggetto)";
    }
}

void PersistenceManagerBase::handleSaveReply(QNetworkReply *reply)
{
    // 1) Legge lo status code
    int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute)
                         .toInt();

    // 2) Legge sempre il body
    QByteArray response = reply->readAll();

    if (statusCode == 201) {
        // OK: response contiene l'UUID
        QString uuid = QString::fromUtf8(response).remove('\"');
        qDebug() << "[PersistenceManagerBase] Creato con UUID =" << uuid;
        emit objectSaved(true, uuid);
    }

    reply->deleteLater();
}

void PersistenceManagerBase::handleUpdateReply(QNetworkReply *reply)
{
    int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    QByteArray response = reply->readAll();

    if (statusCode == 200) {
        // OK: response contiene l'UUID
        QString uuid = QString::fromUtf8(response);
        qDebug() << "[PersistenceManagerBase] Aggiornato con UUID =" << uuid;
        emit objectUpdated(true);
    }
}

void PersistenceManagerBase::handleDeleteReply(QNetworkReply *reply)
{
    // In un sistema reale potresti controllare HTTP 204/200 ecc.
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
