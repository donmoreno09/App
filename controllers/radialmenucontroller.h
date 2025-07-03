/**
 * RadialMenuController.h
 * @brief Load radial menu items.
 *
 * This is a minified rewritten code from the
 * legacy code to load the radial menu items.
 *
 */

#pragma once

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QTimer>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QVariantMap>
#include <QVariantList>
#include <QtQml/qqmlregistration.h>
#include "../core/enums/econtrollers.h"
#include "../core/enums/eservice.h"

/* --------------------------------------------------------------------------- */
class RadialMenuNode : public QObject
{
    Q_OBJECT
    /* properties that QML accesses directly, e.g. node.propertyTreeNode.IS_LEAF */
    Q_PROPERTY(QVariantMap propertyTreeNode READ propertyTreeNode CONSTANT)
    Q_PROPERTY(QString     ID              READ id              CONSTANT)
    Q_PROPERTY(QStringList children        READ children        CONSTANT)
    Q_PROPERTY(QString     PARENT          READ parent          CONSTANT)

public:
    explicit RadialMenuNode(QVariantMap raw, QObject *parent = nullptr)
        : QObject(parent), raw_(std::move(raw))
    {}

    /* ----------- the five helpers that were missing ------------ */
    Q_INVOKABLE int        getCtrl()          const { return raw_.value("ctrl").toInt(); }
    Q_INVOKABLE QString    getDisplayName()   const { return raw_.value("displayName").toString();      }
    Q_INVOKABLE int        getServiceStatus() const { return raw_.value("serviceStatus").toInt(); }
    Q_INVOKABLE int        getModuleStatus()  const { return raw_.value("moduleStatus").toInt();  }
    Q_INVOKABLE bool       isActive()         const { return raw_.value("active").toBool();             }

    /* ----------- data used via direct property access ---------- */
    QVariantMap propertyTreeNode() const { return raw_.value("propertyTreeNode").toMap(); }
    QString     id()              const { return raw_.value("ID").toString();             }
    QStringList children()        const { return raw_.value("children").toStringList(); }
    QString     parent()          const { return raw_.value("PARENT").toString();         }

    QVariantMap raw() const { return raw_; }

private:
    QVariantMap raw_;
};

/* --------------------------------------------------------------------------- */
class RadialMenuController : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit RadialMenuController(QObject *parent = nullptr) : QObject(parent)
    {
        fetchMenu();
    }

    /* ---------- API expected by RadialMenu.qml ---------- */
    Q_INVOKABLE bool         checkIsReady() const { return ready_; }
    Q_INVOKABLE QObject*     getRoot()      const { return nodes_.value(rootId_, nullptr); }
    Q_INVOKABLE QList<QObject*> getChildren (const QString &id) const;
    Q_INVOKABLE QObject*     getNode       (const QString &id) const { return nodes_.value(id, nullptr); }
    Q_INVOKABLE QObject*     getNodeByName (const QString &name) const;

    Q_INVOKABLE void doAction(int ctrl, const QString& /*service*/, bool /*state*/) { qDebug() << "Ctrl: " << ctrl; }
    Q_INVOKABLE void setNodeActive(const QString& /*id*/, bool /*active*/){}

signals:
    void readyChanged(int dummy /*always 0*/, bool ready);

private:
    /* -------- internal storage -------- */
    QHash<QString, RadialMenuNode*> nodes_;        // key = node ID
    QString                         rootId_;
    bool                            ready_ = false;

    /* -------- networking -------- */
    QNetworkAccessManager           nam_;
    const QString                   url_  = QStringLiteral("http://127.0.0.1:5001/getMenu");
    const QByteArray                body_ = R"({"jwt":"eyJhbGciOiJIUzI1NiJ9.eyJyb2xlIjoiQWRtaW4ifQ.TPl8GZ-e_1cpei-gKYxGFbKCkj8LRf5ZQaWarB_CLIk"})";

    void fetchMenu()
    {
        QNetworkRequest req(url_);
        req.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
        auto *reply = nam_.post(req, body_);
        connect(reply, &QNetworkReply::finished, this, [this, reply]{
            if (reply->error() != QNetworkReply::NoError) {
                qWarning() << "RadialMenuController fetch failed:" << reply->errorString();
                QTimer::singleShot(2'000, this, &RadialMenuController::fetchMenu);
                return;
            }
            parseJson(reply->readAll());
        });
    }

    /* -------- JSON → nodes_  -------- */
    void parseJson(const QByteArray &raw)
    {
        QJsonParseError err{};
        const auto doc = QJsonDocument::fromJson(raw, &err);
        if (err.error != QJsonParseError::NoError || !doc.isObject()) {
            qWarning() << "RadialMenuController JSON error:" << err.errorString();
            return;
        }
        const auto arr = doc.object().value("nodes").toArray();

        /* first pass – build a plain map (string → QVariantMap)  */
        QHash<QString, QVariantMap> flat;
        for (const auto &v : arr) {
            QVariantMap m = v.toObject().toVariantMap();
            flat.insert(m.value("ID").toString(), m);
        }

        /* second pass – add derived fields & children lists       */
        QHash<QString, QVariantList> childrenOf; // children of parent like if childrenOf["parentId"] then it gets the list of children of "parentId"
        for (const auto &m : std::as_const(flat))
            childrenOf[m.value("PARENT").toString()] << QVariant::fromValue(m.value("ID").toString());

        for (auto it = flat.begin(); it != flat.end(); ++it) {
            QVariantMap &m = it.value();

            /* children: replace id list with actual objects later */
            QVariantList kids;
            for (const auto &kidIdVar : childrenOf.value(m.value("ID").toString()))
                kids << kidIdVar;
            m["children"] = kids;

            /* ctrl mapping (module → enum value) */
            const QString mod = m.value("propertyTreeNode").toMap().value("MODULE").toString().toLower();
            int ctrl = EControllersClass::Unknown;
            if (mod == "mapservice")      ctrl = EControllersClass::WmsMapController;
            else if (mod == "trackservice") ctrl = EControllersClass::TrackManager;
            else if (mod == "videoservice") ctrl = EControllersClass::VideoController;
            else if (mod == "ownshipservice") ctrl = EControllersClass::OwnPosition;
            m["ctrl"] = ctrl;

            /* display name like old code */
            const QString name = m.value("propertyTreeNode").toMap().value("NAME").toString();
            m["displayName"] = (ctrl == EControllersClass::VideoController) ? "video" : name;

            /* default statuses / flag */
            m["serviceStatus"] = EServiceStatus::ACTIVE;
            m["moduleStatus"]  = EServiceStatus::CLOSED;
            m["active"]        = true;

            /* remember root */
            if (m.value("propertyTreeNode").toMap().value("IS_ROOT").toBool())
                rootId_ = m.value("ID").toString();
        }

        /* third pass – actually create RadialMenuNode objects,
           now children lists can point to QObject* */
        for (auto it = flat.begin(); it != flat.end(); ++it) {
            nodes_.insert(it.key(), new RadialMenuNode(it.value(), this));
        }
        for (RadialMenuNode* n : nodes_) {
            QVariantList kidIds = n->raw().value("children").toList();
            QVariantList kidsObj;
            for (const auto &v : kidIds)
                if (auto *obj = nodes_.value(v.toString(), nullptr))
                    kidsObj << QVariant::fromValue(static_cast<QObject*>(obj));
            n->raw()["children"] = kidsObj;    // patch inside the wrapper
        }

        ready_ = !rootId_.isEmpty();
        emit readyChanged(0, ready_);
    }
};

/* ------------- helper inline methods --------------- */
inline QList<QObject*> RadialMenuController::getChildren(const QString &id) const
{
    QList<QObject*> res;
    if (auto *p = nodes_.value(id, nullptr))
        for (const auto &v : p->raw().value("children").toList())
            if (auto *child = nodes_.value(v.toString(), nullptr))
                res << child;
    return res;
}
inline QObject* RadialMenuController::getNodeByName(const QString &name) const
{
    for (auto *n : nodes_)
        if (n->propertyTreeNode().value("NAME").toString().compare(name, Qt::CaseInsensitive) == 0)
            return n;
    return nullptr;
}
