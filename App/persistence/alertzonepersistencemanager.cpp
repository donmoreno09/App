#include "alertzonepersistencemanager.h"
#include "../connections/apiendpoints.h"
#include "../entities/AlertZone.h"
#include <QDebug>

AlertZonePersistenceManager::AlertZonePersistenceManager(QObject *parent)
    : PersistenceManagerBase(parent)
{
    qDebug() << "[AlertZonePersistenceManager] Persistence manager initialized";
}

IPersistable* AlertZonePersistenceManager::createPersistable() const
{
    return new AlertZone();
}

QString AlertZonePersistenceManager::getApiEndpoint() const
{
    return ApiEndpoints::BaseUrlAlertZone;
}

void AlertZonePersistenceManager::load()
{
    qDebug() << "[AlertZonePersistenceManager] Loading alert zones from backend...";
    qDebug() << "[AlertZonePersistenceManager] GET" << getApiEndpoint();

    m_httpClient.get(QUrl(getApiEndpoint()));

    qDebug() << "[AlertZonePersistenceManager] Load request sent (async)";
}
