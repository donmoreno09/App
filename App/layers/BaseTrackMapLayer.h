#ifndef BASETRACKMAPLAYER_H
#define BASETRACKMAPLAYER_H

#include "BaseMapLayer.h"

class BaseTrackMapLayer : public BaseMapLayer
{
    Q_OBJECT
    Q_PROPERTY(bool active READ active NOTIFY activeChanged FINAL)

public:
    explicit BaseTrackMapLayer(QObject* parent = nullptr);

    void loadData() override;
    void handleLoadedObjects(const QList<IPersistable*>& objects) override;

    bool active() const;
    void setActive(bool newActive);

signals:
    void activeChanged();

private:
    bool m_active = false;
};

#endif // BASETRACKMAPLAYER_H
