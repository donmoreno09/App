#ifndef LAYERS_H
#define LAYERS_H

#include <QObject>
#include <QQmlEngine>

class Layers : public QObject {
    Q_OBJECT
    QML_SINGLETON
    QML_ELEMENT

public:
    Q_INVOKABLE QString aisTrackMapLayer() const { return QStringLiteral("AISTrackMapLayer"); }
    Q_INVOKABLE QString docSpaceTrackMapLayer() const { return QStringLiteral("DocSpaceTrackMapLayer"); }
    Q_INVOKABLE QString tirTrackMapLayer() const { return QStringLiteral("TirTrackMapLayer"); }
    Q_INVOKABLE QString poiMapLayer() const { return QStringLiteral("PoiMapLayer"); }
    Q_INVOKABLE QString annotationMapLayer() const { return QStringLiteral("AnnotationMapLayer"); }
};

#endif // LAYERS_H

