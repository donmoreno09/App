#pragma once

#include <QObject>
#include <QHash>
#include <QList>
#include <QTimer>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QtQml/qqmlregistration.h>
#include "../models/radial-menu/radialmenunode.h"
#include "../connections/apiendpoints.h"

class RadialMenuController : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit RadialMenuController(QObject *parent = nullptr)
        : QObject(parent)
    {
        fetchMenu();
    }

    Q_INVOKABLE bool checkIsReady() const { return m_ready; }
    Q_INVOKABLE RadialMenuNode* getRoot() const { return m_nodes.value(m_rootId, nullptr); }
    Q_INVOKABLE QList<RadialMenuNode*> getChildren(const QString &id) const;
    Q_INVOKABLE RadialMenuNode* getNode(const QString &id) const { return m_nodes.value(id, nullptr); }
    Q_INVOKABLE RadialMenuNode* getNodeByName(const QString &name) const;

    Q_INVOKABLE void doAction(int ctrl, const QString& service, bool) { qDebug() << "Ctrl:" << ctrl; }
    Q_INVOKABLE void setNodeActive(const QString& id, bool) {}

signals:
    void readyChanged(int, bool);

private:
    QHash<QString, RadialMenuNode*> m_nodes;
    QString m_rootId;
    bool m_ready = false;

    QNetworkAccessManager m_nam;
    const QString m_url = ApiEndpoints::GetMenuManager;
    const QByteArray m_body = R"({"jwt":"eyJhbGciOiJIUzI1NiJ9.eyJyb2xlIjoiQWRtaW4ifQ.TPl8GZ-e_1cpei-gKYxGFbKCkj8LRf5ZQaWarB_CLIk"})";

    void fetchMenu()
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

    void parseJson(const QByteArray &raw)
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
        emit readyChanged(0, m_ready);
    }
};

inline QList<RadialMenuNode*> RadialMenuController::getChildren(const QString &id) const
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

inline RadialMenuNode* RadialMenuController::getNodeByName(const QString &name) const
{
    for (RadialMenuNode *n : m_nodes) {
        if (n->displayName().compare(name, Qt::CaseInsensitive) == 0)
            return n;
    }
    return nullptr;
}
