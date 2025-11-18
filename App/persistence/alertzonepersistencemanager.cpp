#include "alertzonepersistencemanager.h"
#include "../connections/apiendpoints.h"
#include "../entities/AlertZone.h"
#include <QDebug>

AlertZonePersistenceManager::AlertZonePersistenceManager(QObject *parent)
    : PersistenceManagerBase(parent)
{
    qDebug() << "[AlertZonePersistenceManager] Persistence manager initialized";
}

QString AlertZonePersistenceManager::getApiEndpoint() const
{
    return ApiEndpoints::BaseUrlAlertZone;
}

IPersistable* AlertZonePersistenceManager::createPersistable() const
{
    return new AlertZone();
}

void AlertZonePersistenceManager::load()
{
    qDebug() << "[AlertZonePersistenceManager] Loading alert zones from backend...";
    qDebug() << "[AlertZonePersistenceManager] GET" << getApiEndpoint();

    m_httpClient.get(QUrl(getApiEndpoint()));

    // It should be like this: m_httpClient.get(QUrl(getApiEndpoint() + "/layer/{?}"));
    // TODO: update the layer id here once be is done

    qDebug() << "[AlertZonePersistenceManager] Load request sent (async)";
}
