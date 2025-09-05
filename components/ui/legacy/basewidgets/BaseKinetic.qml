import QtQuick
import qml.commons.monotonic.time 1.0

Rectangle {
    id: baseKinetic

    property bool kIsActive: true
    property real kPulseFactor: 1.0
    property real kThresholdFactor: 1.0
    property real kFrictionFactor: 7.0
    property real kSteadyT: Math.pow(kThresholdFactor, 2.0)
    property var kPotentialE: Qt.vector2d(0, 0)
    property var kPreviousTimes: []
    property var kPreviousPoints: []

    property var kDeltaP: Qt.vector2d(0, 0)
    property var kPulse: Qt.vector2d(0, 0)

    property real deltaFrameTime: 0.0
    property real currentFrameTime: 0.0
    property real lastFrameTime: 0.0

    MonotonicTime {
        id: time
    }

    Timer {
        id: kTimer
        interval: 1;
        running: false;
        repeat: true
        onTriggered: doKinetic()
    }

    function kTranslationChange(delta, parentX, parentY)
    {
        if (kIsActive && !kTimer.running)
            kMove(parentX, parentY)
    }

    function kGrabChange(transition, eventPoint, parentX, parentY)
    {
        if(kIsActive && transition === PointerDevice.GrabExclusive)
        {
            kDown(parentX, parentY)
        }

        else if (kIsActive && transition === PointerDevice.UngrabExclusive)
        {
            kUp(parentX, parentY)
        }
    }

    function updateDelta()
    {
        lastFrameTime = currentFrameTime
        currentFrameTime = time.monotonicFractSecs()
        deltaFrameTime = currentFrameTime - lastFrameTime
    }

    function doKinetic()
    {
        if (kIsActive)
            var res = kStep()
        if (res)
        {
            x += res.x
            y += res.y

            if (res.x === 0 && res.y === 0)
            {
                kReset()
            }
        }
    }

    function kReset()
    {
        kTimer.stop()
        kPotentialE.x = 0
        kPotentialE.y = 0

        kPreviousTimes= []
        kPreviousPoints= []

        kDeltaP= Qt.vector2d(0, 0)
        kPulse= Qt.vector2d(0, 0)
    }

    function kDown(x, y)
    {
        kReset()
        updateDelta()
        kPreviousTimes.push(time.monotonicFractSecs())
        kPreviousPoints.push([x, y])
    }

    function kUp(x, y)
    {
        updateDelta()
        var elapsed = time.monotonicFractSecs()
        var dt = 1000 * (elapsed - kPreviousTimes[0])
        if (dt > 250.0)
            return

        var dpx = x - kPreviousPoints[0][0]
        var dpy = y - kPreviousPoints[0][1]
        kPulse.x = dpx / Math.max(1000.0 / 60.0, dt / (1000.0 / 60.0))
        kPulse.y = dpy / Math.max(1000.0 / 60.0, dt / (1000.0 / 60.0))

        if (kPulse)
        {
            kPotentialE.x = kPulse.x*kPulseFactor
            kPotentialE.y = kPulse.y*kPulseFactor
        }

        kTimer.start()
    }

    function kMove(x, y)
    {
        updateDelta()
        kPreviousTimes.push(time.monotonicFractSecs())
        kPreviousPoints.push([x, y])

        if(kPreviousPoints.length >= 5)
        {
            kPreviousTimes.splice(0,1)
            kPreviousPoints.splice(0,1)
        }
    }

    function kSteady()
    {
        if (!kPotentialE)
            return true

        var lengthSquared = kPotentialE.dotProduct(kPotentialE)
        return lengthSquared <= kSteadyT
    }

    function kStep()
    {
        if(kSteady())
            return Qt.vector2d(0, 0)

        updateDelta()
        var deltaFt = currentFrameTime - lastFrameTime
        kPotentialE.x /= (1.0 + (kFrictionFactor * deltaFt))
        kPotentialE.y /= (1.0 + (kFrictionFactor * deltaFt))

        return kPotentialE
    }
}
