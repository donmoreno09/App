#ifndef BASELAYER_H
#define BASELAYER_H

#include <QObject>
#include <QString>
#include <QQuickItem>
#include <QPointer>

class BaseLayer : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QQuickItem* item READ item WRITE setItem NOTIFY itemChanged FINAL)
    Q_PROPERTY(QString layerName READ layerName WRITE setLayerName NOTIFY layerNameChanged FINAL)

public:
    explicit BaseLayer(QObject* parent = nullptr);

    virtual ~BaseLayer();

    QString layerName() const;
    void setLayerName(const QString& name);

    QQuickItem *item() const;
    void setItem(QQuickItem *newItem);

signals:
    void ready();
    void layerNameChanged();
    void itemChanged();

protected:
    QString m_layerName;

private:
    QPointer<QQuickItem> m_item;
};

#endif // BASELAYER_H
