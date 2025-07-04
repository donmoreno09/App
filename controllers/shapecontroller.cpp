#include "shapecontroller.h"
#include "../models/shape.h"

ShapeController::ShapeController(QObject *parent)
    : QObject(parent)
{
    connect(&m_persistenceManager, &IPersistenceManager::objectSaved, this, [=](bool success, const QString &objectId) {
        if (success)
            emit shapeSavedSuccessfully(objectId);
        else
            emit shapeSaveFailed();
    });

    connect(&m_persistenceManager, &IPersistenceManager::objectUpdated, this, [=](bool success) {
        if (success)
            emit shapeUpdatedSuccessfully();
        else
            emit shapeUpdateFailed();
    });

    connect(&m_persistenceManager, &IPersistenceManager::objectRemoved, this, [=](bool success) {
        if (success)
            emit shapeDeletedSuccessfully();
        else
            emit shapeDeleteFailed();
    });
}

void ShapeController::saveShapeFromQml(const QVariantMap &data)
{
    Shape shape;

    shape.label = data.value("label").toString();

    // Geometry
    QVariantMap geomMap = data.value("geometry").toMap();
    Geometry geom;
    geom.shapeTypeId = geomMap.value("shapeTypeId").toInt();
    geom.surface = geomMap.value("surface").toDouble();
    geom.height = geomMap.value("height").toDouble();

    QVariantMap centerCoordMap = geomMap.value("coordinate").toMap();
    geom.coordinate.setX(centerCoordMap.value("x").toDouble());
    geom.coordinate.setY(centerCoordMap.value("y").toDouble());

    geom.radiusA = geomMap.value("radiusA").toDouble();
    geom.radiusB = geomMap.value("radiusB").toDouble();

    QVariantList coordList = geomMap.value("coordinates").toList();
    QList<QVector2D> coords;
    for (const QVariant &coordVar : coordList) {
        QVariantMap coordMap = coordVar.toMap();
        float x = static_cast<float>(coordMap.value("x").toDouble());
        float y = static_cast<float>(coordMap.value("y").toDouble());
        coords.append(QVector2D(x, y));
    }

    if (!coords.isEmpty())
        geom.coordinates = coords;
    shape.geometry = geom;

    m_persistenceManager.save(shape);
}


void ShapeController::updateShapeFromQml(const QVariantMap &data)
{
    Shape shape;

    shape.id = data.value("id").toString();
    shape.label = data.value("label").toString();

    // Geometry
    QVariantMap geomMap = data.value("geometry").toMap();
    Geometry geom;
    geom.shapeTypeId = geomMap.value("shapeTypeId").toInt();
    geom.surface = geomMap.value("surface").toDouble();
    geom.height = geomMap.value("height").toDouble();

    QVariantMap centerCoordMap = geomMap.value("coordinate").toMap();
    geom.coordinate.setX(centerCoordMap.value("x").toDouble());
    geom.coordinate.setY(centerCoordMap.value("y").toDouble());

    geom.radiusA = geomMap.value("radiusA").toDouble();
    geom.radiusB = geomMap.value("radiusB").toDouble();

    QVariantList coordList = geomMap.value("coordinates").toList();
    QList<QVector2D> coords;
    for (const QVariant &coordVar : coordList) {
        QVariantMap coordMap = coordVar.toMap();
        float x = static_cast<float>(coordMap.value("x").toDouble());
        float y = static_cast<float>(coordMap.value("y").toDouble());
        coords.append(QVector2D(x, y));
    }

    if (!coords.isEmpty())
        geom.coordinates = coords;
    shape.geometry = geom;

    m_persistenceManager.update(shape);
}

void ShapeController::deleteShapeFromQml(const QString &id)
{
    if (id.isEmpty()) {
        emit shapeDeleteFailed();
        return;
    }

    m_persistenceManager.remove(id);
}
