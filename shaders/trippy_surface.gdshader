shader_type spatial;

render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 base_color : source_color = vec4(0.34, 0.76, 1.0, 1.0);
uniform vec4 accent_color : source_color = vec4(0.82, 0.98, 1.0, 1.0);
uniform float pulse_strength : hint_range(0.0, 2.0) = 0.6;
uniform float glow_strength : hint_range(0.0, 2.5) = 1.05;
uniform float pattern_scale : hint_range(0.005, 0.2) = 0.03;
uniform float rim_strength : hint_range(0.0, 2.0) = 0.9;
uniform float wire_mix : hint_range(0.0, 1.0) = 0.0;
uniform float alpha_strength : hint_range(0.0, 1.0) = 1.0;

varying vec3 world_pos;

float pulse_band(vec3 p, float speed, float density) {
	return sin(length(p.xz) * density - TIME * speed) * 0.5 + 0.5;
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec3 p = world_pos * pattern_scale;
	float radial = length(p.xz);
	float angle = atan(p.z, p.x);
	float segments = 6.0;
	float folded = abs(fract((angle / TAU) * segments) - 0.5);
	float spokes = sin(folded * 46.0 - TIME * 1.25) * 0.5 + 0.5;
	float rings = pulse_band(p, 2.2, 18.0);
	float scan = sin((p.y + radial * 0.7) * 14.0 + TIME * 1.55) * 0.5 + 0.5;
	float lattice = sin((p.x - p.z) * 11.0 + TIME * 0.9) * 0.5 + 0.5;
	float pattern = rings * 0.42 + spokes * 0.24 + scan * 0.2 + lattice * 0.14;
	float neon_mask = smoothstep(0.36, 0.9, pattern);

	float rim = pow(1.0 - abs(dot(normalize(NORMAL), normalize(VIEW))), 2.0);
	float pulse = 0.78 + sin(TIME * (2.0 + pulse_strength) + radial * 0.2) * 0.22;
	vec3 neon = mix(base_color.rgb, accent_color.rgb, neon_mask * 0.82);
	vec3 wire_color = neon * (0.18 + neon_mask * 0.4);
	vec3 shaded_color = mix(base_color.rgb * 0.52, neon, 0.25 + neon_mask * 0.25);
	vec3 emission = neon * (0.28 + neon_mask * glow_strength + rim * rim_strength) * pulse;

	ALBEDO = mix(shaded_color, wire_color, wire_mix);
	EMISSION = emission * mix(0.9, 1.18, wire_mix);
	ROUGHNESS = mix(0.22, 0.72, wire_mix);
	METALLIC = mix(0.3, 0.02, wire_mix);
	SPECULAR = mix(0.55, 0.18, wire_mix);
	ALPHA = base_color.a * alpha_strength;
}
