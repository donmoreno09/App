pragma Singleton

import QtQuick 6.8
import App.Features.Panels 1.0
import App.Features.TitleBar 1.0
import App.Features.SidePanel 1.0
import App.Features.ShipStowage 1.0

import "qrc:/App/Features/SidePanel/routes.js" as Routes

PanelController {
    id: root
    router: PanelRouter { routes: Routes }
}
