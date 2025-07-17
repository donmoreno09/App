import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import Qt.labs.settings 1.1
import raise.singleton.radialmenucontroller 1.0

Dialog {
    id: tracksSelectionHintDialog
    title: qsTr("Suggerimento Selezione Tracce")
    modal: true
    standardButtons: Dialog.Ok | Dialog.Cancel
    closePolicy: Dialog.CloseOnEscape

    background: Rectangle{
        color: "white"
        radius: 8
    }

    width: 450

    property bool hideMessage: false
    property bool hideMessageReady: false

    property bool docSpaceActive: false
    property bool aisActive: false

    Settings {
        id: appSettings
        category: "TracksHint"
        property alias hideMessageInternal: tracksSelectionHintDialog.hideMessage

        Component.onCompleted: {
            tracksSelectionHintDialog.hideMessageReady = true;
            console.log("TracksSelectionHintDialog: appSettings (Settings) Component.onCompleted. hideMessageInternal:", hideMessageInternal, "hideMessageReady:", hideMessageReady);
        }
    }

    contentItem: ColumnLayout {
        spacing: 15
        width: parent.width

        Text {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            text: "Per selezionare le tracce sulla mappa (quelle blu), utilizza lo <b>strumento di selezione</b> <img src='qrc:/components/ui/assets/cursor.svg' width='20' height='20' style='vertical-align: middle;'/> nella barra degli strumenti in alto."
            textFormat: Text.RichText
            font.pixelSize: 14
            color: "black" // Testo nero
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        CheckBox {
            id: dontShowAgainCheckBox
            Layout.alignment: Qt.AlignLeft
            text: "Non mostrare più questo messaggio"
            font.pixelSize: 13
            checked: tracksSelectionHintDialog.hideMessage
            spacing: 12

            Component.onCompleted: {
                for (var i = 0; i < children.length; i++) {
                    if (children[i].hasOwnProperty('color')) {
                        children[i].color = "black"
                    }
                }
            }
        }
    }

    onAccepted: {
        tracksSelectionHintDialog.hideMessage = dontShowAgainCheckBox.checked;
        console.log("Dialog Accepted. hideMessage:", tracksSelectionHintDialog.hideMessage);
    }

    onRejected: {
        tracksSelectionHintDialog.hideMessage = dontShowAgainCheckBox.checked;
        console.log("Dialog Rejected. hideMessage:", tracksSelectionHintDialog.hideMessage);
    }

    Component.onCompleted: {
        console.log("TracksSelectionHintDialog: Dialog Component.onCompleted.");
        docSpaceActive = false;
        aisActive = false;
        var parentWindow = tracksSelectionHintDialog.parent;
        while (parentWindow && !(parentWindow instanceof Window)) {
            parentWindow = parentWindow.parent;
        }
        if (parentWindow) {
            tracksSelectionHintDialog.x = parentWindow.x + (parentWindow.width - tracksSelectionHintDialog.width) / 2;
            tracksSelectionHintDialog.y = parentWindow.y + (parentWindow.height - tracksSelectionHintDialog.height) / 2;
        } else {
            tracksSelectionHintDialog.anchors.centerIn = parent;
        }
    }

    function syncInitialTrackStates() {
        console.log("TracksSelectionHintDialog: syncInitialTrackStates called.");

        var rootNode = RadialMenuController.getRoot();
        if (!rootNode) {
            console.log("ERROR: RadialMenuController.getRoot() returned null during syncInitialTrackStates.");
            return;
        }
        console.log("RadialMenuController Root ID:", rootNode.id);

        var rootChildren = RadialMenuController.getChildren(rootNode.id);
        if (!rootChildren || rootChildren.length === 0) {
            console.log("ERROR: RadialMenuController.getChildren(rootNode.id) returned empty or null during syncInitialTrackStates.");
            return;
        }
        console.log("Root Children Names and Active States:", JSON.stringify(rootChildren.map(n => ({name: n.propertyTreeNode ? n.propertyTreeNode.name : 'N/A', active: n.active}))));


        var tracksNodeId = "";
        for (var i = 0; i < rootChildren.length; i++) {
            if (rootChildren[i].propertyTreeNode && rootChildren[i].propertyTreeNode.name === "tracks") {
                tracksNodeId = rootChildren[i].id;
                console.log("'tracks' node found. ID:", tracksNodeId);
                break;
            }
        }

        if (tracksNodeId !== "") {
            var trackChildren = RadialMenuController.getChildren(tracksNodeId);
            if (!trackChildren || trackChildren.length === 0) {
                console.log("ERROR: RadialMenuController.getChildren(tracksNodeId) returned empty or null for 'tracks' children during syncInitialTrackStates.");
                return;
            }
            console.log("Tracks Children (doc-space, ais, etc.) Names and Active States:", JSON.stringify(trackChildren.map(n => ({name: n.propertyTreeNode ? n.propertyTreeNode.name : 'N/A', active: n.active}))));


            var initialDocSpaceActive = false;
            var initialAisActive = false;

            for (var j = 0; j < trackChildren.length; j++) {
                if (trackChildren[j].propertyTreeNode) {
                    if (trackChildren[j].propertyTreeNode.name === "doc-space") {
                        if (trackChildren[j].active) {
                            initialDocSpaceActive = true;
                            initialAisActive = false; // Exclusivity
                            console.log("Found doc-space active.");
                            break;
                        }
                    } else if (trackChildren[j].propertyTreeNode.name === "ais") {
                        if (trackChildren[j].active) {
                            initialAisActive = true;
                            initialDocSpaceActive = false; // Exclusivity
                            console.log("Found ais active.");
                            break;
                        }
                    }
                }
            }

            docSpaceActive = initialDocSpaceActive;
            aisActive = initialAisActive;

            console.log("TracksSelectionHintDialog: syncInitialTrackStates - Final state: docSpaceActive:", docSpaceActive, "aisActive:", aisActive);

            checkAndOpenDialog();
        } else {
            console.log("TracksSelectionHintDialog: syncInitialTrackStates - 'tracks' node not found in root.");
        }
    }

    function handleRadialMenuOptionToggled(optionId, checked) {
        console.log("TracksSelectionHintDialog: handleRadialMenuOptionToggled RECEIVED - optionId:", optionId, "checked:", checked);
        console.log("TracksSelectionHintDialog: handleRadialMenuOptionToggled - BEFORE update: docSpaceActive:", docSpaceActive, "aisActive:", aisActive);

        if (optionId === "doc-space") {
            docSpaceActive = checked;
            if (checked) aisActive = false;
            checkAndOpenDialog();
        } else if (optionId === "ais") {
            aisActive = checked;
            if (checked) docSpaceActive = false;
            checkAndOpenDialog();
        } else {
            console.log("TracksSelectionHintDialog: handleRadialMenuOptionToggled - Non-track option or parent node. Setting both to false.");
            docSpaceActive = false;
            aisActive = false;
            Qt.callLater(function() {
                console.log("TracksSelectionHintDialog: checkAndOpenDialog called via Qt.callLater for non-leaf node.");
                checkAndOpenDialog();
            });
        }
        console.log("TracksSelectionHintDialog: handleRadialMenuOptionToggled - AFTER update: docSpaceActive:", docSpaceActive, "aisActive:", aisActive);
    }

    function checkAndOpenDialog() {
        console.log("TracksSelectionHintDialog: checkAndOpenDialog called. CURRENT STATE: docSpaceActive:", docSpaceActive, "aisActive:", aisActive, "hideMessage:", hideMessage, "hideMessageReady:", hideMessageReady, "visible:", visible);
        if ((docSpaceActive || aisActive) && hideMessageReady) {
            if (!hideMessage && !visible) {
                console.log("TracksSelectionHintDialog: Conditions met for opening dialog. Opening now.");
                Qt.callLater(function() {
                    open();
                });
            } else if (hideMessage) {
                console.log("TracksSelectionHintDialog: Dialog not opened because hideMessage is true.");
            } else if (visible) {
                console.log("TracksSelectionHintDialog: Dialog not opened because it's already visible.");
            }
        } else {
            console.log("TracksSelectionHintDialog: Conditions not met for opening dialog. Closing dialog if open.");
            if (visible) {
                close();
            }
        }
    }
}
