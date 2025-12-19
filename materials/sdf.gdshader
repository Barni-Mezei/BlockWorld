shader_type canvas_item;

uniform float alpha_threshold = 0.5;
uniform float lin_range = 100.;
uniform int lin_samp = 5;
uniform int ang_samp = 253;
 


vec2 rotate(vec2 v, float a){
	return vec2(v.x * cos(a) - v.y * sin(a), v.x * sin(a) + v.y * cos(a));
}

bool check_uv(vec2 uv){
	return uv.x >= 0. && uv.y >= 0. && uv.x <= 1. && uv.y <= 1. ;
}

float sdf(vec2 uv, vec2 pixel_size, sampler2D text, float threshold, int linear_sampling, float linear_range, int angular_steps) {
	float base_alpha = texture(text,uv).a;
	vec2 pixel_uv = uv/pixel_size;
	float dezoom_step = linear_range/float(linear_sampling);
	for(float dezoom = 1.; dezoom <= linear_range; dezoom += dezoom_step){
		float angle_increment = 2.*PI/float(angular_steps);
		vec2 offset = vec2(float(dezoom),0.);
		for(float angle = 0.; angle < 2.*PI; angle += angle_increment){
			vec2 pixel_offset = rotate(offset,angle);
			vec2 new_uv = (pixel_offset + pixel_uv)*pixel_size;
			float new_alpha = 0.;
			if(check_uv(new_uv)){
				new_alpha = texture(text, new_uv).a;
				
			}
			
			if( (base_alpha > threshold && new_alpha <= threshold) || (base_alpha <= threshold && new_alpha > threshold) ){
				return base_alpha > threshold ? - dezoom : dezoom; 
			}
		}
	}
	return base_alpha > threshold ? - linear_range : linear_range;
	
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR = vec4(0., 0., 0., 1.);
	float dist = sdf(UV, TEXTURE_PIXEL_SIZE, TEXTURE, alpha_threshold, lin_samp, lin_range, ang_samp);
	float ratio = float(dist)/lin_range;
	if (ratio > 0.){
		COLOR.r = ratio;
	} else {
		COLOR.b = - ratio;
	}
	//if(abs(dist)<5.){
		//COLOR = vec4(1.,0.,0.,1.);
		//}
}