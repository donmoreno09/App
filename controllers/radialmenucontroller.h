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
    explicit RadialMenuController(QObject *parent = nullptr);

    Q_INVOKABLE bool checkIsReady() const;
    Q_INVOKABLE RadialMenuNode* getRoot() const;
    Q_INVOKABLE QList<RadialMenuNode*> getChildren(const QString &id) const;
    Q_INVOKABLE RadialMenuNode* getNode(const QString &id) const;
    Q_INVOKABLE RadialMenuNode* getNodeByName(const QString &name) const;

    Q_INVOKABLE void trigger(const QString& name, bool active);
    Q_INVOKABLE void setNodeActive(const QString& id, bool active);

signals:
    void ready(bool);

protected:
    void buildTriggerMap();

private:
    QHash<QString, RadialMenuNode*> m_nodes;
    QHash<QString, std::function<void(bool)>> m_triggerMap;
    QString m_rootId;
    bool m_ready = false;

    QNetworkAccessManager m_nam;
    const QString m_url = ApiEndpoints::GetMenuManager;
    const QByteArray m_body = R"({"jwt":"eyJhbGciOiJIUzI1NiJ9.eyJyb2xlIjoiQWRtaW4ifQ.TPl8GZ-e_1cpei-gKYxGFbKCkj8LRf5ZQaWarB_CLIk"})";

    void fetchMenu();
    void parseJson(const QByteArray &raw);
};
