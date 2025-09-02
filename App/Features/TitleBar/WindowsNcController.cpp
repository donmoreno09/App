#include "WindowsNcController.h"

void WindowsNcController::attachToWindow(QObject *windowObj)
{
    auto* w = qobject_cast<QQuickWindow*>(windowObj);
    if (!w) return;

#ifdef Q_OS_WIN
    m_window = w;
    m_hwnd = reinterpret_cast<HWND>(w->winId());

    applyWinStyles();

    if (!m_filterInstalled) {
        QCoreApplication::instance()->installNativeEventFilter(this);
        m_filterInstalled = true;
    }

    SetWindowPos(m_hwnd, nullptr, 0,0,0,0, SWP_FRAMECHANGED | SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE);
#else
    Q_UNUSED(w);
#endif
}

bool WindowsNcController::isWindows()
{
#ifdef Q_OS_WIN
    return true;
#else
    return false;
#endif
}

QQuickWindow *WindowsNcController::window() const
{
    return m_window;
}

#ifdef Q_OS_WIN
void WindowsNcController::applyWinStyles() {
    if (!m_hwnd) return;

    LONG style = ::GetWindowLongW(m_hwnd, GWL_STYLE);
    style |= WS_THICKFRAME | WS_CAPTION | WS_MAXIMIZEBOX | WS_MINIMIZEBOX | WS_SYSMENU;
    SetWindowLongW(m_hwnd, GWL_STYLE, style);

    const MARGINS margins{1,1,1,1};
    DwmExtendFrameIntoClientArea(m_hwnd, &margins);
}

bool WindowsNcController::nativeEventFilter(const QByteArray& t, void* msg, qintptr* res) {
    if (t != "windows_generic_MSG" && t != "windows_dispatcher_MSG") {
        return false;
    }

    MSG* m = static_cast<MSG*>(msg);

    switch (m->message) {
    case WM_NCCALCSIZE: {
        // eat non-client painting (no native titlebar drawn)
        *res = 0;
        return true;
    }
    case WM_NCHITTEST: {
        if (!m_hwnd) return false;

        // Native resize borders
        const LONG x = GET_X_LPARAM(m->lParam);
        const LONG y = GET_Y_LPARAM(m->lParam);
        RECT r; GetWindowRect(m_hwnd, &r);
        const int b = borderThickness(m_hwnd);
        const bool L = x <  r.left  + b, R = x >= r.right - b;
        const bool T = y <  r.top   + b, B = y >= r.bottom- b;
        if (T && L) { *res = HTTOPLEFT;     return true; }
        if (T && R) { *res = HTTOPRIGHT;    return true; }
        if (B && L) { *res = HTBOTTOMLEFT;  return true; }
        if (B && R) { *res = HTBOTTOMRIGHT; return true; }
        if (L)      { *res = HTLEFT;        return true; }
        if (R)      { *res = HTRIGHT;       return true; }
        if (T)      { *res = HTTOP;         return true; }
        if (B)      { *res = HTBOTTOM;      return true; }
        return false; // client area; QML header handles dragging
    }}

    return false;
}

int WindowsNcController::borderThickness(HWND h)
{
    return GetSystemMetrics(SM_CXSIZEFRAME) + GetSystemMetrics(SM_CXPADDEDBORDER);
}
#endif
