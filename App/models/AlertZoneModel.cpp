#include "AlertZoneModel.h"
#include <QDebug>
#include <QMetaType>
#include <QUuid>

Q_DECLARE_METATYPE(QList<QGeoCoordinate>)

AlertZoneModel::AlertZoneModel(QObject *parent)
    : QAbstractListModel(parent)
{
    // No persistence manager - local storage only
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
    case LayerIdRole:
        return alertZone.layerId;
    case LayerNameRole:
        return alertZone.layerName;
    case ShapeTypeIdRole:
        return alertZone.geometry.shapeTypeId;
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
    case IdRole:
    case LayerIdRole:
    case ShapeTypeIdRole:
    case ModelIndexRole:
        // Immutable
        break;

    case LabelRole: {
        const auto v = value.toString();
        if (alertZone.label != v) {
            alertZone.label = v;
            changed = true;
        }
        break;
    }

    case LayerNameRole: {
        const auto v = value.toString();
        if (alertZone.layerName != v) {
            alertZone.layerName = v;
            changed = true;
        }
        break;
    }

    case CoordinatesRole: {
        QList<QVector2D> newCoords;

        if (value.canConvert<QList<QGeoCoordinate>>()) {
            const auto list = value.value<QList<QGeoCoordinate>>();
            newCoords.reserve(list.size());
            for (const auto &c : list)
                newCoords.append(QVector2D(c.longitude(), c.latitude()));
        } else {
            newCoords = parseCoordinatesVariant(value);
        }

        if (!compareCoords(alertZone.geometry.coordinates, newCoords)) {
            alertZone.geometry.coordinates = newCoords;
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
            { LayerIdRole, "layerId" },
            { LayerNameRole, "layerName" },
            { ShapeTypeIdRole, "shapeTypeId" },
            { CoordinatesRole, "coordinates" },
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

    const QVector2D oldPoint = coordinates.at(coordIndex);
    const QVector2D point(coord.longitude(), coord.latitude());
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

    // Generate UUID locally (no backend)
    m_alertZoneSave->id = QUuid::createUuid().toString(QUuid::WithoutBraces);

    const int index = m_alertZones.size();
    beginInsertRows(QModelIndex(), index, index);
    m_alertZones.push_back(*m_alertZoneSave);
    endInsertRows();

    emit appended();
    setLoading(false);

    qDebug() << "[AlertZoneModel] Appended alert zone:" << m_alertZoneSave->label << "with ID:" << m_alertZoneSave->id;
}

void AlertZoneModel::update(const QVariantMap &data)
{
    setLoading(true);
    buildAlertZoneSave(data);
    m_alertZoneSave->id = data.value("id").toString();

    // Find and update in local storage
    int row = -1;
    for (int i = 0; i < m_alertZones.size(); ++i) {
        if (m_alertZones[i].id == m_alertZoneSave->id) {
            row = i;
            break;
        }
    }

    if (row >= 0) {
        m_alertZones[row] = *m_alertZoneSave;
        QModelIndex idx = index(row, 0);
        emit dataChanged(idx, idx);
        m_oldAlertZone = nullptr;
        emit updated();
        qDebug() << "[AlertZoneModel] Updated alert zone:" << m_alertZoneSave->label;
    }

    setLoading(false);
}

void AlertZoneModel::remove(const QString &id)
{
    setLoading(true);

    int row = -1;
    for (int i = 0; i < m_alertZones.size(); ++i) {
        if (m_alertZones[i].id == id) {
            row = i;
            break;
        }
    }

    if (row >= 0) {
        beginRemoveRows(QModelIndex(), row, row);
        m_alertZones.remove(row);
        endRemoveRows();
        m_oldAlertZone = nullptr;
        emit removed();
        qDebug() << "[AlertZoneModel] Removed alert zone with ID:" << id;
    }

    setLoading(false);
}

QQmlPropertyMap *AlertZoneModel::getEditableAlertZone(int index)
{
    if (index < 0 || index >= m_alertZones.size())
        return nullptr;

    discardChanges();
    m_oldAlertZone = std::make_unique<AlertZone>(m_alertZones[index]);

    // For now, just return nullptr - we'll handle this in QML directly
    // This would need ModelHelper like PoiModel if we want QQmlPropertyMap support
    return nullptr;
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

QList<QVector2D> AlertZoneModel::parseCoordinatesVariant(const QVariant &v)
{
    QList<QVector2D> out;

    if (v.typeId() == QMetaType::QVariantList) {
        const auto list = v.toList();
        out.reserve(list.size());
        for (const auto& item : list) {
            const auto m = item.toMap();
            const float x = m.value(QStringLiteral("x"), m.value(QStringLiteral("lon"))).toFloat();
            const float y = m.value(QStringLiteral("y"), m.value(QStringLiteral("lat"))).toFloat();
            out.push_back(QVector2D(x, y));
        }
        return out;
    }

    if (v.canConvert<QList<QVector2D>>()) {
        return v.value<QList<QVector2D>>();
    }

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

    return out;
}

bool AlertZoneModel::compareCoords(const QList<QVector2D> &a, const QList<QVector2D> &b)
{
    if (a.size() != b.size()) return false;
    for (int i = 0; i < a.size(); ++i) {
        if (!qFuzzyCompare(a[i].x(), b[i].x()) || !qFuzzyCompare(a[i].y(), b[i].y()))
            return false;
    }
    return true;
}

void AlertZoneModel::buildAlertZoneSave(const QVariantMap &data)
{
    m_alertZoneSave = std::make_unique<AlertZone>();

    m_alertZoneSave->label = data.value("label").toString();
    m_alertZoneSave->layerId = 2; // Hardcoded for alert zones

    // Geometry
    QVariantMap geomMap = data.value("geometry").toMap();
    Geometry geom;
    geom.shapeTypeId = geomMap.value("shapeTypeId").toInt(); // Should be 3 (Polygon)

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

    m_alertZoneSave->geometry = geom;
}
