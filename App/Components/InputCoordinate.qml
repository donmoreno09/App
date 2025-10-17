/**
 * WARNING!!
 *
 * This component is currently buggy and needs rework.
 *
 * When changing the value inside the input, it often
 * jumps to the end because onValueChanged is also being
 * invoked. I tried putting up a flag but that does not
 * solve it nor was it a nice solution.
 *
 * I think the best way here is to control everything
 * instead of using TextField.inputMask.
 */

import QtQuick 6.8

import App.Components 1.0 as UI

UI.Input {
    enum Type { Latitude, Longitude }

    readonly property var latitudeRegex: /^(?:(?:[0-8]\d)\.\d{6}° [NS]|90\.000000° [NS])$/
    readonly property var longitudeRegex: /^(?:(?:0\d{2}|1[0-7]\d)\.\d{6}° [EW]|180\.000000° [EW])$/

    property int type: InputCoordinate.Latitude

    property real value: 0

    onValueChanged: {
        const absVal = Math.abs(value).toFixed(6)
        const hemi = (type === InputCoordinate.Latitude)
            ? (value < 0 ? "S" : "N")
            : (value < 0 ? "W" : "E")
        textField.text = (type === InputCoordinate.Latitude)
            ? `${absVal.padStart(8, "0")}° ${hemi}`
            : `${absVal.padStart(9, "0")}° ${hemi}`
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
            textField.text = text.slice(0, -1) + hemi;
        }
    }

    // Update the remembered hemisphere before the input
    // becomes invalid, i.e. missing hemisphere
    textField.onTextChanged: {
        if (textField.acceptableInput) {
            _hemiRemembered = textField.text.slice(-1)

            const deg = parseFloat(textField.text.slice(0, textField.text.indexOf("°")));
            const hemi = textField.text.slice(-1);

            _manualChanged = true
            value = (hemi === "S" || hemi === "W") ? -deg : deg;
        }
    }

    textField.onEditingFinished: _fixHemisphere()
    textField.onFocusChanged: if (!textField.focus) _fixHemisphere();
}
