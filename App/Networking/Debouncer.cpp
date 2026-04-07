#include "Debouncer.h"

Debouncer::Debouncer(QObject *parent) : QObject(parent)
{
    m_timer.setSingleShot(true);

    connect(&m_timer, &QTimer::timeout, this, [this] {
        emit runningChanged();
        invokeCallback();
        emit triggered();
    });
}

Debouncer::Debouncer(int intervalMs, QObject *parent) : Debouncer(parent)
{
    setInterval(intervalMs);
}

int Debouncer::interval() const
{
    return m_timer.interval();
}

void Debouncer::setInterval(int ms)
{
    if (ms < 0) {
        ms = 0;
    }

    if (m_timer.interval() == ms) {
        return;
    }

    m_timer.setInterval(ms);
    emit intervalChanged();
}

bool Debouncer::running() const
{
    return m_timer.isActive();
}

void Debouncer::trigger()
{
    const bool wasRunning = m_timer.isActive();
    m_timer.start();

    if (!wasRunning) {
        emit runningChanged();
    }
}

void Debouncer::trigger(int ms)
{
    if (ms < 0) {
        ms = 0;
    }

    const bool wasRunning = m_timer.isActive();
    const bool intervalChangedNow = (m_timer.interval() != ms);

    m_timer.start(ms); // updates interval then starts/restarts

    if (intervalChangedNow) {
        emit intervalChanged();
    }

    if (!wasRunning) {
        emit runningChanged();
    }
}

void Debouncer::cancel()
{
    if (!m_timer.isActive()) {
        return;
    }

    m_timer.stop();
    m_callback = {};
    emit runningChanged();
}

void Debouncer::flush()
{
    if (!m_timer.isActive()) {
        return;
    }

    m_timer.stop();
    emit runningChanged();
    invokeCallback();
    emit triggered();
}

void Debouncer::invokeCallback()
{
    if (!m_callback) {
        return;
    }

    auto callback = std::move(m_callback);
    m_callback = {};
    callback();
}
