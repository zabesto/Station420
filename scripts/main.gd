extends Node3D

const SYSTEM_SCALE := 1.75
const STATION_SCALE := 2.6
const DESTROYER_SCALE := 3.4
const WORLD_LIMIT := Vector3(8400, 1800, 8400)
const CAMERA_OFFSET := Vector3(0, 132, 290)
const CAMERA_VELOCITY_LEAD := 0.24
const STAR_MASS := 1900000.0
const STAR_RADIUS := 160.0
const SHIP_GRAVITY_SCALE := 0.32
const GRAVITY_CONSTANT := 2.4
const GRAVITY_SOFTENING := 1200.0
const PLAYER_FIRE_COOLDOWN := 0.18
const PLAYER_PROJECTILE_SPEED := 860.0
const ENEMY_PROJECTILE_SPEED := 420.0
const ENEMY_RESPAWN_TIME := 6.0
const ENEMY_ENGAGE_RADIUS := 1400.0
const ENEMY_FIRE_RADIUS := 840.0
const PLAYER_MAX_HULL := 100.0
const PLAYER_MAX_SHIELDS := 100.0
const SHIELD_RECHARGE_RATE := 10.0
const SHIELD_RECHARGE_DELAY := 2.6
const STAR_DAMAGE_RADIUS := 360.0
const STAR_DAMAGE_PER_SECOND := 34.0
const DEBRIS_HAZARD_THICKNESS := 26.0
const DEBRIS_DAMAGE_PER_SECOND := 11.0
const ENEMY_MAX_HULL := 40.0
const PLAYER_PROJECTILE_DAMAGE := 20.0
const ENEMY_PROJECTILE_DAMAGE := 16.0
const ENEMY_CONTACT_DAMAGE := 24.0
const PLAYER_FIRE_RANGE := 1800.0
const ENEMY_SPAWN_COUNT := 4
const PLAYER_COLLISION_RADIUS := 9.0
const PLANET_COLLISION_MARGIN := 18.0
const STAR_COLLISION_MARGIN := 34.0
const STATION_COLLISION_RADIUS := 26.0
const AUDIO_MIX_RATE := 22050.0
const MUSIC_BUFFER_SECONDS := 0.35

const PLANET_LAYOUT := [
	{
		"name": "Nereid",
		"orbit_radius": 520.0,
		"phase": 0.3,
		"mass": 5200.0,
		"radius": 26.0,
		"color": Color(0.42, 0.88, 1.0),
		"orbit_tint": Color(0.22, 0.58, 0.88),
		"tilt": 0.06
	},
	{
		"name": "Cinder",
		"orbit_radius": 960.0,
		"phase": 1.9,
		"mass": 7600.0,
		"radius": 34.0,
		"color": Color(1.0, 0.48, 0.36),
		"orbit_tint": Color(0.88, 0.42, 0.26),
		"tilt": -0.04
	},
	{
		"name": "Morrow",
		"orbit_radius": 1540.0,
		"phase": 3.4,
		"mass": 9800.0,
		"radius": 40.0,
		"color": Color(0.76, 0.88, 1.0),
		"orbit_tint": Color(0.68, 0.8, 1.0),
		"tilt": 0.03
	},
	{
		"name": "Aster",
		"orbit_radius": 2280.0,
		"phase": 5.1,
		"mass": 12800.0,
		"radius": 48.0,
		"color": Color(0.78, 1.0, 0.72),
		"orbit_tint": Color(0.52, 0.9, 0.46),
		"tilt": -0.02
	}
]

const STATION_LAYOUT := [
	{"name": "Orion Gate", "planet": "Nereid", "offset": Vector3(110, 30, 24)},
	{"name": "Lattice Port", "planet": "Nereid", "offset": Vector3(-140, -18, -42)},
	{"name": "Vela Port", "planet": "Cinder", "offset": Vector3(128, 22, 74)},
	{"name": "Mirage Ring", "planet": "Cinder", "offset": Vector3(-116, 36, -102)},
	{"name": "Cygnus Hub", "planet": "Morrow", "offset": Vector3(154, -24, -36)},
	{"name": "Kestrel Dock", "planet": "Morrow", "offset": Vector3(-168, 44, 118)},
	{"name": "Argo Spindle", "planet": "Aster", "offset": Vector3(176, 28, -132)},
	{"name": "Juniper Array", "planet": "Aster", "offset": Vector3(-188, -32, 96)}
]

@onready var player: CharacterBody3D = $Player
@onready var player_visual: MeshInstance3D = $Player/Visual
@onready var camera: Camera3D = $Camera3D
@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var title_label: Label = $CanvasLayer/HUD/TitleLabel
@onready var dock_label: Label = $CanvasLayer/HUD/DockLabel
@onready var cargo_label: Label = $CanvasLayer/HUD/CargoLabel
@onready var objective_label: Label = $CanvasLayer/HUD/ObjectiveLabel
@onready var scanner_label: Label = $CanvasLayer/HUD/ScannerLabel
@onready var message_label: Label = $CanvasLayer/HUD/MessageLabel
@onready var combat_label: Label = $CanvasLayer/HUD/CombatLabel
@onready var alert_label: Label = $CanvasLayer/HUD/AlertLabel
@onready var pause_label: Label = $CanvasLayer/HUD/PauseLabel
@onready var start_label: Label = $CanvasLayer/HUD/StartLabel
@onready var hit_label: Label = $CanvasLayer/HUD/HitLabel
@onready var settings_panel: Panel = $CanvasLayer/HUD/SettingsPanel
@onready var settings_title: Label = $CanvasLayer/HUD/SettingsPanel/SettingsTitle
@onready var preset_value: Label = $CanvasLayer/HUD/SettingsPanel/PresetValue
@onready var bloom_value: Label = $CanvasLayer/HUD/SettingsPanel/BloomValue
@onready var music_value: Label = $CanvasLayer/HUD/SettingsPanel/MusicValue
@onready var sfx_value: Label = $CanvasLayer/HUD/SettingsPanel/SfxValue
@onready var settings_hint: Label = $CanvasLayer/HUD/SettingsPanel/SettingsHint
@onready var settings_hotkeys: Label = $CanvasLayer/HUD/SettingsPanel/SettingsHotkeys

var nearby_station: Area3D = null
var dock_count := 0
var station_order: Array[Area3D] = []
var station_nodes_by_name := {}
var pickup_station := ""
var delivery_station := ""
var cargo_loaded := false
var objective_line: MeshInstance3D
var objective_marker: MeshInstance3D
var objective_flash_time := 0.0
var star_node: Node3D
var planet_bodies := []
var planet_nodes_by_name := {}
var world_root: Node3D
var enemy_target_marker: MeshInstance3D
var destroyer_fleet := []
var enemy_nodes := []
var player_projectiles := []
var enemy_projectiles := []
var transient_effects := []
var music_player: AudioStreamPlayer
var music_playback: AudioStreamGeneratorPlayback
var sfx_streams := {}
var music_time := 0.0
var music_phase_a := 0.0
var music_phase_b := 0.0
var music_phase_c := 0.0
var player_hull := PLAYER_MAX_HULL
var player_shields := PLAYER_MAX_SHIELDS
var kills := 0
var score := 0
var fire_cooldown := 0.0
var shield_recharge_delay := 0.0
var enemy_respawn_timer := 0.0
var alert_timer := 0.0
var hit_timer := 0.0
var paused := false
var game_over_state := false
var start_screen_active := true
var settings_visible := false
var visual_preset_index := 0
var bloom_enabled := true
var music_enabled := true
var sfx_enabled := true


func _ready() -> void:
	player.call("set_world_limit", WORLD_LIMIT)
	alert_label.text = ""
	hit_label.text = ""
	pause_label.visible = false
	start_label.visible = true
	settings_panel.visible = false
	if DisplayServer.get_name() != "headless":
		setup_audio()
	setup_visual_environment()
	create_starfield()
	create_star()
	create_planets()
	create_stations()
	create_shipping_lanes()
	create_navigation_beacons()
	create_destroyer_fleet()
	create_objective_visuals()
	setup_cargo_route()
	call_deferred("spawn_initial_enemies")

	player.global_position = get_random_safe_start_position()
	apply_visual_preset()

	paused = true
	title_label.text = "Station420"
	update_combat_label()
	update_settings_label()
	update_status("Press Enter to launch.\nUse Space to fire and Esc to pause once you are underway.")


func _process(delta: float) -> void:
	update_music_stream()
	update_alert(delta)
	update_hit_feedback(delta)
	update_settings_label()
	if paused:
		return

	update_camera(delta)
	update_objective_visuals(delta)
	update_enemy_target_marker()
	update_station_spin(delta)
	update_destroyer_fleet(delta)
	update_scanner()
	update_combat_label()


func _physics_process(delta: float) -> void:
	if paused:
		return

	simulate_planets(delta)
	player.call("set_gravity_acceleration", compute_ship_gravity() * SHIP_GRAVITY_SCALE)
	resolve_player_solids()
	update_player_combat(delta)
	update_hazards(delta)
	update_enemy_behavior(delta)
	update_projectiles(delta)
	update_effects(delta)
	maybe_spawn_enemies(delta)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventJoypadButton and event.pressed:
		if event.button_index == JOY_BUTTON_START:
			toggle_pause()
			return
		if event.button_index == JOY_BUTTON_Y:
			settings_visible = not settings_visible
			settings_panel.visible = settings_visible
			return
		if event.button_index == JOY_BUTTON_LEFT_SHOULDER:
			set_visual_preset((visual_preset_index + 2) % 3)
			return
		if event.button_index == JOY_BUTTON_RIGHT_SHOULDER:
			set_visual_preset((visual_preset_index + 1) % 3)
			return
		if event.button_index == JOY_BUTTON_DPAD_UP:
			bloom_enabled = not bloom_enabled
			apply_visual_preset()
			return
		if event.button_index == JOY_BUTTON_DPAD_LEFT:
			music_enabled = not music_enabled
			update_music_state()
			return
		if event.button_index == JOY_BUTTON_DPAD_RIGHT:
			sfx_enabled = not sfx_enabled
			return
		if event.button_index == JOY_BUTTON_A and game_over_state:
			restart_game()
			return
		if event.button_index == JOY_BUTTON_A and start_screen_active:
			start_run()
			return

	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ENTER and game_over_state:
		restart_game()
		return

	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		toggle_pause()
		return

	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_TAB:
		settings_visible = not settings_visible
		settings_panel.visible = settings_visible
		return

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_1:
			set_visual_preset(0)
			return
		if event.keycode == KEY_2:
			set_visual_preset(1)
			return
		if event.keycode == KEY_3:
			set_visual_preset(2)
			return
		if event.keycode == KEY_B:
			bloom_enabled = not bloom_enabled
			apply_visual_preset()
			return
		if event.keycode == KEY_M:
			music_enabled = not music_enabled
			update_music_state()
			return
		if event.keycode == KEY_N:
			sfx_enabled = not sfx_enabled
			return

	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ENTER and start_screen_active:
		start_run()
		return

	if paused:
		return

	if event is InputEventJoypadButton and event.pressed:
		if event.button_index == JOY_BUTTON_A:
			try_fire_player_projectile()
			return
		if event.button_index == JOY_BUTTON_X:
			if nearby_station:
				dock_at_station(nearby_station)
			else:
				update_status("No station in range.\nApproach a station halo, then press dock to moor.")
			return

	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
		try_fire_player_projectile()
		return

	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
		if nearby_station:
			dock_at_station(nearby_station)
		else:
			update_status("No station in range.\nApproach a station halo, then press E to dock.")


func create_starfield() -> void:
	world_root = Node3D.new()
	world_root.name = "WorldDetail"
	add_child(world_root)

	var far_stars := MeshInstance3D.new()
	far_stars.name = "FarStars"
	far_stars.mesh = build_star_mesh(420, WORLD_LIMIT, 0.45, 2.0)
	register_style_mesh(far_stars, "ambient", Color(0.82, 0.9, 1.0))
	add_child(far_stars)

	var mid_stars := MeshInstance3D.new()
	mid_stars.name = "MidStars"
	mid_stars.mesh = build_star_mesh(180, WORLD_LIMIT * 0.72, 1.2, 3.4)
	register_style_mesh(mid_stars, "ambient", Color(0.46, 0.88, 1.0))
	add_child(mid_stars)

	var dust_ribbons := MeshInstance3D.new()
	dust_ribbons.name = "DustRibbons"
	dust_ribbons.mesh = build_dust_ribbon_mesh()
	register_style_mesh(dust_ribbons, "ambient", Color(0.26, 0.6, 0.74))
	world_root.add_child(dust_ribbons)


func create_star() -> void:
	star_node = Node3D.new()
	star_node.name = "HeliosPrime"
	star_node.set_meta("collision_radius", STAR_RADIUS + STAR_COLLISION_MARGIN)
	add_child(star_node)

	var star_mesh := MeshInstance3D.new()
	star_mesh.mesh = build_planet_mesh(STAR_RADIUS)
	register_style_mesh(star_mesh, "danger", Color(1.0, 0.84, 0.28))
	star_node.add_child(star_mesh)

	var star_halo := MeshInstance3D.new()
	star_halo.mesh = build_ring_mesh(STAR_RADIUS * 1.5, 48)
	register_style_mesh(star_halo, "danger", Color(1.0, 0.64, 0.18))
	star_halo.rotation = Vector3(PI * 0.5, 0, 0)
	star_node.add_child(star_halo)

	var star_label := Label3D.new()
	star_label.position = Vector3(0, STAR_RADIUS + 18, 0)
	star_label.text = "Helios Prime"
	star_label.font_size = 48
	star_label.no_depth_test = true
	register_style_label(star_label, "label", Color(1.0, 0.88, 0.52))
	star_node.add_child(star_label)


func create_planets() -> void:
	var planets_root := Node3D.new()
	planets_root.name = "Planets"
	add_child(planets_root)

	for planet_data in PLANET_LAYOUT:
		var root := Node3D.new()
		root.name = planet_data["name"]

		var orbit_radius := float(planet_data["orbit_radius"]) * SYSTEM_SCALE
		var phase := float(planet_data["phase"])
		var tilt := float(planet_data["tilt"])
		var y_position := sin(phase * 1.7) * orbit_radius * tilt
		var start_position := Vector3(cos(phase) * orbit_radius, y_position, sin(phase) * orbit_radius)
		root.position = start_position
		var planet_radius := float(planet_data["radius"]) * SYSTEM_SCALE
		root.set_meta("collision_radius", planet_radius + PLANET_COLLISION_MARGIN)

		var planet_mesh := MeshInstance3D.new()
		planet_mesh.mesh = build_planet_mesh(planet_radius)
		register_style_mesh(planet_mesh, "planet", planet_data["color"])
		root.add_child(planet_mesh)

		var orbit_ring := MeshInstance3D.new()
		orbit_ring.mesh = build_ring_mesh(orbit_radius, 96)
		register_style_mesh(orbit_ring, "ambient", planet_data["orbit_tint"])
		orbit_ring.rotation = Vector3(tilt, 0, 0)
		add_child(orbit_ring)

		var debris_ring := MeshInstance3D.new()
		debris_ring.mesh = build_debris_belt_mesh(planet_radius + 94.0, 108.0, 72)
		register_style_mesh(debris_ring, "danger", planet_data["orbit_tint"].lerp(Color.WHITE, 0.18))
		debris_ring.rotation = Vector3(tilt * 3.4, phase * 0.25, 0)
		root.add_child(debris_ring)

		var planet_label := Label3D.new()
		planet_label.position = Vector3(0, planet_radius + 22.0, 0)
		planet_label.text = planet_data["name"]
		planet_label.font_size = 42
		planet_label.no_depth_test = true
		register_style_label(planet_label, "label", Color.WHITE)
		root.add_child(planet_label)

		planets_root.add_child(root)

		var radial_direction := start_position.normalized()
		var tangent := Vector3(-radial_direction.z, 0, radial_direction.x).normalized()
		var orbital_speed := sqrt((GRAVITY_CONSTANT * STAR_MASS) / orbit_radius)
		var velocity := tangent * orbital_speed
		velocity.y = orbital_speed * tilt * 0.18

		var body := {
			"name": planet_data["name"],
			"node": root,
			"mass": float(planet_data["mass"]) * SYSTEM_SCALE * SYSTEM_SCALE,
			"radius": planet_radius,
			"velocity": velocity
		}
		planet_bodies.append(body)
		planet_nodes_by_name[planet_data["name"]] = root


func create_stations() -> void:
	for station_data in STATION_LAYOUT:
		var parent_planet: Node3D = planet_nodes_by_name[station_data["planet"]]
		var orbit_anchor := Node3D.new()
		orbit_anchor.name = "%sAnchor" % station_data["name"]
		orbit_anchor.position = station_data["offset"] * SYSTEM_SCALE
		parent_planet.add_child(orbit_anchor)

		var station := Area3D.new()
		station.name = station_data["name"]
		station.collision_layer = 0
		station.collision_mask = 1
		station.set_meta("station_name", station_data["name"])
		station.set_meta("planet_name", station_data["planet"])
		station.set_meta("dock_offset", Vector3(0, 0, 42))
		station.set_meta("collision_radius", STATION_COLLISION_RADIUS)
		station.set_meta("spin_speed", randf_range(0.12, 0.28))
		station.body_entered.connect(_on_station_body_entered.bind(station))
		station.body_exited.connect(_on_station_body_exited.bind(station))
		orbit_anchor.add_child(station)

		var collision := CollisionShape3D.new()
		var shape := SphereShape3D.new()
		shape.radius = STATION_COLLISION_RADIUS
		collision.shape = shape
		station.add_child(collision)

		var wireframe := MeshInstance3D.new()
		wireframe.mesh = build_station_mesh(22.0 * STATION_SCALE)
		register_style_mesh(wireframe, "station", Color(1.0, 0.72, 0.34))
		station.add_child(wireframe)

		var dock_marker := MeshInstance3D.new()
		dock_marker.position = Vector3(0, 0, 42)
		dock_marker.mesh = build_dock_marker_mesh(7.4)
		register_style_mesh(dock_marker, "dock", Color(0.55, 1.0, 0.85))
		station.add_child(dock_marker)

		var station_label := Label3D.new()
		station_label.position = Vector3(0, 34.0, 0)
		station_label.text = station_data["name"]
		station_label.font_size = 36
		station_label.no_depth_test = true
		register_style_label(station_label, "label", Color.WHITE)
		station.add_child(station_label)

		station_order.append(station)
		station_nodes_by_name[station_data["name"]] = station


func create_shipping_lanes() -> void:
	for i in range(0, station_order.size(), 2):
		if i + 1 >= station_order.size():
			break
		var from_station := station_order[i]
		var to_station := station_order[i + 1]
		var parent_planet: Node3D = from_station.get_parent().get_parent()
		var lane := MeshInstance3D.new()
		lane.mesh = build_shipping_lane_mesh(
			parent_planet.to_local(from_station.global_position),
			parent_planet.to_local(to_station.global_position)
		)
		register_style_mesh(lane, "objective", Color(0.34, 0.88, 0.76))
		parent_planet.add_child(lane)


func create_navigation_beacons() -> void:
	var beacons := [
		{"label": "Spinward", "position": Vector3(0, 180, -WORLD_LIMIT.z * 0.82), "color": Color(0.52, 0.82, 1.0)},
		{"label": "Rimward", "position": Vector3(0, -160, WORLD_LIMIT.z * 0.82), "color": Color(0.48, 1.0, 0.72)},
		{"label": "Sunrise", "position": Vector3(WORLD_LIMIT.x * 0.82, 110, 0), "color": Color(1.0, 0.68, 0.34)},
		{"label": "Null Reach", "position": Vector3(-WORLD_LIMIT.x * 0.82, -90, 0), "color": Color(1.0, 0.42, 0.56)}
	]

	for beacon_data in beacons:
		var root := Node3D.new()
		root.position = beacon_data["position"]
		world_root.add_child(root)

		var mesh := MeshInstance3D.new()
		mesh.mesh = build_nav_beacon_mesh(24.0)
		register_style_mesh(mesh, "objective", beacon_data["color"])
		root.add_child(mesh)

		var label := Label3D.new()
		label.text = beacon_data["label"]
		label.position = Vector3(0, 24, 0)
		label.font_size = 32
		label.no_depth_test = true
		register_style_label(label, "label", Color.WHITE)
		root.add_child(label)


func create_destroyer_fleet() -> void:
	var fleet_layout := [
		{"name": "GDV Sovereign", "radius": WORLD_LIMIT.x * 0.54, "phase": 0.3, "height": 140.0, "speed": 0.018},
		{"name": "GDV Halberd", "radius": WORLD_LIMIT.x * 0.61, "phase": 1.7, "height": -120.0, "speed": 0.014},
		{"name": "GDV Meridian", "radius": WORLD_LIMIT.x * 0.68, "phase": 3.1, "height": 90.0, "speed": 0.011}
	]

	for destroyer_data in fleet_layout:
		var destroyer := Node3D.new()
		destroyer.name = destroyer_data["name"]
		destroyer.set_meta("orbit_radius", destroyer_data["radius"])
		destroyer.set_meta("phase", destroyer_data["phase"])
		destroyer.set_meta("height", destroyer_data["height"])
		destroyer.set_meta("speed", destroyer_data["speed"])
		destroyer.position = compute_destroyer_position(
			float(destroyer_data["radius"]),
			float(destroyer_data["phase"]),
			float(destroyer_data["height"])
		)

		var mesh := MeshInstance3D.new()
		mesh.mesh = build_destroyer_mesh(42.0 * DESTROYER_SCALE)
		register_style_mesh(mesh, "station", Color(0.74, 0.88, 1.0))
		destroyer.add_child(mesh)

		var label := Label3D.new()
		label.text = destroyer_data["name"]
		label.position = Vector3(0, 36, 0)
		label.font_size = 30
		label.no_depth_test = true
		register_style_label(label, "label", Color.WHITE)
		destroyer.add_child(label)

		add_child(destroyer)
		destroyer_fleet.append(destroyer)


func create_objective_visuals() -> void:
	objective_line = MeshInstance3D.new()
	objective_line.name = "ObjectiveLine"
	register_style_mesh(objective_line, "objective", Color(0.5, 0.95, 0.7))
	add_child(objective_line)

	objective_marker = MeshInstance3D.new()
	objective_marker.name = "ObjectiveMarker"
	register_style_mesh(objective_marker, "objective", Color(0.45, 1.0, 0.85))
	add_child(objective_marker)

	enemy_target_marker = MeshInstance3D.new()
	enemy_target_marker.name = "EnemyTargetMarker"
	enemy_target_marker.mesh = build_enemy_target_marker_mesh(14.0)
	register_style_mesh(enemy_target_marker, "target", Color(1.0, 0.52, 0.42))
	enemy_target_marker.visible = false
	add_child(enemy_target_marker)


func update_station_spin(delta: float) -> void:
	for station in station_order:
		if is_instance_valid(station):
			station.rotate_y(float(station.get_meta("spin_speed", 0.18)) * delta)
			station.rotate_x(float(station.get_meta("spin_speed", 0.18)) * delta * 0.32)


func update_destroyer_fleet(delta: float) -> void:
	for destroyer in destroyer_fleet:
		if not is_instance_valid(destroyer):
			continue
		var phase: float = float(destroyer.get_meta("phase")) + float(destroyer.get_meta("speed")) * delta
		destroyer.set_meta("phase", phase)
		var position := compute_destroyer_position(
			float(destroyer.get_meta("orbit_radius")),
			phase,
			float(destroyer.get_meta("height"))
		)
		destroyer.global_position = position
		var next_position := compute_destroyer_position(
			float(destroyer.get_meta("orbit_radius")),
			phase + 0.02,
			float(destroyer.get_meta("height"))
		)
		destroyer.look_at(next_position, Vector3.UP, true)


func compute_destroyer_position(orbit_radius: float, phase: float, height: float) -> Vector3:
	return Vector3(
		cos(phase) * orbit_radius,
		height + sin(phase * 2.0) * 42.0,
		sin(phase) * orbit_radius
	)


func simulate_planets(delta: float) -> void:
	var accelerations := []
	accelerations.resize(planet_bodies.size())

	for i in range(planet_bodies.size()):
		var body_node: Node3D = planet_bodies[i]["node"]
		var body_position := body_node.global_position
		var total_accel := compute_star_gravity(body_position)

		for j in range(planet_bodies.size()):
			if i == j:
				continue
			var other_position: Vector3 = planet_bodies[j]["node"].global_position
			var delta_vector := other_position - body_position
			var softened_distance_sq := delta_vector.length_squared() + GRAVITY_SOFTENING
			var accel_magnitude := GRAVITY_CONSTANT * float(planet_bodies[j]["mass"]) / softened_distance_sq
			total_accel += delta_vector.normalized() * accel_magnitude

		accelerations[i] = total_accel

	for i in range(planet_bodies.size()):
		var velocity: Vector3 = planet_bodies[i]["velocity"]
		velocity += accelerations[i] * delta
		planet_bodies[i]["velocity"] = velocity

		var node: Node3D = planet_bodies[i]["node"]
		node.global_position += velocity * delta
		node.rotate_y(delta * 0.06)


func compute_star_gravity(position: Vector3) -> Vector3:
	var delta_vector := -position
	var softened_distance_sq := delta_vector.length_squared() + GRAVITY_SOFTENING
	var accel_magnitude := GRAVITY_CONSTANT * STAR_MASS / softened_distance_sq
	return delta_vector.normalized() * accel_magnitude


func compute_ship_gravity() -> Vector3:
	var total_gravity := compute_star_gravity(player.global_position)
	for body in planet_bodies:
		var body_position: Vector3 = body["node"].global_position
		var delta_vector := body_position - player.global_position
		var softened_distance_sq := delta_vector.length_squared() + GRAVITY_SOFTENING * 0.35
		var accel_magnitude := GRAVITY_CONSTANT * float(body["mass"]) / softened_distance_sq
		total_gravity += delta_vector.normalized() * accel_magnitude
	return total_gravity


func resolve_player_solids() -> void:
	var blocked := false
	blocked = resolve_body_against_sphere(
		player,
		star_node.global_position,
		float(star_node.get_meta("collision_radius")),
		PLAYER_COLLISION_RADIUS
	) or blocked

	for body in planet_bodies:
		var planet_node: Node3D = body["node"]
		blocked = resolve_body_against_sphere(
			player,
			planet_node.global_position,
			float(planet_node.get_meta("collision_radius")),
			PLAYER_COLLISION_RADIUS
		) or blocked

	for station in station_order:
		blocked = resolve_body_against_sphere(
			player,
			station.global_position,
			float(station.get_meta("collision_radius")),
			PLAYER_COLLISION_RADIUS
		) or blocked

	if blocked:
		set_alert("Collision alarm")


func resolve_body_against_sphere(
	body: CharacterBody3D,
	sphere_center: Vector3,
	sphere_radius: float,
	body_radius: float
) -> bool:
	var offset := body.global_position - sphere_center
	var min_distance := sphere_radius + body_radius
	var distance_sq := offset.length_squared()
	if distance_sq >= min_distance * min_distance:
		return false

	var normal := Vector3.UP
	if distance_sq > 0.0001:
		normal = offset / sqrt(distance_sq)

	body.global_position = sphere_center + normal * min_distance
	var inward_speed := body.velocity.dot(normal)
	if inward_speed < 0.0:
		body.velocity -= normal * inward_speed
	return true


func dock_at_station(station: Area3D) -> void:
	player.global_position = station.global_position + station.get_meta("dock_offset")
	player.velocity = Vector3.ZERO
	dock_count += 1
	objective_flash_time = 0.35

	var station_name := str(station.get_meta("station_name"))
	title_label.text = "Docked"
	dock_label.text = "Docked: %s (%d)" % [station_name, dock_count]
	play_sfx("dock")
	handle_cargo_dock(station_name)


func update_status(message: String) -> void:
	message_label.text = message


func update_alert(delta: float) -> void:
	if alert_timer > 0.0:
		alert_timer = max(alert_timer - delta, 0.0)
		if alert_timer == 0.0:
			alert_label.text = ""


func set_alert(message: String, duration: float = 0.7) -> void:
	alert_label.text = message
	alert_timer = duration
	if duration >= 0.4:
		play_sfx("alert")


func setup_visual_environment() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	world_environment.environment = environment


func get_preset_name(index: int) -> String:
	match index:
		1:
			return "Toon Combat"
		2:
			return "Hologram Drift"
		_:
			return "Neon Wireframe"


func set_visual_preset(index: int) -> void:
	visual_preset_index = clamp(index, 0, 2)
	apply_visual_preset()


func apply_visual_preset() -> void:
	if world_environment.environment == null:
		setup_visual_environment()
	var environment := world_environment.environment
	match visual_preset_index:
		1:
			environment.background_color = Color(0.08, 0.07, 0.09)
			environment.ambient_light_color = Color(0.95, 0.78, 0.58)
			environment.ambient_light_energy = 0.75
			environment.fog_enabled = true
			environment.fog_light_color = Color(0.46, 0.34, 0.22)
			environment.fog_density = 0.00095
		2:
			environment.background_color = Color(0.03, 0.12, 0.12)
			environment.ambient_light_color = Color(0.34, 0.95, 0.82)
			environment.ambient_light_energy = 0.58
			environment.fog_enabled = true
			environment.fog_light_color = Color(0.1, 0.66, 0.62)
			environment.fog_density = 0.0006
		_:
			environment.background_color = Color(0.05, 0.07, 0.12)
			environment.ambient_light_color = Color(0.42, 0.84, 1.0)
			environment.ambient_light_energy = 0.62
			environment.fog_enabled = true
			environment.fog_light_color = Color(0.18, 0.54, 0.88)
			environment.fog_density = 0.00075

	environment.glow_enabled = bloom_enabled
	environment.glow_intensity = 0.78 if bloom_enabled else 0.0
	environment.glow_strength = 0.95 if bloom_enabled else 0.0
	environment.glow_bloom = 0.18 if bloom_enabled else 0.0
	environment.tonemap_exposure = 1.1 if visual_preset_index == 0 else 1.0

	for node in get_tree().get_nodes_in_group("style_mesh"):
		apply_mesh_style(node)
	for node in get_tree().get_nodes_in_group("style_label"):
		apply_label_style(node)
	apply_player_style()
	apply_hud_style()


func register_style_mesh(mesh: MeshInstance3D, role: String, base_color: Color) -> void:
	mesh.set_meta("style_role", role)
	mesh.set_meta("style_base_color", base_color)
	if not mesh.is_in_group("style_mesh"):
		mesh.add_to_group("style_mesh")
	apply_mesh_style(mesh)


func register_style_label(label: Label3D, role: String, base_color: Color = Color.WHITE) -> void:
	label.set_meta("style_role", role)
	label.set_meta("style_base_color", base_color)
	if not label.is_in_group("style_label"):
		label.add_to_group("style_label")
	apply_label_style(label)


func apply_mesh_style(mesh: MeshInstance3D) -> void:
	var role := str(mesh.get_meta("style_role", "world"))
	var base_color: Color = mesh.get_meta("style_base_color", Color.WHITE)
	mesh.material_override = build_style_material(role, base_color)


func apply_label_style(label: Label3D) -> void:
	var role := str(label.get_meta("style_role", "label"))
	var base_color: Color = label.get_meta("style_base_color", Color.WHITE)
	label.modulate = resolve_style_color(role, base_color)


func build_style_material(role: String, base_color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	var color := resolve_style_color(role, base_color)
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	if visual_preset_index == 2 and role not in ["enemy", "danger"]:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.albedo_color.a = 0.58
	return material


func resolve_style_color(role: String, base_color: Color) -> Color:
	match visual_preset_index:
		1:
			if role in ["enemy", "danger", "alert"]:
				return Color(1.0, 0.45, 0.26)
			if role in ["target", "objective", "dock"]:
				return Color(1.0, 0.86, 0.3)
			return quantize_color(base_color.lerp(Color(1.0, 0.82, 0.58), 0.22), 0.26)
		2:
			if role in ["enemy", "danger", "alert"]:
				return Color(1.0, 0.38, 0.44)
			if role in ["target", "objective", "dock"]:
				return Color(0.62, 1.0, 0.88)
			return base_color.lerp(Color(0.26, 1.0, 0.86), 0.5)
		_:
			if role in ["enemy", "danger", "alert"]:
				return Color(1.0, 0.5, 0.34)
			if role in ["target", "objective", "dock"]:
				return Color(0.58, 1.0, 0.84)
			return base_color.lerp(Color(0.36, 0.95, 1.0), 0.16)


func quantize_color(color: Color, step: float) -> Color:
	return Color(
		snappedf(color.r, step),
		snappedf(color.g, step),
		snappedf(color.b, step),
		color.a
	)


func apply_player_style() -> void:
	register_style_mesh(player_visual, "player", Color(0.45, 0.88, 1.0))
	var engine_glow := player_visual.get_node_or_null("EngineGlow")
	if engine_glow is MeshInstance3D:
		register_style_mesh(engine_glow, "objective", Color(0.5, 0.95, 1.0))
	var trail := player.get_node_or_null("Trail")
	if trail is MeshInstance3D:
		register_style_mesh(trail, "objective", Color(0.55, 0.95, 1.0))


func apply_hud_style() -> void:
	var hud_color := Color(0.76, 0.92, 1.0)
	var accent_color := Color(0.56, 1.0, 0.86)
	var alert_color := Color(1.0, 0.58, 0.46)
	match visual_preset_index:
		1:
			hud_color = Color(1.0, 0.9, 0.72)
			accent_color = Color(1.0, 0.82, 0.34)
			alert_color = Color(1.0, 0.48, 0.3)
		2:
			hud_color = Color(0.68, 1.0, 0.9)
			accent_color = Color(0.32, 1.0, 0.82)
			alert_color = Color(1.0, 0.45, 0.54)
	title_label.modulate = accent_color
	dock_label.modulate = hud_color
	cargo_label.modulate = hud_color
	objective_label.modulate = accent_color
	scanner_label.modulate = hud_color
	message_label.modulate = hud_color
	combat_label.modulate = hud_color
	alert_label.modulate = alert_color
	hit_label.modulate = alert_color
	pause_label.modulate = accent_color
	start_label.modulate = accent_color
	settings_panel.modulate = Color(hud_color.r, hud_color.g, hud_color.b, 0.95)
	settings_title.modulate = accent_color
	preset_value.modulate = hud_color
	bloom_value.modulate = hud_color
	music_value.modulate = hud_color
	sfx_value.modulate = hud_color
	settings_hint.modulate = accent_color
	settings_hotkeys.modulate = hud_color


func update_settings_label() -> void:
	preset_value.text = "Preset: %s" % get_preset_name(visual_preset_index)
	bloom_value.text = "Bloom: %s" % ("On" if bloom_enabled else "Off")
	music_value.text = "Music: %s" % ("On" if music_enabled else "Off")
	sfx_value.text = "SFX: %s" % ("On" if sfx_enabled else "Off")


func update_hit_feedback(delta: float) -> void:
	if hit_timer > 0.0:
		hit_timer = max(hit_timer - delta, 0.0)
		if hit_timer == 0.0:
			hit_label.text = ""


func show_hit_feedback(message: String) -> void:
	hit_label.text = message
	hit_timer = 0.55


func start_run() -> void:
	start_screen_active = false
	start_label.visible = false
	paused = false
	title_label.text = "Wireframe System"
	update_status("Launch confirmed.\nRun cargo, avoid hazards, and clear hostile drones.")


func toggle_pause() -> void:
	if game_over_state or start_screen_active:
		return
	paused = not paused
	pause_label.visible = paused
	if paused:
		pause_label.text = "Paused\nPress Esc to resume"
		title_label.text = "Paused"
	else:
		title_label.text = "Wireframe System"


func restart_game() -> void:
	get_tree().reload_current_scene()


func update_combat_label() -> void:
	var target_info := "Target none"
	var target := get_primary_enemy_target()
	if target != null:
		target_info = "Target %.0fm" % player.global_position.distance_to(target.global_position)
	combat_label.text = "Hull %d\nShields %d\nContacts %d\nScore %d\nKills %d\n%s" % [
		int(round(player_hull)),
		int(round(player_shields)),
		enemy_nodes.size(),
		score,
		kills,
		target_info
	]


func update_player_combat(delta: float) -> void:
	fire_cooldown = max(fire_cooldown - delta, 0.0)
	shield_recharge_delay = max(shield_recharge_delay - delta, 0.0)
	if shield_recharge_delay == 0.0 and player_shields < PLAYER_MAX_SHIELDS:
		player_shields = min(player_shields + SHIELD_RECHARGE_RATE * delta, PLAYER_MAX_SHIELDS)


func try_fire_player_projectile() -> void:
	if game_over_state or fire_cooldown > 0.0:
		return
	fire_cooldown = PLAYER_FIRE_COOLDOWN
	var origin: Vector3 = player.call("get_muzzle_position")
	var direction: Vector3 = player.call("get_aim_direction")
	spawn_projectile(origin, direction * PLAYER_PROJECTILE_SPEED + player.velocity * 0.35, true)
	play_sfx("player_fire")
	set_alert("Pulse fired", 0.2)


func spawn_initial_enemies() -> void:
	for i in range(ENEMY_SPAWN_COUNT):
		spawn_enemy()


func maybe_spawn_enemies(delta: float) -> void:
	if game_over_state:
		return
	if enemy_nodes.size() >= ENEMY_SPAWN_COUNT:
		enemy_respawn_timer = 0.0
		return
	enemy_respawn_timer += delta
	if enemy_respawn_timer >= ENEMY_RESPAWN_TIME:
		enemy_respawn_timer = 0.0
		spawn_enemy()


func spawn_enemy() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var radial := Vector3(rng.randf_range(-1.0, 1.0), rng.randf_range(-0.2, 0.2), rng.randf_range(-1.0, 1.0)).normalized()
	var tangent := Vector3(-radial.z, 0, radial.x).normalized()
	var spawn_position := player.global_position + radial * rng.randf_range(340.0, 620.0) + tangent * rng.randf_range(-180.0, 180.0)

	var enemy := Node3D.new()
	enemy.name = "Drone"
	enemy.position = spawn_position
	enemy.set_meta("velocity", Vector3.ZERO)
	enemy.set_meta("hull", ENEMY_MAX_HULL)
	enemy.set_meta("fire_cooldown", rng.randf_range(0.8, 1.6))
	enemy.set_meta("orbit_bias", rng.randf_range(-1.0, 1.0))

	var mesh := MeshInstance3D.new()
	mesh.mesh = build_enemy_ship_mesh()
	register_style_mesh(mesh, "enemy", Color(1.0, 0.46, 0.34))
	enemy.add_child(mesh)

	add_child(enemy)
	enemy_nodes.append(enemy)


func update_enemy_behavior(delta: float) -> void:
	for i in range(enemy_nodes.size() - 1, -1, -1):
		var enemy: Node3D = enemy_nodes[i]
		if not is_instance_valid(enemy):
			enemy_nodes.remove_at(i)
			continue

		var to_player := player.global_position - enemy.global_position
		var distance := to_player.length()
		var direction := to_player.normalized() if distance > 0.001 else Vector3.FORWARD
		var lateral := Vector3(-direction.z, 0, direction.x) * float(enemy.get_meta("orbit_bias")) * 55.0
		var desired_velocity := direction * 130.0 + lateral
		if distance < 220.0:
			desired_velocity = -direction * 110.0 + lateral

		var velocity: Vector3 = enemy.get_meta("velocity")
		velocity = velocity.lerp(desired_velocity, min(delta * 1.4, 1.0))
		enemy.set_meta("velocity", velocity)
		enemy.global_position += velocity * delta
		if velocity.length() > 2.0:
			enemy.look_at(enemy.global_position + velocity.normalized(), Vector3.UP, true)

		var cooldown: float = enemy.get_meta("fire_cooldown")
		cooldown = max(cooldown - delta, 0.0)
		if distance <= ENEMY_FIRE_RADIUS and cooldown == 0.0 and not game_over_state:
			spawn_projectile(enemy.global_position - enemy.global_basis.z * 6.0, direction * ENEMY_PROJECTILE_SPEED, false)
			play_sfx("enemy_fire", -9.0)
			cooldown = 1.5
		enemy.set_meta("fire_cooldown", cooldown)

		if distance > ENEMY_ENGAGE_RADIUS * 2.6:
			enemy.global_position = player.global_position - direction * ENEMY_ENGAGE_RADIUS

		if distance < 18.0:
			damage_player(ENEMY_CONTACT_DAMAGE, "Drone collision", enemy.global_position)
			create_burst(enemy.global_position, Color(1.0, 0.48, 0.38))
			enemy.queue_free()
			enemy_nodes.remove_at(i)


func spawn_projectile(origin: Vector3, velocity: Vector3, from_player: bool) -> void:
	var projectile := Node3D.new()
	projectile.name = "Pulse"
	projectile.global_position = origin
	projectile.set_meta("velocity", velocity)
	projectile.set_meta("from_player", from_player)
	projectile.set_meta("life", 0.0)

	var mesh := MeshInstance3D.new()
	mesh.mesh = build_projectile_mesh()
	register_style_mesh(mesh, "objective" if from_player else "enemy", Color(0.55, 0.95, 1.0) if from_player else Color(1.0, 0.54, 0.42))
	projectile.add_child(mesh)

	add_child(projectile)
	if from_player:
		player_projectiles.append(projectile)
	else:
		enemy_projectiles.append(projectile)


func update_projectiles(delta: float) -> void:
	update_projectile_list(player_projectiles, delta, true)
	update_projectile_list(enemy_projectiles, delta, false)


func update_projectile_list(projectiles: Array, delta: float, from_player: bool) -> void:
	for i in range(projectiles.size() - 1, -1, -1):
		var projectile: Node3D = projectiles[i]
		if not is_instance_valid(projectile):
			projectiles.remove_at(i)
			continue

		var velocity: Vector3 = projectile.get_meta("velocity")
		projectile.global_position += velocity * delta
		projectile.look_at(projectile.global_position + velocity.normalized(), Vector3.UP, true)

		var lifetime: float = projectile.get_meta("life") + delta
		projectile.set_meta("life", lifetime)
		if lifetime > 2.4 or projectile.global_position.length() > WORLD_LIMIT.length() * 1.1:
			projectile.queue_free()
			projectiles.remove_at(i)
			continue

		if from_player:
			if handle_player_projectile_hit(projectile):
				projectiles.remove_at(i)
		else:
			if handle_enemy_projectile_hit(projectile):
				projectiles.remove_at(i)


func handle_player_projectile_hit(projectile: Node3D) -> bool:
	for i in range(enemy_nodes.size() - 1, -1, -1):
		var enemy: Node3D = enemy_nodes[i]
		if not is_instance_valid(enemy):
			enemy_nodes.remove_at(i)
			continue
		if projectile.global_position.distance_to(enemy.global_position) <= 20.0:
			var hull: float = enemy.get_meta("hull") - PLAYER_PROJECTILE_DAMAGE
			enemy.set_meta("hull", hull)
			create_burst(projectile.global_position, Color(0.68, 0.96, 1.0))
			projectile.queue_free()
			if hull <= 0.0:
				kills += 1
				score += 100
				create_burst(enemy.global_position, Color(1.0, 0.56, 0.38))
				play_sfx("enemy_down")
				enemy.queue_free()
				enemy_nodes.remove_at(i)
				set_alert("Drone down", 0.45)
			return true
	return false


func handle_enemy_projectile_hit(projectile: Node3D) -> bool:
	if projectile.global_position.distance_to(player.global_position) <= PLAYER_COLLISION_RADIUS + 4.0:
		damage_player(ENEMY_PROJECTILE_DAMAGE, "Incoming fire", projectile.global_position)
		create_burst(projectile.global_position, Color(1.0, 0.56, 0.42))
		projectile.queue_free()
		return true
	return false


func update_hazards(delta: float) -> void:
	if game_over_state:
		return
	var star_distance: float = player.global_position.length()
	if star_distance < STAR_DAMAGE_RADIUS:
		var heat_scale: float = 1.0 - clamp((star_distance - STAR_RADIUS) / max(STAR_DAMAGE_RADIUS - STAR_RADIUS, 1.0), 0.0, 1.0)
		damage_player(STAR_DAMAGE_PER_SECOND * heat_scale * delta, "Solar flare")

	for body in planet_bodies:
		var planet_node: Node3D = body["node"]
		var ring_centered := player.global_position - planet_node.global_position
		var ring_radius: float = body["radius"] + 54.0
		var planar_distance: float = Vector2(ring_centered.x, ring_centered.z).length()
		var ring_offset: float = abs(planar_distance - ring_radius)
		if ring_offset <= DEBRIS_HAZARD_THICKNESS and abs(ring_centered.y) <= 28.0 and player.velocity.length() > 110.0:
			damage_player(DEBRIS_DAMAGE_PER_SECOND * delta, "%s debris field" % body["name"])


func damage_player(amount: float, reason: String, source_position: Vector3 = Vector3.ZERO) -> void:
	if game_over_state:
		return
	shield_recharge_delay = SHIELD_RECHARGE_DELAY
	if player_shields > 0.0:
		var absorbed: float = min(player_shields, amount)
		player_shields -= absorbed
		amount -= absorbed
	if amount > 0.0:
		player_hull = max(player_hull - amount, 0.0)
	create_burst(player.global_position, Color(1.0, 0.8, 0.46) if player_shields > 0.0 else Color(1.0, 0.4, 0.36))
	play_sfx("hit")
	set_alert(reason, 0.45)
	show_hit_feedback(build_hit_message(reason, source_position))
	if player_hull <= 0.0:
		trigger_game_over(reason)


func trigger_game_over(reason: String) -> void:
	game_over_state = true
	paused = true
	title_label.text = "Ship Lost"
	pause_label.visible = true
	pause_label.text = "Ship Lost\n%s\nPress Enter to restart" % reason
	play_sfx("loss")
	update_status("Run ended.\nPress Enter to restart the patrol.")


func setup_audio() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	var generator := AudioStreamGenerator.new()
	generator.mix_rate = AUDIO_MIX_RATE
	generator.buffer_length = MUSIC_BUFFER_SECONDS
	music_player.stream = generator
	music_player.volume_db = -15.0
	add_child(music_player)
	music_player.play()
	music_playback = music_player.get_stream_playback()
	sfx_streams["player_fire"] = build_player_fire_stream()
	sfx_streams["enemy_fire"] = build_enemy_fire_stream()
	sfx_streams["dock"] = build_dock_stream()
	sfx_streams["hit"] = build_hit_stream()
	sfx_streams["alert"] = build_alert_stream()
	sfx_streams["enemy_down"] = build_enemy_down_stream()
	sfx_streams["loss"] = build_loss_stream()
	update_music_state()
	update_music_stream()


func update_music_stream() -> void:
	if music_playback == null:
		return
	var frames_available := music_playback.get_frames_available()
	if frames_available <= 0:
		return

	var progression := [55.0, 82.41, 73.42, 98.0]
	var accent := [220.0, 246.94, 196.0, 164.81]
	for i in range(frames_available):
		var chord_index := int(floor(music_time / 3.2)) % progression.size()
		var beat_phase := fmod(music_time, 0.8) / 0.8
		var low_freq: float = progression[chord_index]
		var high_freq: float = accent[chord_index]
		music_phase_a += TAU * low_freq / AUDIO_MIX_RATE
		music_phase_b += TAU * (low_freq * 1.5) / AUDIO_MIX_RATE
		music_phase_c += TAU * high_freq / AUDIO_MIX_RATE
		var drone := sin(music_phase_a) * 0.16 + sin(music_phase_b) * 0.08
		var shimmer_gate := pow(max(0.0, sin(beat_phase * PI)), 3.0)
		var shimmer := sin(music_phase_c) * shimmer_gate * 0.035
		var pulse := sin(music_time * TAU * 0.125) * 0.015
		var sample: float = clamp(drone + shimmer + pulse, -0.45, 0.45)
		music_playback.push_frame(Vector2(sample, sample))
		music_time += 1.0 / AUDIO_MIX_RATE


func play_sfx(name: String, volume_db: float = -6.0) -> void:
	if not sfx_enabled:
		return
	var stream: AudioStreamWAV = sfx_streams.get(name, null)
	if stream == null:
		return
	var player_node := AudioStreamPlayer.new()
	player_node.stream = stream
	player_node.volume_db = volume_db
	add_child(player_node)
	player_node.finished.connect(player_node.queue_free)
	player_node.play()


func update_music_state() -> void:
	if music_player == null:
		return
	music_player.volume_db = -15.0 if music_enabled else -80.0


func get_random_safe_start_position() -> Vector3:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for _attempt in range(48):
		var candidate := Vector3(
			rng.randf_range(-WORLD_LIMIT.x * 0.72, WORLD_LIMIT.x * 0.72),
			rng.randf_range(-WORLD_LIMIT.y * 0.55, WORLD_LIMIT.y * 0.55),
			rng.randf_range(-WORLD_LIMIT.z * 0.72, WORLD_LIMIT.z * 0.72)
		)
		if is_position_safe_for_spawn(candidate):
			return candidate
	return Vector3(0, 240, STAR_DAMAGE_RADIUS + 260.0)


func is_position_safe_for_spawn(position: Vector3) -> bool:
	if position.length() < STAR_DAMAGE_RADIUS + 220.0:
		return false
	for body in planet_bodies:
		var node: Node3D = body["node"]
		if position.distance_to(node.global_position) < float(node.get_meta("collision_radius")) + 180.0:
			return false
	for station in station_order:
		if position.distance_to(station.global_position) < float(station.get_meta("collision_radius")) + 120.0:
			return false
	return true


func build_player_fire_stream() -> AudioStreamWAV:
	return build_tone_stream([660.0, 820.0, 980.0], 0.12, 0.22, 0.16, 0.9)


func build_enemy_fire_stream() -> AudioStreamWAV:
	return build_tone_stream([240.0, 210.0, 180.0], 0.16, 0.24, 0.1, 0.7)


func build_dock_stream() -> AudioStreamWAV:
	return build_tone_stream([330.0, 440.0, 554.37], 0.34, 0.2, 0.12, 0.8)


func build_hit_stream() -> AudioStreamWAV:
	return build_noise_stream(0.18, 0.26, 0.55)


func build_alert_stream() -> AudioStreamWAV:
	return build_tone_stream([523.25, 659.25], 0.18, 0.18, 0.1, 0.75)


func build_enemy_down_stream() -> AudioStreamWAV:
	return build_tone_stream([220.0, 164.81, 123.47], 0.28, 0.24, 0.14, 0.85)


func build_loss_stream() -> AudioStreamWAV:
	return build_tone_stream([196.0, 146.83, 110.0, 82.41], 0.6, 0.2, 0.18, 0.95)


func build_tone_stream(
	frequencies: Array,
	duration: float,
	amplitude: float,
	vibrato_depth: float,
	decay_power: float
) -> AudioStreamWAV:
	var sample_count := int(AUDIO_MIX_RATE * duration)
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	var phase := 0.0
	for i in range(sample_count):
		var t := float(i) / AUDIO_MIX_RATE
		var envelope := pow(max(0.0, 1.0 - t / duration), decay_power)
		var freq: float = frequencies[min(int(floor(t / duration * frequencies.size())), frequencies.size() - 1)]
		var modulated_freq := freq * (1.0 + sin(t * TAU * 5.0) * vibrato_depth * 0.02)
		phase += TAU * modulated_freq / AUDIO_MIX_RATE
		var sample := sin(phase) * amplitude * envelope + sin(phase * 0.5) * amplitude * 0.18 * envelope
		write_pcm16_sample(data, i, sample)
	return create_wav_stream(data)


func build_noise_stream(duration: float, amplitude: float, decay_power: float) -> AudioStreamWAV:
	var sample_count := int(AUDIO_MIX_RATE * duration)
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var filter := 0.0
	for i in range(sample_count):
		var t := float(i) / AUDIO_MIX_RATE
		var envelope := pow(max(0.0, 1.0 - t / duration), decay_power)
		filter = lerp(filter, rng.randf_range(-1.0, 1.0), 0.42)
		var sample := filter * amplitude * envelope
		write_pcm16_sample(data, i, sample)
	return create_wav_stream(data)


func write_pcm16_sample(data: PackedByteArray, index: int, sample: float) -> void:
	var clamped: float = clamp(sample, -1.0, 1.0)
	var pcm := int(round(clamped * 32767.0))
	if pcm < 0:
		pcm += 65536
	data[index * 2] = pcm & 0xff
	data[index * 2 + 1] = (pcm >> 8) & 0xff


func create_wav_stream(data: PackedByteArray) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.data = data
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = AUDIO_MIX_RATE
	stream.stereo = false
	return stream


func build_hit_message(reason: String, source_position: Vector3) -> String:
	if source_position == Vector3.ZERO:
		return reason
	var to_source := (source_position - player.global_position).normalized()
	var alignment: float = player.call("get_aim_direction").dot(to_source)
	if alignment > 0.45:
		return "%s ahead" % reason
	if alignment < -0.45:
		return "%s aft" % reason
	var side := "port"
	if to_source.dot(player.global_basis.x) > 0.0:
		side = "starboard"
	return "%s %s" % [reason, side]


func get_primary_enemy_target() -> Node3D:
	var closest: Node3D = null
	var closest_distance := INF
	for enemy in enemy_nodes:
		if not is_instance_valid(enemy):
			continue
		var distance := player.global_position.distance_to(enemy.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest = enemy
	return closest


func update_enemy_target_marker() -> void:
	var target := get_primary_enemy_target()
	if target == null:
		enemy_target_marker.visible = false
		return
	enemy_target_marker.visible = true
	enemy_target_marker.global_position = target.global_position + Vector3(0, 16, 0)
	enemy_target_marker.rotate_y(0.02)


func create_burst(position: Vector3, color: Color) -> void:
	var burst := MeshInstance3D.new()
	burst.mesh = build_burst_mesh(8.0)
	register_style_mesh(burst, "alert", color)
	burst.global_position = position
	burst.set_meta("life", 0.0)
	add_child(burst)
	transient_effects.append(burst)


func update_effects(delta: float) -> void:
	for i in range(transient_effects.size() - 1, -1, -1):
		var effect: MeshInstance3D = transient_effects[i]
		if not is_instance_valid(effect):
			transient_effects.remove_at(i)
			continue
		var life: float = effect.get_meta("life") + delta
		effect.set_meta("life", life)
		effect.scale = Vector3.ONE * (1.0 + life * 3.2)
		effect.rotate_y(delta * 2.8)
		if life > 0.35:
			effect.queue_free()
			transient_effects.remove_at(i)


func update_camera(delta: float) -> void:
	var lead := player.velocity * CAMERA_VELOCITY_LEAD
	var desired := player.global_position + CAMERA_OFFSET + lead
	camera.global_position = camera.global_position.lerp(desired, min(delta * 1.45, 1.0))
	var look_target := player.global_position + player.velocity * 0.1 + Vector3(0, 6, -10)
	camera.look_at(look_target, Vector3.UP)


func update_objective_visuals(delta: float) -> void:
	if objective_flash_time > 0.0:
		objective_flash_time = max(objective_flash_time - delta, 0.0)

	var target_station := get_target_station()
	if target_station == null:
		objective_line.visible = false
		objective_marker.visible = false
		return

	var station_position := target_station.global_position
	var pulse := 1.0 + sin(Time.get_ticks_msec() * 0.002) * 0.14
	objective_marker.global_position = station_position + Vector3(0, 0, 18)
	objective_marker.mesh = build_ring_mesh(8.5 * pulse, 36)
	objective_marker.visible = true

	var line_color := Color(0.5, 0.95, 0.7)
	if objective_flash_time > 0.0:
		line_color = Color(1.0, 1.0, 1.0)
	objective_line.set_meta("style_base_color", line_color)
	apply_mesh_style(objective_line)
	objective_line.mesh = build_line_mesh(PackedVector3Array([
		player.global_position,
		station_position + Vector3(0, 0, 18)
	]))
	objective_line.visible = true

	update_objective_label(target_station)


func update_scanner() -> void:
	var lines := PackedStringArray()
	lines.append("Scanner:")
	lines.append("Star Dist  %.0f" % player.global_position.length())
	lines.append("Gravity    %.2f" % compute_ship_gravity().length())
	lines.append("Speed      %.1f" % player.velocity.length())
	lines.append("Boost      %s" % ("online" if Input.is_key_pressed(KEY_SHIFT) else "idle"))
	lines.append("")

	for station in station_order:
		var station_name := str(station.get_meta("station_name"))
		var planet_name := str(station.get_meta("planet_name"))
		var distance := player.global_position.distance_to(station.global_position)
		var marker := "  "
		if station_name == pickup_station and not cargo_loaded:
			marker = "> "
		elif station_name == delivery_station and cargo_loaded:
			marker = "> "
		lines.append("%s%s [%s] %.0fm" % [marker, station_name, planet_name, distance])

	scanner_label.text = "\n".join(lines)


func get_target_station() -> Area3D:
	var target_name := pickup_station
	if cargo_loaded:
		target_name = delivery_station
	return station_nodes_by_name.get(target_name, null)


func update_objective_label(target_station: Area3D) -> void:
	var target_name := str(target_station.get_meta("station_name"))
	var planet_name := str(target_station.get_meta("planet_name"))
	var distance := player.global_position.distance_to(target_station.global_position)
	var stage := "Pickup"
	if cargo_loaded:
		stage = "Deliver"
	objective_label.text = "Objective: %s at %s / %s (%.0fm)" % [stage, target_name, planet_name, distance]


func _on_station_body_entered(body: Node3D, station: Area3D) -> void:
	if body != player:
		return
	nearby_station = station
	title_label.text = "Approach"
	update_status("Press E to dock at %s.\nYou are in %s orbit." % [str(station.get_meta("station_name")), str(station.get_meta("planet_name"))])


func _on_station_body_exited(body: Node3D, station: Area3D) -> void:
	if body != player:
		return
	if nearby_station == station:
		nearby_station = null
		title_label.text = "Wireframe System"
		update_status("WASD move, R/F rise and descend.\nHold Shift to boost toward the active shipping corridor.")


func setup_cargo_route() -> void:
	if station_order.size() < 2:
		cargo_label.text = "Cargo: unavailable"
		objective_label.text = "Objective: unavailable"
		return

	cargo_loaded = false
	pickup_station = str(station_order[0].get_meta("station_name"))
	delivery_station = str(station_order[6].get_meta("station_name"))
	cargo_label.text = "Cargo: pick up at %s, deliver to %s" % [pickup_station, delivery_station]
	objective_label.text = "Objective: pickup at %s" % pickup_station


func handle_cargo_dock(station_name: String) -> void:
	if station_name == pickup_station and not cargo_loaded:
		cargo_loaded = true
		title_label.text = "Cargo Loaded"
		cargo_label.text = "Cargo: loaded at %s, deliver to %s" % [pickup_station, delivery_station]
		update_status("Cargo loaded at %s.\nNow travel across the system to %s." % [pickup_station, delivery_station])
		return

	if station_name == delivery_station and cargo_loaded:
		cargo_loaded = false
		title_label.text = "Cargo Delivered"
		update_status("Delivery complete at %s.\nA new long-haul route has been assigned." % delivery_station)
		advance_cargo_route()
		return

	if station_name == delivery_station and not cargo_loaded:
		update_status("This is %s.\nYou still need to load cargo at %s first." % [delivery_station, pickup_station])
		return

	update_status("Dock complete at %s.\nCurrent route: %s to %s." % [station_name, pickup_station, delivery_station])


func advance_cargo_route() -> void:
	var pickup_index := station_name_index(pickup_station)
	var delivery_index := station_name_index(delivery_station)

	pickup_station = str(station_order[(pickup_index + 3) % station_order.size()].get_meta("station_name"))
	delivery_station = str(station_order[(delivery_index + 5) % station_order.size()].get_meta("station_name"))
	if pickup_station == delivery_station:
		delivery_station = str(station_order[(delivery_index + 6) % station_order.size()].get_meta("station_name"))

	cargo_label.text = "Cargo: pick up at %s, deliver to %s" % [pickup_station, delivery_station]
	objective_label.text = "Objective: pickup at %s" % pickup_station


func station_name_index(name: String) -> int:
	for i in range(station_order.size()):
		if str(station_order[i].get_meta("station_name")) == name:
			return i
	return 0


func make_line_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	return material


func build_star_mesh(count: int, extents: Vector3, min_size: float, max_size: float) -> ArrayMesh:
	var vertices := PackedVector3Array()
	var rng := RandomNumberGenerator.new()
	rng.seed = 4606

	for i in range(count):
		var center := Vector3(
			rng.randf_range(-extents.x, extents.x),
			rng.randf_range(-extents.y, extents.y),
			rng.randf_range(-extents.z, extents.z)
		)
		var size := rng.randf_range(min_size, max_size)
		vertices.append_array([
			center + Vector3(-size, 0, 0), center + Vector3(size, 0, 0),
			center + Vector3(0, -size, 0), center + Vector3(0, size, 0),
			center + Vector3(0, 0, -size), center + Vector3(0, 0, size)
		])

	return build_line_mesh(vertices)


func build_planet_mesh(radius: float) -> ArrayMesh:
	var vertices := PackedVector3Array()
	vertices.append_array(build_circle_vertices(radius, 56, Vector3.RIGHT, Vector3.UP))
	vertices.append_array(build_circle_vertices(radius, 56, Vector3.RIGHT, Vector3.FORWARD))
	vertices.append_array(build_circle_vertices(radius, 56, Vector3.UP, Vector3.FORWARD))
	return build_line_mesh(vertices)


func build_station_mesh(size: float) -> ArrayMesh:
	var s := size
	var top := Vector3(0, s, 0)
	var bottom := Vector3(0, -s, 0)
	var east := Vector3(s, 0, 0)
	var west := Vector3(-s, 0, 0)
	var north := Vector3(0, 0, -s)
	var south := Vector3(0, 0, s)
	var upper_ring := [
		Vector3(s * 0.55, s * 0.45, 0),
		Vector3(0, s * 0.45, s * 0.55),
		Vector3(-s * 0.55, s * 0.45, 0),
		Vector3(0, s * 0.45, -s * 0.55)
	]
	var lower_ring := [
		Vector3(s * 0.55, -s * 0.45, 0),
		Vector3(0, -s * 0.45, s * 0.55),
		Vector3(-s * 0.55, -s * 0.45, 0),
		Vector3(0, -s * 0.45, -s * 0.55)
	]
	var vertices := PackedVector3Array([
		top, east, top, south, top, west, top, north,
		bottom, east, bottom, south, bottom, west, bottom, north,
		east, south, south, west, west, north, north, east
	])
	for i in range(upper_ring.size()):
		vertices.append(upper_ring[i])
		vertices.append(upper_ring[(i + 1) % upper_ring.size()])
		vertices.append(lower_ring[i])
		vertices.append(lower_ring[(i + 1) % lower_ring.size()])
		vertices.append(upper_ring[i])
		vertices.append(lower_ring[i])
		vertices.append(top)
		vertices.append(upper_ring[i])
		vertices.append(bottom)
		vertices.append(lower_ring[i])
	for i in range(upper_ring.size()):
		vertices.append(upper_ring[i])
		vertices.append(lower_ring[(i + 1) % lower_ring.size()])
	return build_line_mesh(vertices)


func build_dock_marker_mesh(radius: float) -> ArrayMesh:
	var vertices := PackedVector3Array([
		Vector3(-radius, 0, 0), Vector3(radius, 0, 0),
		Vector3(0, -radius, 0), Vector3(0, radius, 0),
		Vector3(0, 0, -radius), Vector3(0, 0, radius)
	])
	return build_line_mesh(vertices)


func build_ring_mesh(radius: float, segments: int) -> ArrayMesh:
	return build_line_mesh(build_circle_vertices(radius, segments, Vector3.RIGHT, Vector3.UP))


func build_shipping_lane_mesh(from_point: Vector3, to_point: Vector3) -> ArrayMesh:
	var vertices := PackedVector3Array()
	var segments := 18
	var midpoint := (from_point + to_point) * 0.5
	var lift := midpoint.normalized() * 38.0
	var previous := from_point
	for i in range(1, segments + 1):
		var t := float(i) / float(segments)
		var point := from_point.lerp(to_point, t) + sin(t * PI) * lift
		vertices.append(previous)
		vertices.append(point)
		previous = point
	return build_line_mesh(vertices)


func build_debris_belt_mesh(radius: float, spread: float, count: int) -> ArrayMesh:
	var vertices := PackedVector3Array()
	var rng := RandomNumberGenerator.new()
	rng.seed = int(radius * 13.0)
	for i in range(count):
		var angle := rng.randf_range(0.0, TAU)
		var distance := radius + rng.randf_range(-spread, spread)
		var center := Vector3(cos(angle) * distance, rng.randf_range(-10.0, 10.0), sin(angle) * distance)
		var size := rng.randf_range(2.4, 6.0)
		vertices.append_array([
			center + Vector3(-size, 0, 0), center + Vector3(size, 0, 0),
			center + Vector3(0, -size * 0.6, 0), center + Vector3(0, size * 0.6, 0),
			center + Vector3(0, 0, -size), center + Vector3(0, 0, size)
		])
	return build_line_mesh(vertices)


func build_nav_beacon_mesh(radius: float) -> ArrayMesh:
	var vertices := PackedVector3Array([
		Vector3(0, radius, 0), Vector3(radius * 0.5, 0, 0),
		Vector3(radius * 0.5, 0, 0), Vector3(0, -radius, 0),
		Vector3(0, -radius, 0), Vector3(-radius * 0.5, 0, 0),
		Vector3(-radius * 0.5, 0, 0), Vector3(0, radius, 0),
		Vector3(0, 0, -radius * 0.7), Vector3(0, 0, radius * 0.7)
	])
	return build_line_mesh(vertices)


func build_enemy_ship_mesh() -> ArrayMesh:
	var vertices := PackedVector3Array([
		Vector3(0, 0, -8), Vector3(5, 0, 4),
		Vector3(5, 0, 4), Vector3(0, 2.6, 7),
		Vector3(0, 2.6, 7), Vector3(-5, 0, 4),
		Vector3(-5, 0, 4), Vector3(0, 0, -8),
		Vector3(-7, 0, 1), Vector3(-2, 0, 4),
		Vector3(7, 0, 1), Vector3(2, 0, 4),
		Vector3(0, -2.2, 5), Vector3(0, 2.6, 7)
	])
	return build_line_mesh(vertices)


func build_destroyer_mesh(length: float) -> ArrayMesh:
	var half := length * 0.5
	var beam := length * 0.12
	var tower := length * 0.09
	var vertices := PackedVector3Array([
		Vector3(0, 0, -half), Vector3(beam, 0, half * 0.4),
		Vector3(beam, 0, half * 0.4), Vector3(beam * 1.4, 0, half),
		Vector3(beam * 1.4, 0, half), Vector3(-beam * 1.4, 0, half),
		Vector3(-beam * 1.4, 0, half), Vector3(-beam, 0, half * 0.4),
		Vector3(-beam, 0, half * 0.4), Vector3(0, 0, -half),
		Vector3(-beam * 0.8, tower, -half * 0.15), Vector3(beam * 0.8, tower, -half * 0.15),
		Vector3(beam * 0.8, tower, -half * 0.15), Vector3(beam * 0.45, tower * 1.6, half * 0.12),
		Vector3(beam * 0.45, tower * 1.6, half * 0.12), Vector3(-beam * 0.45, tower * 1.6, half * 0.12),
		Vector3(-beam * 0.45, tower * 1.6, half * 0.12), Vector3(-beam * 0.8, tower, -half * 0.15),
		Vector3(-beam * 1.1, 0, half * 0.72), Vector3(-beam * 1.9, 0, half),
		Vector3(beam * 1.1, 0, half * 0.72), Vector3(beam * 1.9, 0, half),
		Vector3(-beam * 0.55, -tower * 0.55, half * 0.9), Vector3(beam * 0.55, -tower * 0.55, half * 0.9)
	])
	return build_line_mesh(vertices)


func build_enemy_target_marker_mesh(radius: float) -> ArrayMesh:
	var inner := radius * 0.48
	var vertices := PackedVector3Array([
		Vector3(-radius, 0, -radius), Vector3(-inner, 0, -inner),
		Vector3(radius, 0, -radius), Vector3(inner, 0, -inner),
		Vector3(-radius, 0, radius), Vector3(-inner, 0, inner),
		Vector3(radius, 0, radius), Vector3(inner, 0, inner)
	])
	return build_line_mesh(vertices)


func build_projectile_mesh() -> ArrayMesh:
	var vertices := PackedVector3Array([
		Vector3(0, 0, -2.8), Vector3(0, 0, 2.8),
		Vector3(-0.8, 0, 1.4), Vector3(0.8, 0, 1.4),
		Vector3(0, -0.8, 1.4), Vector3(0, 0.8, 1.4)
	])
	return build_line_mesh(vertices)


func build_burst_mesh(radius: float) -> ArrayMesh:
	var vertices := PackedVector3Array([
		Vector3(-radius, 0, 0), Vector3(radius, 0, 0),
		Vector3(0, -radius, 0), Vector3(0, radius, 0),
		Vector3(0, 0, -radius), Vector3(0, 0, radius),
		Vector3(-radius * 0.7, -radius * 0.7, 0), Vector3(radius * 0.7, radius * 0.7, 0),
		Vector3(-radius * 0.7, radius * 0.7, 0), Vector3(radius * 0.7, -radius * 0.7, 0)
	])
	return build_line_mesh(vertices)


func build_dust_ribbon_mesh() -> ArrayMesh:
	var vertices := PackedVector3Array()
	var rng := RandomNumberGenerator.new()
	rng.seed = 7781
	for ribbon in range(5):
		var previous := Vector3(
			-WORLD_LIMIT.x * 0.8,
			rng.randf_range(-WORLD_LIMIT.y * 0.6, WORLD_LIMIT.y * 0.6),
			rng.randf_range(-WORLD_LIMIT.z * 0.7, WORLD_LIMIT.z * 0.7)
		)
		for i in range(1, 22):
			var point := Vector3(
				lerp(-WORLD_LIMIT.x * 0.8, WORLD_LIMIT.x * 0.8, float(i) / 21.0),
				previous.y + rng.randf_range(-34.0, 34.0),
				previous.z + rng.randf_range(-160.0, 160.0)
			)
			vertices.append(previous)
			vertices.append(point)
			previous = point
	return build_line_mesh(vertices)


func build_circle_vertices(radius: float, segments: int, axis_a: Vector3, axis_b: Vector3) -> PackedVector3Array:
	var vertices := PackedVector3Array()
	for i in range(segments):
		var a0 := TAU * float(i) / float(segments)
		var a1 := TAU * float(i + 1) / float(segments)
		var p0 := axis_a * cos(a0) * radius + axis_b * sin(a0) * radius
		var p1 := axis_a * cos(a1) * radius + axis_b * sin(a1) * radius
		vertices.append(p0)
		vertices.append(p1)
	return vertices


func build_line_mesh(vertices: PackedVector3Array) -> ArrayMesh:
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices

	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	return mesh
