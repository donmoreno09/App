#include "LanguageEnum.h"

namespace Language {

QString toString(Code language)
{
    switch (language) {
    case Code::English:
        return "en";
    case Code::Italian:
        return "it";
    }
    return "en"; // Default fallback
}

Code fromString(const QString &languageCode)
{
    if (languageCode == "en") return Code::English;
    if (languageCode == "it") return Code::Italian;

    return Code::English; // Default fallback
}

QStringList getAllCodes()
{
    return QStringList() << "en" << "it";
}

bool isSupported(const QString &languageCode)
{
    return languageCode == "en" || languageCode == "it";
}

}
