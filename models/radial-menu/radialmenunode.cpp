#include "radialmenunode.h"
#include <QJsonArray>
#include "../../core/legacy/enums/eservice.h"
#include "../../core/trackmanager.h"

RadialMenuNode::RadialMenuNode(QObject *parent)
    : QObject(parent)
{
}

PropertyTreeNode* RadialMenuNode::propertyTreeNode() const
{
    return m_propertyTreeNode;
}

QString RadialMenuNode::id() const
{
    return m_id;
}

QStringList RadialMenuNode::children() const
{
    return m_children;
}

QString RadialMenuNode::parent() const
{
    return m_parent;
}

int RadialMenuNode::ctrl() const
{
    return m_ctrl;
}

QString RadialMenuNode::displayName() const
{
    return m_displayName;
}

int RadialMenuNode::serviceStatus() const
{
    return m_serviceStatus;
}

int RadialMenuNode::moduleStatus() const
{
    return m_moduleStatus;
}

bool RadialMenuNode::active() const
{
    return m_active;
}

QJsonObject RadialMenuNode::toJson() const
{
    QJsonObject json;

    json["ID"] = m_id;
    json["PARENT"] = m_parent;
    json["children"] = QJsonArray::fromStringList(m_children);
    json["ctrl"] = m_ctrl;
    json["displayName"] = m_displayName;
    json["serviceStatus"] = m_serviceStatus;
    json["moduleStatus"] = m_moduleStatus;
    json["active"] = m_active;
    json["propertyTreeNode"] = m_propertyTreeNode ? m_propertyTreeNode->toJson() : QJsonObject();

    return json;
}

void RadialMenuNode::fromJson(const QJsonObject& json)
{
    m_id = json["ID"].toString();
    m_parent = json["PARENT"].toString();
    m_children.clear();

    for (const QJsonValue& val : json["children"].toArray())
        m_children.append(val.toString());

    // TODO: Not needed anymore, check the TODO notes on the header file of this class.
    // m_ctrl = json["ctrl"].toInt();
    m_serviceStatus = EServiceStatus::ACTIVE;
    // m_moduleStatus = json["moduleStatus"].toInt();
    // m_active = json["active"].toBool();

    if (m_propertyTreeNode == nullptr)
        m_propertyTreeNode = new PropertyTreeNode(this);

    m_propertyTreeNode->fromJson(json["propertyTreeNode"].toObject());
    m_displayName = m_propertyTreeNode->name();

    // These tracks are not activated by default.
    m_active = false;
}

void RadialMenuNode::setServiceStatus(int newServiceStatus)
{
    if (m_serviceStatus == newServiceStatus)
        return;
    m_serviceStatus = newServiceStatus;
    emit serviceStatusChanged();
}

void RadialMenuNode::setActive(bool newActive)
{
    if (m_active == newActive)
        return;
    m_active = newActive;
    emit activeChanged();
}
