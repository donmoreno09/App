import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8
import App.Components 1.0 as UI
import App.Themes 1.0

UI.FloatingWindow {
    width: 1200
    height: 740
    visible: true

    property var parentWindow: null
    windowWidth: parentWindow ? parentWindow.width : 1200
    windowHeight: parentWindow ? parentWindow.height : 740
    property string title: "CSV Viewer"
    property string csvSource: "qrc:/App/assets/resources/data.csv"
    property var csvHeaders: []
    property var csvData: []
    property var colWidths: []

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.spacing.s2
        anchors.margins: Theme.spacing.s2

        Label {
            text: title
            font.bold: true
            font.pixelSize: Theme.typography.fontSize200
            color: Theme.colors.white500
            Layout.fillWidth: true
        }

        Item { // Contenitore fisso per header + dati
            Layout.fillWidth: true
            Layout.fillHeight: true

            // Header
            Row {
                id: headerRow
                y: 0
                spacing: 8
            }

            // Flickable principale
            Flickable {
                id: flickableData
                anchors.top: headerRow.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                contentWidth: columnData.width
                contentHeight: columnData.height
                clip: true

                onContentXChanged: headerRow.x = -contentX

                Column {
                    id: columnData
                    spacing: 2
                }

                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AlwaysOn }
                ScrollBar.horizontal: ScrollBar { policy: ScrollBar.AlwaysOn }
            }
        }
    }

    function loadCsv(url) {
        csvHeaders = []
        csvData = []
        colWidths = []

        var xhr = new XMLHttpRequest()
        xhr.open("GET", url)
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                var lines = xhr.responseText.split("\n").filter(l => l.trim())
                if (!lines.length) return

                csvHeaders = lines[0].split(";").map(s => s.trim().replace(/_/g,' ')
                            .replace(/([a-z])([A-Z])/g, '$1 $2'))
                csvData = []

                colWidths = csvHeaders.map(h => h.length*8 + 40)

                for (var i=1; i<Math.min(lines.length,100); i++){
                    var row = lines[i].split(";").map(s => s.trim())
                    csvData.push(row)
                    for (var c=0; c<row.length; c++){
                        let w = row[c].length*8+40
                        if (w>colWidths[c]) colWidths[c] = w
                    }
                }

                populateTable()
            }
        }
        xhr.send()
    }

    function populateTable() {
        // svuota
        for (let i=headerRow.children.length-1;i>=0;i--) headerRow.children[i].destroy()
        for (let i=columnData.children.length-1;i>=0;i--) columnData.children[i].destroy()

        // header
        for (let i=0;i<csvHeaders.length;i++){
            Qt.createQmlObject(`
                import QtQuick 6.8
                import QtQuick.Controls 6.8
                Label {
                    text: "${csvHeaders[i]}"
                    font.bold: true
                    color: "white"
                    width: ${colWidths[i]}
                    height: 30
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    background: Rectangle { color: "#444"; radius: 3 }
                }`, headerRow)
        }

        // dati
        for (let r=0;r<csvData.length;r++){
            let row = Qt.createQmlObject(`import QtQuick 6.8; import QtQuick.Controls 6.8; Row { spacing: 8 }`, columnData)
            for (let c=0;c<csvHeaders.length;c++){
                let value = csvData[r][c]||""
                Qt.createQmlObject(`
                    import QtQuick 6.8
                    import QtQuick.Controls 6.8
                    Label {
                        text: "${value.replace(/"/g,'\\\"')}"
                        color: "lightgray"
                        width: ${colWidths[c]}
                        height: 28
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                        background: Rectangle { color: ((${r}%2==0) ? "#222" : "#333"); radius: 2 }
                    }`, row)
            }
        }
    }

    Component.onCompleted: loadCsv(csvSource)
}
