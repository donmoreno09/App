#pragma once

#include <qglobal.h>
#include <QCoreApplication>
#include <QObject>
#include <QQuickWindow>
#include <QtQml/qqmlregistration.h>

#ifdef Q_OS_WIN
#include <QAbstractNativeEventFilter>
#include <windows.h>
#include <windowsx.h> // GET_X_LPARAM / GET_Y_LPARAM
#include <dwmapi.h>
#pragma comment(lib, "Dwmapi.lib")
#endif

class WindowsNcController : public QObject
#ifdef Q_OS_WIN
    , public QAbstractNativeEventFilter
#endif
{
    Q_OBJECT
    QML_SINGLETON
    QML_ELEMENT

    Q_PROPERTY(QQuickWindow* window READ window NOTIFY windowChanged)

public:
    explicit WindowsNcController(QObject* parent = nullptr) : QObject(parent) {}

    // Call once from QML after ApplicationWindow is ready
    Q_INVOKABLE void attachToWindow(QObject* windowObj);

    Q_INVOKABLE static bool isWindows();

    // Note: If the window is an ApplicationWindow, it is possible to get the
    //       main window through ApplicationWindow.window in QML.
    QQuickWindow *window() const;

#ifdef Q_OS_WIN
    bool nativeEventFilter(const QByteArray& t, void* msg, qintptr* res) override;
#endif

signals:
    void windowChanged();

private:
    QQuickWindow *m_window = nullptr;

#ifdef Q_OS_WIN
    HWND m_hwnd = nullptr;
    bool m_filterInstalled = false;

    static int borderThickness(HWND h);

    void applyWinStyles();
#endif
};
