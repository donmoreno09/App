#include "variantlistmodel.h"

VariantListModel::VariantListModel(QObject *parent)
    : QAbstractListModel(parent)
{}

const QVariantList &VariantListModel::data() const
{
    return m_data;
}

int VariantListModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return m_data.length();
}

QVariant VariantListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return {};

    if (role == Qt::DisplayRole)
        return m_data.at(index.row());

    return {};
}

bool VariantListModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (!index.isValid())
        return false;

    if (index.row() < 0 || index.row() >= m_data.length())
        return false;

    m_data[index.row()] = value;
    emit dataChanged(index, index, { role, Qt::DisplayRole });
    return true;
}

Qt::ItemFlags VariantListModel::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return Qt::NoItemFlags;

    return QAbstractItemModel::flags(index) | Qt::ItemIsEditable;
}

QHash<int, QByteArray> VariantListModel::roleNames() const
{
    return { { Qt::DisplayRole, "modelData" } };
}

void VariantListModel::resetWith(const QVariantList &data)
{
    beginResetModel();
    m_data = data;
    endResetModel();
}

QVariant VariantListModel::at(int index) const
{
    return m_data.at(index);
}

void VariantListModel::append(const QVariant &item)
{
    const int index = m_data.length();

    beginInsertRows(QModelIndex(), index, index);
    m_data.append(item);
    endInsertRows();
}

void VariantListModel::setItemAt(int index, const QVariant &item)
{
    if (index < 0 || index >= m_data.size())
        return;

    m_data[index] = item;

    const QModelIndex modelIndex = createIndex(index, 0);
    emit dataChanged(modelIndex, modelIndex, { Qt::EditRole, Qt::DisplayRole });
}

void VariantListModel::removeItemAt(int index)
{
    beginRemoveRows(QModelIndex(), index, index);
    m_data.removeAt(index);
    endRemoveRows();
}
