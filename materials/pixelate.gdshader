shader_type spatial;
render_mode unshaded, fog_disabled;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, source_color, filter_nearest;
uniform sampler2D DEPTH_TEXTURE: hint_depth_texture, source_color, filter_nearest;

uniform float pixel_count : hint_range(0, 20.0, 0.01) = 0.1;
uniform float range : hint_range(0, 64.0, 0.01) = 5.0;
uniform float gamma : hint_range(0, 1.0, 0.01) = 1.0;
uniform float a : hint_range(0, 100.0, 0.01) = 1.0;

float linearize_depth(vec2 uv_coord, mat4 proj_matrix){
	float depth = texture(DEPTH_TEXTURE, uv_coord).x;
	vec3 ndc = vec3(uv_coord, depth) * range;
	vec4 view = proj_matrix * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z;
	return linear_depth;
}

void vertex(){
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	vec2 screen_size = vec2(textureSize(SCREEN_TEXTURE, CURRENT_RENDERER));
	vec2 pixel_step = screen_size / vec2(pixel_count);
	vec2 uv = floor(SCREEN_UV * pixel_step) / pixel_step;

	//uv = uv * a - a/2.0;

	vec4 screen_color = texture(SCREEN_TEXTURE, uv);
	float depth = 1.0 - linearize_depth(uv, INV_PROJECTION_MATRIX);

	//ALBEDO = screen_color.rgb * depth * gamma;
	ALBEDO = screen_color.rgb;
}