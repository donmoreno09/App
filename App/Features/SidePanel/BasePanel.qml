import QtQuick 6.8

import App.Themes 1.0
import App.Components 1.0 as UI

Item {
    // Base panel will be updated later, for now
    // the content is a text title for testing purposes.

    property alias title: titleEl.text

    Text {
        id: titleEl
        text: "Base panel"
        color: Theme.colors.text
    }
}
