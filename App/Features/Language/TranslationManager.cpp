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
        emit revisionChanged();
    });
}

void TranslationManager::retranslate()
{
    if (!m_retranslateTimer->isActive()) {
        m_retranslateTimer->start();
    }
}

void TranslationManager::onLanguageChanged()
{
    retranslate();
}
