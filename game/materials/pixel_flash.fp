#version 140

// Pixel-art sprite with an additive "flash" color on top of the texture.
// Used where the art is too dark for a multiplied tint to show (zombies).

in mediump vec2 var_texcoord0;

out vec4 out_fragColor;

uniform mediump sampler2D texture_sampler;
uniform fs_uniforms
{
    mediump vec4 tint;
    mediump vec4 flash; // rgb = color, w = strength
};

void main()
{
    // Pre-multiply alpha since all runtime textures already are
    mediump vec4 tint_pm = vec4(tint.xyz * tint.w, tint.w);
    mediump vec4 color = texture(texture_sampler, var_texcoord0.xy) * tint_pm;
    color.rgb += flash.rgb * flash.w * color.a;
    out_fragColor = color;
}
