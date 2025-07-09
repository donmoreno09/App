#ifndef RADIALMENUNODE_H
#define RADIALMENUNODE_H

#include <QObject>
#include <QVariantMap>
#include "../../persistence/ipersistable.h"
#include "propertytreenode.h"

class RadialMenuNode : public QObject, public IPersistable
{
    Q_OBJECT

    Q_PROPERTY(PropertyTreeNode* propertyTreeNode READ propertyTreeNode CONSTANT)
    Q_PROPERTY(QString id READ id CONSTANT)
    Q_PROPERTY(QStringList children READ children CONSTANT)
    Q_PROPERTY(QString parent READ parent CONSTANT)

    Q_PROPERTY(int ctrl READ ctrl CONSTANT)
    // TODO: Is this really needed? It's basically a redirection to
    //       the propertyTreeNode's name.
    // REVIEW: Matter of fact, why not just reflect how the JSON
    //         is structured here?
    Q_PROPERTY(QString displayName READ displayName CONSTANT)
    // TODO: I have no idea what's serviceStatus is for but it
    //       seems safe to remove. Have to check the legacy code
    //       whether it's fundamental for the app.
    Q_PROPERTY(int serviceStatus READ serviceStatus WRITE setServiceStatus NOTIFY serviceStatusChanged)
    // TODO: Same as serviceStatus, it isn't in the JSON itself.
    //       Check in the legacy code if needed.
    Q_PROPERTY(int moduleStatus READ moduleStatus CONSTANT)
    Q_PROPERTY(bool active READ active WRITE setActive NOTIFY activeChanged)

public:
    explicit RadialMenuNode(QObject *parent = nullptr);

    PropertyTreeNode* propertyTreeNode() const;
    QString id() const;
    QStringList children() const;
    QString parent() const;

    int ctrl() const;
    QString displayName() const;
    int serviceStatus() const;
    int moduleStatus() const;
    bool active() const;

    // IPersistable interface
    virtual QJsonObject toJson() const override;
    virtual void fromJson(const QJsonObject &json) override;

    void setServiceStatus(int newServiceStatus);

    void setActive(bool newActive);

signals:
    void serviceStatusChanged();
    void activeChanged();

private:
    PropertyTreeNode* m_propertyTreeNode = nullptr;
    QString m_id;
    QString m_parent;
    QStringList m_children;

    int m_ctrl = 0;
    QString m_displayName;
    int m_serviceStatus = 0;
    int m_moduleStatus = 0;

    // It seems that this `active` property is for QML
    // where the button becomes "highlighted" if true
    bool m_active = false;
};


#endif // RADIALMENUNODE_H
