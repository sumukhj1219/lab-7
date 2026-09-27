#version 140

// Solid tint color with darker 45-degree stripes, matching the HUD's
// hatched mutation bar. hatch.x = repeat (px), hatch.y = stripe width,
// hatch.z = stripe brightness (1 = no stripes). origin.xy = point the
// stripes are pinned to (set from script), so they move with the bar.

in mediump vec2 var_texcoord0;
in highp vec2 var_world;

out vec4 out_fragColor;

uniform mediump sampler2D texture_sampler;
uniform fs_uniforms
{
    mediump vec4 tint;
    mediump vec4 hatch;
    highp vec4 origin;
};

void main()
{
    mediump vec4 tex = texture(texture_sampler, var_texcoord0.xy);
    highp vec2 p = var_world - origin.xy;
    mediump float stripe = step(mod(p.x + p.y, hatch.x), hatch.y);
    mediump vec3 color = tint.xyz * mix(1.0, hatch.z, stripe);
    out_fragColor = vec4(color * tint.w, tint.w) + tex * 0.0;
}
