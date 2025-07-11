#ifndef PROPERTYTREENODE_H
#define PROPERTYTREENODE_H

#include <QObject>
#include <QJsonObject>
#include "../../persistence/ipersistable.h"

class PropertyTreeNode : public QObject, public IPersistable
{
    Q_OBJECT

    Q_PROPERTY(QString nodeId       READ nodeId       CONSTANT)
    Q_PROPERTY(QString hostnameDev  READ hostnameDev  CONSTANT)
    Q_PROPERTY(QString hostnameProd READ hostnameProd CONSTANT)
    Q_PROPERTY(bool    isLeaf       READ isLeaf       CONSTANT)
    Q_PROPERTY(QString name         READ name         CONSTANT)
    Q_PROPERTY(int     portDev      READ portDev      CONSTANT)
    Q_PROPERTY(int     portPrd      READ portPrd      CONSTANT)
    Q_PROPERTY(QString imageSrc     READ imageSrc     CONSTANT)
    Q_PROPERTY(bool    isRoot       READ isRoot       CONSTANT)
    Q_PROPERTY(QString module       READ module       CONSTANT)

public:
    explicit PropertyTreeNode(QObject* parent = nullptr);

    QString nodeId() const;
    QString hostnameDev() const;
    QString hostnameProd() const;
    bool isLeaf() const;
    QString name() const;
    int portDev() const;
    int portPrd() const;
    QString imageSrc() const;
    bool isRoot() const;
    QString module() const;

    QJsonObject toJson() const override;
    void fromJson(const QJsonObject& json) override;

private:
    QString m_nodeId;
    QString m_hostnameDev;
    QString m_hostnameProd;
    bool m_isLeaf = false;
    QString m_name;
    int m_portDev = 0;
    int m_portPrd = 0;
    QString m_imageSrc;
    bool m_isRoot = false;
    QString m_module;
};

Q_DECLARE_METATYPE(PropertyTreeNode*)

#endif // PROPERTYTREENODE_H
