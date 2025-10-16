import QtQuick
import QtQuick.Shapes

Shape {
    id: root
    visible: false

    ShapePath {
        strokeWidth: 0

        // Fill the shape's rectangle
        startX: 0; startY: 0
        PathLine { x: root.width;  y: 0 }
        PathLine { x: root.width;  y: root.height }
        PathLine { x: 0;           y: root.height }
        PathLine { x: 0;           y: 0 }

        // Linear gradient
        // x1,y1 and x2,y2 define the "gradient axis" which is the line along which colors
        // interpolate. Lines of equal color ("bands") are "perpendicular" to this axis.
        //
        // To make the bright band run exactly along the window diagonal (bottom-left -> top-right)
        // for any width/height, set the axis to be the perpendicular line through the center.
        // For a WxH item, the center is (W/2, H/2). A line perpendicular to that diagonal has
        // slope W/H, so stepping ±(H/2, W/2) from the center gives the axis endpoints below.
        //
        // The endpoints may lie outside the item and that’s fine since Qt pads the gradient beyond [0, 1].
        // With stops at 0, 0.5, 1 the highlight sits on the diagonal of the screen.
        fillGradient: LinearGradient {
            x1: root.width/2  - root.height/2
            y1: root.height/2 - root.width/2
            x2: root.width/2  + root.height/2
            y2: root.height/2 + root.width/2

            GradientStop { position: 0.00; color: "#000000" }
            GradientStop { position: 0.50; color: "#001C35" }
            GradientStop { position: 1.00; color: "#000000" }
        }

    }
}
