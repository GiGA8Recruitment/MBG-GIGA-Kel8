//// card_shadow.gdshader
//shader_type canvas_item;
//
//uniform vec4  shadow_color : source_color = vec4(0.0, 0.0, 0.0, 0.4);
//uniform vec2  shadow_offset = vec2(4.0, 6.0);
//uniform float shadow_blur   = 3.0;
//
//void fragment() {
    //vec2 uv = UV;
    //vec4 original = texture(TEXTURE, uv);
//
    //// Sample alpha sekitar offset untuk blur shadow
    //float shadow_alpha = 0.0;
    //int samples = 8;
    //for (int i = 0; i < samples; i++) {
        //float angle = float(i) * 3.14159 * 2.0 / float(samples);
        //for (float r = 0.0; r <= 1.0; r += 0.5) {
            //vec2 blur_offset = vec2(cos(angle), sin(angle)) * r * shadow_blur;
            //vec2 shadow_uv = uv - (shadow_offset + blur_offset) * TEXTURE_PIXEL_SIZE;
            //shadow_alpha += texture(TEXTURE, shadow_uv).a;
        //}
    //}
    //shadow_alpha = clamp(shadow_alpha / float(samples * 3), 0.0, 1.0);
//
    //// Blend: shadow dulu, lalu kartu di atasnya
    //vec4 shadow = shadow_color * shadow_alpha * (1.0 - original.a);
    //COLOR = original + shadow;
//}

// card_shadow_simple.gdshader
shader_type canvas_item;

uniform vec4  shadow_color  : source_color = vec4(0.0, 0.0, 0.0, 0.5);
uniform vec2  shadow_offset = vec2(3.0, 5.0);   // pixel offset x, y
uniform float shadow_softness = 1.5;            // semakin besar semakin blur

void fragment() {
    vec4 original = texture(TEXTURE, UV);

    float shadow = 0.0;
    float total  = 0.0;

    // 3x3 sample grid untuk soft edge
    for (float x = -shadow_softness; x <= shadow_softness; x += shadow_softness) {
        for (float y = -shadow_softness; y <= shadow_softness; y += shadow_softness) {
            vec2 offset_uv = UV - (shadow_offset + vec2(x, y)) * TEXTURE_PIXEL_SIZE;
            shadow += texture(TEXTURE, offset_uv).a;
            total  += 1.0;
        }
    }

    shadow = clamp(shadow / total, 0.0, 1.0);
    vec4 shadow_layer = shadow_color * shadow * (1.0 - original.a);

    COLOR = original + shadow_layer;
}