shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec3 inverted_color = 1.0 - textureLod(screen_texture, SCREEN_UV, 0.0).rgb;
	
    COLOR = vec4(inverted_color, texture(TEXTURE, UV).a);
}
