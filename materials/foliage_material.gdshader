shader_type spatial;
//render_mode blend_mix, depth_draw_opaque, diffuse_burley;
render_mode diffuse_toon, depth_prepass_alpha;

uniform sampler2D foliage_atlas : source_color, filter_nearest_mipmap;
uniform sampler2D foliage_mask : source_color, filter_nearest_mipmap;
uniform sampler2D foliage_color_map : source_color, filter_linear;

uniform float motion_amount : hint_range(0.0, 1.0);
uniform vec2 biome_color_position;

void vertex() {
	vec3 offset = vec3(
		sin(VERTEX.x*VERTEX.y     + TIME * 2.5),
		cos(VERTEX.y              + TIME * 2.0),
		sin(VERTEX.z*VERTEX.y*2.0 + TIME * 3.0)
	);

	VERTEX += offset * motion_amount * 0.1;
}

void fragment() {
	vec4 albedo_tex = texture(foliage_atlas, UV);
	float mask = texture(foliage_mask, UV).r;
	vec3 biome_color = texture(foliage_color_map, biome_color_position).rgb;

	ALBEDO = mix(albedo_tex.rgb, albedo_tex.rgb * biome_color, mask);
	ALPHA = albedo_tex.a;
	ALPHA_SCISSOR_THRESHOLD = 0.1;
	
	ROUGHNESS = 1.0;
	METALLIC = 0.0;
	SPECULAR = 0.0;
}
