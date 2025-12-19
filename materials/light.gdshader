shader_type spatial;
render_mode cull_back, depth_test_default, vertex_lighting, depth_prepass_alpha;

varying vec3 world_vertex;
varying vec3 voxel_vertex;

uniform float light_resolution : hint_range(1.0, 64.0, 1.0) = 16;
uniform sampler2D TEXTURE : source_color, filter_nearest;

void fragment() {
	world_vertex = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	
	vec3 snapping = vec3(0.49);

	voxel_vertex = roundEven(world_vertex * light_resolution + snapping) / light_resolution;
	LIGHT_VERTEX = (VIEW_MATRIX * vec4(voxel_vertex, 1.0)).xyz;

	vec4 color = texture(TEXTURE, UV);
	ALBEDO = color.rgb;
	ALPHA = color.a;
}

void light() {
	vec3 world_light = (INV_VIEW_MATRIX * vec4(LIGHT, 0.0)).xyz;
	vec3 world_light_pos = world_vertex + world_light * 1.0 / ATTENUATION;

	float att = 1.0 / distance(voxel_vertex, world_light_pos);
	DIFFUSE_LIGHT += vec3(att);
}