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

void WindowsNcController::minimize() {
#ifdef Q_OS_WIN
    if (!m_window) return;
    auto s = m_window->windowStates();
    // Preserve Qt::WindowMaximized (if set) and add Minimized
    m_window->setWindowStates(s | Qt::WindowMinimized);
#endif
}

void WindowsNcController::toggleMaximize() {
#ifdef Q_OS_WIN
    if (!m_window) return;
    auto s = m_window->windowStates();
    if (s.testFlag(Qt::WindowMaximized)) {
        // Back to normal, ensure Minimized is cleared
        m_window->setWindowStates(Qt::WindowNoState);
    } else {
        // Go maximized, ensure Minimized is cleared
        m_window->setWindowStates((s | Qt::WindowMaximized) & ~Qt::WindowMinimized);
    }
#endif
}

QQuickWindow *WindowsNcController::window() const
{
    return m_window;
}

#ifdef Q_OS_WIN
void WindowsNcController::applyWinStyles()
{
    if (!m_hwnd) return;

    LONG style = ::GetWindowLongW(m_hwnd, GWL_STYLE);
    style |= WS_THICKFRAME | WS_CAPTION | WS_MAXIMIZEBOX | WS_MINIMIZEBOX | WS_SYSMENU;
    ::SetWindowLongW(m_hwnd, GWL_STYLE, style);

    // only extend the top border into client area
    const MARGINS margins{0, 0, 1, 0};
    ::DwmExtendFrameIntoClientArea(m_hwnd, &margins);
}

bool WindowsNcController::nativeEventFilter(const QByteArray& t, void* msg, qintptr* res)
{
    if (t != "windows_generic_MSG")
        return false;

    MSG* m = static_cast<MSG*>(msg);

    if (!m_hwnd || m->hwnd != m_hwnd)
        return false;

    switch (m->message) {
    case WM_NCCALCSIZE: {
        const UINT dpi = GetDpiForWindow(m_hwnd);
        const int pad = GetSystemMetricsForDpi(SM_CXPADDEDBORDER, dpi);
        const int borderX = GetSystemMetricsForDpi(SM_CXSIZEFRAME, dpi) + pad;
        const int borderY = GetSystemMetricsForDpi(SM_CYSIZEFRAME, dpi) + pad;

        RECT* rect = nullptr;
        if (m->wParam) {
            auto* params = reinterpret_cast<NCCALCSIZE_PARAMS*>(m->lParam);
            rect = &params->rgrc[0];
        } else {
            rect = reinterpret_cast<RECT*>(m->lParam);
        }

        // Preserve native outer resize border behavior
        rect->left   += borderX;
        rect->right  -= borderX;
        rect->bottom -= borderY;

        // Only when maximized
        if (IsZoomed(m_hwnd)) {
            rect->top += borderY;
        }

        *res = 0;
        return true;
    }

    case WM_NCHITTEST: {
        LRESULT lr = 0;
        if (DwmDefWindowProc(m_hwnd, m->message, m->wParam, m->lParam, &lr)) {
            *res = lr;
            return true;
        }

        const LONG x = GET_X_LPARAM(m->lParam);
        const LONG y = GET_Y_LPARAM(m->lParam);

        RECT r{};
        GetWindowRect(m_hwnd, &r);

        const UINT dpi = GetDpiForWindow(m_hwnd);
        const int bx = GetSystemMetricsForDpi(SM_CXSIZEFRAME, dpi)
                       + GetSystemMetricsForDpi(SM_CXPADDEDBORDER, dpi);
        const int by = GetSystemMetricsForDpi(SM_CYSIZEFRAME, dpi)
                       + GetSystemMetricsForDpi(SM_CXPADDEDBORDER, dpi);

        const bool L = x <  r.left   + bx;
        const bool R = x >= r.right  - bx;
        const bool T = y <  r.top    + by;
        const bool B = y >= r.bottom - by;

        if (T && L) { *res = HTTOPLEFT;     return true; }
        if (T && R) { *res = HTTOPRIGHT;    return true; }
        if (B && L) { *res = HTBOTTOMLEFT;  return true; }
        if (B && R) { *res = HTBOTTOMRIGHT; return true; }
        if (L)      { *res = HTLEFT;        return true; }
        if (R)      { *res = HTRIGHT;       return true; }
        if (T)      { *res = HTTOP;         return true; }
        if (B)      { *res = HTBOTTOM;      return true; }

        return false;
    }
    }

    return false;
}

int WindowsNcController::borderThickness(HWND h)
{
    return GetSystemMetrics(SM_CXSIZEFRAME) + GetSystemMetrics(SM_CXPADDEDBORDER);
}
#endif
