#include "PropertyTreeNode.h"

PropertyTreeNode::PropertyTreeNode(QObject* parent)
    : QObject(parent)
{
}

QString PropertyTreeNode::nodeId() const
{
    return m_nodeId;
}

QString PropertyTreeNode::hostnameDev() const
{
    return m_hostnameDev;
}

QString PropertyTreeNode::hostnameProd() const
{
    return m_hostnameProd;
}

bool PropertyTreeNode::isLeaf() const
{
    return m_isLeaf;
}

QString PropertyTreeNode::name() const
{
    return m_name;
}

int PropertyTreeNode::portDev() const
{
    return m_portDev;
}

int PropertyTreeNode::portPrd() const
{
    return m_portPrd;
}

QString PropertyTreeNode::imageSrc() const
{
    return m_imageSrc;
}

bool PropertyTreeNode::isRoot() const
{
    return m_isRoot;
}

QString PropertyTreeNode::module() const
{
    return m_module;
}

QJsonObject PropertyTreeNode::toJson() const
{
    QJsonObject json;

    json["NODE_ID"] = m_nodeId;
    json["HOSTNAME_DEV"] = m_hostnameDev;
    json["HOSTNAME_PROD"] = m_hostnameProd;
    json["IS_LEAF"] = m_isLeaf;
    json["NAME"] = m_name;
    json["PORT_DEV"] = m_portDev;
    json["PORT_PRD"] = m_portPrd;
    json["IMAGE_SRC"] = m_imageSrc;
    json["IS_ROOT"] = m_isRoot;
    json["MODULE"] = m_module;

    return json;
}

void PropertyTreeNode::fromJson(const QJsonObject& json)
{
    m_nodeId = json["NODE_ID"].toString();
    m_hostnameDev = json["HOSTNAME_DEV"].toString();
    m_hostnameProd = json["HOSTNAME_PROD"].toString();
    m_isLeaf = json["IS_LEAF"].toBool();
    m_name = json["NAME"].toString();
    m_portDev = json["PORT_DEV"].toInt();
    m_portPrd = json["PORT_PRD"].toInt();
    m_imageSrc = json["IMAGE_SRC"].toString();
    m_isRoot = json["IS_ROOT"].toBool();
    m_module = json["MODULE"].toString().toLower();
}
