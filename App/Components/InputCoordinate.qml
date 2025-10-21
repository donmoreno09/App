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
 *
 * UPDATE: For now, the input should be controlled by
 * this component. Use the setText method to set the text.
 */

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

    /**
     * Formats and sets the field given a numeric coordinate.
     * - Clamps to valid ranges (lat: [-90, 90], lon: [-180, 180]).
     * - Pads integer part (lat: 2, lon: 3).
     * - Uses N/S for latitude, E/W for longitude; 0 uses the positive hemisphere.
     */
    function setText(num) {
        if (num === null || num === undefined || !isFinite(num))
            return

        const isLat = (type === InputCoordinate.Latitude)
        const maxAbs = isLat ? 90 : 180
        const hemi = (num < 0)
                     ? (isLat ? "S" : "W")
                     : (isLat ? "N" : "E")

        let absDeg = Math.min(Math.abs(num), maxAbs)
        // Force 6 decimals as string
        const fixed = absDeg.toFixed(6)
        const dot = fixed.indexOf(".")
        const intPart = dot === -1 ? fixed : fixed.slice(0, dot)
        const fracPart = dot === -1 ? "000000" : fixed.slice(dot + 1)

        const pad = isLat ? 2 : 3
        const paddedInt = intPart.padStart(pad, "0")

        const formatted = paddedInt + "." + fracPart + "° " + hemi
        textField.text = formatted
        _hemiRemembered = hemi
    }
}
