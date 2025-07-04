#ifndef REGISTERTEMPLATE_H
#define REGISTERTEMPLATE_H

#include <QtQml>


namespace Register {

template <class T>
struct QMetaType {
    QMetaType(const QString& name) {
        qRegisterMetaType<T>(name.toStdString().c_str());
    }
};

template <class T>
struct QmlCreatableType {
    QmlCreatableType() = delete;
    QmlCreatableType(const QString& uri, const int& versionMajor, const int& versionMinor, const QString& name) {
        qmlRegisterType<T>(uri.toStdString().c_str(), versionMajor, versionMinor, name.toStdString().c_str());
    }
};

template <class T>
struct QmlUncreatableType {
    QmlUncreatableType() = delete;
    QmlUncreatableType(const QString& uri, const int& versionMajor, const int& versionMinor, const QString& name) {
        qmlRegisterUncreatableType<T>(uri.toStdString().c_str(), versionMajor, versionMinor, name.toStdString().c_str(), name + " is not available.");
    }
};

}

#endif // REGISTERTEMPLATE_H
