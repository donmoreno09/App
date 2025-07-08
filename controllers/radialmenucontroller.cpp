#include "radialmenucontroller.h"
#include <QDebug>

RadialMenuController::RadialMenuController(QObject *parent)
    : QObject(parent)
{
    fetchMenu();
}

bool RadialMenuController::checkIsReady() const
{
    return m_ready;
}

RadialMenuNode* RadialMenuController::getRoot() const
{
    return m_nodes.value(m_rootId, nullptr);
}

QList<RadialMenuNode*> RadialMenuController::getChildren(const QString &id) const
{
    QList<RadialMenuNode*> res;
    if (RadialMenuNode *p = m_nodes.value(id, nullptr)) {
        const QStringList &children = p->children();
        for (const QString &childId : children) {
            if (RadialMenuNode *child = m_nodes.value(childId, nullptr))
                res << child;
        }
    }
    return res;
}

RadialMenuNode* RadialMenuController::getNode(const QString &id) const
{
    return m_nodes.value(id, nullptr);
}

RadialMenuNode* RadialMenuController::getNodeByName(const QString &name) const
{
    for (RadialMenuNode *n : m_nodes) {
        if (n->displayName().compare(name, Qt::CaseInsensitive) == 0)
            return n;
    }
    return nullptr;
}

void RadialMenuController::doAction(int ctrl, const QString& service, bool active)
{
    qDebug() << "Ctrl:" << ctrl;
}

void RadialMenuController::setNodeActive(const QString& id, bool active)
{
    Q_UNUSED(id)
    // Empty for now
}

void RadialMenuController::fetchMenu()
{
    QNetworkRequest req(m_url);
    req.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    QNetworkReply *reply = m_nam.post(req, m_body);

    connect(reply, &QNetworkReply::finished, this, [this, reply] {
        if (reply->error() != QNetworkReply::NoError) {
            qWarning() << "RadialMenuController fetch failed:" << reply->errorString();
            QTimer::singleShot(2000, this, &RadialMenuController::fetchMenu);
            return;
        }
        parseJson(reply->readAll());
    });
}

void RadialMenuController::parseJson(const QByteArray &raw)
{
    QJsonParseError err;
    QJsonDocument doc = QJsonDocument::fromJson(raw, &err);
    if (err.error != QJsonParseError::NoError || !doc.isObject()) {
        qWarning() << "RadialMenuController JSON error:" << err.errorString();
        return;
    }

    QJsonArray nodesArray= doc.object().value("nodes").toArray();
    for (const QJsonValue& nodeVal : nodesArray) {
        auto* node = new RadialMenuNode(this);
        node->fromJson(nodeVal.toObject());
        m_nodes.insert(node->id(), node);
        if (node->propertyTreeNode()->isRoot())
            m_rootId = node->id();
    }

    m_ready = !m_rootId.isEmpty();
    emit ready(m_ready);
}
