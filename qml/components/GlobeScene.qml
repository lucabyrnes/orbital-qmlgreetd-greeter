import QtQuick 2.15
import QtQuick.Effects
import QtQuick3D
import "OrbitalMath.js" as OrbitalMath

Item {
    id: root

    property real u: 10
    property color cyan: "#22B8CF"
    property color magenta: "#D85A9F"
    property color green: "#55C985"
    property color unavailable: "#60788A"

    readonly property alias satelliteLabels: satelliteLabelModel
    readonly property alias satelliteRangeModel: satelliteRangeModel
    readonly property int totalSatelliteCount: satelliteDefinitions.length
    readonly property int visibleSatelliteLabelLimit: 9
    property int satellitesInUse: 0
    property real groundScreenX: 0
    property real groundScreenY: 0
    property real globeScreenCenterX: width * 0.5
    property real globeScreenCenterY: height * 0.5
    property bool groundVisible: true
    property string groundName: "LOCAL TERMINAL"
    property string groundStatus: "AWAITING AUTH"

    property real sceneTime: 0
    property real earthRadiusKm: 6371.0
    property real globeSceneRadius: 172.0
    property vector3d globeCenter: Qt.vector3d(-260, 68, 0)

    // Static cinematic globe image alignment controls.
    // Tune these values while the 3D globe remains visible underneath:
    // - staticGlobeImageOffsetX / staticGlobeImageOffsetY: absolute pixel nudges
    //   relative to the projected 3D globe center on screen
    // - staticGlobeImageScale: size multiplier based on screen height
    // - staticGlobeImageOpacity: temporary alignment opacity, currently 50%
    // - staticGlobeImageDebugColorEnabled: toggles the temporary red tint on/off
    // - staticGlobeImageTintColor: temporary red tint for easy alignment
    // Disable renderGlobeModelEnabled and renderAtmosphereShaderEnabled after
    // image alignment to save GPU work.
    property bool renderGlobeModelEnabled: false
    property bool renderAtmosphereShaderEnabled: false
    property bool staticGlobeImageEnabled: true
    property bool staticGlobeImageDebugColorEnabled: false
    property real staticGlobeImageOffsetX: -4
    property real staticGlobeImageOffsetY: 0
    property real staticGlobeImageScale: 0.83
    property real staticGlobeImageOpacity: 1
    property color staticGlobeImageTintColor: "#ff0000"

    // Custom Quick3D atmosphere shell tuning. The shader uses these values to
    // build a view-dependent Fresnel rim plus a faint dayside glow around Earth.
    property color atmosphereColor: '#2f93ff'
    property real atmosphereRadiusScale: 1.01
    property real atmosphereOpacity: 0.3
    property real atmosphereRimPower: 4
    property real atmosphereInnerGlow: 3
    property vector3d sunLightEuler: Qt.vector3d(-45, 155, 0)
    property vector3d atmosphereSunDirection: root.directionalLightSourceVector(root.sunLightEuler)

    property var cachedOrbitPaths: []
    property bool orbitPathsDirty: true

    // Ground station coordinates. Defaults are near the US east coast/New York area.
    property real groundLatDeg: 4
    property real groundLonDeg: -187

    // Static globe orientation. Tune these values to align the texture artwork with
    // the projected ground station and camera composition.
    property vector3d globeEulerRotation: Qt.vector3d(-10, 125, 20)

    // Circular orbit definitions using close-in visual LEO altitudes.
    // Altitudes are in km and control visual orbit radius through OrbitalMath.
    readonly property int orbitSegmentsPerOrbit: 128
    readonly property var orbitDefinitions: [
        { name: "EQUATORIAL LEO", altitudeKm:  900, inclinationDeg: 210, raanDeg:  10, color: root.cyan,    opacity: 0.4 },
        { name: "INCLINED LEO",   altitudeKm: 1000, inclinationDeg: 130, raanDeg:   0, color: root.cyan,    opacity: 0.4 },
        { name: "POLAR LEO",      altitudeKm: 1280, inclinationDeg:  88, raanDeg: 108, color: root.cyan,    opacity: 0.4 }
    ]

    readonly property var satelliteDefinitions: [
        { name: "EQ-LEO-1",  role: "EQUATORIAL LEO", altitudeKm:  900, inclinationDeg:  210, raanDeg:  10, phaseDeg:  30, speed: 1.04 },
        { name: "EQ-LEO-2",  role: "EQUATORIAL LEO", altitudeKm:  900, inclinationDeg:  210, raanDeg:  10, phaseDeg:  90, speed: 1.04 },
        { name: "EQ-LEO-3",  role: "EQUATORIAL LEO", altitudeKm:  900, inclinationDeg:  210, raanDeg:  10, phaseDeg: 140, speed: 1.04 },

        { name: "INC-LEO-1", role: "INCLINED LEO",   altitudeKm:  1000, inclinationDeg: 130, raanDeg:  0, phaseDeg: 150, speed: 0.88 },
        { name: "INC-LEO-2", role: "INCLINED LEO",   altitudeKm:  1000, inclinationDeg: 130, raanDeg:  0, phaseDeg: 120, speed: 0.88 },
        { name: "INC-LEO-3", role: "INCLINED LEO",   altitudeKm:  1000, inclinationDeg: 130, raanDeg:  0, phaseDeg:  85, speed: 0.88 },

        { name: "POL-LEO-1", role: "POLAR LEO",      altitudeKm: 1280, inclinationDeg: 88, raanDeg: 108, phaseDeg: 290, speed: -0.72 },
        { name: "POL-LEO-2", role: "POLAR LEO",      altitudeKm: 1280, inclinationDeg: 88, raanDeg: 108, phaseDeg:  60, speed: -0.72 },
        { name: "POL-LEO-3", role: "POLAR LEO",      altitudeKm: 1280, inclinationDeg: 88, raanDeg: 108, phaseDeg:  30, speed: -0.72 }
    ]

    function satelliteScene(sat) {
        return root.rotateAroundGlobe(OrbitalMath.satelliteScenePosition(
                                          root.globeCenter,
                                          root.globeSceneRadius,
                                          sat.altitudeKm,
                                          sat.inclinationDeg,
                                          sat.raanDeg,
                                          sat.phaseDeg + root.sceneTime * sat.speed))
    }

    function groundScene() {
        return root.globeSurfaceScenePosition(root.groundLatDeg, root.groundLonDeg, 2.0)
    }

    function orbitPoint(orbit, deg) {
        return root.rotateAroundGlobe(OrbitalMath.satelliteScenePosition(
                                          root.globeCenter,
                                          root.globeSceneRadius,
                                          orbit.altitudeKm,
                                          orbit.inclinationDeg,
                                          orbit.raanDeg,
                                          deg))
    }

    function globeRotate(v) {
        let rotated = OrbitalMath.rotateX(v, root.globeEulerRotation.x)
        rotated = OrbitalMath.rotateY(rotated, root.globeEulerRotation.y)
        rotated = OrbitalMath.rotateZ(rotated, root.globeEulerRotation.z)
        return rotated
    }

    function directionalLightSourceVector(euler) {
        // Qt Quick3D directional lights illuminate along their rotated -Z axis.
        // The atmosphere shader wants the inverse vector: surface-to-sun.
        let lightForward = Qt.vector3d(0, 0, -1)
        lightForward = OrbitalMath.rotateX(lightForward, euler.x)
        lightForward = OrbitalMath.rotateY(lightForward, euler.y)
        lightForward = OrbitalMath.rotateZ(lightForward, euler.z)
        return Qt.vector3d(-lightForward.x, -lightForward.y, -lightForward.z)
    }

    function rotateAroundGlobe(p) {
        const local = Qt.vector3d(p.x - root.globeCenter.x,
                                  p.y - root.globeCenter.y,
                                  p.z - root.globeCenter.z)
        const rotated = root.globeRotate(local)
        return Qt.vector3d(root.globeCenter.x + rotated.x,
                           root.globeCenter.y + rotated.y,
                           root.globeCenter.z + rotated.z)
    }

    function globeSurfaceScenePosition(latDeg, lonDeg, surfaceLift) {
        const unit = root.globeRotate(OrbitalMath.llaToUnit(latDeg, lonDeg))
        const radius = root.globeSceneRadius + (surfaceLift || 0)
        return Qt.vector3d(root.globeCenter.x + unit.x * radius,
                           root.globeCenter.y + unit.y * radius,
                           root.globeCenter.z + unit.z * radius)
    }

    function groundFrame() {
        const lonRad = root.groundLonDeg * Math.PI / 180.0
        const up = root.globeRotate(OrbitalMath.llaToUnit(root.groundLatDeg, root.groundLonDeg))
        const east = root.globeRotate(Qt.vector3d(-Math.sin(lonRad), 0, Math.cos(lonRad)))
        const north = OrbitalMath.cross(up, east)
        return { east: east, north: north, up: up }
    }

    function lookAnglesFromGround(groundPosition, satellitePosition) {
        const frame = root.groundFrame()
        const rho = Qt.vector3d(satellitePosition.x - groundPosition.x,
                                satellitePosition.y - groundPosition.y,
                                satellitePosition.z - groundPosition.z)
        const range = Math.max(1e-9, OrbitalMath.norm(rho))
        const e = OrbitalMath.dot(rho, frame.east)
        const n = OrbitalMath.dot(rho, frame.north)
        const u = OrbitalMath.dot(rho, frame.up)
        let azimuth = Math.atan2(e, n) * 180.0 / Math.PI
        if (azimuth < 0)
            azimuth += 360.0

        const elevation = Math.asin(Math.max(-1, Math.min(1, u / range))) * 180.0 / Math.PI
        return { azimuth: azimuth, elevation: elevation, rangeScene: range }
    }

    function statusColor(state) {
        if (state === "ACTIVE") return root.green
        if (state === "ACQUIRING") return root.magenta
        return root.unavailable
    }

    function statusRank(state) {
        if (state === "ACTIVE") return 0
        if (state === "ACQUIRING") return 1
        return 3
    }

    function topSatelliteLabelIndexes(candidates) {
        const selected = []
        const selectedByIndex = ({})

        function candidateSort(a, b) {
            const aDistanceFromZenith = Math.abs(90.0 - a.elevation)
            const bDistanceFromZenith = Math.abs(90.0 - b.elevation)
            if (Math.abs(aDistanceFromZenith - bDistanceFromZenith) > 0.001)
                return aDistanceFromZenith - bDistanceFromZenith
            if (Math.abs(a.elevation - b.elevation) > 0.001)
                return b.elevation - a.elevation
            return a.rangeScene - b.rangeScene
        }

        candidates.sort(candidateSort)

        // Choose the top N satellites by elevation, where "top" means closest
        // to zenith (90 degrees). Visibility is applied after this ranking so
        // off-screen or occluded top-N satellites do not allow lower-ranked
        // satellites to take their label slots.
        for (let j = 0; j < candidates.length && j < root.visibleSatelliteLabelLimit; ++j) {
            const candidate = candidates[j]
            if (!candidate.visible || selectedByIndex[candidate.index])
                continue

            selected.push(candidate.index)
            selectedByIndex[candidate.index] = true
        }

        return selectedByIndex
    }

    function localIndexForSegment(segmentIndex) {
        return segmentIndex % root.orbitSegmentsPerOrbit
    }

    function isSatelliteApproachingRange(sat, currentElevation) {
        const g = groundScene()
        const futureSat = {
            altitudeKm: sat.altitudeKm,
            inclinationDeg: sat.inclinationDeg,
            raanDeg: sat.raanDeg,
            phaseDeg: sat.phaseDeg + 0.25 * sat.speed,
            speed: sat.speed
        }
        const futureLook = root.lookAnglesFromGround(g, satelliteScene(futureSat))
        return futureLook.elevation > currentElevation
    }

    function refreshProjectedMarkers() {
        syncSatelliteLabelModel()

        const globeCenterScreen = view.mapFrom3DScene(root.globeCenter)
        root.globeScreenCenterX = globeCenterScreen.x
        root.globeScreenCenterY = globeCenterScreen.y

        const g = groundScene()
        const gs = view.mapFrom3DScene(g)
        const groundOcc = OrbitalMath.screenOccludedBySphere(camera.position, g, root.globeCenter, root.globeSceneRadius * 0.98)
        root.groundScreenX = gs.x
        root.groundScreenY = gs.y
        root.groundVisible = !groundOcc && gs.x > -root.u*8 && gs.x < root.width + root.u*8 && gs.y > -root.u*8 && gs.y < root.height + root.u*8
        const rangedSatellites = []
        const labelCandidates = []
        let activeCount = 0

        for (let i = 0; i < root.satelliteDefinitions.length; ++i) {
            const sat = root.satelliteDefinitions[i]
            const s = satelliteScene(sat)
            const screen = view.mapFrom3DScene(s)
            const look = root.lookAnglesFromGround(g, s)
            const occluded = OrbitalMath.screenOccludedBySphere(camera.position, s, root.globeCenter, root.globeSceneRadius * 0.98)
            const state = OrbitalMath.statusFromGeometry(look.elevation, occluded, isSatelliteApproachingRange(sat, look.elevation))
            const snr = OrbitalMath.snrFromElevation(look.elevation)
            const visible = !occluded
                    && screen.x > -root.u * 18
                    && screen.x < root.width + root.u * 18
                    && screen.y > -root.u * 18
                    && screen.y < root.height + root.u * 18
            satelliteLabelModel.setProperty(i, "x", screen.x)
            satelliteLabelModel.setProperty(i, "y", screen.y)
            satelliteLabelModel.setProperty(i, "visible", false)
            satelliteLabelModel.setProperty(i, "accent", String(root.statusColor(state)))
            satelliteLabelModel.setProperty(i, "status", state)

            labelCandidates.push({
                index: i,
                name: sat.name,
                elevation: look.elevation,
                visible: visible,
                rangeScene: look.rangeScene
            })

            if (state !== "NO LOS") {
                if (state === "ACTIVE")
                    activeCount += 1

                rangedSatellites.push({
                    name: sat.name,
                    elevation: Math.max(0, look.elevation),
                    snr: snr,
                    state: state,
                    accent: root.statusColor(state),
                    rank: root.statusRank(state)
                })
            }
        }

        const visibleLabelIndexes = root.topSatelliteLabelIndexes(labelCandidates)
        for (let labelIndex = 0; labelIndex < satelliteLabelModel.count; ++labelIndex)
            satelliteLabelModel.setProperty(labelIndex, "visible", !!visibleLabelIndexes[labelIndex])

        rangedSatellites.sort(function(a, b) {
            if (a.rank !== b.rank)
                return a.rank - b.rank
            return b.elevation - a.elevation
        })

        satelliteRangeModel.clear()
        for (let j = 0; j < rangedSatellites.length; ++j) {
            const ranged = rangedSatellites[j]
            satelliteRangeModel.append({
                name: ranged.name,
                elevation: Math.round(ranged.elevation),
                snr: ranged.snr.toFixed(1),
                linkState: ranged.state,
                accent: String(ranged.accent)
            })
        }
        root.satellitesInUse = activeCount
    }

    function syncSatelliteLabelModel() {
        while (satelliteLabelModel.count < root.satelliteDefinitions.length) {
            const sat = root.satelliteDefinitions[satelliteLabelModel.count]
            satelliteLabelModel.append({
                name: sat.name,
                status: "NO LOS",
                x: 0,
                y: 0,
                visible: true,
                accent: String(root.unavailable)
            })
        }

        for (let i = 0; i < root.satelliteDefinitions.length; ++i) {
            const sat = root.satelliteDefinitions[i]
            if (satelliteLabelModel.get(i).name !== sat.name)
                satelliteLabelModel.setProperty(i, "name", sat.name)
        }
    }

    NumberAnimation on sceneTime {
        from: 0
        to: 220
        duration: 300000
        loops: Animation.Infinite
    }

    Timer {
    id: satelliteUpdateTimer
    interval: 50
    running: true
    repeat: true

        onTriggered: {
            root.refreshProjectedMarkers()
        }
    }

    Timer {
    id: initialOrbitPaintTimer
    interval: 100
    running: true
    repeat: false

        onTriggered: {
            root.orbitPathsDirty = true
            projectedOrbitCanvas.requestPaint()
        }
    }

    onWidthChanged: {
        refreshProjectedMarkers()
        orbitPathsDirty = true
        projectedOrbitCanvas.requestPaint()
    }

    onHeightChanged: {
        refreshProjectedMarkers()
        orbitPathsDirty = true
        projectedOrbitCanvas.requestPaint()
    }

    Component.onCompleted: {
        refreshProjectedMarkers()
        orbitPathsDirty = true
        projectedOrbitCanvas.requestPaint()
    }

    ListModel {
        id: satelliteLabelModel
    }

    ListModel {
        id: satelliteRangeModel
    }

    View3D {
        id: view
        anchors.fill: parent
        camera: camera

        environment: SceneEnvironment {
            backgroundMode: SceneEnvironment.Transparent
            antialiasingMode: SceneEnvironment.MSAA
            antialiasingQuality: SceneEnvironment.High
        }

        PerspectiveCamera {
            id: camera
            position: Qt.vector3d(-100, 70, 740)
            eulerRotation.x: 0
            fieldOfView: 37
            clipFar: 2000
        }

        DirectionalLight {
            id: sunLight
            eulerRotation: root.sunLightEuler
            brightness: 5
        }

        Model {
            id: globe
            source: "#Sphere"
            visible: root.renderGlobeModelEnabled
            scale: Qt.vector3d(root.globeSceneRadius / 50.0,
                               root.globeSceneRadius / 50.0,
                               root.globeSceneRadius / 50.0)
            position: root.globeCenter
            eulerRotation: root.globeEulerRotation

            materials: [
                PrincipledMaterial {
                    id: earthMaterial

                    baseColorMap: Texture {
                        source: "../assets/earth_day.jpg"
                        generateMipmaps: true
                        mipFilter: Texture.Linear
                    }

                    // White keeps the texture un-tinted so the day map carries full color.
                    baseColor: "#ffffff"

                    // A low self-lit copy of the day map keeps colors saturated instead
                    // of letting the lit surface wash out into gray under scene lighting.
                    emissiveMap: Texture {
                        source: "../assets/earth_night.jpg"
                        generateMipmaps: true
                        mipFilter: Texture.Linear
                    }

                    roughnessMap: Texture {
                        source: "../assets/earth_roughness.jpg"
                        generateMipmaps: true
                        mipFilter: Texture.Linear
                    }

                    roughness: 1
                    metalness: 0.0
                    specularAmount: 0.04

                    // Small emissive lift so the dark side is not pure black.
                    emissiveFactor: Qt.vector3d(1, 1, 1)
                }
            ]

        }

        Model {
            id: atmosphereShell
            source: "#Sphere"
            visible: root.renderAtmosphereShaderEnabled
            position: root.globeCenter
            scale: Qt.vector3d((root.globeSceneRadius * root.atmosphereRadiusScale) / 50.0,
                               (root.globeSceneRadius * root.atmosphereRadiusScale) / 50.0,
                               (root.globeSceneRadius * root.atmosphereRadiusScale) / 50.0)
            castsShadows: false
            receivesShadows: false

            materials: [
                CustomMaterial {
                    id: atmosphereMaterial
                    shadingMode: CustomMaterial.Unshaded
                    vertexShader: "../shaders/atmosphere.vert"
                    fragmentShader: "../shaders/atmosphere.frag"

                    // These properties are exposed as uniforms in the shader.
                    property color glowColor: root.atmosphereColor
                    property real glowOpacity: root.atmosphereOpacity
                    property real rimPower: root.atmosphereRimPower
                    property real innerGlow: root.atmosphereInnerGlow
                    property vector3d sunDirection: root.atmosphereSunDirection

                    sourceBlend: CustomMaterial.SrcAlpha
                    destinationBlend: CustomMaterial.OneMinusSrcAlpha
                    cullMode: Material.NoCulling
                }
            ]
        }

    }

    Item {
        id: staticGlobeImageLayer
        anchors.fill: parent
        visible: root.staticGlobeImageEnabled
        z: 1

        Image {
            id: staticGlobeImageSource
            source: "../assets/globe_asset.png"
            width: root.height * root.staticGlobeImageScale
            height: width * 2048.0 / 2135.0
            x: root.globeScreenCenterX + root.staticGlobeImageOffsetX - width / 2
            y: root.globeScreenCenterY + root.staticGlobeImageOffsetY - height / 2
            fillMode: Image.PreserveAspectFit
            mipmap: true
            smooth: true
            visible: false
        }

        MultiEffect {
            anchors.fill: staticGlobeImageSource
            source: staticGlobeImageSource
            opacity: root.staticGlobeImageOpacity
            colorization: root.staticGlobeImageDebugColorEnabled ? 1.0 : 0.0
            colorizationColor: root.staticGlobeImageTintColor
        }
    }

    Canvas {
    id: projectedOrbitCanvas
    anchors.fill: parent
    z: 2
    antialiasing: true

    property int orbitDrawSegments: 128
    property real globeOcclusionRadius: root.globeSceneRadius * 1.005

    function orbitSunFactor(point3d) {
        const radial = OrbitalMath.normalize(Qt.vector3d(point3d.x - root.globeCenter.x,
                                                        point3d.y - root.globeCenter.y,
                                                        point3d.z - root.globeCenter.z))
        const sunDot = OrbitalMath.dot(radial, root.atmosphereSunDirection)
        return Math.max(0.18, Math.min(1.0, 0.42 + sunDot * 0.58))
    }

    function rebuildOrbitCache() {
        let paths = []

        for (let i = 0; i < root.orbitDefinitions.length; ++i) {
            const orbit = root.orbitDefinitions[i]
            let visibleSegments = []
            let currentSegment = []

            for (let j = 0; j <= orbitDrawSegments; ++j) {
                const deg = j * 360.0 / orbitDrawSegments
                const p3 = root.orbitPoint(orbit, deg)
                const p2 = view.mapFrom3DScene(p3)

                const occluded = OrbitalMath.screenOccludedBySphere(
                    camera.position,
                    p3,
                    root.globeCenter,
                    globeOcclusionRadius
                )

                const onScreen =
                    p2.x > -root.u * 20 &&
                    p2.x < root.width + root.u * 20 &&
                    p2.y > -root.u * 20 &&
                    p2.y < root.height + root.u * 20

                if (!occluded && onScreen) {
                    currentSegment.push({
                        x: p2.x,
                        y: p2.y,
                        sun: orbitSunFactor(p3)
                    })
                } else {
                    if (currentSegment.length > 1)
                        visibleSegments.push(currentSegment)

                    currentSegment = []
                }
            }

            if (currentSegment.length > 1)
                visibleSegments.push(currentSegment)

            paths.push({
                name: orbit.name,
                color: orbit.color === undefined ? root.cyan : orbit.color,
                opacity: orbit.opacity === undefined ? 0.35 : orbit.opacity,
                segments: visibleSegments
            })
        }

        root.cachedOrbitPaths = paths
        root.orbitPathsDirty = false
    }

    function drawCachedOrbit(ctx, path) {
        ctx.save()
        ctx.setLineDash([])
        ctx.lineCap = "butt"
        ctx.lineJoin = "round"

        function strokeLitSegments(width, opacityScale) {
            ctx.strokeStyle = path.color
            ctx.lineWidth = width

            for (let s = 0; s < path.segments.length; ++s) {
                const segment = path.segments[s]
                if (segment.length < 2)
                    continue

                for (let i = 1; i < segment.length; ++i) {
                    const start = segment[i - 1]
                    const end = segment[i]
                    const sun = (start.sun + end.sun) * 0.5
                    ctx.globalAlpha = path.opacity * opacityScale * sun
                    ctx.beginPath()
                    ctx.moveTo(start.x, start.y)
                    ctx.lineTo(end.x, end.y)
                    ctx.stroke()
                }
            }
        }

        // soft glow pass
        strokeLitSegments(root.u * 0.34, 0.20)

        // main line pass
        strokeLitSegments(Math.max(0.8, root.u * 0.10), 0.92)

        ctx.restore()
    }

    onPaint: {
        const ctx = getContext("2d")
        ctx.clearRect(0, 0, width, height)

        ctx.lineCap = "round"
        ctx.lineJoin = "round"

        if (root.orbitPathsDirty)
            rebuildOrbitCache()

        for (let i = 0; i < root.cachedOrbitPaths.length; ++i)
            drawCachedOrbit(ctx, root.cachedOrbitPaths[i])

        ctx.globalAlpha = 1.0
        ctx.setLineDash([])
    }
}
}
