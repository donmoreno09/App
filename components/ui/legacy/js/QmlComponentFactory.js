
var component;
var widget;

function create(parent, params, componentName) {
    component = Qt.createComponent(componentName);
    if (component.status === Component.Ready)
        widget = finishCreation(parent, params);
    else
        component.statusChanged.connect(finishCreation);

    return widget


}




function finishCreation(parent, params) {
    if (component.status === Component.Ready) {
        widget = component.createObject(parent, params);
        if (widget === null) {
            // Error Handling
            console.log("Error creating object");
        }
    } else if (component.status === Component.Error) {
        // Error Handling
        console.log("Error loading component:", component.errorString());
    }

    return widget
}
