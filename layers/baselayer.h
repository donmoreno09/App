#ifndef BASELAYER_H
#define BASELAYER_H

#include <QObject>
#include <QString>
#include <QMap>

class BaseLayer : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isVisible READ isVisible WRITE setVisible NOTIFY visibleChanged)
    Q_PROPERTY(bool isEnabled READ isEnabled WRITE setEnabled NOTIFY enabledChanged)
    Q_PROPERTY(bool onFocus READ onFocus WRITE setFocus NOTIFY focusChanged)
    Q_PROPERTY(QString layerName READ layerName WRITE setLayerName NOTIFY layerNameChanged)

public:
    explicit BaseLayer(QObject* parent = nullptr);
    virtual ~BaseLayer();


    // Stato
    bool isVisible() const;
    void setVisible(bool visible);

    bool isEnabled() const;
    void setEnabled(bool enabled);

    bool onFocus() const;
    void setFocus(bool focus);

    bool isActive() const;
    void setActive(bool active);

    QString layerName() const;
    void setLayerName(const QString& name);

    Q_INVOKABLE virtual void initialize();

signals:
    void layerReady();
    void visibleChanged();
    void enabledChanged();
    void activeChanged();
    void focusChanged();
    void layerNameChanged();

protected:
    QString m_layerName;
    bool m_isVisible = true;
    bool m_isEnabled = true;
    bool m_isActive = false;
    bool m_onFocus = false;
};

#endif // BASELAYER_H
