import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.Map 1.0
import App.Features.TitleBar 1.0
import App.Features.SidePanel 1.0

import "components"

RowLayout {
    spacing: Theme.spacing.s3

    ButtonGroup { id: navigationGroup; exclusive: true }
    ButtonGroup { id: toolsGroup; exclusive: true }


    MapToolbarContainer {
        MapToolbarItem {
            source: "qrc:/App/assets/icons/map.svg"
            checkable: true
            ButtonGroup.group: navigationGroup

            onClicked: {
                TitleBarController.setTitle("Map Tilesets")
                SidePanelController.toggle("maptilesets")
            }
        }

        MapToolbarItem {
            source: "qrc:/App/assets/icons/home.svg"
            checkable: true
            ButtonGroup.group: navigationGroup
        }
    }

    MapToolbarContainer {
        MapToolbarItem {
            source: "qrc:/App/assets/icons/gps.svg"
            checkable: true
            ButtonGroup.group: toolsGroup
        }

        MapToolbarItem {
            source: "qrc:/App/assets/icons/plus.svg"
            checkable: true
            ButtonGroup.group: toolsGroup

            onClicked: MapController.zoomIn()
        }

        MapToolbarItem {
            source: "qrc:/App/assets/icons/minus.svg"
            checkable: true
            ButtonGroup.group: toolsGroup
            icon.height: 0 // Hacky fix since the minus svg is being stretched

            onClicked: MapController.zoomOut()
        }
    }
}
