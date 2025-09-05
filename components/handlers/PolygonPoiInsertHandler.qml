import QtQuick 2.15
import QtPositioning 6.8
import raise.singleton.controllers 1.0
import "../models/shapes.js" as ShapeModel

BaseAreaPoiInsertHandler {
    id: handler
    property var polygon: null
    property bool isUpdatingCoordinates: false

    function calculatePolygonCenter(coordinates) {
        if (!coordinates || coordinates.length < 3) return null;

        let centerLat = 0;
        let centerLon = 0;
        let validPoints = 0;

        const pointsToUse = coordinates.length > 3 &&
            Math.abs(coordinates[0].latitude - coordinates[coordinates.length - 1].latitude) < 0.000001 &&
            Math.abs(coordinates[0].longitude - coordinates[coordinates.length - 1].longitude) < 0.000001
            ? coordinates.length - 1 : coordinates.length;

        for (let i = 0; i < pointsToUse; i++) {
            const coord = coordinates[i];
            if (coord && typeof coord.latitude === 'number' && typeof coord.longitude === 'number') {
                centerLat += coord.latitude;
                centerLon += coord.longitude;
                validPoints++;
            }
        }

        if (validPoints > 0) {
            return QtPositioning.coordinate(centerLat / validPoints, centerLon / validPoints);
        }

        return null;
    }

    Connections {
        target: drawingArea.loader.item
        ignoreUnknownSignals: true

        function onPolygonCreated(newPolygon) {
            if (topToolbar.currentMode !== 'poi-area') return
            if (topToolbar.currentPoiCategory < 0 || topToolbar.currentPoiType < 0) return

            handler.polygon = newPolygon

            let minX = Infinity, minY = Infinity, maxX = -Infinity, maxY = -Infinity;
            for (let coord of newPolygon.path) {
                const p = mapView.fromCoordinate(coord, false)
                minX = Math.min(minX, p.x);
                minY = Math.min(minY, p.y);
                maxX = Math.max(maxX, p.x);
                maxY = Math.max(maxY, p.y);
            }
            const centerPoint = Qt.point((minX + maxX)/2, (minY + maxY)/2)
            const centerCoord = mapView.toCoordinate(centerPoint)
            mapView.center = centerCoord

            polygonPoiPopup.x = (parent.width - polygonPoiPopup.width) / 2
            polygonPoiPopup.y = (parent.height - polygonPoiPopup.height) / 2

            polygonPoiPopup.setPolygonCoordinates(newPolygon.path)
            polygonPoiPopup.open()
        }
    }

    Connections {
        target: polygonPoiPopup
        ignoreUnknownSignals: true
        enabled: topToolbar.currentMode === "poi-area" && handler.savingIndex < 0

        function onPolygonChanged(coordinates) {
            if (handler.isUpdatingCoordinates) {
                return
            }

            handler.isUpdatingCoordinates = true

            handler.polygon = {
                path: coordinates
            }

            if (drawingArea && drawingArea.loader && drawingArea.loader.item) {
                if (drawingArea.loader.item.objectName === "PolygonEditor") {
                    const currentPath = drawingArea.loader.item.path
                    let needsUpdate = !currentPath || currentPath.length !== coordinates.length

                    if (!needsUpdate && currentPath) {
                        for (let i = 0; i < coordinates.length; i++) {
                            const current = currentPath[i]
                            const newCoord = coordinates[i]
                            if (!current || !newCoord ||
                                Math.abs(current.latitude - newCoord.latitude) > 0.000001 ||
                                Math.abs(current.longitude - newCoord.longitude) > 0.000001) {
                                needsUpdate = true
                                break
                            }
                        }
                    }

                    if (needsUpdate) {
                        try {
                            const editor = drawingArea.loader.item

                            if (editor.hasOwnProperty("polygon")) {
                                editor.polygon = coordinates
                            } else if (editor.hasOwnProperty("polygonPath")) {
                                editor.polygonPath = coordinates
                            } else if (editor.hasOwnProperty("vertices")) {
                                editor.vertices = coordinates
                            } else if (editor.hasOwnProperty("coordinates")) {
                                editor.coordinates = coordinates
                            } else if (editor.hasOwnProperty("path")) {
                                editor.path = coordinates
                            } else {
                                if (editor.hasOwnProperty("resetPreview")) {
                                    editor.resetPreview()
                                }

                                if (editor.hasOwnProperty("_path")) {
                                    editor._path = coordinates
                                } else if (editor.hasOwnProperty("pathPoints")) {
                                    editor.pathPoints = coordinates
                                }
                            }
                        } catch (error) {
                        }
                    }
                }
            }

            if (coordinates.length >= 3) {
                let minLat = Infinity, minLon = Infinity, maxLat = -Infinity, maxLon = -Infinity;

                for (let coord of coordinates) {
                    if (coord && typeof coord.latitude === 'number' && typeof coord.longitude === 'number') {
                        minLat = Math.min(minLat, coord.latitude);
                        minLon = Math.min(minLon, coord.longitude);
                        maxLat = Math.max(maxLat, coord.latitude);
                        maxLon = Math.max(maxLon, coord.longitude);
                    }
                }

                if (minLat !== Infinity && minLon !== Infinity) {
                    const centerLat = (minLat + maxLat) / 2;
                    const centerLon = (minLon + maxLon) / 2;
                    const centerCoord = QtPositioning.coordinate(centerLat, centerLon);
                    mapView.center = centerCoord;
                }
            }

            Qt.callLater(function() {
                handler.isUpdatingCoordinates = false
            })
        }

        function onSaveClicked(details) {
            if (!handler.polygon) return

            let finalPath = handler.polygon.path
            if (details.coordinates && details.coordinates.length > 0) {
                finalPath = details.coordinates
            }

            if (finalPath.length < 3) {
                return
            }

            const data = ShapeModel.createPolygon(details.id, details.label, finalPath)

            const polygonCenter = calculatePolygonCenter(finalPath);
            if (polygonCenter) {
                if (data.hasOwnProperty("labelPosition")) {
                    data.labelPosition = polygonCenter;
                } else if (data.hasOwnProperty("textPosition")) {
                    data.textPosition = polygonCenter;
                } else if (data.geometry && data.geometry.hasOwnProperty("coordinate")) {
                    data.geometry.coordinate = {
                        x: polygonCenter.longitude,
                        y: polygonCenter.latitude
                    };
                }
            }

            handler.prefillData(data, details)

            if (details.category && details.category.name) {
                data.categoryName = details.category.name
            }
            if (details.type && details.type.value) {
                data.typeName = details.type.value
            }
            if (details.healthStatus && details.healthStatus.value) {
                data.healthStatusName = details.healthStatus.value
            }
            if (details.operationalState && details.operationalState.value) {
                data.operationalStateName = details.operationalState.value
            }

            if (!data.label || !details.category || !details.type) {
                return
            }

            try {
                handler.savingIndex = staticPoiLayerInstance.businessLogic.poiModel.rowCount()
                staticPoiLayerInstance.businessLogic.poiModel.append(data)
                PoiController.savePoiFromQml(data)
            } catch (error) {
                handler.savingIndex = -1
                return
            }

            if (drawingArea.loader.item && drawingArea.loader.item.objectName === "PolygonEditor") {
                drawingArea.loader.item.resetPreview()
            }

            handler.resetState()
        }

        function onClosed() {
            handler.resetState()
        }
    }

    function resetState() {
        if (drawingArea.loader.item && drawingArea.loader.item.objectName === "PolygonEditor") {
            drawingArea.loader.item.resetPreview()
        }

        handler.polygon = null
        handler.isUpdatingCoordinates = false
    }
}
