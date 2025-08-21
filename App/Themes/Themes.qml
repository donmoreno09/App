pragma Singleton

import QtQuick

QtObject {
    /*! \qmltype Themes
        \inqmlmodule App.Themes
        \brief Enumerates all available theme variants.

        You can directly use Themes.Fincantieri, QML lifts up
        enum constants so no need to write `Themes.Variants.Fincantieri`.
     */

    enum Variants {
        Fincantieri,
        FincantieriLight
    }
}
