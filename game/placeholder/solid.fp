#version 140

// Placeholder only: fills the whole sprite quad with the tint color,
// ignoring the texture, so walls and floor show as solid rectangles.

in mediump vec2 var_texcoord0;

out vec4 out_fragColor;

uniform mediump sampler2D texture_sampler;
uniform fs_uniforms
{
    mediump vec4 tint;
};

void main()
{
    mediump vec4 tex = texture(texture_sampler, var_texcoord0.xy);
    out_fragColor = vec4(tint.xyz * tint.w, tint.w) + tex * 0.0;
}
