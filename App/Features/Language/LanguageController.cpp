#include "LanguageController.h"
#include <QCoreApplication>
#include <QGuiApplication>
#include <QSettings>
#include <QLocale>

#include "LanguageEnum.h"
#include "LanguageLogger.h"

// Anonymous namespace to make _logger exclusive for this file
namespace {
Logger& _logger()
{
    static Logger logger = LanguageLogger::get().child({
        {"service", "LANGUAGE_CONTROLLER"}
    });
    return logger;
}
}

LanguageController *LanguageController::s_instance = nullptr;

LanguageController::LanguageController(QObject *parent)
    : QObject(parent)
    , m_translator(new QTranslator(this))
{
    s_instance = this;

    // Initialize available languages
    m_availableLanguages = Language::getAllCodes();

    // Restore saved language or detect system language
    m_currentLanguage = initializeLanguage();

    // Load the determined language
    loadLanguage(m_currentLanguage);
}

LanguageController::~LanguageController()
{
    s_instance = nullptr;
}

LanguageController *LanguageController::instance()
{
    return s_instance;
}

QString LanguageController::currentLanguage() const
{
    return m_currentLanguage;
}

void LanguageController::setCurrentLanguage(const QString &language)
{
    // Validate input
    if (language.isEmpty()) {
        _logger().warn("Rejected empty language code");
        return;
    }

    if (!Language::isSupported(language)) {
        QString availableList = Language::getAllCodes().join(", ");
        _logger().warn("Rejected unsupported language", {
            kv("language", language),
            kv("available", availableList)
        });
        return;
    }

    if (m_currentLanguage == language) {
        return; // Already current language
    }

    // Attempt to load the language
    m_currentLanguage = language;

    // Save to persistent settings
    QSettings settings;
    settings.setValue("language", language);

    // Try to load the language
    loadLanguage(language);

    // Always emit signals since loadLanguage handles fallbacks
    emit currentLanguageChanged();
    emit languageChanged();
}

QStringList LanguageController::availableLanguages() const
{
    return m_availableLanguages;
}

QString LanguageController::initializeLanguage()
{
    // Try to restore saved language preference
    QSettings settings;
    QString savedLanguage = settings.value("language").toString();

    if (!savedLanguage.isEmpty() && Language::isSupported(savedLanguage)) {
        _logger().info("Restored saved language", { kv("language", savedLanguage) });
        return savedLanguage;
    }

    // Fallback to system locale detection
    QString systemLocale = QLocale::system().name().left(2);

    if (Language::isSupported(systemLocale)) {
        _logger().info("Using system language", { kv("language", systemLocale) });
        return systemLocale;
    }

    // Final fallback to English
    _logger().info("Falling back to default language", { kv("language", "en") });
    return "en";
}

void LanguageController::loadLanguage(const QString &language)
{
    // Try requested language first
    if (tryLoadLanguage(language)) {
        return;
    }

    // Fallback to system language if different from requested
    QString systemLang = QLocale::system().name().left(2);
    if (language != systemLang && tryLoadLanguage(systemLang)) {
        _logger().warn("Requested language failed; using system language", {
            kv("requested", language),
            kv("fallback", systemLang)
        });
        m_currentLanguage = systemLang; // Update current language to reflect reality
        emit currentLanguageChanged();
        return;
    }

    // Final fallback to English
    if (language != "en" && tryLoadLanguage("en")) {
        _logger().warn("Language load failed; falling back to English", { kv("requested", language) });
        m_currentLanguage = "en"; // Update current language to reflect reality
        emit currentLanguageChanged();
        return;
    }

    // Critical error - log and continue without translator
    _logger().warn("All language fallbacks failed", { kv("requested", language) });
}

bool LanguageController::tryLoadLanguage(const QString &language)
{
    // Remove the old translator
    QCoreApplication::removeTranslator(m_translator);

    // Use clean resource path from Qt translation system
    QString resourcePath = QString(":/translations/app_%1.qm").arg(language);

    if (m_translator->load(resourcePath)) {
        QCoreApplication::installTranslator(m_translator);
        _logger().info("Loaded translation file", {
            kv("language", language),
            kv("path", resourcePath)
        });
        return true;
    }

    _logger().warn("Translation file not found", {
        kv("language", language),
        kv("path", resourcePath)
    });
    return false;
}
