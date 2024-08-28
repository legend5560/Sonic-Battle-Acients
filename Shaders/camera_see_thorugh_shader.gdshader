shader_type spatial;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = textureLod(SCREEN_TEXTURE, SCREEN_UV, 10.5).rgb;
}
