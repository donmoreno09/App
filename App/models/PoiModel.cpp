#include "PoiModel.h"
#include <QDebug>
#include <QMetaType>

Q_DECLARE_METATYPE(QList<QGeoCoordinate>) // declare the list type

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
    case CoordinateRole: {
        QGeoCoordinate coord(poi.geometry.coordinate.y(), poi.geometry.coordinate.x());
        return QVariant::fromValue(coord);
    }
    case CoordinatesRole: {
        QList<QGeoCoordinate> out;
        out.reserve(poi.geometry.coordinates.size());
        for (int i = 0 ; i < poi.geometry.coordinates.length(); i++) {
            if (i == poi.geometry.coordinates.length() - 1) break; // skip last point which is used for closing polygon and since the logic in QML doesn't need it

            const auto& p = poi.geometry.coordinates[i];
            out.append(QGeoCoordinate(p.y(), p.x())); // lat, lon
        }
        return QVariant::fromValue(out);
    }
    case TopLeftRole: {
        if (!isRectangle(poi.geometry)) return QVariant::fromValue(QGeoCoordinate());

        QGeoCoordinate topLeft(poi.geometry.coordinates[0].y(), poi.geometry.coordinates[0].x());
        return QVariant::fromValue(topLeft);
    }
    case BottomRightRole: {
        if (!isRectangle(poi.geometry)) return QVariant::fromValue(QGeoCoordinate());

        QGeoCoordinate bottomRight(poi.geometry.coordinates[2].y(), poi.geometry.coordinates[2].x());
        return QVariant::fromValue(bottomRight);
    }
    case RadiusARole:     return poi.geometry.radiusA;
    case RadiusBRole:     return poi.geometry.radiusB;
    case IsRectangleRole: return isRectangle(poi.geometry);

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

    // Temp/Internals
    case ModelIndexRole: {
        return index.row();
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
    // Immutable IDs/data
    case IdRole:
    case LayerIdRole:
    case TypeIdRole:
    case CategoryIdRole:
    case HealthStatusIdRole:
    case OperationalStateIdRole:
    case ShapeTypeIdRole:
    case IsRectangleRole:
    case ModelIndexRole:
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
    case CoordinateRole: {
        const QGeoCoordinate coord = value.value<QGeoCoordinate>();
        const QVector2D point(coord.longitude(), coord.latitude());
        if (!qFuzzyCompare(point.x(), poi.geometry.coordinate.x()) || !qFuzzyCompare(point.y(), poi.geometry.coordinate.y())) {
            poi.geometry.coordinate = point;
            changed = true;
        }
        break;
    }
    case CoordinatesRole: {
        QList<QVector2D> newCoords;

        // Preferred: direct QList<QGeoCoordinate>
        if (value.canConvert<QList<QGeoCoordinate>>()) {
            const auto list = value.value<QList<QGeoCoordinate>>();
            newCoords.reserve(list.size());
            for (const auto &c : list)
                newCoords.append(QVector2D(c.longitude(), c.latitude())); // x=lon, y=lat
        } else {
            // Fallbacks: [{x,y}], [[x,y]], QList<QVector2D>, etc.
            newCoords = parseCoordinatesVariant(value);
        }

        if (!compareCoords(poi.geometry.coordinates, newCoords)) {
            poi.geometry.coordinates = newCoords;
            changed = true;
        }
        break;
    }
    case TopLeftRole: {
        if (!isRectangle(poi.geometry)) return false;

        const QGeoCoordinate c = value.value<QGeoCoordinate>();
        const QVector2D topLeft(c.longitude(), c.latitude()); // x=lon, y=lat

        // Opposite corner from current geometry if present, otherwise degenerate
        QVector2D bottomRight = topLeft;
        if (poi.geometry.coordinates.size() >= 3) {
            bottomRight = poi.geometry.coordinates[2]; // index 2 is bottom right
        }

        // Rebuild rectangle: TL, TR, BR, BL, TL
        QList<QVector2D> rect;
        rect.reserve(5);
        const QVector2D topRight(bottomRight.x(), topLeft.y());
        const QVector2D bottomLeft(topLeft.x(), bottomRight.y());
        rect << topLeft << topRight << bottomRight << bottomLeft << topLeft;

        if (!compareCoords(poi.geometry.coordinates, rect)) {
            poi.geometry.coordinates = rect;
            changed = true;
        }
        break;
    }
    case BottomRightRole: {
        if (!isRectangle(poi.geometry)) return false;

        const QGeoCoordinate c = value.value<QGeoCoordinate>();
        const QVector2D BR(c.longitude(), c.latitude()); // x=lon, y=lat

        // Opposite corner from current geometry if present, otherwise degenerate
        QVector2D TL = BR;
        if (poi.geometry.coordinates.size() >= 1) {
            TL = poi.geometry.coordinates[0]; // index 0 is top left
        }

        // Rebuild rectangle: TL, TR, BR, BL, TL
        QList<QVector2D> rect;
        rect.reserve(5);
        const QVector2D TR(BR.x(), TL.y());
        const QVector2D BL(TL.x(), BR.y());
        rect << TL << TR << BR << BL << TL;

        if (!compareCoords(poi.geometry.coordinates, rect)) {
            poi.geometry.coordinates = rect;
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
        { CoordinateRole, "coordinate" },
        { CoordinatesRole, "coordinates" },
        { TopLeftRole, "topLeft" },
        { BottomRightRole, "bottomRight" },
        { RadiusARole, "radiusA" },
        { RadiusBRole, "radiusB" },
        { IsRectangleRole, "isRectangle" },

        { NoteRole, "note" },
        { ModelIndexRole, "modelIndex" },
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

void PoiModel::setCoordinate(int row, int coordIndex, const QGeoCoordinate &coord)
{
    const QModelIndex idx = index(row, 0);
    if (!idx.isValid() || row < 0 || row >= m_pois.size())
        return;

    auto& coordinates = m_pois[row].geometry.coordinates;
    if (coordIndex < 0 || coordIndex >= coordinates.length())
        return;

    const QVector2D oldPoint = coordinates.at(coordIndex);
    const QVector2D point(coord.longitude(), coord.latitude());
    if (!qFuzzyCompare(point.x(), oldPoint.x()) || !qFuzzyCompare(point.y(), oldPoint.y())) {
        coordinates[coordIndex] = point;

        // Since in the QML side, I don't show the last point, we update it here
        if (coordIndex == 0) coordinates[coordinates.length() - 1] = point;

        emit dataChanged(idx, idx, { CoordinatesRole });
    }
}

void PoiModel::insertCoordinate(int row, int coordIndex, const QGeoCoordinate &coord)
{
    const QModelIndex idx = index(row, 0);
    if (!idx.isValid() || row < 0 || row >= m_pois.size())
        return;

    auto& coordinates = m_pois[row].geometry.coordinates;

    if (coordIndex < 0 || coordIndex > coordinates.length())
        return;

    const QVector2D point(coord.longitude(), coord.latitude());
    coordinates.insert(coordIndex, point);

    // Update closing point if inserting at the beginning
    if (coordIndex == 0 && coordinates.length() > 1) {
        coordinates[coordinates.length() - 1] = point;
    }

    emit dataChanged(idx, idx, { CoordinatesRole });
}

void PoiModel::removeCoordinate(int row, int coordIndex)
{
    const QModelIndex idx = index(row, 0);
    if (!idx.isValid() || row < 0 || row >= m_pois.size())
        return;

    auto& coordinates = m_pois[row].geometry.coordinates;

    if (coordIndex < 0 || coordIndex >= coordinates.length())
        return;

    // Prevent invalid polygons (minimum 3 unique points + 1 closing = 4 total)
    if (coordinates.length() <= 4)
        return;

    coordinates.removeAt(coordIndex);

    // Update closing point if we removed the first point
    if (coordIndex == 0 && coordinates.length() > 0) {
        coordinates[coordinates.length() - 1] = coordinates[0];
    }

    emit dataChanged(idx, idx, { CoordinatesRole });
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

    discardChanges();

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
        m_oldPoi = nullptr;
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

bool PoiModel::isRectangle(const Geometry &geom)
{
    // Must be shapeTypeId == 3 (rectangle) and 5 coordinates (closed loop)
    if (geom.shapeTypeId != 3 || geom.coordinates.size() != 5)
        return false;

    const QVector2D& TL = geom.coordinates[0];
    const QVector2D& TR = geom.coordinates[1];
    const QVector2D& BR = geom.coordinates[2];
    const QVector2D& BL = geom.coordinates[3];
    const QVector2D& backToTL = geom.coordinates[4];

    // Ensure closure (last == first)
    if (!qFuzzyCompare(TL.x(), backToTL.x()) || !qFuzzyCompare(TL.y(), backToTL.y()))
        return false;

    // Check rectangle rules:
    // TL.y == TR.y, TR.x == BR.x, BR.y == BL.y, BL.x == TL.x
    if (!qFuzzyCompare(TL.y(), TR.y())) return false;
    if (!qFuzzyCompare(TR.x(), BR.x())) return false;
    if (!qFuzzyCompare(BR.y(), BL.y())) return false;
    if (!qFuzzyCompare(BL.x(), TL.x())) return false;

    // Optional: ensure non-degenerate (width/height > 0)
    // const double width  = std::abs(TR.x() - TL.x());
    // const double height = std::abs(TL.y() - BL.y());
    // if (qFuzzyIsNull(width) || qFuzzyIsNull(height))
    //     return false;

    return true;
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
        qWarning() << "Error: Could not save PoI with label '" << (m_poiSave != nullptr ? m_poiSave->label : "unknown") << "'. Check logs.";
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

