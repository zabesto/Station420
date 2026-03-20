extends Control

var hud_color := Color(0.78, 0.92, 1.0)
var accent_color := Color(0.56, 1.0, 0.86)
var alert_color := Color(1.0, 0.58, 0.46)
var star_marker := Vector2.ZERO
var station_markers: Array[Dictionary] = []
var hostile_markers: Array[Dictionary] = []
var target_marker := Vector2.ZERO
var target_visible := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_theme_colors(hud: Color, accent: Color, alert: Color) -> void:
	hud_color = hud
	accent_color = accent
	alert_color = alert
	queue_redraw()


func set_map_data(star_pos: Vector2, stations: Array[Dictionary], hostiles: Array[Dictionary], target_pos: Vector2, has_target: bool) -> void:
	star_marker = star_pos
	station_markers = stations
	hostile_markers = hostiles
	target_marker = target_pos
	target_visible = has_target
	queue_redraw()


func _draw() -> void:
	var rect: Rect2 = Rect2(Vector2.ZERO, size)
	if rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return
	var center: Vector2 = rect.size * 0.5
	var radius: float = min(rect.size.x, rect.size.y) * 0.42
	draw_rect(rect, Color(0.02, 0.03, 0.05, 0.78), true)
	draw_rect(rect, Color(accent_color.r, accent_color.g, accent_color.b, 0.32), false, 2.0)
	draw_arc(center, radius, 0.0, TAU, 72, Color(hud_color.r, hud_color.g, hud_color.b, 0.42), 1.5, true)
	draw_arc(center, radius * 0.66, 0.0, TAU, 64, Color(hud_color.r, hud_color.g, hud_color.b, 0.18), 1.0, true)
	draw_line(center + Vector2(-radius, 0.0), center + Vector2(radius, 0.0), Color(hud_color.r, hud_color.g, hud_color.b, 0.16), 1.0)
	draw_line(center + Vector2(0.0, -radius), center + Vector2(0.0, radius), Color(hud_color.r, hud_color.g, hud_color.b, 0.16), 1.0)

	_draw_marker(center, star_marker, 4.0, Color(1.0, 0.84, 0.42), true)
	for station in station_markers:
		var pos: Vector2 = station.get("pos", Vector2.ZERO)
		var is_target: bool = station.get("target", false)
		var marker_color: Color = accent_color if not is_target else Color.WHITE
		var marker_center: Vector2 = center + pos * radius
		draw_rect(Rect2(marker_center - Vector2.ONE * 3.0, Vector2.ONE * 6.0), Color(marker_color.r, marker_color.g, marker_color.b, 0.9), true)
		if is_target:
			draw_arc(marker_center, 8.0, 0.0, TAU, 24, Color(accent_color.r, accent_color.g, accent_color.b, 0.7), 1.4, true)

	for hostile in hostile_markers:
		var pos: Vector2 = hostile.get("pos", Vector2.ZERO)
		_draw_marker(center, pos, 3.6, alert_color, true)

	if target_visible:
		var target_center: Vector2 = center + target_marker * radius
		draw_arc(target_center, 10.0, 0.0, TAU, 28, Color(accent_color.r, accent_color.g, accent_color.b, 0.78), 1.5, true)
		draw_circle(target_center, 1.8, Color(accent_color.r, accent_color.g, accent_color.b, 0.9))

	var ship_points := PackedVector2Array([
		center + Vector2(0.0, -10.0),
		center + Vector2(-6.0, 7.0),
		center + Vector2(0.0, 3.0),
		center + Vector2(6.0, 7.0)
	])
	draw_colored_polygon(ship_points, Color(hud_color.r, hud_color.g, hud_color.b, 0.94))


func _draw_marker(center: Vector2, normalized_pos: Vector2, radius: float, color: Color, filled: bool) -> void:
	var point: Vector2 = center + normalized_pos * min(size.x, size.y) * 0.42
	if filled:
		draw_circle(point, radius, Color(color.r, color.g, color.b, 0.92))
	else:
		draw_arc(point, radius, 0.0, TAU, 18, Color(color.r, color.g, color.b, 0.92), 1.0, true)
