shader_type spatial;
render_mode unshaded;

uniform int pixel_size = 4; //Resolution must be divisible by pixel_size
uniform sampler2D SCREEN_TEXTURE : source_color, hint_screen_texture, filter_nearest;

//To make the mesh cover the camera always.
void vertex(){
    POSITION = vec4(VERTEX, 1.0);
}

void fragment(){
    float x = float(int(FRAGCOORD.x) % pixel_size)/2.0;
    float y = float(int(FRAGCOORD.y) % pixel_size)/2.0;

    x = FRAGCOORD.x + floor(float(pixel_size) / 2.0) - x;
    y = FRAGCOORD.y + floor(float(pixel_size) / 2.0) - y;

    ALBEDO = texture(SCREEN_TEXTURE, vec2(x, y) / VIEWPORT_SIZE).xyz;
}