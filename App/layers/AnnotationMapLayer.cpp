#include "annotationmaplayer.h"
#include "../persistence/shapepersistencemanager.h"
#include <QDebug>
#include <core/GeoSelectionUtils.h>
#include <entities/shape.h>

AnnotationMapLayer::AnnotationMapLayer(QObject* parent)
    : BaseMapLayer(parent)
{
    setObjectName("AnnotationMapLayer");
    m_annotationModel = new VariantListModel(this);
}

void AnnotationMapLayer::initialize() {
    qDebug() << "[AnnotationMapLayer:initialize] polling ...";
    BaseMapLayer::initialize();
    loadData();
}

void AnnotationMapLayer::selectInRect(const QGeoCoordinate &topLeft, const QGeoCoordinate &bottomRight)
{
    QVariantList selectedAnnots = GeoSelection::selectInRect(m_annotationModel->data(), topLeft, bottomRight);
    qDebug() << "[AnnotationMapLayer] selectedShapes: " << selectedAnnots;
    m_selectedAnnotations = selectedAnnots;
    emit selectedInRect();
}

void AnnotationMapLayer::clearSelection()
{
    m_selectedAnnotations.clear();
    emit clearedSelection();
}

void AnnotationMapLayer::loadData()
{
    if (!m_loader) {
        m_loader = new ShapePersistenceManager(this);
        connect(m_loader, &IPersistenceManager::objectsLoaded, this, [this](const QList<IPersistable*>& objs) {
            this->handleLoadedObjects(objs);
        });
    }

    m_loader->load();
}

void AnnotationMapLayer::handleLoadedObjects(const QList<IPersistable*>& objects) {
    QVariantList annots;

    for (IPersistable* obj : objects) {
        Shape* shape = dynamic_cast<Shape*>(obj);
        if (shape) {
            QVariantMap map;
            map["id"] = shape->id;
            map["label"] = shape->label;
            map["geometry"] = shape->geometry.toJson();
            annots.append(map);
        }
    }

    m_annotationModel->resetWith(annots);
    emit annotationsChanged();
}

VariantListModel *AnnotationMapLayer::annotationModel() const
{
    return m_annotationModel;
}
