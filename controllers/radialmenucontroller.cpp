#include "radialmenucontroller.h"
#include <QDebug>
#include "../core/trackmanager.h"

RadialMenuController::RadialMenuController(QObject *parent)
    : QObject(parent)
{
    buildTriggerMap();
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

void RadialMenuController::trigger(const QString &name, bool active)
{
    if (m_triggerMap.contains(name)) {
        m_triggerMap[name](active);
    } else {
        qDebug() << "Triggered " << name << " but no associated handler is present.";
    }
}

void RadialMenuController::setNodeActive(const QString& id, bool active)
{
    // check if leaf node (no need as well, the QML handles it)
    //   check if parent supports multi-checks
    //   otherwise disable other nodes under the parent (no need, the QML handles it)
    // else (parent node)
    //   do nothing
    auto* node = m_nodes.value(id, nullptr);
    auto* parent = m_nodes.value(node->parent(), nullptr);
    node->setActive(active);
}

void RadialMenuController::buildTriggerMap()
{
    // Triggers for tracks' nodes
    m_triggerMap.insert("doc-space", [](bool active) {
        qDebug() << "doc-space triggered!";

        if (active) {
            TrackManager::instance()->activate("doc-space");
        } else {
            TrackManager::instance()->deactivate("doc-space");
        }
    });

    m_triggerMap.insert("ais", [](bool active) {
        qDebug() << "ais triggered!";

        if (active) {
            TrackManager::instance()->activate("ais");
        } else {
            TrackManager::instance()->deactivate("ais");
        }
    });

    // Triggers for maps' nodes
    m_triggerMap.insert("osm", [](bool active) {
        qDebug() << "osm triggered!";
    });

    m_triggerMap.insert("google", [](bool active) {
        qDebug() << "google triggered!";
    });

    m_triggerMap.insert("wms", [](bool active) {
        qDebug() << "wms triggered!";
    });

    // Triggers for tools' nodes
    m_triggerMap.insert("videoplayer", [](bool active) {
        qDebug() << "videoplayer triggered!";
    });
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
