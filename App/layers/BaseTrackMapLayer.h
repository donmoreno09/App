#ifndef BASETRACKMAPLAYER_H
#define BASETRACKMAPLAYER_H

#include "BaseMapLayer.h"
#include "models/ClusterModel.h"

class BaseTrackMapLayer : public BaseMapLayer
{
    Q_OBJECT
    Q_PROPERTY(bool active READ active NOTIFY activeChanged FINAL)
    Q_PROPERTY(ClusterModel *clusterModel READ clusterModel CONSTANT FINAL)

public:
    explicit BaseTrackMapLayer(QObject* parent = nullptr);

    bool active() const;
    void setActive(bool newActive);
    ClusterModel *clusterModel() const;

signals:
    void activeChanged();

private:
    bool m_active = false;
    ClusterModel* m_clusterModel = nullptr;
};

#endif // BASETRACKMAPLAYER_H
