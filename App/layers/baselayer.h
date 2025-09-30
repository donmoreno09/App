#ifndef BASELAYER_H
#define BASELAYER_H

#include <QObject>
#include <QString>

class BaseLayer : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool active READ active WRITE setActive NOTIFY activeChanged FINAL)
    Q_PROPERTY(bool visible READ visible WRITE setVisible NOTIFY visibleChanged FINAL)
    Q_PROPERTY(QString layerName READ layerName WRITE setLayerName NOTIFY layerNameChanged FINAL)

public:
    explicit BaseLayer(QObject* parent = nullptr);

    virtual ~BaseLayer();

    Q_INVOKABLE virtual void initialize();

    QString layerName() const;
    void setLayerName(const QString& name);

    bool active() const;
    void setActive(bool newActive);

    bool visible() const;
    void setVisible(bool newVisible);

signals:
    void layerReady();
    void layerNameChanged();
    void activeChanged();
    void itemChanged();

    void visibleChanged();

protected:
    QString m_layerName;

private:
    bool m_active = false;
    bool m_visible = true;
};

#endif // BASELAYER_H
