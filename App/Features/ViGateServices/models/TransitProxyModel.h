#ifndef TRANSITPROXYMODEL_H
#define TRANSITPROXYMODEL_H

#include <QSortFilterProxyModel>

class TransitProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(QString laneTypeFilter READ laneTypeFilter WRITE setLaneTypeFilter NOTIFY laneTypeFilterChanged)

public:
    explicit TransitProxyModel(QObject* parent = nullptr);

    QString laneTypeFilter() const { return m_laneTypeFilter; }
    void setLaneTypeFilter(const QString& filter);

signals:
    void laneTypeFilterChanged();

protected:
    bool filterAcceptsRow(int sourceRow, const QModelIndex& sourceParent) const override;

private:
    QString m_laneTypeFilter = "ALL";
};

#endif // TRANSITPROXYMODEL_H
