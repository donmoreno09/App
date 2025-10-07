import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import Qt.labs.settings 1.1
import raise.singleton.radialmenucontroller 1.0
import raise.singleton.language 1.0

Dialog {
    id: tracksSelectionHintDialog
    title: tracksSelectionHintDialog.dialogTitle
    modal: true
    standardButtons: Dialog.Ok | Dialog.Cancel
    closePolicy: Dialog.CloseOnEscape

    background: Rectangle{
        color: "#1D2B4A"
        radius: 8
    }

    palette {
        window: "#404040"
        windowText: "white"
        button: "#1D2B4A"
        buttonText: "white"
    }

    width: 450

    property string fontFamily: "RobotoMedium"

    property bool hideMessage: false
    property bool hideMessageReady: false

    property bool docSpaceActive: false
    property bool aisActive: false

    // Debug timing
    property bool dialogInitialized: false

    // Automatic retranslation properties
    property string dialogTitle: qsTr("Track Selection Hint")
    property string instructionText: qsTr("To select tracks on the map, use the <b>selection tool</b> <img src='qrc:/components/ui/assets/cursor_dialog.svg' width='20' height='20' style='vertical-align: middle;'/> in the toolbar at the top.")
    property string checkboxText: qsTr("Don't show this message again")

    // Auto-retranslate when language changes
    function retranslateUi() {
        dialogTitle = qsTr("Track Selection Hint")
        instructionText = qsTr("To select tracks on the map, use the <b>selection tool</b> <img src='qrc:/components/ui/assets/cursor_dialog.svg' width='20' height='20' style='vertical-align: middle;'/> in the toolbar at the top.")
        checkboxText = qsTr("Don't show this message again")
    }

    Settings {
        id: appSettings
        category: "TracksHint"
        property alias hideMessageInternal: tracksSelectionHintDialog.hideMessage

        Component.onCompleted: {
            tracksSelectionHintDialog.hideMessageReady = true;

            if (tracksSelectionHintDialog.dialogInitialized) {
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
            text: tracksSelectionHintDialog.instructionText
            textFormat: Text.RichText
            font.pixelSize: 14
            font.family: tracksSelectionHintDialog.fontFamily;
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        CheckBox {
            id: dontShowAgainCheckBox
            Layout.alignment: Qt.AlignLeft
            text: tracksSelectionHintDialog.checkboxText
            font.pixelSize: 13
            font.family: tracksSelectionHintDialog.fontFamily;
            checked: tracksSelectionHintDialog.hideMessage
            spacing: 12

            Component.onCompleted: {
                for (var i = 0; i < children.length; i++) {
                    if (children[i].hasOwnProperty('color')) {
                        children[i].color = "white"
                    }
                }
            }
        }
    }

    onAccepted: {
        tracksSelectionHintDialog.hideMessage = dontShowAgainCheckBox.checked;
    }

    onRejected: {
        tracksSelectionHintDialog.hideMessage = dontShowAgainCheckBox.checked;
    }

    Component.onCompleted: {
        docSpaceActive = false;
        aisActive = false;
        dialogInitialized = true;

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

    // Automatic retranslation on language change
    Connections {
        target: LanguageController
        function onLanguageChanged() {
            console.log("Language changed signal received - auto-retranslating")
            root.retranslateUi()
        }
        function onLanguageLoadFailed(language, reason) {
            console.error("Language load failed:", language, "-", reason)
        }
    }

    function syncInitialTrackStates() {
        // Verifica se RadialMenuController è pronto
        if (!RadialMenuController.checkIsReady()) {
            Qt.callLater(function() {
                setTimeout(syncInitialTrackStates, 100);
            });
            return;
        }

        var rootNode = RadialMenuController.getRoot();
        if (!rootNode) {
            return;
        }

        var rootChildren = RadialMenuController.getChildren(rootNode.id);
        if (!rootChildren || rootChildren.length === 0) {
            return;
        }

        var tracksNodeId = "";
        for (var i = 0; i < rootChildren.length; i++) {
            if (rootChildren[i].propertyTreeNode && rootChildren[i].propertyTreeNode.name === "tracks") {
                tracksNodeId = rootChildren[i].id;
                break;
            }
        }

        if (tracksNodeId !== "") {
            var trackChildren = RadialMenuController.getChildren(tracksNodeId);
            if (!trackChildren || trackChildren.length === 0) {
                return;
            }

            var initialDocSpaceActive = false;
            var initialAisActive = false;

            for (var j = 0; j < trackChildren.length; j++) {
                if (trackChildren[j].propertyTreeNode) {
                    if (trackChildren[j].propertyTreeNode.name === "doc-space") {
                        initialDocSpaceActive = trackChildren[j].active;
                    } else if (trackChildren[j].propertyTreeNode.name === "ais") {
                        initialAisActive = trackChildren[j].active;
                    }
                }
            }

            docSpaceActive = initialDocSpaceActive;
            aisActive = initialAisActive;

            // Usa un timer per dare tempo al Settings di completarsi
            if (!hideMessageReady) {
                Qt.callLater(function() {
                    setTimeout(function() {
                        checkAndOpenDialog();
                    }, 200);
                });
            } else {
                checkAndOpenDialog();
            }
        }
    }

    function handleRadialMenuOptionToggled(optionId, checked) {
        if (optionId === "doc-space") {
            docSpaceActive = checked;
            if (checked) aisActive = false;
            checkAndOpenDialog();
        } else if (optionId === "ais") {
            aisActive = checked;
            if (checked) docSpaceActive = false;
            checkAndOpenDialog();
        } else {
            docSpaceActive = false;
            aisActive = false;
            Qt.callLater(function() {
                checkAndOpenDialog();
            });
        }
    }

    function checkAndOpenDialog() {
        var shouldShow = (docSpaceActive || aisActive) && hideMessageReady && !hideMessage;

        if (shouldShow) {
            if (!visible) {
                Qt.callLater(function() {
                    open();
                });
            }
        } else {
            if (visible) {
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
