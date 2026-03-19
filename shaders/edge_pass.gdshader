shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float threshold = 0.16;
uniform float strength = 1.55;
uniform float glow_strength = 1.12;
uniform float darken = 0.12;
uniform float halo_radius = 1.85;
uniform vec3 edge_tint = vec3(0.18, 0.92, 1.0);

float luminance(vec3 color) {
	return dot(color, vec3(0.299, 0.587, 0.114));
}

float sobel_edge(vec2 uv, vec2 px) {
	float tl = luminance(textureLod(screen_texture, uv + vec2(-px.x, -px.y), 0.0).rgb);
	float  t = luminance(textureLod(screen_texture, uv + vec2(0.0, -px.y), 0.0).rgb);
	float tr = luminance(textureLod(screen_texture, uv + vec2(px.x, -px.y), 0.0).rgb);
	float  l = luminance(textureLod(screen_texture, uv + vec2(-px.x, 0.0), 0.0).rgb);
	float  r = luminance(textureLod(screen_texture, uv + vec2(px.x, 0.0), 0.0).rgb);
	float bl = luminance(textureLod(screen_texture, uv + vec2(-px.x, px.y), 0.0).rgb);
	float  b = luminance(textureLod(screen_texture, uv + vec2(0.0, px.y), 0.0).rgb);
	float br = luminance(textureLod(screen_texture, uv + vec2(px.x, px.y), 0.0).rgb);

	float gx = -tl - 2.0 * l - bl + tr + 2.0 * r + br;
	float gy = -tl - 2.0 * t - tr + bl + 2.0 * b + br;
	return length(vec2(gx, gy));
}

void fragment() {
	vec2 px = SCREEN_PIXEL_SIZE;
	vec3 scene = textureLod(screen_texture, SCREEN_UV, 0.0).rgb;
	float center_edge = sobel_edge(SCREEN_UV, px) * strength;
	float edge = smoothstep(threshold, threshold + 0.22, center_edge);
	float halo = 0.0;
	halo += sobel_edge(SCREEN_UV + vec2(px.x * halo_radius, 0.0), px);
	halo += sobel_edge(SCREEN_UV + vec2(-px.x * halo_radius, 0.0), px);
	halo += sobel_edge(SCREEN_UV + vec2(0.0, px.y * halo_radius), px);
	halo += sobel_edge(SCREEN_UV + vec2(0.0, -px.y * halo_radius), px);
	halo = smoothstep(threshold * 0.42, threshold + 0.18, halo * 0.25 * strength);

	vec3 edge_color = edge_tint * edge + edge_tint * halo * glow_strength * 0.55;
	vec3 shaded_scene = scene * (1.0 - edge * darken);
	vec3 final_color = shaded_scene + edge_color * (0.6 + halo * 0.7);
	COLOR = vec4(final_color, 1.0);
}
