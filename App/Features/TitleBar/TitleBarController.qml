pragma Singleton
import QtQuick 6.8

QtObject {
    id: titleBarController

    property string currentTitle: "Overview"

    function setTitle(title) {
        if (currentTitle !== title) {
            currentTitle = title
        }
    }
}
