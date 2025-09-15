import QtQuick 6.8
import QtQuick.Layouts 6.8
import App.Themes 1.0

ColumnLayout {
    anchors.centerIn: parent
    spacing: Theme.spacing.s4

    Text {
        text: "PP Fraktion Sans Light - " + font.family
        font.family: Theme.typography.familySans
        font.pixelSize: Theme.typography.sizeLg
        font.weight: Theme.typography.weightLight
        color: Theme.colors.text
    }

    Text {
        text: "PP Fraktion Sans Bold - " + font.family
        font.family: Theme.typography.familySans
        font.pixelSize: Theme.typography.sizeLg
        font.weight: Theme.typography.weightBold
        color: Theme.colors.text
    }

    Text {
        text: "PP Fraktion Mono Regular - " + font.family
        font.family: Theme.typography.familyMono
        font.pixelSize: Theme.typography.sizeLg
        font.weight: Theme.typography.weightNormal
        color: Theme.colors.text
    }

    Text {
        text: "PP Fraktion Mono Bold - " + font.family
        font.family: Theme.typography.familyMono
        font.pixelSize: Theme.typography.sizeLg
        font.weight: Theme.typography.weightBold
        color: Theme.colors.text
    }
}
