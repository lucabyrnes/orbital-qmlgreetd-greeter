import QtQuick 2.15

Item {
    id: root

    property color primaryColor: "#22B8CF"
    property color secondaryColor: "#DCE6EC"

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()

            // The source drawing uses a 311 x 385 portrait view box. Scale it
            // uniformly and center it so its proportions survive in this item.
            // Extra source-space padding keeps rounded stroke caps inside the
            // Canvas instead of clipping the upper radio wave.
            const sourceWidth = 311
            const sourceHeight = 385
            const sourcePadding = 8
            const paddedWidth = sourceWidth + sourcePadding * 2
            const paddedHeight = sourceHeight + sourcePadding * 2
            const scale = Math.min(width / paddedWidth, height / paddedHeight)
            ctx.translate((width - sourceWidth * scale) / 2,
                          (height - sourceHeight * scale) / 2)
            ctx.scale(scale, scale)
            ctx.lineCap = "round"
            ctx.lineJoin = "round"

            // Cyan pedestal and base, traced from the supplied reference.
            ctx.beginPath()
            ctx.moveTo(30.5, 364.728)
            ctx.bezierCurveTo(79.4921, 364.131, 150.528, 363.611, 154, 365)
            ctx.bezierCurveTo(158, 366.6, 162, 378.666, 163.5, 384.5)
            ctx.lineTo(0.5, 384.5)
            ctx.bezierCurveTo(0.5, 378.5, 6.83333, 369, 10, 365)
            ctx.bezierCurveTo(16.1141, 364.912, 23.0523, 364.819, 30.5, 364.728)

            ctx.moveTo(30.5, 364.728)
            ctx.bezierCurveTo(37.5, 342.152, 53.1, 295.2, 59.5, 288)
            ctx.moveTo(59.5, 288)
            ctx.bezierCurveTo(70.3, 288, 95.8333, 288, 105, 288)
            ctx.moveTo(59.5, 288)
            ctx.bezierCurveTo(57.6667, 280.166, 56.5, 258.5, 69, 248)
            ctx.moveTo(105, 288)
            ctx.bezierCurveTo(111.333, 308.166, 121.3, 352.538, 124.5, 364.138)
            ctx.moveTo(105, 288)
            ctx.bezierCurveTo(105.167, 286.669, 106.6, 282.008, 111, 274.004)
            ctx.strokeStyle = root.primaryColor
            ctx.lineWidth = 10.5
            ctx.stroke()

            // Cyan reflector: overlapping curves form the tilted dish rim and
            // its broad lower bowl exactly as in the reference silhouette.
            ctx.beginPath()
            ctx.moveTo(111, 274.004)
            ctx.bezierCurveTo(93.1392, 266.473, 78.4409, 256.45, 69, 248)
            ctx.bezierCurveTo(-9.8, 178, 25.5, 91.4998, 45, 73.9998)
            ctx.moveTo(45, 73.9998)
            ctx.bezierCurveTo(52, 120, 160.5, 246.5, 233, 262.5)
            ctx.moveTo(45, 73.9998)
            ctx.bezierCurveTo(54.6667, 62.4998, 90.5, 55.3998, 156.5, 107)
            ctx.moveTo(233, 262.5)
            ctx.bezierCurveTo(205, 293, 144.219, 288.011, 111, 274.004)
            ctx.moveTo(233, 262.5)
            ctx.bezierCurveTo(266.5, 242.5, 228.333, 181.871, 206, 151.5)
            ctx.strokeStyle = root.primaryColor
            ctx.lineWidth = 10.5
            ctx.stroke()

            // Light feed arm and receiver.
            ctx.beginPath()
            ctx.moveTo(164.5, 173.5)
            ctx.lineTo(220, 107)
            ctx.bezierCurveTo(224.167, 97.8331, 227.2, 80.5998, 206, 84.9998)
            ctx.bezierCurveTo(186.8, 101, 152.333, 131, 137.5, 144)
            ctx.strokeStyle = root.secondaryColor
            ctx.lineWidth = 10.5
            ctx.stroke()

            // Light radio waves.
            ctx.beginPath()
            ctx.moveTo(213.5, 37.9998)
            ctx.bezierCurveTo(232.5, 40.3331, 270.5, 55.5998, 270.5, 97.9998)
            ctx.strokeStyle = root.secondaryColor
            ctx.lineWidth = 10.5
            ctx.stroke()

            ctx.beginPath()
            ctx.moveTo(216, 0.499786)
            ctx.bezierCurveTo(244.5, 1.33312, 303.2, 21.9998, 310, 97.9998)
            ctx.strokeStyle = root.secondaryColor
            ctx.lineWidth = 10.5
            ctx.stroke()
        }

        Connections {
            target: root
            function onPrimaryColorChanged() { canvas.requestPaint() }
            function onSecondaryColorChanged() { canvas.requestPaint() }
        }
    }
}
