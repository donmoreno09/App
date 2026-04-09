#ifndef DEBOUNCER_H
#define DEBOUNCER_H

#include <QObject>
#include <QQmlEngine>
#include <QTimer>

class Debouncer : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(int interval READ interval WRITE setInterval NOTIFY intervalChanged FINAL)
    Q_PROPERTY(bool running READ running NOTIFY runningChanged FINAL)

public:
    explicit Debouncer(QObject* parent = nullptr);
    explicit Debouncer(int intervalMs, QObject* parent = nullptr);

    int interval() const;
    void setInterval(int ms);

    bool running() const;

    Q_INVOKABLE void trigger();
    Q_INVOKABLE void trigger(int ms);

    Q_INVOKABLE void cancel();
    Q_INVOKABLE void flush();

    template<typename Functor>
        requires std::invocable<Functor>
    void trigger(Functor&& callback)
    {
        m_callback = std::forward<Functor>(callback);
        trigger();
    }

    template<typename Functor>
        requires std::invocable<Functor>
    void trigger(int ms, Functor&& callback)
    {
        m_callback = std::forward<Functor>(callback);
        trigger(ms);
    }

signals:
    void intervalChanged();
    void runningChanged();
    void triggered();

private:
    QTimer m_timer;
    std::function<void()> m_callback;

    void invokeCallback();
};

#endif // DEBOUNCER_H
