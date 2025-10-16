pragma Singleton

import QtQuick 6.8

import App.Features.Language 1.0
import App.Features.SidePanel 1.0

import "qrc:/App/Features/SidePanel/routes.js" as Routes

QtObject {
    id: titleBarController

    property string currentTitle: {
        TranslationManager.revision; // Update title on language changed.

        if (SidePanelController.isOpen) {
            switch(PanelRouter.currentPath) {
            case Routes.Languages: return qsTr("Languages")
            case Routes.Mission: return qsTr("Mission")
            case Routes.Pod: return qsTr("Pod")
            case Routes.Notifications: return qsTr("Notifications")
            case Routes.MapTilesets: return qsTr("Map Tilesets")
            case Routes.MapLayers: return qsTr("Map Layers")
            case Routes.DateTimeTest: return qsTr("DateTime Test")
            case Routes.ToggleTest: return qsTr("Toggle Test")
            case Routes.TextAreaTest: return qsTr("TextArea Test")
            case Routes.OverlayTest: return qsTr("Overlay Test")
            case Routes.SwitcherTest: return qsTr("Switcher Test")
            case Routes.SliderTest: return qsTr("Slider Test")
            case Routes.ModalTest: return qsTr("Modal Test")
            case Routes.ButtonTest: return qsTr("Button Test")
            case Routes.ArrivalContentTest: return qsTr("Arrival Content")
            case Routes.ArrivalDateContentTest: return qsTr("Arrival Date Content")
            case Routes.ArrivalDateTimeContentTest: return qsTr("Arrival DateTime Content")
            case Routes.TrailerPredictionTest: return qsTr("Trailer Predictions")
            case Routes.ViGateServicesTest: return qsTr("Leonardo Vi Gate Services")
            case Routes.TrackPanel: return qsTr("Track Details")
            case Routes.TirPanel: return qsTr("Tir Details")
            case Routes.NotFound: return qsTr("Not Found")
            }
        }

        return qsTr("Overview")
    }
}
