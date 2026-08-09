.pragma library

const EARTH_RADIUS_KM = 6371.0

function deg2rad(d) { return d * Math.PI / 180.0 }
function rad2deg(r) { return r * 180.0 / Math.PI }

function v3(x, y, z) { return Qt.vector3d(x, y, z) }
function add(a, b) { return v3(a.x + b.x, a.y + b.y, a.z + b.z) }
function sub(a, b) { return v3(a.x - b.x, a.y - b.y, a.z - b.z) }
function mul(a, s) { return v3(a.x * s, a.y * s, a.z * s) }
function dot(a, b) { return a.x * b.x + a.y * b.y + a.z * b.z }
function cross(a, b) { return v3(a.y*b.z - a.z*b.y, a.z*b.x - a.x*b.z, a.x*b.y - a.y*b.x) }
function norm(a) { return Math.sqrt(dot(a, a)) }
function normalize(a) { var n = Math.max(1e-9, norm(a)); return mul(a, 1.0 / n) }
function clamp(x, lo, hi) { return Math.max(lo, Math.min(hi, x)) }

function rotateX(p, angleDeg) {
    var r = deg2rad(angleDeg)
    var c = Math.cos(r), s = Math.sin(r)
    return v3(p.x, p.y*c - p.z*s, p.y*s + p.z*c)
}

function rotateY(p, angleDeg) {
    var r = deg2rad(angleDeg)
    var c = Math.cos(r), s = Math.sin(r)
    return v3(p.x*c + p.z*s, p.y, -p.x*s + p.z*c)
}

function rotateZ(p, angleDeg) {
    var r = deg2rad(angleDeg)
    var c = Math.cos(r), s = Math.sin(r)
    return v3(p.x*c - p.y*s, p.x*s + p.y*c, p.z)
}

// Lat/lon in degrees. This coordinate system is chosen for visual consistency
// with the QtQuick3D scene: x/y/z are globe-local scene axes.
function llaToUnit(latDeg, lonDeg) {
    var lat = deg2rad(latDeg)
    var lon = deg2rad(lonDeg)
    var clat = Math.cos(lat)
    return v3(clat * Math.cos(lon), Math.sin(lat), clat * Math.sin(lon))
}

function groundScenePosition(globeCenter, sceneRadius, latDeg, lonDeg, surfaceLift) {
    var u = llaToUnit(latDeg, lonDeg)
    return add(globeCenter, mul(u, sceneRadius + (surfaceLift || 0)))
}

function satelliteUnitFromElements(inclinationDeg, raanDeg, phaseDeg) {
    var nu = deg2rad(phaseDeg)
    var p = v3(Math.cos(nu), Math.sin(nu), 0)
    p = rotateX(p, inclinationDeg)
    p = rotateY(p, raanDeg)
    return normalize(p)
}

function satelliteScenePosition(globeCenter, sceneRadius, altitudeKm, inclinationDeg, raanDeg, phaseDeg) {
    var orbitRadius = sceneRadius * (EARTH_RADIUS_KM + altitudeKm) / EARTH_RADIUS_KM
    var u = satelliteUnitFromElements(inclinationDeg, raanDeg, phaseDeg)
    return add(globeCenter, mul(u, orbitRadius))
}

function localFrame(latDeg, lonDeg) {
    var up = normalize(llaToUnit(latDeg, lonDeg))
    var east = normalize(v3(-Math.sin(deg2rad(lonDeg)), 0, Math.cos(deg2rad(lonDeg))))
    var north = normalize(cross(up, east))
    return { east: east, north: north, up: up }
}

function lookAngles(groundPosition, satellitePosition, latDeg, lonDeg) {
    var frame = localFrame(latDeg, lonDeg)
    var rho = sub(satellitePosition, groundPosition)
    var r = Math.max(1e-9, norm(rho))
    var e = dot(rho, frame.east)
    var n = dot(rho, frame.north)
    var u = dot(rho, frame.up)
    var az = rad2deg(Math.atan2(e, n))
    if (az < 0) az += 360
    var el = rad2deg(Math.asin(clamp(u / r, -1, 1)))
    return { azimuth: az, elevation: el, rangeScene: r }
}

function hasLineOfSight(groundPosition, satellitePosition, latDeg, lonDeg) {
    return lookAngles(groundPosition, satellitePosition, latDeg, lonDeg).elevation > 0.0
}

function screenOccludedBySphere(cameraPosition, targetPosition, sphereCenter, sphereRadius) {
    var d = sub(targetPosition, cameraPosition)
    var f = sub(cameraPosition, sphereCenter)
    var a = dot(d, d)
    var b = 2.0 * dot(f, d)
    var c = dot(f, f) - sphereRadius * sphereRadius
    var disc = b*b - 4*a*c
    if (disc < 0) return false
    disc = Math.sqrt(disc)
    var t1 = (-b - disc) / (2*a)
    var t2 = (-b + disc) / (2*a)
    return (t1 > 0.001 && t1 < 0.999) || (t2 > 0.001 && t2 < 0.999)
}

function statusFromGeometry(elevation, screenOccluded, acquiring) {
    if (screenOccluded) return "NO LOS"
    if (elevation > 20) return "ACTIVE"
    if (elevation > 0 && acquiring) return "ACQUIRING"
    return "NO LOS"
}

function colorForStatus(status, magenta, green, muted) {
    if (status === "ACTIVE") return green
    if (status === "ACQUIRING") return magenta
    return muted
}

function snrFromElevation(elevation) {
    if (elevation <= 0) return 0.0
    return clamp(7.0 + elevation * 0.34, 0.0, 31.0)
}
