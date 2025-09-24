#include "annotationmaplayer.h"
#include "../events/selectionboxbus.h"
#include "../core/geoselectionutils.h"
#include "../persistence/shapepersistencemanager.h"
#include "../models/shape.h"
#include <QDebug>

AnnotationMapLayer::AnnotationMapLayer(QObject* parent)
    : BaseMapLayer(parent)
{
    setObjectName("AnnotationMapLayer");
    m_annotationModel = new VariantListModel(this);

    connect(SelectionBoxBus::instance(), &SelectionBoxBus::selected, this, &AnnotationMapLayer::handleSelectionBoxSelected);
    connect(SelectionBoxBus::instance(), &SelectionBoxBus::deselected, this, &AnnotationMapLayer::handleSelectionBoxDeselected);
}

void AnnotationMapLayer::initialize() {
    qDebug() << "[AnnotationMapLayer:initialize] polling ...";
    BaseMapLayer::initialize();
    loadData();
}

void AnnotationMapLayer::syncSelectedObject(const QVariant &object, bool isToRemove)
{
    for (int i = 0; i < m_selectedAnnotations.length(); i++) {
        if (m_selectedAnnotations[i].toMap().value("id") == object.toMap().value("id")) {
            if (isToRemove) m_selectedAnnotations.removeAt(i);
            else m_selectedAnnotations[i] = object;
            break;
        }
    }

    emit selectedObjectsChanged();
}

void AnnotationMapLayer::handleSelectionBoxSelected(const QString &target, const QGeoCoordinate &topLeft, const QGeoCoordinate &bottomRight, int mode)
{
    if (target != layerName())
        return;

    QVariantList selectedAnnots = GeoSelection::selectInRect(m_annotationModel->data(), topLeft, bottomRight);
    qDebug() << "elek: selectedShapes: " << selectedAnnots;
    m_selectedAnnotations = selectedAnnots;
    emit selectedObjectsChanged();
}

void AnnotationMapLayer::handleSelectionBoxDeselected(const QString &target, int mode)
{
    if (target != layerName())
        return;

    m_selectedAnnotations.clear();
    emit selectedObjectsChanged();
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
