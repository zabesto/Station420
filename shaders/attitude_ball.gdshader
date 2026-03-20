shader_type spatial;
render_mode unshaded, cull_back, depth_draw_opaque;

uniform vec4 upper_color : source_color = vec4(0.18, 0.72, 1.0, 1.0);
uniform vec4 lower_color : source_color = vec4(0.96, 0.54, 0.22, 1.0);
uniform vec4 line_color : source_color = vec4(0.9, 0.96, 1.0, 1.0);
uniform vec4 accent_color : source_color = vec4(0.35, 1.0, 0.86, 1.0);
uniform float line_width = 0.055;
uniform float glow_strength = 1.0;
uniform float alpha_scale = 1.0;

float band_line(float value, float width) {
	float band = abs(fract(value) - 0.5);
	return 1.0 - smoothstep(width, width * 1.8, band);
}

void fragment() {
	vec3 n = normalize(NORMAL);
	float hemi = smoothstep(-0.04, 0.04, n.y);
	vec3 base = mix(lower_color.rgb, upper_color.rgb, hemi);

	float horizon = 1.0 - smoothstep(line_width, line_width * 1.9, abs(n.y));
	float latitude = band_line((n.y * 0.5 + 0.5) * 4.0, line_width * 0.42);
	float longitude_angle = atan(n.x, -n.z) / TAU + 0.5;
	float longitude = band_line(longitude_angle * 6.0, line_width * 0.28);
	float prime_meridian = 1.0 - smoothstep(line_width * 0.72, line_width * 1.55, abs(n.x));

	float grid = max(horizon, max(latitude * 0.55, longitude * 0.35));
	grid = max(grid, prime_meridian * 0.5);

	float rim = pow(1.0 - max(dot(normalize(VIEW), n), 0.0), 2.4);
	vec3 color = mix(base, line_color.rgb, grid);
	color += accent_color.rgb * rim * 0.35;

	ALBEDO = color;
	EMISSION = color * (0.28 + grid * glow_strength * 0.7 + rim * 0.2);
	ALPHA = mix(0.82, 1.0, clamp(grid + rim * 0.6, 0.0, 1.0)) * alpha_scale;
}
