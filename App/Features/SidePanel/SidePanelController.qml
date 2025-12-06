pragma Singleton

import QtQuick 6.8
import App.Features.Panels 1.0
import App.Features.MapModes 1.0
import App.Features.TitleBar 1.0
import App.Features.SidePanel 1.0
import App.Features.ShipStowage 1.0

import "qrc:/App/Features/SidePanel/routes.js" as Routes

PanelController {
    id: root
    router: PanelRouter {
        routes: Routes

        onStackWillChange: function (_cd, _nd, _fp, toPath) {
            // To prevent the panels for PoI and AlertZone to be in an invalid state,
            // clear their state first before opening their panel.
            if (router.currentPath === Routes.Poi || router.currentPath === Routes.AlertZone) {
                MapModeController.clearState()
            }
        }

        onStackChanged: {
            // This is where we return back to interaction mode
            if (router.currentPath === Routes.Poi || router.currentPath === Routes.AlertZone) {
                return
            }

            if (MapModeController.activeMode !== MapModeRegistry.interactionMode)
                MapModeController.setActiveMode(MapModeRegistry.interactionMode)
        }
    }
}
