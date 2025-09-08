#include "TranslationManager.h"
#include "LanguageController.h"
#include <QDebug>

TranslationManager::TranslationManager(QObject *parent)
    : QObject(parent)
    , m_retranslateTimer(new QTimer(this))
{
    qDebug() << "TranslationManager: Initializing...";

    // Connect to your existing LanguageController
    connect(LanguageController::instance(), &LanguageController::languageChanged,
            this, &TranslationManager::onLanguageChanged);

    // Timer to batch multiple rapid language changes
    m_retranslateTimer->setSingleShot(true);
    m_retranslateTimer->setInterval(0); // Next event loop iteration
    connect(m_retranslateTimer, &QTimer::timeout, [this]() {
        ++m_revision;
        qDebug() << "TranslationManager: Revision updated to" << m_revision;
        emit revisionChanged();
    });

    qDebug() << "TranslationManager: Ready, initial revision:" << m_revision;
}

void TranslationManager::retranslate()
{
    qDebug() << "TranslationManager: Manual retranslate requested";
    if (!m_retranslateTimer->isActive()) {
        m_retranslateTimer->start();
    }
}

void TranslationManager::onLanguageChanged()
{
    qDebug() << "TranslationManager: Language changed signal received, triggering retranslation";
    retranslate();
}
