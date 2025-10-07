import QtQuick
import QtQuick.Controls
import QtQuick.Shapes
import QtPositioning

import "../../basewidgets" as Widgets
import "../commons" as PanelsCommons
import "../../../qtds" as QTDSComponents
import "../../commons" as UiWidgets

//import qml.controllers.trackspanelscontroller 1.0
//import qml.controllers.trackdetailscontroller 1.0
//import qml.controllers.wmsmapcontroller 1.0
//import qml.etrack.definitions.identities 1.0
//import qml.etrack.definitions.symbols 1.0

PanelsCommons.BasePanel {
    id: baseTrackPanel

    required property var trackData   // PORTING: dati live della traccia
    required property var marker      // PORTING: riferimento al Track.qml

    // variables to track responsiveness to screen resize
    property real relativeX: 0.5 // as a percentage of parent.width
    property real relativeY: 0.5 // as a percentage of parent.height

    objectName: "baseTrackPanel"
    width: 330
    height: 390
    color: "transparent"
    radius: 3
    border.color: "#cfdff3"
    border.width: 0
    opacity: 1.0
    visible: false
    minimizable: true

    doTranslation: true
    doScale: false
    doRotation: false
    doPress: false

    //onPressed: (evtHandler, w) => {console.log("onPressed", evtHandler, w.name)}
    //onLongPressed: (evtHandler, w) => {console.log("onLongPressed", evtHandler, w.name)}
    //onDoublePressed: (evtHandler, w) => {console.log("onDoublePressed", evtHandler, w.name)}
    //onTransformScale: (evtHandler, w, delta) => {console.log("onTransformScale", evtHandler, w.name, delta)}
    //onTransformRotation: (evtHandler, w, delta) => {console.log("onTransformRotation", evtHandler, w.name, delta)}

    onMove: (evtHandler, w, delta) => {
        if(baseTrackPanel.link)
            baseTrackPanel.link.panelAnchor = Qt.point(baseTrackPanel.centerX, baseTrackPanel.centerY)
    }

    onMinimized: (val) => {
        if (baseTrackPanel.link)
            baseTrackPanel.link.visible=!val
        if(!val) {
            let pos = baseTrackPanel.reposBboxIn(baseTrackPanel.marker)
            baseTrackPanel.x = pos[0]
            baseTrackPanel.y = pos[1]
        }
    }

    onCenterXChanged: () => {
        if(baseTrackPanel.link)
            baseTrackPanel.link.panelAnchor = Qt.point(baseTrackPanel.centerX, baseTrackPanel.centerY)
    }

    onCenterYChanged: () => {
        if(baseTrackPanel.link)
            baseTrackPanel.link.panelAnchor = Qt.point(baseTrackPanel.centerX, baseTrackPanel.centerY)
    }

    clip: true

    state: ""
    headerTitleText: "Trace unknown"

    property var link
    property string trackUid
    property string trackChannel
    property bool ownShipPovActive: false

    name: "Track"

    signal closed()
    signal centerViewRequested(var coordinate)

    Connections {
        target: baseTrackPanel.closeButton

        function onClicked() {
            baseTrackPanel.close()
        }
    }


    Item {

        id: info
        parent: baseTrackPanel.bodySection
        anchors.fill: parent
        anchors.centerIn: parent

        ListModel {
            id: bodyItemModel
        }

        ScrollView {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: parent.width / 50
            anchors.topMargin: parent.width / 50
            anchors.leftMargin: parent.width / 25
            anchors.rightMargin: parent.width / 25

            ListView {
                id: infoListView
                //pressDelay: 1000
                orientation: ListView.Vertical
                flickableDirection: Flickable.VerticalFlick
                interactive :true
                spacing: 4
                model: bodyItemModel
                width:info.width
                delegate: PanelsCommons.PanelListItem {
                    objectName: qsTr(key.toLowerCase())
                    height: 20
                    keyTxt: qsTr(key.toLowerCase())
                    valueTxt: qsTr(value.toLowerCase())
                    keyColor: "#FFF0CB"
                    valueColor: "#ffffff"
                    width: info.width - ((info.width / 25) * 2 )
                }

                Component.onCompleted: {
                    currentIndex = -1
                }
            }
        }
    }

    Item {
        id: options
        parent: baseTrackPanel.footerSection
        anchors.fill: parent
        anchors.centerIn: parent

        UiWidgets.SwitchButton {
            id: historyBtn
            width: 200
            height: 24
            label: "track history"
            labelFontPointSize: 9
            image: "qrc:///assets/icons/panels/track/trackhistory.svg"
            switchBackgroundColorOff: "#ed1c24"
            switchBackgroundColorOn: "#68f25c"
            switchButtonColorOff:"#edf7fa"
            switchButtonColorOn:"#edf7fa"
            switchButtonColorOnDown: "#e9e9e9"
            switchButtonColorOffDown: "#e9e9e9"
            switchBorderWidth: 0
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: parent.width / 1.9
            anchors.right: parent.right
            anchors.topMargin: parent.width / 25
            anchors.rightMargin: parent.width / 25
            switchHandleWidth: 32
            circular: true

            onSwitched: (checked, state) => {
                    if(checked)
                        marker.getHistory()
                    else
                        marker.closeHistory()
            }
        }

        Widgets.BaseButton {
            id: centerViewBtn
            width: 120
            height: 30
            image: "qrc:///assets/icons/panels/track/trackcenter.svg"
            text: "center view"
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: parent.width / 25
            anchors.leftMargin: parent.width / 25
            enabled: !baseTrackPanel.ownShipPovActive
            orientation: Widgets.BaseButton.LayoutOrientation.Horizontal
            direction: Widgets.BaseButton.LayoutDirection.LeftToRight
            labelHAlignment: Text.AlignLeft
            backgroundColor: "#4a92cb"
            backgroundColorDown: "#184b80"
            labelColor: "#cfdff3"
            labelColorDown: "#ffffff"
            imageColor: "#cfdff3"
            imageColorDown: "#ffffff"
            labelBoldDown: true
            imagePadding: 2

            onClicked: {
                console.log("[WARNING][BaseTrackPanel] commentato per refactor")
                baseTrackPanel.centerViewRequested(QtPositioning.coordinate(trackData.pos[0], trackData.pos[1]))
            }
        }
    }

    Component.onCompleted: {
        console.log("BaseTrackPanel on completed...")
    }

    onLinkChanged: {
        if(baseTrackPanel.link) {
            baseTrackPanel.link.panelAnchor = Qt.point(baseTrackPanel.centerX, baseTrackPanel.centerY)
            baseTrackPanel.link.visibleChanged.connect(baseTrackPanel.handleLinkVisibleChanged)
        }
    }

    onTrackDataChanged: {
        baseTrackPanel.updateData()
        if (!baseTrackPanel.isMinimized)
            baseTrackPanel.visible = true
    }

    function saveChanges() {
        let changes = {}
        for(let index in infoListView.contentItem.children) {
            //console.log("***saveChanges panel****", infoListView.contentItem.children[index], infoListView.contentItem.children[index].keyTxt, infoListView.contentItem.children[index].valueTxt)
            //console.log(Object.keys(infoListView.contentItem.children[index]))
            infoListView.contentItem.children[index].saveChanges()
            changes[infoListView.contentItem.children[index].objectName] = infoListView.contentItem.children[index].valueTxt
        }
        console.log("[WARNING][BaseTrackPanel] commentato per refactor")
        // TrackDetailsController.changeTrackDetails(trackUid,changes["symbol"],changes["identity"]);
    }

    function getValuesFromKey(key) {
        let res = []
        if(key==="identity")
            res = ETrackIdentities.getAllValues()
        else if (key==="symbol")
            res = ETrackSymbolSet.getAllValues()
        return res
    }

    function reposBboxIn(marker) {
        let marginX = 100
        let marginY = 100

        let posX = marker.screenPos.x + marker.realWidth/2 + marginX
        let posY = marker.screenPos.y - marker.realHeight/2 - marginY

        if (posX >= baseTrackPanel.xBboxRule.maximum || (parent.width - posX) < baseTrackPanel.width)
        {
            posX = marker.screenPos.x - baseTrackPanel.width - marginX
        }
        else if (posX <= baseTrackPanel.xBboxRule.minimum || posX < 0)
        {
            posX = marker.screenPos.x + marker.realWidth + marginX
        }

        if (posY >= baseTrackPanel.yBboxRule.maximum || (parent.height - posY) < baseTrackPanel.height)
        {
            posY = marker.screenPos.y - baseTrackPanel.height - marginY
        }
        else if (posY <= baseTrackPanel.yBboxRule.minimum || posY < 0)
        {
            posY = marker.screenPos.y + marginY
        }

        return [posX, posY]

    }

    function open(marker, link = null) {
        baseTrackPanel.marker = marker
        if (baseTrackPanel.anchor)
            baseTrackPanel.unminimize(baseTrackPanel.reposBboxIn(baseTrackPanel.marker))
        else{
            let pos = baseTrackPanel.reposBboxIn(baseTrackPanel.marker)
            baseTrackPanel.link = link
            baseTrackPanel.x = pos[0]
            baseTrackPanel.y = pos[1]
        }
    }

    function close() {
        if(baseTrackPanel.link) {
            baseTrackPanel.link.destroy()
            baseTrackPanel.link = null
        }
        baseTrackPanel.marker = null
        baseTrackPanel.destroyAnchor() // Method from BaseScatter.qml to destroy the minimized UI state
        baseTrackPanel.destroy()
        baseTrackPanel.closed()
    }

    function handleLinkVisibleChanged()
    {
        if ( baseTrackPanel.link && baseTrackPanel.link.visible)
            baseTrackPanel.link.panelAnchor = Qt.point(baseTrackPanel.centerX, baseTrackPanel.centerY)
    }

    function updateData() {
        console.log("[INFO][BaseTrackPanel] updateData for track: ", baseTrackPanel.trackData.tracknumber)
        if (!baseTrackPanel.trackData) {
            console.log("[WARNING][BaseTrackPanel] trackData is null ...")
            return
        }
        bodyItemModel.clear()

        // Aggiorna il titolo
        // OLD: baseTrackPanel.headerTitleText = "T"+(baseTrackPanel.trackData.trackedObject.tracknumber) ? "T"+baseTrackPanel.trackData.trackedObject.tracknumber : "Trace unknown"
        if (baseTrackPanel.trackData.tracknumber !== undefined)
            baseTrackPanel.headerTitleText = "T" + trackData.tracknumber
        else
            baseTrackPanel.headerTitleText = qsTr("Trace unknown")


        /* Scorro tutte le proprietà di trackData */
        for (const key of Object.keys(trackData)) {

            const value = trackData[key]

            console.log("[INFO][BaseTrackPanel] updateData → key:", key, "value:", JSON.stringify(value))

            /* 4a. Converto la coppia (key,value) in righe “pronte” per la view */
            const rows = parseValue(key, value)   // rows è un array o null

            /* 4b. Se parseValue() ha restituito qualcosa, lo aggiungo al modello */
            if (rows) {
                for (const row of rows) {
                    bodyItemModel.append(row)
                    console.log("[INFO][BaseTrackPanel] updateData append row:", row)
                }
            }
        }
    }

    function parseValue(key, value) {
        let res = []
        switch (key)
        {
            case "name": {
                if (trackData.tracktype === 'doc-space') res.push({ key: "Name", value: value ? value : "unknown" })
                break
            }

            case "destination": {
                if (value && trackData.tracktype === 'doc-space') res.push({ key: "Destination", value })
                break
            }

            case "cargo_code": {
                if (value && trackData.tracktype === 'doc-space') res.push({ key: "Cargo Code", value })
                break
            }

            case "time": {
                let k = "timestamp"
                let date = new Date(value*1000);

                let v = date.toLocaleString({ "day": "2-digit", "month": "2-digit", "year": "numeric",
                                          "hour": "2-digit", "minute": "2-digit", "second": "2-digit"});

                res.push({"key": k, "value": v})

                break
            }

            case "pos": {
                let k1 = "latitude"
                let k2 = "longitude"
                let k3 = "altitude"
                let v1 = (value.length >= 2 && value[0]) ? value[0].toFixed(5) +" °" : "unknown"
                let v2 = (value.length >= 2 && value[1]) ? value[1].toFixed(5)+" °" : "unknown"
                let v3 = (value.length >= 2 && value[2]) ? ((value[2]*3.281)/100.0).toFixed(2)+ " hFt" : "unknown"

                res.push({"key": k1, "value": v1})
                res.push({"key": k2, "value": v2})

                // Don't show altitude if it doesn't exist.
                if (v3 !== "unknown") res.push({"key":k3,"value":v3  })
                break
            }

            case "vel": {
                let k = "Velocity"
                let v = value

                let heading=(((Math.atan2(-v[1],v[0]))* (180/Math.PI))+90.0)
                res.push({"key": "Heading", "value": heading.toString()+"°"})
                let vel=Math.sqrt(Math.pow(v[0],2)+Math.pow(v[1],2))
                res.push({"key": "Speed", "value": vel.toFixed(2)+" Km/h"})
                break
            }
        }

        if (res.length > 0)
            return res

        return null
    }

    // Handle responsiveness when screen is resized
    onXChanged: updateRelativePosition()
    onYChanged: updateRelativePosition()

    function updateRelativePosition() {
        if (!baseTrackPanel.isAnchorActive && baseTrackPanel.visible) { // only update if not collapsed
            relativeX = x / parent.width
            relativeY = y / parent.height
        }
    }

    function repositionFromRelative() {
        if (!baseTrackPanel.isAnchorActive && baseTrackPanel.visible) {
            x = relativeX * parent.width
            y = relativeY * parent.height
        }
    }

    Connections {
        target: parent
        function onWidthChanged() { repositionFromRelative() }
        function onHeightChanged() { repositionFromRelative() }
    }

    // Handle responsiveness on the panel marker link
    function repositionMarkerAnchor() {
        if (marker && marker.updateScreenPos) {
            // By using callLater, we're deferring the update
            // of the marker anchor. This is important since
            // maximizing/restoring down the window is triggered
            // as a onWidth/HeightChanged and the map track object
            // is updated after the window has been maximized/restored.
            // Therefore, the need to defer the updateScreenPos
            // after the map object has been updated.
            Qt.callLater(marker.updateScreenPos)
        }
    }

    Connections {
        target: parent
        function onWidthChanged() { repositionMarkerAnchor() }
        function onHeightChanged() { repositionMarkerAnchor() }
    }
}
