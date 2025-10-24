#include "PoiModel.h"
#include <QDebug>

PoiModel::PoiModel(QObject *parent)
    : QAbstractListModel(parent), m_helper(new ModelHelper(this)), m_persistenceManager(new PoiPersistenceManager(this))
{
    connect(m_persistenceManager, &PoiPersistenceManager::objectsLoaded, this, &PoiModel::handleObjectsLoaded, Qt::UniqueConnection);
    connect(m_persistenceManager, &PoiPersistenceManager::objectSaved, this, &PoiModel::handlePoiSaved, Qt::UniqueConnection);
    connect(m_persistenceManager, &PoiPersistenceManager::objectGot, this, &PoiModel::handlePoiGot, Qt::UniqueConnection);
    connect(m_persistenceManager, &PoiPersistenceManager::objectUpdated, this, &PoiModel::handlePoiUpdated, Qt::UniqueConnection);
    connect(m_persistenceManager, &PoiPersistenceManager::objectRemoved, this, &PoiModel::handlePoiRemoved, Qt::UniqueConnection);

    m_persistenceManager->load();
}

int PoiModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) return 0;

    return m_pois.size();
}

QVariant PoiModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) return {};
    if (index.row() < 0 || index.row() >= m_pois.size()) return {};

    const auto& poi = m_pois[index.row()];
    switch (role) {
    // Poi
    case IdRole:                   return poi.id;
    case LabelRole:                return poi.label;
    case LayerIdRole:              return poi.layerId;
    case LayerNameRole:            return poi.layerName;
    case TypeIdRole:               return poi.typeId;
    case TypeNameRole:             return poi.typeName;
    case CategoryIdRole:           return poi.categoryId;
    case CategoryNameRole:         return poi.categoryName;
    case HealthStatusIdRole:       return poi.healthStatusId;
    case HealthStatusNameRole:     return poi.healthStatusName;
    case OperationalStateIdRole:   return poi.operationalStateId;
    case OperationalStateNameRole: return poi.operationalStateName;

    // Geometry
    case ShapeTypeIdRole:          return poi.geometry.shapeTypeId;
    case SurfaceRole:              return poi.geometry.surface;
    case HeightRole:               return poi.geometry.height;
    case LatitudeRole:             return poi.geometry.coordinate.y(); // lat
    case LongitudeRole:            return poi.geometry.coordinate.x(); // lon
    case CoordinatesRole: {
        auto* that = const_cast<PoiModel*>(this);
        auto* cm = that->getCoordsModel(poi.id, poi.geometry.coordinates);
        return QVariant::fromValue(static_cast<QObject*>(cm));
    }
    case RadiusARole:              return poi.geometry.radiusA;
    case RadiusBRole:              return poi.geometry.radiusB;

    // Details/Metadata
    case NoteRole: {
        auto it = poi.details.metadata.find(QStringLiteral("note"));
        if (it != poi.details.metadata.end()) {
            if (auto notePtr = qSharedPointerCast<NoteMetadataEntry>(it.value())) {
                return notePtr->note;
            }
        }
        return {};
    }
    }

    return {};
}

bool PoiModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (!index.isValid()) return false;
    if (index.row() < 0 || index.row() >= m_pois.size()) return false;

    auto& poi = m_pois[index.row()];
    bool changed = false;

    switch (role) {
    // Immutable IDs
    case IdRole:
    case LayerIdRole:
    case TypeIdRole:
    case CategoryIdRole:
    case HealthStatusIdRole:
    case OperationalStateIdRole:
    case ShapeTypeIdRole:
        break;

    // Poi
    case LabelRole: {
        const auto v = value.toString();
        if (poi.label != v) { poi.label = v; changed = true; }
        break;
    }
    case LayerNameRole: {
        const auto v = value.toString();
        if (poi.layerName != v) { poi.layerName = v; changed = true; }
        break;
    }
    case TypeNameRole: {
        const auto v = value.toString();
        if (poi.typeName != v) { poi.typeName = v; changed = true; }
        break;
    }
    case CategoryNameRole: {
        const auto v = value.toString();
        if (poi.categoryName != v) { poi.categoryName = v; changed = true; }
        break;
    }
    case HealthStatusNameRole: {
        const auto v = value.toString();
        if (poi.healthStatusName != v) { poi.healthStatusName = v; changed = true; }
        break;
    }
    case OperationalStateNameRole: {
        const auto v = value.toString();
        if (poi.operationalStateName != v) { poi.operationalStateName = v; changed = true; }
        break;
    }

    // Geometry
    case SurfaceRole: {
        const double v = value.toDouble();
        if (!qFuzzyCompare(poi.geometry.surface, v)) { poi.geometry.surface = v; changed = true; }
        break;
    }
    case HeightRole: {
        const double v = value.toDouble();
        if (!qFuzzyCompare(poi.geometry.height, v)) { poi.geometry.height = v; changed = true; }
        break;
    }
    case LatitudeRole: {
        const float lat = value.toFloat();
        if (!qFuzzyCompare(poi.geometry.coordinate.y(), lat)) {
            poi.geometry.coordinate.setY(lat);
            changed = true;
        }
        break;
    }
    case LongitudeRole: {
        const float lon = value.toFloat();
        if (!qFuzzyCompare(poi.geometry.coordinate.x(), lon)) {
            poi.geometry.coordinate.setX(lon);
            changed = true;
        }
        break;
    }
    case CoordinatesRole: {
        const QList<QVector2D> newCoords = parseCoordinatesVariant(value);

        if (!compareCoords(poi.geometry.coordinates, newCoords)) {
            poi.geometry.coordinates = newCoords;

            // If a cached child model exists for this POI id, update it
            if (auto* cm = m_coordsModels.value(poi.id, nullptr)) {
                cm->setPoints(newCoords);
            }

            changed = true;
        }
        break;
    }
    case RadiusARole: {
        const double v = value.toDouble();
        if (!qFuzzyCompare(poi.geometry.radiusA, v)) { poi.geometry.radiusA = v; changed = true; }
        break;
    }
    case RadiusBRole: {
        const double v = value.toDouble();
        if (!qFuzzyCompare(poi.geometry.radiusB, v)) { poi.geometry.radiusB = v; changed = true; }
        break;
    }

    // Details/Metadata
    case NoteRole: {
        const auto v = value.toString();
        auto it = poi.details.metadata.find(QStringLiteral("note"));
        QSharedPointer<NoteMetadataEntry> notePtr;
        if (it == poi.details.metadata.end()) {
            notePtr = QSharedPointer<NoteMetadataEntry>::create();
            poi.details.metadata.insert(QStringLiteral("note"), notePtr);
        } else {
            notePtr = qSharedPointerCast<NoteMetadataEntry>(it.value());
            if (!notePtr) { // replace wrong type with NoteMetadataEntry
                notePtr = QSharedPointer<NoteMetadataEntry>::create();
                it.value() = notePtr;
            }
        }
        if (notePtr->note != v) { notePtr->note = v; changed = true; }
        break;
    }
    }

    if (changed) emit dataChanged(index, index, { role });
    return changed;
}

QHash<int, QByteArray> PoiModel::roleNames() const
{
    return {
        { IdRole, "id" },
        { LabelRole, "label" },
        { LayerIdRole, "layerId" },
        { LayerNameRole, "layerName" },
        { TypeIdRole, "typeId" },
        { TypeNameRole, "typeName" },
        { CategoryIdRole, "categoryId" },
        { CategoryNameRole, "categoryName" },
        { HealthStatusIdRole, "healthStatusId" },
        { HealthStatusNameRole, "healthStatusName" },
        { OperationalStateIdRole, "operationalStateId" },
        { OperationalStateNameRole, "operationalStateName" },

        { ShapeTypeIdRole, "shapeTypeId" },
        { SurfaceRole, "surface" },
        { HeightRole, "height" },
        { LatitudeRole, "latitude" },
        { LongitudeRole, "longitude" },
        { CoordinatesRole, "coordinates" },
        { RadiusARole, "radiusA" },
        { RadiusBRole, "radiusB" },

        { NoteRole, "note" },
    };
}

Qt::ItemFlags PoiModel::flags(const QModelIndex &index) const
{
    if (!index.isValid()) return Qt::NoItemFlags;

    return Qt::ItemIsEditable | Qt::ItemIsSelectable;
}

QVector<Poi> &PoiModel::pois()
{
    return m_pois;
}

void PoiModel::append(const QVariantMap &data)
{
    setLoading(true);
    buildPoiSave(data);
    m_persistenceManager->save(*m_poiSave);
}

void PoiModel::update(const QVariantMap &data)
{
    setLoading(true);
    buildPoiSave(data);
    m_poiSave->id = data.value("id").toString();
    m_persistenceManager->update(*m_poiSave);
}

void PoiModel::remove(const QString &id)
{
    setLoading(true);
    m_persistenceManager->remove(id);
}

QQmlPropertyMap *PoiModel::getEditablePoi(int index)
{
    if (index < 0 || index >= m_pois.size())
        return nullptr;

    m_oldPoi = std::make_unique<Poi>(m_pois[index]);
    m_persistenceManager->get(m_oldPoi->id);

    return m_helper->map(index, 0);
}

void PoiModel::discardChanges()
{
    if (m_oldPoi == nullptr)
        return;

    int row = -1;
    for (int i = 0; i < m_pois.size(); ++i) {
        if (m_pois[i].id == m_oldPoi->id) {
            row = i;
            break;
        }
    }

    if (row >= 0) {
        m_pois[row] = *m_oldPoi;
        QModelIndex idx = index(row, 0);
        emit dataChanged(idx, idx);
    }
}

void PoiModel::printData()
{
    for (const auto& poi : std::as_const(m_pois)) {
        qDebug() << "ID: " << poi.id << " -------------------";
        qDebug() << "Label: " << poi.label;
        qDebug() << "Latitude: " << poi.geometry.coordinate.y();
        qDebug() << "Longitude: " << poi.geometry.coordinate.x();
    }
}

bool PoiModel::loading() const
{
    return m_loading;
}

void PoiModel::setLoading(bool newLoading)
{
    if (m_loading == newLoading)
        return;
    m_loading = newLoading;
    emit loadingChanged();
}

QList<QVector2D> PoiModel::parseCoordinatesVariant(const QVariant &v)
{
    QList<QVector2D> out;

    // 1) QVariantList of maps: [{x:..., y:...}, ...]
    if (v.typeId() == QMetaType::QVariantList) {
        const auto list = v.toList();
        out.reserve(list.size());
        for (const auto& item : list) {
            const auto m = item.toMap();
            // Accept either x/y or lon/lat naming if you want to be lenient
            const float x = m.value(QStringLiteral("x"), m.value(QStringLiteral("lon"))).toFloat();
            const float y = m.value(QStringLiteral("y"), m.value(QStringLiteral("lat"))).toFloat();
            out.push_back(QVector2D(x, y));
        }
        return out;
    }

    // 2) QList<QVector2D> directly wrapped in a QVariant
    if (v.canConvert<QList<QVector2D>>()) {
        return v.value<QList<QVector2D>>();
    }

    // 3) QVariantList of 2-element arrays: [[x,y], [x,y], ...]
    if (v.canConvert<QVariantList>()) {
        const auto list = v.toList();
        out.reserve(list.size());
        for (const auto& item : list) {
            const auto arr = item.toList();
            if (arr.size() >= 2) {
                out.push_back(QVector2D(arr[0].toFloat(), arr[1].toFloat()));
            }
        }
        return out;
    }

    // Unknown format -> empty
    return out;
}

bool PoiModel::compareCoords(const QList<QVector2D> &a, const QList<QVector2D> &b)
{
    if (a.size() != b.size()) return false;
    for (int i = 0; i < a.size(); ++i) {
        if (!qFuzzyCompare(a[i].x(), b[i].x()) || !qFuzzyCompare(a[i].y(), b[i].y()))
            return false;
    }
    return true;
}

CoordinatesModel *PoiModel::getCoordsModel(const QString &id, const QList<QVector2D> &pts)
{
    if (id.isEmpty()) return nullptr;

    if (auto* m = m_coordsModels.value(id, nullptr))
        return m;

    auto* m = new CoordinatesModel(this);
    m->setPoints(pts);
    m_coordsModels.insert(id, m);
    return m;
}

void PoiModel::removeCoordsModel(const QString &id)
{
    if (auto* m = m_coordsModels.take(id))
        m->deleteLater();
}

void PoiModel::buildPoiSave(const QVariantMap &data)
{
    m_poiSave = std::make_unique<Poi>();

    m_poiSave->label = data.value("label").toString();
    m_poiSave->layerId = data.value("layerId").toInt();
    m_poiSave->typeId = data.value("typeId").toInt();
    m_poiSave->categoryId = data.value("categoryId").toInt();
    m_poiSave->healthStatusId = data.value("healthStatusId").toInt();
    m_poiSave->operationalStateId = data.value("operationalStateId").toInt();

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
    for (const QVariant &coordVar : std::as_const(coordList)) {
        QVariantMap coordMap = coordVar.toMap();
        float x = static_cast<float>(coordMap.value("x").toDouble());
        float y = static_cast<float>(coordMap.value("y").toDouble());
        coords.append(QVector2D(x, y));
    }

    if (!coords.isEmpty())
        geom.coordinates = coords;
    m_poiSave->geometry = geom;

    m_poiSave->details.metadata.clear();

    QVariantMap detailsMap = data.value("details").toMap(); // maps to JSON field "details"
    QVariantMap metadataMap = detailsMap.value("metadata").toMap(); // maps to "details.metadata"

    for (auto it = metadataMap.begin(); it != metadataMap.end(); ++it) {
        QString key = it.key();

        if (key == "note") {
            auto entry = QSharedPointer<NoteMetadataEntry>::create();
            entry->note = it.value().toString();
            m_poiSave->details.metadata.insert(key, entry);
        }
    }
}

void PoiModel::handlePoiSaved(bool success, const QString &uuid)
{
    if (!success) {
        qWarning() << "Error: Could not save PoI with label. Check logs.";
    } else {
        const int index = m_pois.size();
        beginInsertRows(QModelIndex(), index, index);

        m_poiSave->id = uuid;
        m_pois.push_back(*m_poiSave);

        endInsertRows();
        emit appended();
    }

    setLoading(false);
}

void PoiModel::handlePoiUpdated(bool success)
{
    if (!success) {
        qWarning() << "Error: Could not update PoI with id '" << m_poiSave->id << "'. Check logs.";
    } else {
        m_oldPoi = nullptr;
        emit updated();
    }

    setLoading(false);
}

void PoiModel::handleObjectsLoaded(const QList<IPersistable*> &objects)
{
    beginResetModel();

    // Drop cached per-POI coordinate models
    for (auto it = m_coordsModels.begin(); it != m_coordsModels.end(); ++it) {
        if (it.value()) it.value()->deleteLater();
    }
    m_coordsModels.clear();

    // Rebuild backing store
    m_pois.clear();
    m_pois.reserve(objects.size());
    for (IPersistable* obj : objects) {
        if (auto* poi = dynamic_cast<Poi*>(obj)) {
            m_pois.push_back(*poi); // copy value object
            delete poi; // free this here since it's copied above anyway and it isn't freed elsewhere
        }
    }

    endResetModel();
}

void PoiModel::handlePoiGot(const IPersistable *object)
{
    const Poi* poi = dynamic_cast<const Poi*>(object);
    if (!poi) return;

    // Find the corresponding row in the model
    int row = -1;
    for (int i = 0; i < m_pois.size(); ++i) {
        if (m_pois[i].id == poi->id) {
            row = i;
            break;
        }
    }

    // If the POI exists in our model, update it
    if (row >= 0) {
        m_pois[row] = *poi;
        QModelIndex idx = index(row, 0);
        emit dataChanged(idx, idx);
        emit fetched(poi->id);
    }
}

void PoiModel::handlePoiRemoved(bool success)
{
    if (!success) {
        qWarning() << "Error: Could not remove PoI with id '" << m_poiSave->id << "'. Check logs.";
    } else {
        int row = -1;
        for (int i = 0; i < m_pois.size(); ++i) {
            if (m_pois[i].id == m_oldPoi->id) {
                row = i;
                break;
            }
        }

        beginRemoveRows(QModelIndex(), row, row);
        m_pois.remove(row);
        endRemoveRows();

        m_oldPoi = nullptr;
        emit removed();
    }

    setLoading(false);
}

