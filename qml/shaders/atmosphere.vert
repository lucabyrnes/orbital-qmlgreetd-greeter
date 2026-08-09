// Qt Quick3D CustomMaterial vertex shader snippet.
// Passes world-space shell position and normal to the fragment shader so the
// atmosphere can calculate a proper camera-facing Fresnel rim.

VARYING vec3 vWorldPosition;
VARYING vec3 vWorldNormal;

void MAIN()
{
    vWorldPosition = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    vWorldNormal = normalize(NORMAL_MATRIX * NORMAL);
    POSITION = MODELVIEWPROJECTION_MATRIX * vec4(VERTEX, 1.0);
}
