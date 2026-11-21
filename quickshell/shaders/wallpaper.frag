// The moving wallpaper (LiveWallpaper.qml). It starts from the painted
// picture and moves three things in it, each by the amount the painter says
// is visible there (nocturne/wallpaper, live layers):
//   mist   banks drift through the valleys, thickening and thinning it
//   stars  each twinkles at its own pace
//   lake   the glints on the moon's path ripple
//   glow   the moon's light on the sky, the arch and the hills breathes
// plus low fog over the valleys and, now and then, a shooting star.
// Light is added in linear light, as the painter does, then encoded again.
// Quickshell loads the compiled wallpaper.frag.qsb. After a change, run in
// this folder (qsb is in qt6-shadertools):
//   /usr/lib/qt6/bin/qsb --glsl "100 es,120,150" --hlsl 50 --msl 12 -o wallpaper.frag.qsb wallpaper.frag
#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float time;        // seconds
    float aspect;      // the picture's width over its height
    float wind;        // how fast the mist drifts; 1 is a calm night
    float strength;    // 0 is the still picture, 1 fully moving
    vec4 mistColor;    // linear RGB; w is the layer's scale
    vec4 starColor;    // linear RGB; w is the layer's scale
    vec4 glowColor;    // linear RGB; w is the glints layer's scale
    vec4 scales;       // x: the painted sparkles' scale, y: the glow's
};

layout(binding = 1) uniform sampler2D picture;
layout(binding = 2) uniform sampler2D motion;  // r mist, g stars, b star timing
layout(binding = 3) uniform sampler2D lake;    // r moon path, g painted sparkles, b the moon's glow

vec3 toLinear(vec3 c) {
    return mix(c / 12.92, pow((c + 0.055) / 1.055, vec3(2.4)), step(0.04045, c));
}

vec3 toSrgb(vec3 c) {
    c = clamp(c, 0.0, 1.0);
    return mix(c * 12.92, 1.055 * pow(c, vec3(1.0 / 2.4)) - 0.055, step(0.0031308, c));
}

float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

float fbm(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    for (int i = 0; i < 4; i++) {
        v += a * noise(p);
        p = p * 2.03 + 17.0;
        a *= 0.5;
    }
    return v;
}

void main() {
    vec2 uv = qt_TexCoord0;
    vec3 color = toLinear(texture(picture, uv).rgb);
    vec3 m = texture(motion, uv).rgb;
    vec3 l = texture(lake, uv).rgb;
    vec2 p = vec2(uv.x * aspect, uv.y); // height units, as the painter uses

    // Mist: long, low banks drifting sideways. The painted mist is the
    // average; a bank adds to it, a gap takes from it.
    float mist = m.r * mistColor.w;
    float bank = fbm(vec2(p.x * 2.6 - time * 0.06 * wind, p.y * 16.0 + time * 0.006));
    color += mistColor.rgb * mist * (bank - 0.5) * 3.5 * strength;

    // Low fog: thin, broad drifts across the valleys and the lake, below the
    // far range so the sky and the moon stay clear.
    float band = smoothstep(0.665, 0.70, uv.y) * (1.0 - smoothstep(0.93, 0.995, uv.y));
    float drift = fbm(vec2(p.x * 1.3 - time * 0.045 * wind, p.y * 7.0 + time * 0.008));
    float fog = smoothstep(0.48, 0.82, drift) * band;
    color += mistColor.rgb * fog * 0.55 * strength;

    // Stars: two waves per star, timed by the star's own value.
    float star = m.g * starColor.w;
    float t = m.b;
    float twinkle = 0.65 * sin(time * (1.1 + t * 2.6) + t * 40.0)
                  + 0.35 * sin(time * (3.1 + t * 3.4) + t * 13.0);
    color += starColor.rgb * star * twinkle * 1.1 * strength;

    // The lake: ripples stretched sideways, sharpened into glints, sliding.
    // They replace the painted ones along the moon's path.
    float path = l.r * glowColor.w;
    float painted = l.g * scales.x;
    vec2 q = vec2(p.x * 60.0 + time * 0.45, p.y * 380.0 + sin(p.x * 25.0 + time * 1.0) * 1.6);
    float n = 0.7 * noise(q) + 0.3 * noise(q * 2.13 + vec2(time * 0.6, 0.0));
    float glint = pow(clamp((n - 0.58) / 0.42, 0.0, 1.0), 2.0);
    float shimmer = 0.08 * (noise(vec2(p.x * 9.0, p.y * 90.0 - time * 0.7)) - 0.5);
    color += glowColor.rgb * (1.4 * glint * path - 0.9 * painted + shimmer * path) * strength;

    // The moon's glow breathes: it swells and settles over about seven
    // seconds, with a slower, smaller wave under it so it never feels like a
    // metronome. Only where the painter lit things with it.
    float halo = l.b * scales.y;
    float breath = 0.20 * sin(time * 0.9) + 0.07 * sin(time * 0.37 + 1.3);
    color += glowColor.rgb * halo * breath * strength;

    // Now and then a shooting star, high in the sky where nothing covers it:
    // one every two minutes or so, at a moment and place of its own.
    float period = 110.0;
    float k = floor(time / period);
    float start = 8.0 + hash(vec2(k, 1.7)) * (period - 12.0);
    float progress = (time - k * period - start) / 0.9; // 0.9 seconds across
    if (progress > 0.0 && progress < 1.0) {
        float angle = radians(18.0 + 20.0 * hash(vec2(k, 4.1)));
        float side = hash(vec2(k, 9.3)) < 0.5 ? -1.0 : 1.0;
        vec2 direction = vec2(side * cos(angle), sin(angle));
        vec2 from = vec2(aspect * (0.25 + 0.5 * hash(vec2(k, 2.9))), 0.04 + 0.12 * hash(vec2(k, 6.5)));
        vec2 head = from + direction * 0.30 * progress;
        float along = clamp(dot(p - head, -direction) / 0.09, 0.0, 1.0); // 0 at the head
        vec2 nearest = head - direction * along * 0.09;
        float across = length(p - nearest);
        float streak = exp(-across / 0.0011) * (1.0 - along) * sin(3.14159 * progress);
        color += starColor.rgb * streak * 0.9 * step(uv.y, 0.36) * strength;
    }

    fragColor = vec4(toSrgb(color), 1.0) * qt_Opacity;
}
