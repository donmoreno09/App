#include "shapepersistencemanager.h"
#include <QJsonDocument>
#include "../connections/apiendpoints.h"
#include "../models/shape.h"

ShapePersistenceManager::ShapePersistenceManager(QObject *parent)
    : PersistenceManagerBase(parent)
{}

QString ShapePersistenceManager::getApiEndpoint() const
{
    return ApiEndpoints::BaseUrlShapes;
}

IPersistable* ShapePersistenceManager::createPersistable() const
{
    return new Shape();
}
