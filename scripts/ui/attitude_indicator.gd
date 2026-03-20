extends Control

var hud_color := Color(0.78, 0.92, 1.0)
var accent_color := Color(0.56, 1.0, 0.86)
var upper_color := Color(0.24, 0.78, 1.0)
var lower_color := Color(0.96, 0.52, 0.24)
var sun_color := Color(1.0, 0.92, 0.58)
var roll_angle := 0.0
var pitch_normalized := 0.0
var sun_angle := 0.0
var grid_enabled := true


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_theme_colors(hud: Color, accent: Color, upper: Color, lower: Color, sun: Color) -> void:
	hud_color = hud
	accent_color = accent
	upper_color = upper
	lower_color = lower
	sun_color = sun
	queue_redraw()


func set_indicator_state(roll: float, pitch: float, sun: float, show_grid: bool) -> void:
	roll_angle = roll
	pitch_normalized = clamp(pitch, -1.0, 1.0)
	sun_angle = sun
	grid_enabled = show_grid
	queue_redraw()


func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	if rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return
	var center := rect.size * 0.5
	var radius: float = min(rect.size.x, rect.size.y) * 0.42
	var horizon_offset: float = pitch_normalized * radius * 0.82
	draw_rect(rect, Color(0.02, 0.03, 0.05, 0.86), true)

	var sky_points := _build_horizon_polygon(center, radius, roll_angle, horizon_offset, true)
	var ground_points := _build_horizon_polygon(center, radius, roll_angle, horizon_offset, false)
	draw_colored_polygon(sky_points, Color(upper_color.r, upper_color.g, upper_color.b, 0.92))
	draw_colored_polygon(ground_points, Color(lower_color.r, lower_color.g, lower_color.b, 0.9))

	if grid_enabled:
		_draw_horizon_ladder(center, radius, horizon_offset)
	draw_circle(center, radius * 0.995, Color(0.01, 0.02, 0.03, 0.78))
	draw_arc(center, radius, 0.0, TAU, 90, Color(hud_color.r, hud_color.g, hud_color.b, 0.82), 1.6, true)
	draw_arc(center, radius * 0.68, 0.0, TAU, 72, Color(hud_color.r, hud_color.g, hud_color.b, 0.2), 1.0, true)
	draw_line(center + Vector2(-radius, 0.0), center + Vector2(-radius * 0.34, 0.0), Color(hud_color.r, hud_color.g, hud_color.b, 0.74), 1.6)
	draw_line(center + Vector2(radius * 0.34, 0.0), center + Vector2(radius, 0.0), Color(hud_color.r, hud_color.g, hud_color.b, 0.74), 1.6)
	draw_line(center + Vector2(0.0, -radius), center + Vector2(0.0, -radius * 0.36), Color(hud_color.r, hud_color.g, hud_color.b, 0.4), 1.0)
	draw_line(center + Vector2(0.0, radius * 0.36), center + Vector2(0.0, radius), Color(hud_color.r, hud_color.g, hud_color.b, 0.4), 1.0)
	_draw_sun_marker(center, radius)
	_draw_center_reticle(center)


func _build_horizon_polygon(center: Vector2, radius: float, angle: float, offset: float, upper: bool) -> PackedVector2Array:
	var tangent := Vector2.RIGHT.rotated(angle)
	var normal := Vector2.UP.rotated(angle)
	var horizon_center := center + normal * offset
	var span := radius * 3.2
	var depth := radius * 3.6
	var sign := -1.0 if upper else 1.0
	return PackedVector2Array([
		horizon_center - tangent * span,
		horizon_center + tangent * span,
		horizon_center + tangent * span + normal * depth * sign,
		horizon_center - tangent * span + normal * depth * sign,
	])


func _draw_horizon_ladder(center: Vector2, radius: float, offset: float) -> void:
	var tangent := Vector2.RIGHT.rotated(roll_angle)
	var normal := Vector2.UP.rotated(roll_angle)
	for step in range(-3, 4):
		var y_offset := offset + float(step) * radius * 0.2
		if abs(y_offset) > radius * 1.2:
			continue
		var rung_center := center + normal * y_offset
		var rung_width := radius * (0.58 if step == 0 else 0.38)
		var alpha := 0.62 if step == 0 else 0.34
		draw_line(
			rung_center - tangent * rung_width,
			rung_center + tangent * rung_width,
			Color(hud_color.r, hud_color.g, hud_color.b, alpha),
			1.2
		)


func _draw_sun_marker(center: Vector2, radius: float) -> void:
	var marker_radius := radius * 0.82
	var marker_pos := center + Vector2.UP.rotated(sun_angle) * marker_radius
	draw_arc(marker_pos, 8.0, 0.0, TAU, 22, Color(sun_color.r, sun_color.g, sun_color.b, 0.9), 1.3, true)
	draw_line(marker_pos + Vector2(-5.0, 0.0), marker_pos + Vector2(5.0, 0.0), Color(sun_color.r, sun_color.g, sun_color.b, 0.9), 1.2)
	draw_line(marker_pos + Vector2(0.0, -5.0), marker_pos + Vector2(0.0, 5.0), Color(sun_color.r, sun_color.g, sun_color.b, 0.9), 1.2)


func _draw_center_reticle(center: Vector2) -> void:
	draw_arc(center, 18.0, 0.0, TAU, 36, Color(accent_color.r, accent_color.g, accent_color.b, 0.36), 1.0, true)
	draw_line(center + Vector2(-16.0, 0.0), center + Vector2(-4.0, 0.0), Color(hud_color.r, hud_color.g, hud_color.b, 0.92), 1.5)
	draw_line(center + Vector2(4.0, 0.0), center + Vector2(16.0, 0.0), Color(hud_color.r, hud_color.g, hud_color.b, 0.92), 1.5)
	draw_line(center + Vector2(0.0, -16.0), center + Vector2(0.0, -4.0), Color(hud_color.r, hud_color.g, hud_color.b, 0.72), 1.2)
	draw_line(center + Vector2(0.0, 4.0), center + Vector2(0.0, 16.0), Color(hud_color.r, hud_color.g, hud_color.b, 0.72), 1.2)
