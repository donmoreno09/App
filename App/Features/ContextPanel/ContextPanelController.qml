pragma Singleton

import QtQuick 6.8
import App.Features.Panels 1.0

import "qrc:/App/Features/ContextPanel/routes.js" as Routes

PanelController {
    id: root
    router: PanelRouter { routes: Routes }
}
