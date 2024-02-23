shader_type spatial;
render_mode depth_test_disabled, unshaded;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;

uniform vec4 fog_colour : source_color = vec4(1.0);
uniform vec4 sun_colour : source_color = vec4(1.0);
uniform float fog_opacity = 0.5;
uniform float fog_density = 1.0;
uniform float fog_hdr_multiplier = 1.0;
uniform float sun_hdr_multiplier = 1.0;
uniform vec3 sun = vec3(0.5,-0.5,0.0);
uniform float sun_power = 1.0;

varying vec3 cam_pos;

void vertex() {
	POSITION = vec4(VERTEX, 1.0);
}

void fragment() {
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).x;
	vec3 ndc = vec3(SCREEN_UV, depth) * 2.0 - 1.0;
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z;
	
	vec4 viewspace_sun = vec4(sun,1.0) * INV_VIEW_MATRIX;
	float sun_amount = dot(normalize(viewspace_sun.xyz), normalize(view.xyz));

	float fog_amount = 1.0 - exp(-linear_depth*fog_density*0.001*fog_opacity);
	
	ALPHA = abs(fog_amount);
	vec3 main_colour = fog_colour.xyz * fog_hdr_multiplier;
	ALBEDO = mix(main_colour, sun_colour.xyz*sun_hdr_multiplier, pow((sun_amount + 1.0) / 2.0, sun_power));
	
}