#include <QJsonDocument>
#include "poipersistencemanager.h"
#include "../connections/apiendpoints.h"
#include "../models/poi.h"

PoiPersistenceManager::PoiPersistenceManager(QObject *parent)
    : PersistenceManagerBase(parent)
{}

QString PoiPersistenceManager::getApiEndpoint() const
{
    return ApiEndpoints::BaseUrlPoi;
}

IPersistable* PoiPersistenceManager::createPersistable() const
{
    return new Poi();
}

void PoiPersistenceManager::load()
{
    qDebug() << "[PersistenceManagerBase] calling load...";
    m_httpClient.get(QUrl(getApiEndpoint() + "/layer/1"));
}
