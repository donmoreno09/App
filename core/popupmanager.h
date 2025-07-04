#ifndef POPUPMANAGER_H
#define POPUPMANAGER_H

#include <QObject>
#include <QQmlEngine>
#include <QList>
#include <QtQuick/QQuickItem>

class PopupManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(int baseZ READ baseZ WRITE setBaseZ NOTIFY baseZChanged)
    Q_PROPERTY(int maxZ READ maxZ WRITE setMaxZ NOTIFY maxZChanged)

public:
    static QObject* singletonProvider(QQmlEngine*, QJSEngine*) {
        return new PopupManager();
    }

    int baseZ() const { return m_baseZ; }
    void setBaseZ(int base) {
        if (m_baseZ != base) {
            m_baseZ = base;
            emit baseZChanged();
            updateZ();
        }
    }

    int maxZ() const { return m_maxZ; }
    void setMaxZ(int max) {
        if (m_maxZ != max) {
            m_maxZ = max;
            emit maxZChanged();
            updateZ();
        }
    }

    Q_INVOKABLE void bringToFront(QQuickItem* popup);
    Q_INVOKABLE void unregister(QQuickItem* popup);

signals:
    void baseZChanged();
    void maxZChanged();

private:
    explicit PopupManager(QObject* parent = nullptr);
    void updateZ();

    QList<QQuickItem*> m_stack;
    int m_baseZ;
    int m_maxZ;
};

#endif // POPUPMANAGER_H
