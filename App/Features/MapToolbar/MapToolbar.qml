import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.Map 1.0

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

            onClicked: MapController.zoomIn()
        }

        MapToolbarItem {
            source: "qrc:/App/assets/icons/minus.svg"
            icon.height: 0 // Hacky fix since the minus svg is being stretched

            onClicked: MapController.zoomOut()
        }
    }
}
