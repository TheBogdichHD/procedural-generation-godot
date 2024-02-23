shader_type spatial;

//render_mode unshaded;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;

uniform sampler2D mask;
uniform sampler2D gradient : source_color;
uniform sampler2D noise;
uniform float tilingA = 10.0;
uniform float tilingB = 8.0;
uniform vec2 scroll_speedA = vec2(0.05, 0.0);
uniform vec2 scroll_speedB = vec2(0.0, 0.05);
uniform float noise_scale = 1.0;
uniform float noise_scale2 = 1.0;
uniform float displacement_amplitude = 1.0;
uniform float displacement_scroll_speed = 1.0;
uniform float test = 1.0;
uniform float test2 = 10.0;
uniform float test3 = 10.0;

void fragment(){
	float warp = texture(noise, UV).r * noise_scale;
	vec2 offsetA = fract(TIME * scroll_speedA);
	vec2 offsetB = fract(TIME * scroll_speedB);
	float layerA = texture(mask, UV*tilingA + offsetA + warp).r;
	float layerB = texture(mask, UV*tilingB + offsetB + warp).r;
	layerA += layerB * 0.5;
	
	
	
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).r;
	depth = depth * 2.0 - 1.0;
	float z = -PROJECTION_MATRIX[3][2] / (depth + PROJECTION_MATRIX[2][2]);
	float delta = -(z - VERTEX.z) * test; // z is negative.
	//float foam = 1.0 - min(max(delta, 0.0), 1.0);
	
	//layerA += foam;
	layerA = max(min(layerA, 1.0), 0.0);
	
	layerA = 0.5;
	
	vec3 col = texture(gradient, vec2(mix(layerA, 0.0, clamp(delta, 0.0, 1.0)))).rgb;
	col = mix(vec3(1.0), col, pow(clamp(delta * test2, 0.0, 1.0), test3));
	
	ALBEDO = col;
	//ALPHA = 1.0 - min(max(delta, 0.0), 1.0);
}

void vertex(){
	float displ = texture(noise, UV * noise_scale2 + fract(TIME * displacement_scroll_speed * 0.1)).r;
	VERTEX.y += ((displ - 0.5) * 2.0) * displacement_amplitude;
}