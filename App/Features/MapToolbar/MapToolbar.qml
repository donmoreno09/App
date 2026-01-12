import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

import App.Themes 1.0
import App.Components 1.0 as UI
import App.Features.MapToolbar 1.0
import App.Features.Map 1.0
import App.Features.TitleBar 1.0
import App.Features.ContextPanel 1.0

import "qrc:/App/Features/ContextPanel/routes.js" as ContextRoutes

ColumnLayout {
    spacing: Theme.spacing.s3

    MapToolbarContainer {
        MapToolbarItem {
            source: "qrc:/App/assets/icons/map.svg"
            checkable: true

            onClicked: ContextPanelController.toggle(ContextRoutes.MapTools)
        }

        MapToolbarItem {
            source: "qrc:/App/assets/icons/plus.svg"
            checkable: true

            onClicked: MapController.zoomIn()
        }

        MapToolbarItem {
            source: "qrc:/App/assets/icons/minus.svg"
            checkable: true
            icon.height: 0 // Hacky fix since the minus svg is being stretched

            onClicked: MapController.zoomOut()
        }
    }
}
