shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform int effect_mode = 1;
uniform float threshold = 0.5;
uniform float strength = 0.7;
uniform float glow_strength = 0.55;
uniform float darken = 0.12;
uniform float halo_radius = 1.85;
uniform vec3 edge_tint = vec3(0.18, 0.92, 1.0);
uniform float aux_mix = 0.35;

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

vec3 blur_scene(vec2 uv, vec2 px, float radius) {
	vec3 sum = textureLod(screen_texture, uv, 0.0).rgb * 0.36;
	sum += textureLod(screen_texture, uv + vec2(px.x * radius, 0.0), 0.0).rgb * 0.16;
	sum += textureLod(screen_texture, uv + vec2(-px.x * radius, 0.0), 0.0).rgb * 0.16;
	sum += textureLod(screen_texture, uv + vec2(0.0, px.y * radius), 0.0).rgb * 0.16;
	sum += textureLod(screen_texture, uv + vec2(0.0, -px.y * radius), 0.0).rgb * 0.16;
	return sum;
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
	vec3 final_color = scene;

	if (effect_mode == 0) {
		final_color = mix(scene, scene + edge_color * 0.35, glow_strength * 0.25);
	} else if (effect_mode == 1) {
		vec3 shaded_scene = scene * (1.0 - edge * darken);
		final_color = shaded_scene + edge_color * (0.75 + halo * 0.85);
	} else if (effect_mode == 2) {
		vec3 toon = floor(scene * (3.0 + aux_mix * 4.0)) / (3.0 + aux_mix * 4.0);
		final_color = mix(scene, toon, 0.72) + edge_color * 0.62;
	} else if (effect_mode == 3) {
		float shift = (0.6 + aux_mix * 2.0) * px.x;
		vec3 glass;
		glass.r = textureLod(screen_texture, SCREEN_UV + vec2(shift, 0.0), 0.0).r;
		glass.g = textureLod(screen_texture, SCREEN_UV, 0.0).g;
		glass.b = textureLod(screen_texture, SCREEN_UV - vec2(shift, 0.0), 0.0).b;
		final_color = mix(scene, glass, 0.42) + edge_color * 0.4;
	} else if (effect_mode == 4) {
		vec3 blurred = blur_scene(SCREEN_UV, px, 1.0 + aux_mix * 3.0);
		final_color = mix(scene, blurred, 0.65);
	} else if (effect_mode == 5) {
		float cells = mix(88.0, 18.0, aux_mix);
		vec2 cell_uv = floor(SCREEN_UV * cells) / cells;
		vec3 block = textureLod(screen_texture, cell_uv, 0.0).rgb;
		float tone = luminance(block);
		float glyph = step(0.2, tone) + step(0.4, tone) + step(0.6, tone) + step(0.8, tone);
		vec3 ascii_color = mix(vec3(0.02, 0.03, 0.04), edge_tint * 0.95, glyph / 4.0);
		final_color = mix(scene, ascii_color, 0.78) + edge_color * 0.22;
	} else if (effect_mode == 6) {
		vec3 cold = mix(scene, vec3(luminance(scene)) * edge_tint, 0.52 + aux_mix * 0.18);
		final_color = cold + edge_color * 0.55;
	} else if (effect_mode == 7) {
		vec2 centered_uv = SCREEN_UV * 2.0 - 1.0;
		float vignette = clamp(1.0 - dot(centered_uv * 0.82, centered_uv * 0.82), 0.0, 1.0);
		float scanline = 0.9 + sin((SCREEN_UV.y / max(px.y, 0.00001)) * 0.85) * 0.08;
		float grille = 0.94 + sin((SCREEN_UV.x / max(px.x, 0.00001)) * 1.05) * 0.05;
		vec3 crt = scene * scanline * grille * mix(0.72, 1.0, vignette);
		final_color = crt + edge_color * 0.18;
	} else if (effect_mode == 8) {
		float tone = luminance(scene);
		float grain = fract(sin(dot(floor(SCREEN_UV / max(px * 2.0, vec2(0.00001))), vec2(127.1, 311.7))) * 43758.5453123);
		vec3 night = mix(vec3(0.01, 0.02, 0.01), vec3(0.22, 0.96, 0.32), tone);
		final_color = night * (0.82 + grain * 0.18) + edge_color * 0.16;
	} else if (effect_mode == 9) {
		float heat = luminance(scene);
		vec3 thermal = mix(vec3(0.04, 0.02, 0.12), vec3(0.26, 0.08, 0.56), smoothstep(0.0, 0.22, heat));
		thermal = mix(thermal, vec3(0.96, 0.22, 0.12), smoothstep(0.2, 0.62, heat));
		thermal = mix(thermal, vec3(1.0, 0.92, 0.62), smoothstep(0.58, 1.0, heat));
		final_color = thermal + edge_color * 0.12;
	} else {
		float tone = luminance(scene);
		vec2 grid_uv = abs(fract(SCREEN_UV * mix(48.0, 120.0, 1.0 - aux_mix)) - 0.5);
		float grid = 1.0 - smoothstep(0.44, 0.5, min(grid_uv.x, grid_uv.y) * 2.0);
		vec3 blueprint = mix(vec3(0.02, 0.04, 0.12), vec3(0.08, 0.2, 0.42), tone * 0.4);
		vec3 line = mix(vec3(0.26, 0.86, 1.0), edge_tint, 0.35);
		final_color = blueprint + line * (edge * 0.7 + grid * 0.18 + halo * 0.2);
	}
	COLOR = vec4(final_color, 1.0);
}
