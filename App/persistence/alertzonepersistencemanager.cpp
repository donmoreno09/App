#include "alertzonepersistencemanager.h"
#include "../connections/apiendpoints.h"
#include "../entities/AlertZone.h"

AlertZonePersistenceManager::AlertZonePersistenceManager(QObject *parent)
    : PersistenceManagerBase(parent)
{}

QString AlertZonePersistenceManager::getApiEndpoint() const
{
    return ApiEndpoints::BaseUrlAlertZone();
}

IPersistable* AlertZonePersistenceManager::createPersistable() const
{
    return new AlertZone();
}

void AlertZonePersistenceManager::load()
{
    qDebug() << "[AlertZonePersistenceManager] Loading alert zones from backend...";

    QString endpoint = getApiEndpoint() + "/all";
    qDebug() << "[AlertZonePersistenceManager] GET" << endpoint;

    m_httpClient.get(QUrl(endpoint));

    qDebug() << "[AlertZonePersistenceManager] Load request sent (async)";
}
