import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI

import "components"

RowLayout {
    spacing: Theme.spacing.s3

    MapToolbarContainer {
        MapToolbarItem {
            source: "qrc:/App/assets/icons/map.svg"
        }

        MapToolbarItem {
            source: "qrc:/App/assets/icons/home.svg"
        }
    }

    MapToolbarContainer {
        MapToolbarItem {
            source: "qrc:/App/assets/icons/gps.svg"
        }

        MapToolbarItem {
            source: "qrc:/App/assets/icons/plus.svg"
        }

        MapToolbarItem {
            source: "qrc:/App/assets/icons/minus.svg"

            // Hacky fix since the minus svg is being stretched
            icon.height: 0
        }
    }
}
