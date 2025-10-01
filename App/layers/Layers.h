#ifndef LAYERS_H
#define LAYERS_H

#include <QObject>
#include <QQmlEngine>

class Layers : public QObject {
    Q_OBJECT
    QML_SINGLETON
    QML_ELEMENT

public:
    Q_INVOKABLE QString aisMapLayer() const { return QStringLiteral("AISMapLayer"); }
    Q_INVOKABLE QString docSpaceMapLayer() const { return QStringLiteral("DocSpaceMapLayer"); }
    Q_INVOKABLE QString poiMapLayer() const { return QStringLiteral("PoiMapLayer"); }
    Q_INVOKABLE QString annotationMapLayer() const { return QStringLiteral("AnnotationMapLayer"); }
};

#endif // LAYERS_H

