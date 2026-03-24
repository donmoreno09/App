#include "AlertZoneModel.h"
#include <QDebug>
#include <QMetaType>

Q_DECLARE_METATYPE(QList<QGeoCoordinate>)

AlertZoneModel::AlertZoneModel(QObject *parent)
    : QAbstractListModel(parent), m_helper(new ModelHelper(this))
{
}

void AlertZoneModel::initialize(HttpClient* client)
{
    Q_ASSERT(client);
    m_httpClient = client;
    m_api = new AlertZoneApi(client, this);
}

void AlertZoneModel::fetch()
{
    if (!m_api) return;

    m_api->getMany([this](const QVector<AlertZone>& zones) {
        beginResetModel();
        m_alertZones.clear();
        m_alertZones.reserve(zones.size());
        for (auto& az : zones)
            m_alertZones.push_back(az);
        endResetModel();
    }, [](const ErrorResult& er) {
        qDebug().noquote() << "[AlertZoneModel] Could not load alert zones:" << er.message;
    });
}

void AlertZoneModel::clear()
{
    beginResetModel();
    m_alertZones.clear();
    endResetModel();
}

int AlertZoneModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) return 0;

    return m_alertZones.size();
}

QVariant AlertZoneModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) return {};
    if (index.row() < 0 || index.row() >= m_alertZones.size()) return {};

    const auto& alertZone = m_alertZones[index.row()];
    switch (role) {
    case IdRole:
        return alertZone.id;
    case LabelRole:
        return alertZone.label;

    // Geometry
    case ShapeTypeIdRole:
        return alertZone.geometry.shapeTypeId;
    case SurfaceRole:
        return alertZone.geometry.surface;
    case HeightRole:
        return alertZone.geometry.height;
    case CoordinateRole: {
        QGeoCoordinate coord(alertZone.geometry.coordinate.y(), alertZone.geometry.coordinate.x());
        return QVariant::fromValue(coord);
    }
    case CoordinatesRole: {
        QList<QGeoCoordinate> out;
        out.reserve(alertZone.geometry.coordinates.size());
        for (int i = 0; i < alertZone.geometry.coordinates.length(); i++) {
            if (i == alertZone.geometry.coordinates.length() - 1) break; // skip last closing point
            const auto& p = alertZone.geometry.coordinates[i];
            out.append(QGeoCoordinate(p.y(), p.x())); // lat, lon
        }
        return QVariant::fromValue(out);
    }
    case TopLeftRole: {
        if (!isRectangle(alertZone.geometry)) return QVariant::fromValue(QGeoCoordinate());
        QGeoCoordinate topLeft(alertZone.geometry.coordinates[0].y(), alertZone.geometry.coordinates[0].x());
        return QVariant::fromValue(topLeft);
    }
    case BottomRightRole: {
        if (!isRectangle(alertZone.geometry)) return QVariant::fromValue(QGeoCoordinate());
        QGeoCoordinate bottomRight(alertZone.geometry.coordinates[2].y(), alertZone.geometry.coordinates[2].x());
        return QVariant::fromValue(bottomRight);
    }
    case RadiusARole:
        return alertZone.geometry.radiusA;
    case RadiusBRole:
        return alertZone.geometry.radiusB;
    case IsRectangleRole:
        return isRectangle(alertZone.geometry);

    case NoteRole: {
        auto it = alertZone.details.metadata.find(QStringLiteral("note"));
        if (it != alertZone.details.metadata.end()) {
            if (auto notePtr = qSharedPointerCast<NoteMetadataEntry>(it.value())) {
                return notePtr->note;
            }
        }
        return {};
    }
    case SeverityRole:
        return alertZone.severity;
    case ActiveRole:
        return alertZone.active;
    case LayersRole: {
        QVariantMap map;
        for (auto it = alertZone.layers.begin(); it != alertZone.layers.end(); ++it) {
            map.insert(it.key(), it.value());
        }
        return map;
    }
    case ModelIndexRole:
        return index.row();
    }

    return {};
}

bool AlertZoneModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (!index.isValid()) return false;
    if (index.row() < 0 || index.row() >= m_alertZones.size()) return false;

    auto& alertZone = m_alertZones[index.row()];
    bool changed = false;

    switch (role) {
    // Immutable
    case IdRole:
    case ShapeTypeIdRole:
    case IsRectangleRole:
    case ModelIndexRole:
        break;

    case LabelRole: {
        const auto v = value.toString();
        if (alertZone.label != v) {
            alertZone.label = v;
            changed = true;
        }
        break;
    }

    case NoteRole: {
        const auto v = value.toString();
        auto it = alertZone.details.metadata.find(QStringLiteral("note"));
        QSharedPointer<NoteMetadataEntry> notePtr;
        if (it == alertZone.details.metadata.end()) {
            notePtr = QSharedPointer<NoteMetadataEntry>::create();
            alertZone.details.metadata.insert(QStringLiteral("note"), notePtr);
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

    case SeverityRole: {
        const int v = value.toInt();
        if (alertZone.severity != v) {
            alertZone.severity = v;
            changed = true;
        }
        break;
    }

    case ActiveRole: {
        const bool v = value.toBool();
        if (alertZone.active != v) {
            alertZone.active = v;
            changed = true;
        }
        break;
    }

    case LayersRole: {
        const QVariantMap vMap = value.toMap();
        QMap<QString, bool> newLayers;
        for (auto it = vMap.begin(); it != vMap.end(); ++it) {
            newLayers.insert(it.key(), it.value().toBool());
        }
        if (alertZone.layers != newLayers) {
            alertZone.layers = newLayers;
            changed = true;
        }
        break;
    }

    // Geometry
    case SurfaceRole: {
        const double v = value.toDouble();
        if (!qFuzzyCompare(alertZone.geometry.surface, v)) {
            alertZone.geometry.surface = v;
            changed = true;
        }
        break;
    }
    case HeightRole: {
        const double v = value.toDouble();
        if (!qFuzzyCompare(alertZone.geometry.height, v)) {
            alertZone.geometry.height = v;
            changed = true;
        }
        break;
    }
    case CoordinateRole: {
        const QGeoCoordinate coord = value.value<QGeoCoordinate>();
        const QPointF point(coord.longitude(), coord.latitude());
        if (!qFuzzyCompare(point.x(), alertZone.geometry.coordinate.x()) ||
            !qFuzzyCompare(point.y(), alertZone.geometry.coordinate.y())) {
            alertZone.geometry.coordinate = point;
            changed = true;
        }
        break;
    }
    case CoordinatesRole: {
        QList<QPointF> newCoords;

        if (value.canConvert<QList<QGeoCoordinate>>()) {
            const auto list = value.value<QList<QGeoCoordinate>>();
            newCoords.reserve(list.size());
            for (const auto &c : list)
                newCoords.append(QPointF(c.longitude(), c.latitude()));
        } else {
            newCoords = parseCoordinatesVariant(value);
        }

        if (!compareCoords(alertZone.geometry.coordinates, newCoords)) {
            alertZone.geometry.coordinates = newCoords;
            changed = true;
        }
        break;
    }
    case TopLeftRole: {
        if (!isRectangle(alertZone.geometry)) return false;

        const QGeoCoordinate c = value.value<QGeoCoordinate>();
        const QPointF topLeft(c.longitude(), c.latitude());

        QPointF bottomRight = topLeft;
        if (alertZone.geometry.coordinates.size() >= 3) {
            bottomRight = alertZone.geometry.coordinates[2];
        }

        QList<QPointF> rect;
        rect.reserve(5);
        const QPointF topRight(bottomRight.x(), topLeft.y());
        const QPointF bottomLeft(topLeft.x(), bottomRight.y());
        rect << topLeft << topRight << bottomRight << bottomLeft << topLeft;

        if (!compareCoords(alertZone.geometry.coordinates, rect)) {
            alertZone.geometry.coordinates = rect;
            changed = true;
        }
        break;
    }
    case BottomRightRole: {
        if (!isRectangle(alertZone.geometry)) return false;

        const QGeoCoordinate c = value.value<QGeoCoordinate>();
        const QPointF BR(c.longitude(), c.latitude());

        QPointF TL = BR;
        if (alertZone.geometry.coordinates.size() >= 1) {
            TL = alertZone.geometry.coordinates[0];
        }

        QList<QPointF> rect;
        rect.reserve(5);
        const QPointF TR(BR.x(), TL.y());
        const QPointF BL(TL.x(), BR.y());
        rect << TL << TR << BR << BL << TL;

        if (!compareCoords(alertZone.geometry.coordinates, rect)) {
            alertZone.geometry.coordinates = rect;
            changed = true;
        }
        break;
    }
    case RadiusARole: {
        const double v = value.toDouble();
        if (!qFuzzyCompare(alertZone.geometry.radiusA, v)) {
            alertZone.geometry.radiusA = v;
            changed = true;
        }
        break;
    }
    case RadiusBRole: {
        const double v = value.toDouble();
        if (!qFuzzyCompare(alertZone.geometry.radiusB, v)) {
            alertZone.geometry.radiusB = v;
            changed = true;
        }
        break;
    }
    }

    if (changed) emit dataChanged(index, index, { role });
    return changed;
}

QHash<int, QByteArray> AlertZoneModel::roleNames() const
{
    return {
            { IdRole, "id" },
            { LabelRole, "label" },

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
            { SeverityRole, "severity" },
            { ActiveRole, "active" },
            { LayersRole, "layers" },
            { ModelIndexRole, "modelIndex" },
            };
}

Qt::ItemFlags AlertZoneModel::flags(const QModelIndex &index) const
{
    if (!index.isValid()) return Qt::NoItemFlags;
    return Qt::ItemIsEditable | Qt::ItemIsSelectable;
}

QVector<AlertZone> &AlertZoneModel::alertZones()
{
    return m_alertZones;
}

void AlertZoneModel::setCoordinate(int row, int coordIndex, const QGeoCoordinate &coord)
{
    const QModelIndex idx = index(row, 0);
    if (!idx.isValid() || row < 0 || row >= m_alertZones.size())
        return;

    auto& coordinates = m_alertZones[row].geometry.coordinates;
    if (coordIndex < 0 || coordIndex >= coordinates.length())
        return;

    const QPointF oldPoint = coordinates.at(coordIndex);
    const QPointF point(coord.longitude(), coord.latitude());
    if (!qFuzzyCompare(point.x(), oldPoint.x()) || !qFuzzyCompare(point.y(), oldPoint.y())) {
        coordinates[coordIndex] = point;

        // Update closing point if modifying first point
        if (coordIndex == 0) coordinates[coordinates.length() - 1] = point;

        emit dataChanged(idx, idx, { CoordinatesRole });
    }
}

void AlertZoneModel::append(const QVariantMap &data)
{
    setLoading(true);
    buildAlertZoneSave(data);

    // Copy poi to prevent lambda from possibly referincing freed pointer
    auto azCopy = *m_alertZoneSave;

    m_api->post(azCopy, [this, azCopy](const QString& uuid) mutable {
        const int index = m_alertZones.size();
        beginInsertRows(QModelIndex(), index, index);

        azCopy.id = uuid;
        m_alertZones.push_back(azCopy);

        endInsertRows();
        emit appended();
        setLoading(false);
    }, [this](const ErrorResult& er) {
        qDebug().noquote() << "[AlertZoneModel] Could not save alert zone:" << er.message;
        setLoading(false);
    });
}

void AlertZoneModel::update(const QVariantMap &data)
{
    setLoading(true);
    buildAlertZoneSave(data);
    m_alertZoneSave->id = data.value("id").toString();

    m_api->put(*m_alertZoneSave, [this] {
        int row = -1;
        for (int i = 0; i < m_alertZones.size(); i++) {
            if(m_alertZones[i].id == m_alertZoneSave->id){
                row = i;
                break;
            }
        }

        if (row >= 0) {
            m_alertZones[row] = *m_alertZoneSave;

            QModelIndex idx = index(row, 0);
            emit dataChanged(idx, idx);
        }

        m_oldAlertZone = nullptr;
        emit updated();
        setLoading(false);
    }, [this](const ErrorResult& er) {
        qDebug().noquote().nospace() << "[AlertZoneModel] Could not update alert zone with id " << m_alertZoneSave->id << ": " << er.message;
        setLoading(false);
    });
}

void AlertZoneModel::remove(const QString &id)
{
    setLoading(true);

    m_api->remove(id, [this, id] {
        int row = -1;
        for (int i = 0; i < m_alertZones.size(); i++) {
            if (m_alertZones[i].id == id) {
                row = i;
                break;
            }
        }

        if (row < 0) { // nothing to remove
            setLoading(false);
            return;
        }

        beginRemoveRows(QModelIndex(), row, row);
        m_alertZones.remove(row);
        endRemoveRows();

        m_oldAlertZone = nullptr;
        emit removed();
        setLoading(false);
    }, [this, id](const ErrorResult& er) {
        qDebug().noquote().nospace() << "[AlertZoneModel] Could not delete alert zone with id " << id << ": " << er.message;
        setLoading(false);
    });
}

QQmlPropertyMap *AlertZoneModel::getEditableAlertZone(int index)
{
    if (index < 0 || index >= m_alertZones.size())
        return nullptr;

    discardChanges();

    m_oldAlertZone = std::make_unique<AlertZone>(m_alertZones[index]);
    m_api->get(m_oldAlertZone->id, [this](const AlertZone& az) {
        // Find the corresponding row in the model
        int row = -1;
        for (int i = 0; i < m_alertZones.size(); i++) {
            if (m_alertZones[i].id == az.id) {
                row = i;
                break;
            }
        }

        // If the POI exists in our model, update it
        if (row >= 0) {
            m_alertZones[row] = az;
            QModelIndex idx = this->index(row, 0);
            emit dataChanged(idx, idx);
            emit fetched(az.id);
        }
    }, [this](const auto& er) {
        qDebug().noquote() << "[AlertZoneModel] Could not get alert zone:" << m_oldAlertZone->id;
    });

    return m_helper->map(index, 0);
}

void AlertZoneModel::discardChanges()
{
    if (m_oldAlertZone == nullptr)
        return;

    int row = -1;
    for (int i = 0; i < m_alertZones.size(); ++i) {
        if (m_alertZones[i].id == m_oldAlertZone->id) {
            row = i;
            break;
        }
    }

    if (row >= 0) {
        m_alertZones[row] = *m_oldAlertZone;
        m_oldAlertZone = nullptr;
        QModelIndex idx = index(row, 0);
        emit dataChanged(idx, idx);
    }
}

void AlertZoneModel::printData()
{
    for (const auto& alertZone : std::as_const(m_alertZones)) {
        qDebug() << "ID: " << alertZone.id << " -------------------";
        qDebug() << "Label: " << alertZone.label;
        qDebug() << "Coordinates count:" << alertZone.geometry.coordinates.size();
    }
}

bool AlertZoneModel::loading() const
{
    return m_loading;
}

void AlertZoneModel::setLoading(bool newLoading)
{
    if (m_loading == newLoading)
        return;
    m_loading = newLoading;
    emit loadingChanged();
}

QList<QPointF> AlertZoneModel::parseCoordinatesVariant(const QVariant &v)
{
    QList<QPointF> out;

    if (v.typeId() == QMetaType::QVariantList) {
        const auto list = v.toList();
        out.reserve(list.size());
        for (const auto& item : list) {
            const auto m = item.toMap();
            const double x = m.value(QStringLiteral("x"), m.value(QStringLiteral("lon"))).toDouble();
            const double y = m.value(QStringLiteral("y"), m.value(QStringLiteral("lat"))).toDouble();
            out.push_back(QPointF(x, y));
        }
        return out;
    }

    if (v.canConvert<QList<QPointF>>()) {
        return v.value<QList<QPointF>>();
    }

    if (v.canConvert<QVariantList>()) {
        const auto list = v.toList();
        out.reserve(list.size());
        for (const auto& item : list) {
            const auto arr = item.toList();
            if (arr.size() >= 2) {
                out.push_back(QPointF(arr[0].toDouble(), arr[1].toDouble()));
            }
        }
        return out;
    }

    return out;
}

bool AlertZoneModel::compareCoords(const QList<QPointF> &a, const QList<QPointF> &b)
{
    if (a.size() != b.size()) return false;
    for (int i = 0; i < a.size(); ++i) {
        if (!qFuzzyCompare(a[i].x(), b[i].x()) || !qFuzzyCompare(a[i].y(), b[i].y()))
            return false;
    }
    return true;
}

bool AlertZoneModel::isRectangle(const Geometry &geom)
{
    // Must be shapeTypeId == 3 (polygon) and 5 coordinates (closed loop)
    if (geom.shapeTypeId != 3 || geom.coordinates.size() != 5)
        return false;

    const QPointF& TL = geom.coordinates[0];
    const QPointF& TR = geom.coordinates[1];
    const QPointF& BR = geom.coordinates[2];
    const QPointF& BL = geom.coordinates[3];
    const QPointF& backToTL = geom.coordinates[4];

    // Ensure closure (last == first)
    if (!qFuzzyCompare(TL.x(), backToTL.x()) || !qFuzzyCompare(TL.y(), backToTL.y()))
        return false;

    // Check rectangle rules:
    // TL.y == TR.y, TR.x == BR.x, BR.y == BL.y, BL.x == TL.x
    if (!qFuzzyCompare(TL.y(), TR.y())) return false;
    if (!qFuzzyCompare(TR.x(), BR.x())) return false;
    if (!qFuzzyCompare(BR.y(), BL.y())) return false;
    if (!qFuzzyCompare(BL.x(), TL.x())) return false;

    return true;
}

void AlertZoneModel::buildAlertZoneSave(const QVariantMap &data)
{
    m_alertZoneSave = std::make_unique<AlertZone>();

    m_alertZoneSave->label = data.value("label").toString();
    m_alertZoneSave->active = data.value("active", true).toBool();
    m_alertZoneSave->severity = data.value("severity", "low").toInt();

    qDebug() << "[buildAlertZoneSave] Active: " << m_alertZoneSave->active;

    QVariantMap layersMap = data.value("layers").toMap();
    for (auto it = layersMap.begin(); it != layersMap.end(); ++it) {
        m_alertZoneSave->layers.insert(it.key(), it.value().toBool());
    }

    // Geometry
    QVariantMap geomMap = data.value("geometry").toMap();
    Geometry geom;
    geom.shapeTypeId = geomMap.value("shapeTypeId").toInt();
    geom.surface = geomMap.value("surface").toDouble();
    geom.height = geomMap.value("height").toDouble();

    // Center coordinate (for ellipse)
    QVariantMap centerCoordMap = geomMap.value("coordinate").toMap();
    geom.coordinate.setX(centerCoordMap.value("x").toDouble());
    geom.coordinate.setY(centerCoordMap.value("y").toDouble());

    // Radii (for ellipse)
    geom.radiusA = geomMap.value("radiusA").toDouble();
    geom.radiusB = geomMap.value("radiusB").toDouble();

    // Coordinates (for polygon/rectangle)
    QVariantList coordList = geomMap.value("coordinates").toList();
    QList<QPointF> coords;
    for (const QVariant &coordVar : std::as_const(coordList)) {
        QVariantMap coordMap = coordVar.toMap();
        const double x = coordMap.value("x").toDouble();
        const double y = coordMap.value("y").toDouble();
        coords.append(QPointF(x, y));
    }

    if (!coords.isEmpty())
        geom.coordinates = coords;
    m_alertZoneSave->geometry = geom;

    // Process Details/Metadata
    m_alertZoneSave->details.metadata.clear();

    QVariantMap detailsMap = data.value("details").toMap();
    QVariantMap metadataMap = detailsMap.value("metadata").toMap();

    for (auto it = metadataMap.begin(); it != metadataMap.end(); ++it) {
        QString key = it.key();

        if (key == "note") {
            auto entry = QSharedPointer<NoteMetadataEntry>::create();
            entry->note = it.value().toString();
            m_alertZoneSave->details.metadata.insert(key, entry);
        }
    }
}
