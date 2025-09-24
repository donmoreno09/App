#ifndef PERSISTENCEMANAGERBASE_H
#define PERSISTENCEMANAGERBASE_H

#include "ipersistencemanager.h"
#include "../connections/httpclient.h"
#include <QNetworkReply>

class PersistenceManagerBase : public IPersistenceManager
{
    Q_OBJECT
public:
    explicit PersistenceManagerBase(QObject *parent = nullptr);

    virtual void load() override;
    virtual void get(const QString &objectId) override;
    virtual void save(const IPersistable &object) override;
    virtual void update(const IPersistable &object) override;
    virtual void remove(const QString &objectId) override;

protected:
    HttpClient m_httpClient;

    virtual QString getApiEndpoint() const = 0;
    virtual IPersistable* createPersistable() const = 0;

private slots:
    void onRequestFinished(QNetworkReply *reply);

private:
    void handleGetOrLoadReply(QNetworkReply *reply);
    void handleSaveReply(QNetworkReply *reply);
    void handleUpdateReply(QNetworkReply *reply);
    void handleDeleteReply(QNetworkReply *reply);
    void emitFailed(QNetworkReply *reply);
};

#endif // PERSISTENCEMANAGERBASE_H
