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

    // Debug timing
    property bool dialogInitialized: false

    Settings {
        id: appSettings
        category: "TracksHint"
        property alias hideMessageInternal: tracksSelectionHintDialog.hideMessage

        Component.onCompleted: {
            console.log("=== SETTINGS COMPONENT COMPLETED ===");
            console.log("Settings completed at:", new Date().toISOString());
            console.log("hideMessageInternal:", hideMessageInternal);

            tracksSelectionHintDialog.hideMessageReady = true;
            console.log("hideMessageReady set to:", tracksSelectionHintDialog.hideMessageReady);


            if (tracksSelectionHintDialog.dialogInitialized) {
                console.log("Settings ready, calling checkAndOpenDialog");
                Qt.callLater(tracksSelectionHintDialog.checkAndOpenDialog);
            }
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
            color: "black"
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
        console.log("=== DIALOG COMPONENT COMPLETED ===");
        console.log("Dialog completed at:", new Date().toISOString());

        docSpaceActive = false;
        aisActive = false;
        dialogInitialized = true;

        console.log("Dialog initialized. hideMessageReady:", hideMessageReady);

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
        console.log("=== SYNC INITIAL TRACK STATES ===");
        console.log("syncInitialTrackStates called at:", new Date().toISOString());
        console.log("Current state - hideMessageReady:", hideMessageReady, "dialogInitialized:", dialogInitialized);

        // Verifica se RadialMenuController è pronto
        if (!RadialMenuController.checkIsReady()) {
            console.log("RadialMenuController not ready, retrying in 100ms");
            Qt.callLater(function() {
                setTimeout(syncInitialTrackStates, 100);
            });
            return;
        }

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
                        initialDocSpaceActive = trackChildren[j].active;
                        console.log("doc-space found, active:", initialDocSpaceActive);
                    } else if (trackChildren[j].propertyTreeNode.name === "ais") {
                        initialAisActive = trackChildren[j].active;
                        console.log("ais found, active:", initialAisActive);
                    }
                }
            }

            docSpaceActive = initialDocSpaceActive;
            aisActive = initialAisActive;

            console.log("=== FINAL SYNC STATE ===");
            console.log("docSpaceActive:", docSpaceActive, "aisActive:", aisActive);
            console.log("hideMessageReady:", hideMessageReady, "hideMessage:", hideMessage);
            console.log("Should show dialog?", (docSpaceActive || aisActive) && hideMessageReady && !hideMessage);

            // Usa un timer per dare tempo al Settings di completarsi
            if (!hideMessageReady) {
                console.log("Settings not ready, waiting 200ms");
                Qt.callLater(function() {
                    setTimeout(function() {
                        console.log("Retry after Settings delay - hideMessageReady:", hideMessageReady);
                        checkAndOpenDialog();
                    }, 200);
                });
            } else {
                checkAndOpenDialog();
            }
        } else {
            console.log("TracksSelectionHintDialog: syncInitialTrackStates - 'tracks' node not found in root.");
        }
    }

    function handleRadialMenuOptionToggled(optionId, checked) {
        console.log("=== RADIAL MENU OPTION TOGGLED ===");
        console.log("optionId:", optionId, "checked:", checked);
        console.log("BEFORE update: docSpaceActive:", docSpaceActive, "aisActive:", aisActive);

        if (optionId === "doc-space") {
            docSpaceActive = checked;
            if (checked) aisActive = false;
            checkAndOpenDialog();
        } else if (optionId === "ais") {
            aisActive = checked;
            if (checked) docSpaceActive = false;
            checkAndOpenDialog();
        } else {
            console.log("Non-track option or parent node. Setting both to false.");
            docSpaceActive = false;
            aisActive = false;
            Qt.callLater(function() {
                checkAndOpenDialog();
            });
        }
        console.log("AFTER update: docSpaceActive:", docSpaceActive, "aisActive:", aisActive);
    }

    function checkAndOpenDialog() {
        console.log("=== CHECK AND OPEN DIALOG ===");
        console.log("Current time:", new Date().toISOString());
        console.log("CURRENT STATE:");
        console.log("  docSpaceActive:", docSpaceActive);
        console.log("  aisActive:", aisActive);
        console.log("  hideMessage:", hideMessage);
        console.log("  hideMessageReady:", hideMessageReady);
        console.log("  visible:", visible);
        console.log("  dialogInitialized:", dialogInitialized);

        var shouldShow = (docSpaceActive || aisActive) && hideMessageReady && !hideMessage;
        console.log("Should show dialog?", shouldShow);

        if (shouldShow) {
            if (!visible) {
                console.log("*** OPENING DIALOG ***");
                Qt.callLater(function() {
                    open();
                });
            } else {
                console.log("Dialog already visible");
            }
        } else {
            console.log("Conditions not met for opening dialog");
            if (!hideMessageReady) {
                console.log("  -> hideMessageReady is false");
            }
            if (hideMessage) {
                console.log("  -> hideMessage is true");
            }
            if (!(docSpaceActive || aisActive)) {
                console.log("  -> Neither docSpaceActive nor aisActive is true");
            }

            if (visible) {
                console.log("Closing dialog");
                close();
            }
        }
    }

    // Funzione di utility per setTimeout
    function setTimeout(callback, delay) {
        var timer = Qt.createQmlObject("import QtQuick 6.8; Timer {}", tracksSelectionHintDialog);
        timer.interval = delay;
        timer.repeat = false;
        timer.triggered.connect(function() {
            callback();
            timer.destroy();
        });
        timer.start();
    }
}
