#include "_prelude_fog.fragment.glsl"

// [1] Banding in games http://loopit.dk/banding_in_games.pdf

in lowp vec3 v_uv;

uniform lowp samplerCube u_cubemap;
uniform lowp float u_opacity;
uniform highp float u_temporal_offset;
uniform highp vec3 u_sun_direction;

float sun_disk(highp vec3 ray_direction, highp vec3 sun_direction) {
    highp float cos_angle = dot(normalize(ray_direction), sun_direction);

    // Sun angular angle is ~0.5°
    const highp float cos_sun_angular_diameter = 0.99996192306;
    const highp float smoothstep_delta = 1e-5;

    return smoothstep(
        cos_sun_angular_diameter - smoothstep_delta,
        cos_sun_angular_diameter + smoothstep_delta,
        cos_angle);
}

float map(float value, float start, float end, float new_start, float new_end) {
    return ((value - start) * (new_end - new_start)) / (end - start) + new_start;
}

void main() {
    vec3 uv = v_uv;

    // Add a small offset to prevent black bands around areas where
    // the scattering algorithm does not manage to gather lighting
    const float y_bias = 0.015;
    uv.y += y_bias;

    // Inverse of the operation applied for non-linear UV parameterization
    uv.y = pow(abs(uv.y), 1.0 / 5.0);

    // To make better utilization of the visible range (e.g. over the horizon, UVs
    // from 0.0 to 1.0 on the Y-axis in cubemap space), the UV range is remapped from
    // (0.0,1.0) to (-1.0,1.0) on y. The inverse operation is applied when generating.
    uv.y = map(uv.y, 0.0, 1.0, -1.0, 1.0);

    vec3 sky_color = texture(u_cubemap, uv).rgb;

#ifdef FOG
    // Apply fog contribution if enabled
    // Swizzle to put z-up (ignoring x-y mirror since fog does not depend on azimuth)
    sky_color = fog_apply_sky_gradient(v_uv.xzy, sky_color);
#endif

    // Add sun disk
    sky_color += 0.1 * sun_disk(v_uv, u_sun_direction);

    glFragColor = vec4(sky_color * u_opacity, u_opacity);

#ifdef OVERDRAW_INSPECTOR
    glFragColor = vec4(1.0);
#endif
}
