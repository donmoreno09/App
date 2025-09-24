#ifndef VARIANTLISTMODEL_H
#define VARIANTLISTMODEL_H

#include <QAbstractListModel>
#include <QQmlEngine>

class VariantListModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT

public:
    explicit VariantListModel(QObject *parent = nullptr);

    const QVariantList& data() const;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;

    Qt::ItemFlags flags(const QModelIndex &index) const override;

    virtual QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void resetWith(const QVariantList &data);

    Q_INVOKABLE QVariant at(int index) const;

    Q_INVOKABLE void append(const QVariant& item);

    Q_INVOKABLE void setItemAt(int index, const QVariant& item);

    Q_INVOKABLE void removeItemAt(int index);

private:
    QVariantList m_data;
};

#endif // VARIANTLISTMODEL_H
