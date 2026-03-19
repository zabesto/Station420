shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float fog_density = 1.0;
uniform vec4 tint : source_color = vec4(0.06, 0.11, 0.18, 0.26);

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

void fragment() {
	vec3 scene = textureLod(screen_texture, SCREEN_UV, 0.0).rgb;
	vec2 centered_uv = SCREEN_UV * 2.0 - 1.0;
	float radial = smoothstep(0.0, 1.0, length(centered_uv) * 0.96);
	float horizon = smoothstep(-0.4, 1.0, SCREEN_UV.y);
	float grain = hash(floor(SCREEN_UV * vec2(320.0, 180.0))) * 0.12;
	float fog = clamp((0.28 + radial * 0.72 + horizon * 0.26 + grain) * fog_density, 0.0, 1.0);
	vec3 color = mix(scene, tint.rgb, fog * tint.a * 2.7);
	color += tint.rgb * fog * 0.14;
	COLOR = vec4(color, 1.0);
}
