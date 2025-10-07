#pragma once

#include <QObject>

class InteractionModeManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString currentSelectedShapeId READ currentSelectedShapeId WRITE setCurrentSelectedShapeId NOTIFY currentSelectedShapeIdChanged FINAL)
    Q_PROPERTY(InteractionMode currentMode READ currentMode WRITE setCurrentMode NOTIFY currentModeChanged)

public:
    enum InteractionMode {
        Hand,
        Cursor,
        DrawPoint,
        DrawRectangle,
        DrawPolygon,
        DrawPolyline,
        DrawEllipse,
        DefineZone
    };
    Q_ENUM(InteractionMode)

    static InteractionModeManager* getInstance();

    InteractionMode currentMode() const;
    void setCurrentMode(InteractionMode mode);

    QString currentSelectedShapeId() const;
    void setCurrentSelectedShapeId(const QString &newCurrentSelectedShapeId);

signals:
    void currentModeChanged();
    void currentSelectedShapeIdChanged(const QString &selectedId, const QString &previousSelectedId);

private:
    explicit InteractionModeManager(QObject* parent = nullptr);
    static InteractionModeManager* instance;
    InteractionMode m_currentMode;
    QString m_currentSelectedShapeId;
};
