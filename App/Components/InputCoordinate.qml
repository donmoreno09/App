import QtQuick 6.8

import App.Components 1.0 as UI

UI.Input {
    enum Type { Latitude, Longitude }

    readonly property var latitudeRegex: /^(?:(?:[0-8]\d)\.\d{6}° [NS]|90\.000000° [NS])$/
    readonly property var longitudeRegex: /^(?:(?:0\d{2}|1[0-7]\d)\.\d{6}° [EW]|180\.000000° [EW])$/

    property int type: InputCoordinate.Latitude

    readonly property real value: {
        const text = textField.text
        const deg = parseFloat(text.slice(0, text.indexOf("°")));
        const hemi = text.slice(-1);
        return (hemi === "S" || hemi === "W") ? -deg : deg;
    }

    textField.inputMask: (type === InputCoordinate.Latitude) ? "99.999999° >A; " : "999.999999° >A; "
    textField.text: (type === InputCoordinate.Latitude) ? "00.000000° N" : "000.000000° E"
    textField.overwriteMode: true

    textField.validator: RegularExpressionValidator {
        regularExpression: (type === InputCoordinate.Latitude) ? latitudeRegex : longitudeRegex
    }

    // Hemisphere Fix Logic
    // The main idea is that when the user leaves
    // the input, it should make sure that hemisphere
    // letter is correct and reappears.
    property string _hemiRemembered: (type === InputCoordinate.Type.Latitude) ? "N" : "E"

    function _getHemiRegex() { return (type === InputCoordinate.Type.Latitude) ? /[NS]/ : /[EW]/ }
    function _getDefaultHemi() { return (type === InputCoordinate.Type.Latitude) ? "N" : "E" }
    function _fixHemisphere() {
        let text = textField.text;
        const last = text.slice(-1);
        if (!_getHemiRegex().test(last)) {
            const hemi = _hemiRemembered || _getDefaultHemi();
            textField.text = text.slice(0, -1) + hemi; // put back valid hemi
        }
    }

    // Update the remembered hemisphere before the input
    // becomes invalid, i.e. missing hemisphere
    textField.onTextChanged: if (textField.acceptableInput) _hemiRemembered = textField.text.slice(-1)

    textField.onEditingFinished: _fixHemisphere()
    textField.onFocusChanged: if (!textField.focus) _fixHemisphere();
}
