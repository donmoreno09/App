#pragma once

#include <QObject>
#include <QQmlEngine>
#include <QTimer>
#include <qcoreapplication.h>

class TranslationManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int revision READ revision NOTIFY revisionChanged)
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit TranslationManager(QObject *parent = nullptr);

    int revision() const { return m_revision; }

    // Manual retranslation trigger (optional)
    Q_INVOKABLE void retranslate();

signals:
    void revisionChanged();

private slots:
    void onLanguageChanged();

private:
    int m_revision = 0;
    QTimer* m_retranslateTimer;
};
