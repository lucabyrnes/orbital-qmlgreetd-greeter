// Qt Quick3D CustomMaterial fragment shader snippet.
// Produces a transparent atmospheric shell with a Fresnel rim glow and a subtle
// sun-facing lift. Tuned from components/GlobeScene.qml through material uniforms.

VARYING vec3 vWorldPosition;
VARYING vec3 vWorldNormal;

void MAIN()
{
    vec3 n = normalize(vWorldNormal);
    vec3 v = normalize(CAMERA_POSITION - vWorldPosition);
    vec3 s = normalize(sunDirection);

    float facing = clamp(dot(n, v), 0.0, 1.0);
    float rim = pow(1.0 - facing, rimPower);
    float limb = smoothstep(0.12, 1.0, rim);
    float sunFacing = dot(n, s);
    float daySide = smoothstep(-0.02, 0.42, sunFacing);
    float twilight = smoothstep(-0.18, 0.12, sunFacing);

    // Keep the strong atmospheric rim on the illuminated limb only. Without this
    // mask, the Fresnel term wraps around the entire silhouette independent of
    // the light direction.
    float sunlitLimb = limb * daySide;
    float haze = innerGlow * twilight * (1.0 - smoothstep(0.0, 0.72, facing));
    float alpha = clamp((sunlitLimb + haze) * glowOpacity, 0.0, 0.92);

    vec3 color = glowColor.rgb * (0.55 + 1.45 * sunlitLimb + 0.35 * daySide);

    FRAGCOLOR = vec4(color, alpha);
}
