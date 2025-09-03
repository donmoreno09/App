pragma Singleton
import QtQuick 6.8

/*!
    \qmltype TitleController
    \brief Simple singleton to manage application title state

    This lightweight controller provides just what you need:
    - Single setTitle() method
    - Automatic property binding updates
    - No over-engineering
*/
QtObject {
    id: titleController

    // Current title - components bind to this property
    property string currentTitle: "Overview"

    // Simple method to update title
    function setTitle(title) {
        if (currentTitle !== title) {
            currentTitle = title
            console.log("Title changed to:", title)
        }
    }

    // Optional: Reset to default
    function resetTitle() {
        setTitle("Overview")
    }
}
