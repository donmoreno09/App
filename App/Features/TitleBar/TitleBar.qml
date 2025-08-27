import QtQuick 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI
import App.StubComponents 1.0 as UI

UI.GlobalBackgroundConsumer {
    id: root

    RowLayout {
        anchors.fill: parent

        // Padding
        Item { Layout.preferredWidth: Theme.spacing.s1 }

        UI.DateTime { }

        UI.Title { }

        RowLayout {
            UI.Button { }

            UI.SearchBar { }

            RowLayout {
                UI.Button { }

                UI.Button { }

                UI.Button { }
            }
        }

        // Padding
        Item { Layout.preferredWidth: Theme.spacing.s1 }
    }
}
