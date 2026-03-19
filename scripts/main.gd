extends Node3D

const SYSTEM_SCALE := 35.0
const STATION_SCALE := 8.0
const DESTROYER_SCALE := 3.4
const WORLD_LIMIT := Vector3(120000, 18000, 120000)
const CAMERA_OFFSET := Vector3(0, 132, 290)
const CAMERA_MIN_DISTANCE := 8.0
const CAMERA_MAX_DISTANCE := 28.0
const CLOSE_VIEW_DISTANCE := 32.0
const CHASE_CAMERA_NEAR := 0.5
const COCKPIT_CAMERA_NEAR := 0.05
const CAMERA_MOUSE_SENSITIVITY := 0.005
const FIRST_PERSON_MOUSE_SENSITIVITY := 0.0024
const CAMERA_FOCUS_OFFSET := Vector3(0, 0.9, 0)
const CONTROLLER_CAMERA_DEADZONE := 0.28
const CONTROLLER_CAMERA_SPEED := Vector2(2.6, 1.9)
const CHASE_BIAS_DELAY := 0.8
const CHASE_BIAS_SPEED := 0.42
const CHASE_PITCH_TARGET := -0.14
const CINEMATIC_IDLE_DELAY := 60.0
const CINEMATIC_BLEND_IN_SPEED := 0.42
const CINEMATIC_BLEND_OUT_SPEED := 1.8
const CINEMATIC_BAR_HEIGHT := 92.0
const STAR_MASS := 1900000.0
const STAR_RADIUS := 3200.0
const RINGWORLD_ORBIT_RADIUS := 42000.0
const RINGWORLD_STATION_RADIUS := 4200.0
const RINGWORLD_DOCK_OFFSET := 900.0
const SHIP_GRAVITY_SCALE := 0.32
const GRAVITY_CONSTANT := 2.4
const GRAVITY_SOFTENING := 1200.0
const PLAYER_FIRE_COOLDOWN := 0.18
const PLAYER_PROJECTILE_SPEED := 860.0
const ENEMY_PROJECTILE_SPEED := 420.0
const ENEMY_RESPAWN_TIME := 6.0
const ENEMY_ENGAGE_RADIUS := 1400.0
const ENEMY_FIRE_RADIUS := 840.0
const ENEMY_FIELD_SPAWN_MIN_DISTANCE := 1800.0
const ENEMY_FIELD_RESPAWN_MIN_DISTANCE := 1200.0
const ENEMY_AMBUSH_WAKE_RADIUS := 900.0
const ENEMY_FIELD_PATROL_RADIUS := 82.0
const ENEMY_FIELD_PATROL_SPEED := 68.0
const PLAYER_MAX_HULL := 100.0
const PLAYER_MAX_SHIELDS := 100.0
const SHIELD_RECHARGE_RATE := 10.0
const SHIELD_RECHARGE_DELAY := 2.6
const STAR_DAMAGE_RADIUS := 7200.0
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
const PLANET_COLLISION_MARGIN := 120.0
const STAR_COLLISION_MARGIN := 320.0
const STATION_COLLISION_RADIUS := 120.0
const AUDIO_MIX_RATE := 22050.0
const MUSIC_BUFFER_SECONDS := 0.35
const MUSIC_VOLUME_BIAS_DB := -4.0
const DEFAULTS_SAVE_PATH := "user://debug_defaults.json"
const AUTOPILOT_APPROACH_FACTOR := 0.82
const AUTOPILOT_APPROACH_MIN := 320.0
const AUTOPILOT_APPROACH_MAX := 1600.0
const AUTOPILOT_ALIGN_FACTOR := 0.28
const AUTOPILOT_ALIGN_MIN := 90.0
const AUTOPILOT_ALIGN_MAX := 320.0
const AUTOPILOT_DEPART_FACTOR := 0.72
const AUTOPILOT_DEPART_MIN := 360.0
const AUTOPILOT_DEPART_MAX := 1900.0
const AUTOPILOT_DOCK_DURATION := 1.6
const AUTOPILOT_DOCK_HOLD := 1.35
const AUTOPILOT_LAUNCH_DURATION := 1.9
const AUTOPILOT_ARM_DURATION := 3.0
const AUTOPILOT_TURN_DURATION := 1.8
const AUTOPILOT_CRUISE_LEAD := 0.42
const AUTOPILOT_ALIGN_LEAD := 0.28
const AUTOPILOT_LAUNCH_LEAD := 0.34

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
	{"name": "Orion Gate", "planet": "Nereid", "offset": Vector3(260, 56, 120)},
	{"name": "Vela Port", "planet": "Cinder", "offset": Vector3(-340, 84, -210)},
	{"name": "Cygnus Hub", "planet": "Morrow", "offset": Vector3(420, -72, 180)},
	{"name": "Argo Spindle", "planet": "Aster", "offset": Vector3(-520, 96, -260)}
]

@onready var player: CharacterBody3D = $Player
@onready var player_visual: MeshInstance3D = $Player/Visual
@onready var camera: Camera3D = $Camera3D
@onready var world_environment: WorldEnvironment = $WorldEnvironment
@onready var blur_pass: ColorRect = $CanvasLayer/BlurPass
@onready var edge_pass: ColorRect = $CanvasLayer/EdgePass
@onready var title_label: Label = $CanvasLayer/HUD/TitleLabel
@onready var debug_save_defaults_button: Button = $CanvasLayer/HUD/DebugSaveDefaultsButton
@onready var cinematic_top_bar: ColorRect = $CanvasLayer/HUD/CinematicTopBar
@onready var cinematic_bottom_bar: ColorRect = $CanvasLayer/HUD/CinematicBottomBar
@onready var dock_label: Label = $CanvasLayer/HUD/DockLabel
@onready var cargo_label: Label = $CanvasLayer/HUD/CargoLabel
@onready var objective_label: Label = $CanvasLayer/HUD/ObjectiveLabel
@onready var scanner_label: Label = $CanvasLayer/HUD/ScannerLabel
@onready var message_label: Label = $CanvasLayer/HUD/MessageLabel
@onready var combat_label: Label = $CanvasLayer/HUD/CombatLabel
@onready var alert_label: Label = $CanvasLayer/HUD/AlertLabel
@onready var pause_card: Panel = $CanvasLayer/HUD/PauseCard
@onready var pause_label: Label = $CanvasLayer/HUD/PauseLabel
@onready var start_card: Panel = $CanvasLayer/HUD/StartCard
@onready var start_label: Label = $CanvasLayer/HUD/StartLabel
@onready var start_sub_label: Label = $CanvasLayer/HUD/StartSubLabel
@onready var start_status_label: Label = $CanvasLayer/HUD/StartStatusLabel
@onready var start_progress_frame: Panel = $CanvasLayer/HUD/StartProgressFrame
@onready var start_progress_bar: ProgressBar = $CanvasLayer/HUD/StartProgressFrame/StartProgressBar
@onready var start_hint_label: Label = $CanvasLayer/HUD/StartHintLabel
@onready var hit_label: Label = $CanvasLayer/HUD/HitLabel
@onready var top_frame: Panel = $CanvasLayer/HUD/TopFrame
@onready var left_frame: Panel = $CanvasLayer/HUD/LeftFrame
@onready var right_frame: Panel = $CanvasLayer/HUD/RightFrame
@onready var message_frame: Panel = $CanvasLayer/HUD/MessageFrame
@onready var hull_bar: ProgressBar = $CanvasLayer/HUD/LeftFrame/HullBar
@onready var shield_bar: ProgressBar = $CanvasLayer/HUD/LeftFrame/ShieldBar
@onready var dock_value: Label = $CanvasLayer/HUD/LeftFrame/DockValue
@onready var route_value: Label = $CanvasLayer/HUD/LeftFrame/RouteValue
@onready var scanner_value: Label = $CanvasLayer/HUD/LeftFrame/ScannerValue
@onready var combat_value: Label = $CanvasLayer/HUD/RightFrame/CombatValue
@onready var message_value: Label = $CanvasLayer/HUD/MessageFrame/MessageValue
@onready var alert_value: Label = $CanvasLayer/HUD/TopFrame/AlertValue
@onready var hit_value: Label = $CanvasLayer/HUD/TopFrame/HitValue
@onready var attitude_viewport: SubViewport = $CanvasLayer/HUD/TopFrame/AttitudeViewport
@onready var attitude_display: TextureRect = $CanvasLayer/HUD/TopFrame/AttitudeDisplay
@onready var attitude_ball: MeshInstance3D = $CanvasLayer/HUD/TopFrame/AttitudeViewport/AttitudeRoot/AttitudeBall
@onready var attitude_needle: MeshInstance3D = $CanvasLayer/HUD/TopFrame/AttitudeViewport/AttitudeRoot/AttitudeNeedle
@onready var reticle: Control = $CanvasLayer/HUD/Reticle
@onready var cockpit_overlay: Control = $CanvasLayer/HUD/CockpitOverlay
@onready var cockpit_mode_label: Label = $CanvasLayer/HUD/CockpitOverlay/CockpitModeLabel
@onready var settings_panel: Panel = $CanvasLayer/HUD/SettingsPanel
@onready var settings_title: Label = $CanvasLayer/HUD/SettingsPanel/SettingsTitle
@onready var preset_value: Label = $CanvasLayer/HUD/SettingsPanel/PresetValue
@onready var preset_prev_button: Button = $CanvasLayer/HUD/SettingsPanel/PresetPrevButton
@onready var preset_next_button: Button = $CanvasLayer/HUD/SettingsPanel/PresetNextButton
@onready var render_mode_button: Button = $CanvasLayer/HUD/SettingsPanel/RenderModeButton
@onready var bloom_value: Label = $CanvasLayer/HUD/SettingsPanel/BloomValue
@onready var bloom_button: Button = $CanvasLayer/HUD/SettingsPanel/BloomButton
@onready var music_value: Label = $CanvasLayer/HUD/SettingsPanel/MusicValue
@onready var music_slider: HSlider = $CanvasLayer/HUD/SettingsPanel/MusicSlider
@onready var music_button: Button = $CanvasLayer/HUD/SettingsPanel/MusicButton
@onready var sfx_value: Label = $CanvasLayer/HUD/SettingsPanel/SfxValue
@onready var sfx_slider: HSlider = $CanvasLayer/HUD/SettingsPanel/SfxSlider
@onready var sfx_button: Button = $CanvasLayer/HUD/SettingsPanel/SfxButton
@onready var trail_value: Label = $CanvasLayer/HUD/SettingsPanel/TrailValue
@onready var trail_button: Button = $CanvasLayer/HUD/SettingsPanel/TrailButton
@onready var guidance_value: Label = $CanvasLayer/HUD/SettingsPanel/GuidanceValue
@onready var guidance_button: Button = $CanvasLayer/HUD/SettingsPanel/GuidanceButton
@onready var invert_y_value: Label = $CanvasLayer/HUD/SettingsPanel/InvertYValue
@onready var invert_y_button: Button = $CanvasLayer/HUD/SettingsPanel/InvertYButton
@onready var physics_mode_value: Label = $CanvasLayer/HUD/SettingsPanel/PhysicsModeValue
@onready var physics_mode_button: Button = $CanvasLayer/HUD/SettingsPanel/PhysicsModeButton
@onready var edge_threshold_value: Label = $CanvasLayer/HUD/SettingsPanel/EdgeThresholdValue
@onready var edge_threshold_slider: HSlider = $CanvasLayer/HUD/SettingsPanel/EdgeThresholdSlider
@onready var edge_strength_value: Label = $CanvasLayer/HUD/SettingsPanel/EdgeStrengthValue
@onready var edge_strength_slider: HSlider = $CanvasLayer/HUD/SettingsPanel/EdgeStrengthSlider
@onready var edge_glow_value: Label = $CanvasLayer/HUD/SettingsPanel/EdgeGlowValue
@onready var edge_glow_slider: HSlider = $CanvasLayer/HUD/SettingsPanel/EdgeGlowSlider
@onready var blur_amount_value: Label = $CanvasLayer/HUD/SettingsPanel/BlurAmountValue
@onready var blur_amount_slider: HSlider = $CanvasLayer/HUD/SettingsPanel/BlurAmountSlider
@onready var settings_hint: Label = $CanvasLayer/HUD/SettingsPanel/SettingsHint
@onready var settings_hotkeys: Label = $CanvasLayer/HUD/SettingsPanel/SettingsHotkeys

var nearby_station: Area3D = null
var dock_count := 0
var station_order: Array[Area3D] = []
var station_nodes_by_name := {}
var shipping_lane_nodes: Array[MeshInstance3D] = []
var pickup_station := ""
var delivery_station := ""
var cargo_loaded := false
var objective_line: MeshInstance3D
var objective_marker: MeshInstance3D
var objective_flash_time := 0.0
var objective_guidance_enabled := false
var star_node: Node3D
var sunlight: DirectionalLight3D
var planet_bodies := []
var planet_nodes_by_name := {}
var world_root: Node3D
var enemy_target_marker: MeshInstance3D
var enemy_target_lead_marker: MeshInstance3D
var enemy_target_label: Label3D
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
var radio_track_index := -1
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
var boot_screen_time := 0.0
var settings_visible := false
var visual_preset_index := 0
var shaded_mode := false
var bloom_enabled := true
var music_enabled := true
var sfx_enabled := true
var music_volume := 0.72
var sfx_volume := 0.85
var invert_y_axis := false
var flight_physics_mode := "game"
var edge_threshold := 0.16
var edge_strength_scale := 1.0
var edge_glow_scale := 1.0
var blur_strength_scale := 1.0
var autopilot_active := false
var autopilot_state := ""
var autopilot_station: Area3D = null
var autopilot_timer := 0.0
var autopilot_fx_timer := 0.0
var camera_mode := 0
var orbit_distance := 18.0
var orbit_pitch := -0.32
var orbit_yaw := 0.0
var orbit_pitch_target := -0.32
var orbit_yaw_target := 0.0
var orbit_dragging := false
var camera_manual_input_timer := 0.0
var first_person_yaw := 0.0
var first_person_pitch := 0.0
var idle_input_timer := 0.0
var cinematic_mode_active := false
var cinematic_blend := 0.0
var cinematic_time := 0.0


func _ready() -> void:
	if DisplayServer.get_name() != "headless":
		get_window().min_size = Vector2i(1280, 720)
		get_window().mode = Window.MODE_MAXIMIZED
	player.call("set_world_limit", WORLD_LIMIT)
	alert_label.text = ""
	hit_label.text = ""
	pause_card.visible = false
	pause_label.visible = false
	start_card.visible = true
	start_label.visible = true
	settings_panel.visible = false
	dock_label.visible = false
	cargo_label.visible = false
	objective_label.visible = false
	scanner_label.visible = false
	message_label.visible = false
	combat_label.visible = false
	alert_label.visible = false
	hit_label.visible = false
	if DisplayServer.get_name() != "headless":
		setup_audio()
	setup_blur_pass()
	setup_edge_pass()
	setup_attitude_indicator()
	setup_visual_environment()
	create_starfield()
	create_star()
	create_planets()
	create_stations()
	create_ringworld_station()
	create_shipping_lanes()
	create_navigation_beacons()
	create_destroyer_fleet()
	create_objective_visuals()
	setup_cargo_route()
	call_deferred("spawn_initial_enemies")

	load_saved_defaults()
	var start_spawn: Dictionary = get_start_spawn_data()
	player.global_position = start_spawn.get("position", Vector3.ZERO)
	if start_spawn.has("forward"):
		player.call("set_spawn_orientation", start_spawn["forward"])
	apply_start_camera_framing(start_spawn)
	player.call("set_physics_mode", flight_physics_mode)
	apply_visual_preset()
	player.call("set_camera_view", camera_mode)
	connect_settings_controls()

	paused = true
	title_label.text = "Station420"
	update_combat_label()
	update_settings_label()
	update_status("Press Enter to launch.\nMouse steers. Use Space to fire and Esc to pause once you are underway.")
	update_mouse_mode()


func _exit_tree() -> void:
	if music_player != null:
		music_player.stop()
	music_playback = null


func connect_settings_controls() -> void:
	preset_prev_button.pressed.connect(_on_preset_prev_pressed)
	preset_next_button.pressed.connect(_on_preset_next_pressed)
	debug_save_defaults_button.pressed.connect(_on_debug_save_defaults_pressed)
	render_mode_button.pressed.connect(_on_render_mode_pressed)
	bloom_button.pressed.connect(_on_bloom_pressed)
	music_slider.value_changed.connect(_on_music_slider_changed)
	music_button.pressed.connect(_on_music_pressed)
	sfx_slider.value_changed.connect(_on_sfx_slider_changed)
	sfx_button.pressed.connect(_on_sfx_pressed)
	trail_button.pressed.connect(_on_trail_pressed)
	guidance_button.pressed.connect(_on_guidance_pressed)
	invert_y_button.pressed.connect(_on_invert_y_pressed)
	physics_mode_button.pressed.connect(_on_physics_mode_pressed)
	edge_threshold_slider.value_changed.connect(_on_edge_threshold_slider_changed)
	edge_strength_slider.value_changed.connect(_on_edge_strength_slider_changed)
	edge_glow_slider.value_changed.connect(_on_edge_glow_slider_changed)
	blur_amount_slider.value_changed.connect(_on_blur_amount_slider_changed)
	music_slider.value = music_volume * 100.0
	sfx_slider.value = sfx_volume * 100.0
	edge_threshold_slider.value = edge_threshold * 100.0
	edge_strength_slider.value = edge_strength_scale * 100.0
	edge_glow_slider.value = edge_glow_scale * 100.0
	blur_amount_slider.value = blur_strength_scale * 100.0


func load_saved_defaults() -> void:
	if not FileAccess.file_exists(DEFAULTS_SAVE_PATH):
		return
	var file := FileAccess.open(DEFAULTS_SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		return
	var data: Dictionary = parsed
	visual_preset_index = int(data.get("visual_preset_index", visual_preset_index))
	shaded_mode = bool(data.get("shaded_mode", shaded_mode))
	bloom_enabled = bool(data.get("bloom_enabled", bloom_enabled))
	music_enabled = bool(data.get("music_enabled", music_enabled))
	sfx_enabled = bool(data.get("sfx_enabled", sfx_enabled))
	music_volume = float(data.get("music_volume", music_volume))
	sfx_volume = float(data.get("sfx_volume", sfx_volume))
	invert_y_axis = bool(data.get("invert_y_axis", invert_y_axis))
	flight_physics_mode = str(data.get("flight_physics_mode", flight_physics_mode))
	edge_threshold = float(data.get("edge_threshold", edge_threshold))
	edge_strength_scale = float(data.get("edge_strength_scale", edge_strength_scale))
	edge_glow_scale = float(data.get("edge_glow_scale", edge_glow_scale))
	blur_strength_scale = float(data.get("blur_strength_scale", blur_strength_scale))
	camera_mode = int(data.get("camera_mode", camera_mode))
	orbit_distance = float(data.get("orbit_distance", orbit_distance))
	orbit_pitch = float(data.get("orbit_pitch", orbit_pitch))
	orbit_yaw = float(data.get("orbit_yaw", orbit_yaw))
	orbit_pitch_target = orbit_pitch
	orbit_yaw_target = orbit_yaw
	objective_guidance_enabled = bool(data.get("objective_guidance_enabled", objective_guidance_enabled))
	var trail_default := bool(data.get("trail_enabled", false))
	var current_trail := bool(player.get("trail_enabled"))
	if trail_default != current_trail:
		player.call("toggle_motion_trail")


func save_current_defaults() -> void:
	var payload := {
		"visual_preset_index": visual_preset_index,
		"shaded_mode": shaded_mode,
		"bloom_enabled": bloom_enabled,
		"music_enabled": music_enabled,
		"sfx_enabled": sfx_enabled,
		"music_volume": music_volume,
		"sfx_volume": sfx_volume,
		"invert_y_axis": invert_y_axis,
		"flight_physics_mode": flight_physics_mode,
		"edge_threshold": edge_threshold,
		"edge_strength_scale": edge_strength_scale,
		"edge_glow_scale": edge_glow_scale,
		"blur_strength_scale": blur_strength_scale,
		"camera_mode": camera_mode,
		"orbit_distance": orbit_distance,
		"orbit_pitch": orbit_pitch,
		"orbit_yaw": orbit_yaw,
		"objective_guidance_enabled": objective_guidance_enabled,
		"trail_enabled": bool(player.get("trail_enabled"))
	}
	var file := FileAccess.open(DEFAULTS_SAVE_PATH, FileAccess.WRITE)
	if file == null:
		set_alert("Defaults save failed", 0.45)
		return
	file.store_string(JSON.stringify(payload, "\t"))
	set_alert("Defaults saved", 0.45)
	update_status("Debug defaults snapshot saved.\nThis button is temporary and can be removed after you settle on the baseline.")


func _on_debug_save_defaults_pressed() -> void:
	save_current_defaults()


func _process(delta: float) -> void:
	update_boot_screen(delta)
	update_music_stream()
	update_alert(delta)
	update_hit_feedback(delta)
	update_settings_label()
	update_debug_overlay()
	update_overlay_blur()
	update_attitude_indicator()
	camera_manual_input_timer = max(camera_manual_input_timer - delta, 0.0)
	update_idle_cinematic(delta)
	if paused:
		return

	update_controller_camera(delta)
	var camera_smooth: float = clamp(delta * 9.5, 0.0, 1.0)
	orbit_yaw = lerp_angle(orbit_yaw, orbit_yaw_target, camera_smooth)
	orbit_pitch = lerp(orbit_pitch, orbit_pitch_target, camera_smooth)
	update_camera(delta)
	update_contextual_line_visibility()
	update_objective_visuals(delta)
	update_enemy_target_marker()
	update_station_spin(delta)
	update_destroyer_fleet(delta)
	update_scanner()
	update_combat_label()


func note_player_activity() -> void:
	idle_input_timer = 0.0
	if cinematic_mode_active:
		cinematic_mode_active = false


func update_idle_cinematic(delta: float) -> void:
	var allow_cinematic := not paused and not start_screen_active and not settings_visible and not autopilot_active and not game_over_state
	if allow_cinematic:
		idle_input_timer += delta
		if idle_input_timer >= CINEMATIC_IDLE_DELAY:
			cinematic_mode_active = true
			cinematic_time += delta
	else:
		idle_input_timer = 0.0
		cinematic_mode_active = false
		cinematic_time = 0.0
	var target_blend: float = 1.0 if cinematic_mode_active else 0.0
	var blend_speed: float = CINEMATIC_BLEND_IN_SPEED if target_blend > cinematic_blend else CINEMATIC_BLEND_OUT_SPEED
	cinematic_blend = move_toward(cinematic_blend, target_blend, delta * blend_speed)
	if cinematic_blend <= 0.001 and not cinematic_mode_active:
		cinematic_time = 0.0
	update_cinematic_overlay()


func update_cinematic_overlay() -> void:
	var hud_alpha: float = 1.0 - cinematic_blend
	for node in [
		debug_save_defaults_button,
		top_frame,
		left_frame,
		right_frame,
		message_frame,
		reticle,
		cockpit_overlay,
		title_label,
		dock_label,
		cargo_label,
		objective_label,
		scanner_label,
		message_label,
		combat_label,
		alert_label,
		start_card,
		start_label,
		start_sub_label,
		start_status_label,
		start_progress_frame,
		start_hint_label,
		pause_card,
		pause_label,
		hit_label,
		settings_panel
	]:
		if node != null:
			node.modulate.a = hud_alpha
	cinematic_top_bar.visible = cinematic_blend > 0.001
	cinematic_bottom_bar.visible = cinematic_blend > 0.001
	cinematic_top_bar.modulate.a = cinematic_blend
	cinematic_bottom_bar.modulate.a = cinematic_blend
	cinematic_top_bar.size.y = CINEMATIC_BAR_HEIGHT * cinematic_blend
	cinematic_bottom_bar.position.y = get_viewport().get_visible_rect().size.y - CINEMATIC_BAR_HEIGHT * cinematic_blend
	cinematic_bottom_bar.size.y = CINEMATIC_BAR_HEIGHT * cinematic_blend


func _physics_process(delta: float) -> void:
	if paused:
		return

	simulate_planets(delta)
	player.call("set_gravity_acceleration", compute_ship_gravity() * SHIP_GRAVITY_SCALE)
	if update_autopilot(delta):
		update_effects(delta)
		return
	resolve_player_solids()
	update_player_combat(delta)
	update_hazards(delta)
	update_enemy_behavior(delta)
	update_projectiles(delta)
	update_effects(delta)
	maybe_spawn_enemies(delta)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and event.relative.length() > 0.01:
		note_player_activity()
	elif event is InputEventMouseButton and event.pressed:
		note_player_activity()
	elif event is InputEventKey and event.pressed and not event.echo:
		note_player_activity()
	elif event is InputEventJoypadButton and event.pressed:
		note_player_activity()

	if event is InputEventJoypadButton and event.pressed:
		if event.button_index == JOY_BUTTON_START:
			toggle_pause()
			return
		if event.button_index == JOY_BUTTON_Y:
			toggle_camera_mode()
			return
		if event.button_index == JOY_BUTTON_B and not start_screen_active and not game_over_state:
			toggle_shaded_mode()
			return
		if event.button_index == JOY_BUTTON_BACK:
			settings_visible = not settings_visible
			settings_panel.visible = settings_visible
			update_mouse_mode()
			return
		if event.button_index == JOY_BUTTON_LEFT_SHOULDER:
			set_visual_preset((visual_preset_index + 3) % 4)
			return
		if event.button_index == JOY_BUTTON_RIGHT_SHOULDER:
			set_visual_preset((visual_preset_index + 1) % 4)
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
			toggle_autopilot()
			return
		if event.button_index == JOY_BUTTON_DPAD_DOWN:
			toggle_trail()
			return
		if event.button_index == JOY_BUTTON_LEFT_STICK:
			toggle_guidance()
			return
		if event.button_index == JOY_BUTTON_RIGHT_STICK:
			reset_view()
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
		toggle_camera_mode()
		return

	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_V:
		reset_view()
		return

	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_H:
		settings_visible = not settings_visible
		settings_panel.visible = settings_visible
		update_mouse_mode()
		return

	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_BACKSLASH:
		toggle_shaded_mode()
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
		if event.keycode == KEY_4:
			set_visual_preset(3)
			return
		if event.keycode == KEY_B:
			toggle_bloom()
			return
		if event.keycode == KEY_M:
			toggle_music()
			return
		if event.keycode == KEY_N:
			toggle_sfx()
			return
		if event.keycode == KEY_T:
			toggle_trail()
			return
		if event.keycode == KEY_G:
			toggle_guidance()
			return
		if event.keycode == KEY_C:
			hail_radio_contact()
			return
		if event.keycode == KEY_J:
			toggle_autopilot()
			return
		if event.keycode == KEY_P:
			toggle_physics_mode()
			return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed and camera_mode <= 1:
			orbit_distance = clamp(orbit_distance - 10.0, CAMERA_MIN_DISTANCE, CAMERA_MAX_DISTANCE)
			return
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed and camera_mode <= 1:
			orbit_distance = clamp(orbit_distance + 10.0, CAMERA_MIN_DISTANCE, CAMERA_MAX_DISTANCE)
			return

	if event is InputEventMouseMotion:
		if not paused and not settings_visible and not start_screen_active:
			handle_camera_look(event.relative)
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
	far_stars.mesh = build_star_mesh(3200, WORLD_LIMIT * 2.2, 0.35, 1.9)
	register_style_mesh(far_stars, "ambient", Color(0.82, 0.9, 1.0))
	add_child(far_stars)

	var mid_stars := MeshInstance3D.new()
	mid_stars.name = "MidStars"
	mid_stars.mesh = build_star_mesh(1400, WORLD_LIMIT * 1.45, 0.8, 2.8)
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
	mark_mesh_wireframe_only(star_mesh)
	register_style_mesh(star_mesh, "danger", Color(1.0, 0.84, 0.28))
	star_node.add_child(star_mesh)

	var star_solid := MeshInstance3D.new()
	star_solid.mesh = build_planet_solid_mesh(STAR_RADIUS)
	mark_mesh_solid_only(star_solid)
	register_style_mesh(star_solid, "danger", Color(1.0, 0.84, 0.28))
	star_node.add_child(star_solid)

	var star_corona := MeshInstance3D.new()
	var corona_mesh := SphereMesh.new()
	corona_mesh.radius = STAR_RADIUS * 1.85
	corona_mesh.height = STAR_RADIUS * 3.7
	corona_mesh.radial_segments = 24
	corona_mesh.rings = 14
	star_corona.mesh = corona_mesh
	var corona_material := StandardMaterial3D.new()
	corona_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	corona_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	corona_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	corona_material.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
	corona_material.albedo_color = Color(1.0, 0.78, 0.3, 0.18)
	corona_material.emission_enabled = true
	corona_material.emission = Color(1.0, 0.72, 0.22) * 1.9
	star_corona.material_override = corona_material
	star_node.add_child(star_corona)

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

	sunlight = DirectionalLight3D.new()
	sunlight.name = "Sunlight"
	sunlight.light_color = Color(1.0, 0.94, 0.82)
	sunlight.light_energy = 1.8
	sunlight.shadow_enabled = true
	sunlight.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
	sunlight.directional_shadow_max_distance = 220000.0
	sunlight.directional_shadow_split_1 = 0.06
	sunlight.directional_shadow_split_2 = 0.18
	sunlight.directional_shadow_split_3 = 0.42
	sunlight.rotation = Vector3(deg_to_rad(-36.0), deg_to_rad(28.0), 0.0)
	add_child(sunlight)


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
		mark_mesh_wireframe_only(planet_mesh)
		register_style_mesh(planet_mesh, "planet", planet_data["color"])
		root.add_child(planet_mesh)

		var planet_solid := MeshInstance3D.new()
		planet_solid.mesh = build_planet_solid_mesh(planet_radius)
		mark_mesh_solid_only(planet_solid)
		register_style_mesh(planet_solid, "planet", planet_data["color"])
		root.add_child(planet_solid)

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
		station.set_meta("dock_offset", Vector3(0, 0, 220))
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
		mark_mesh_wireframe_only(wireframe)
		register_style_mesh(wireframe, "station", Color(1.0, 0.72, 0.34))
		station.add_child(wireframe)

		var station_solid := MeshInstance3D.new()
		station_solid.mesh = build_station_solid_mesh(22.0 * STATION_SCALE)
		mark_mesh_solid_only(station_solid)
		register_style_mesh(station_solid, "station", Color(1.0, 0.72, 0.34))
		station.add_child(station_solid)

		var dock_marker := MeshInstance3D.new()
		dock_marker.position = Vector3(0, 0, 220)
		dock_marker.mesh = build_dock_marker_mesh(24.0)
		register_style_mesh(dock_marker, "dock", Color(0.55, 1.0, 0.85))
		station.add_child(dock_marker)

		var dock_marker_solid := MeshInstance3D.new()
		dock_marker_solid.position = Vector3(0, 0, 220)
		dock_marker_solid.mesh = build_dock_marker_solid_mesh(24.0)
		mark_mesh_solid_only(dock_marker_solid)
		register_style_mesh(dock_marker_solid, "dock", Color(0.55, 1.0, 0.85))
		station.add_child(dock_marker_solid)

		var station_label := Label3D.new()
		station_label.position = Vector3(0, 180.0, 0)
		station_label.text = station_data["name"]
		station_label.font_size = 36
		station_label.no_depth_test = true
		register_style_label(station_label, "label", Color.WHITE)
		station.add_child(station_label)

		station_order.append(station)
		station_nodes_by_name[station_data["name"]] = station


func create_ringworld_station() -> void:
	var ringworld_root := Node3D.new()
	ringworld_root.name = "Eidolon Ring Anchor"
	ringworld_root.position = Vector3(RINGWORLD_ORBIT_RADIUS, 2600.0, -12000.0)
	ringworld_root.rotation = Vector3(deg_to_rad(68.0), deg_to_rad(18.0), 0.0)
	add_child(ringworld_root)

	var station := Area3D.new()
	station.name = "Eidolon Ring"
	station.collision_layer = 0
	station.collision_mask = 1
	station.set_meta("station_name", "Eidolon Ring")
	station.set_meta("planet_name", "Helios Prime")
	station.set_meta("dock_offset", Vector3(0, 0, RINGWORLD_STATION_RADIUS + RINGWORLD_DOCK_OFFSET))
	station.set_meta("collision_radius", RINGWORLD_STATION_RADIUS + 320.0)
	station.set_meta("spin_speed", 0.025)
	station.body_entered.connect(_on_station_body_entered.bind(station))
	station.body_exited.connect(_on_station_body_exited.bind(station))
	ringworld_root.add_child(station)

	var collision := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = RINGWORLD_STATION_RADIUS + 320.0
	collision.shape = shape
	station.add_child(collision)

	var wireframe := MeshInstance3D.new()
	wireframe.mesh = build_ringworld_station_mesh(RINGWORLD_STATION_RADIUS)
	mark_mesh_wireframe_only(wireframe)
	register_style_mesh(wireframe, "station", Color(0.92, 0.8, 0.38))
	station.add_child(wireframe)

	var solid_mesh := MeshInstance3D.new()
	solid_mesh.mesh = build_ringworld_station_solid_mesh(RINGWORLD_STATION_RADIUS)
	mark_mesh_solid_only(solid_mesh)
	register_style_mesh(solid_mesh, "station", Color(0.92, 0.8, 0.38))
	station.add_child(solid_mesh)

	var dock_marker := MeshInstance3D.new()
	dock_marker.position = Vector3(0, 0, RINGWORLD_STATION_RADIUS + RINGWORLD_DOCK_OFFSET)
	dock_marker.mesh = build_dock_marker_mesh(90.0)
	register_style_mesh(dock_marker, "dock", Color(0.55, 1.0, 0.85))
	station.add_child(dock_marker)

	var dock_marker_solid := MeshInstance3D.new()
	dock_marker_solid.position = Vector3(0, 0, RINGWORLD_STATION_RADIUS + RINGWORLD_DOCK_OFFSET)
	dock_marker_solid.mesh = build_dock_marker_solid_mesh(90.0)
	mark_mesh_solid_only(dock_marker_solid)
	register_style_mesh(dock_marker_solid, "dock", Color(0.55, 1.0, 0.85))
	station.add_child(dock_marker_solid)

	var station_label := Label3D.new()
	station_label.position = Vector3(0, RINGWORLD_STATION_RADIUS * 0.65, 0)
	station_label.text = "Eidolon Ring"
	station_label.font_size = 72
	station_label.no_depth_test = true
	register_style_label(station_label, "label", Color.WHITE)
	station.add_child(station_label)

	station_order.append(station)
	station_nodes_by_name["Eidolon Ring"] = station


func create_shipping_lanes() -> void:
	for i in range(0, station_order.size(), 2):
		if i + 1 >= station_order.size():
			break
		var from_station := station_order[i]
		var to_station := station_order[i + 1]
		var parent_planet: Node3D = from_station.get_parent().get_parent()
		var lane := MeshInstance3D.new()
		var local_midpoint := (parent_planet.to_local(from_station.global_position) + parent_planet.to_local(to_station.global_position)) * 0.5
		lane.mesh = build_shipping_lane_mesh(
			parent_planet.to_local(from_station.global_position),
			parent_planet.to_local(to_station.global_position)
		)
		lane.set_meta("fade_local_midpoint", local_midpoint)
		register_style_mesh(lane, "lane", Color(0.34, 0.88, 0.76, 0.0))
		parent_planet.add_child(lane)
		shipping_lane_nodes.append(lane)

		var lane_solid := MeshInstance3D.new()
		lane_solid.mesh = build_shipping_lane_solid_mesh(
			parent_planet.to_local(from_station.global_position),
			parent_planet.to_local(to_station.global_position)
		)
		mark_mesh_solid_only(lane_solid)
		lane_solid.set_meta("fade_local_midpoint", local_midpoint)
		register_style_mesh(lane_solid, "lane", Color(0.34, 0.88, 0.76, 0.0))
		parent_planet.add_child(lane_solid)
		shipping_lane_nodes.append(lane_solid)


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

		var solid_mesh := MeshInstance3D.new()
		solid_mesh.mesh = build_nav_beacon_solid_mesh(24.0)
		mark_mesh_solid_only(solid_mesh)
		register_style_mesh(solid_mesh, "objective", beacon_data["color"])
		root.add_child(solid_mesh)

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
		mark_mesh_wireframe_only(mesh)
		register_style_mesh(mesh, "station", Color(0.74, 0.88, 1.0))
		destroyer.add_child(mesh)

		var solid_mesh := MeshInstance3D.new()
		solid_mesh.mesh = build_destroyer_solid_mesh(42.0 * DESTROYER_SCALE)
		mark_mesh_solid_only(solid_mesh)
		register_style_mesh(solid_mesh, "station", Color(0.74, 0.88, 1.0))
		destroyer.add_child(solid_mesh)

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
	enemy_target_marker.mesh = build_enemy_target_marker_mesh(18.0)
	register_style_mesh(enemy_target_marker, "target", Color(1.0, 0.52, 0.42))
	enemy_target_marker.visible = false
	add_child(enemy_target_marker)

	enemy_target_lead_marker = MeshInstance3D.new()
	enemy_target_lead_marker.name = "EnemyTargetLeadMarker"
	enemy_target_lead_marker.mesh = build_target_lead_marker_mesh(8.0)
	register_style_mesh(enemy_target_lead_marker, "objective", Color(0.72, 0.96, 1.0))
	enemy_target_lead_marker.visible = false
	add_child(enemy_target_lead_marker)

	enemy_target_label = Label3D.new()
	enemy_target_label.name = "EnemyTargetLabel"
	enemy_target_label.font_size = 30
	enemy_target_label.no_depth_test = true
	register_style_label(enemy_target_label, "target", Color(1.0, 0.72, 0.62))
	enemy_target_label.visible = false
	add_child(enemy_target_label)


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
	return compute_gravity_at_position(player.global_position)


func compute_gravity_at_position(position: Vector3) -> Vector3:
	var total_gravity := compute_star_gravity(position)
	for body in planet_bodies:
		var body_position: Vector3 = body["node"].global_position
		var delta_vector := body_position - position
		var softened_distance_sq := delta_vector.length_squared() + GRAVITY_SOFTENING * 0.35
		var accel_magnitude := GRAVITY_CONSTANT * float(body["mass"]) / softened_distance_sq
		total_gravity += delta_vector.normalized() * accel_magnitude
	return total_gravity


func resolve_player_solids() -> void:
	if star_node == null or not is_instance_valid(star_node):
		return
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
	nearby_station = station
	dock_count += 1
	objective_flash_time = 0.35

	var station_name := str(station.get_meta("station_name"))
	title_label.text = "Docked"
	dock_label.text = "⌂ %s %d" % [station_name, dock_count]
	play_sfx("dock")
	handle_cargo_dock(station_name)


func update_status(message: String) -> void:
	message_label.text = message
	message_value.text = message


func update_debug_overlay() -> void:
	var view_name := get_camera_mode_name()
	var render_name := "Shaded" if shaded_mode else "Wireframe"
	var preset_name := get_preset_name(visual_preset_index)
	var ap_state := "MANUAL" if not autopilot_active else "AP %s" % get_autopilot_state_display()
	alert_value.text = "VIEW %s | RENDER %s | PRESET %s | %s" % [view_name.to_upper(), render_name.to_upper(), preset_name.to_upper(), ap_state]
	if camera_mode == 2:
		hit_value.text = "HEAD yaw %.0f pitch %.0f | ZOOM n/a" % [rad_to_deg(first_person_yaw), rad_to_deg(first_person_pitch)]
	else:
		hit_value.text = "ORBIT yaw %.0f pitch %.0f | ZOOM %.0fm" % [rad_to_deg(orbit_yaw), rad_to_deg(orbit_pitch), orbit_distance]


func get_autopilot_state_display() -> String:
	if not autopilot_active:
		return "MANUAL"
	if autopilot_state == "arm":
		var countdown: float = max(ceil(AUTOPILOT_ARM_DURATION - autopilot_timer), 0.0)
		return "ARM T-%d" % int(countdown)
	return autopilot_state.to_upper()


func setup_attitude_indicator() -> void:
	attitude_viewport.msaa_3d = Viewport.MSAA_4X
	attitude_display.texture = attitude_viewport.get_texture()
	attitude_viewport.size = Vector2i(156, 156)
	update_attitude_indicator_theme()

	var needle_mesh := BoxMesh.new()
	needle_mesh.size = Vector3(3.6, 0.12, 0.12)
	attitude_needle.mesh = needle_mesh
	attitude_needle.position = Vector3(0.0, 0.0, 2.75)


func update_attitude_indicator() -> void:
	if attitude_ball == null:
		return
	var ship_basis: Basis = player.call("get_visual_basis")
	attitude_ball.transform.basis = ship_basis.orthonormalized()
	attitude_ball.rotation.z = Time.get_ticks_msec() * 0.00042


func update_attitude_indicator_theme() -> void:
	if attitude_ball == null or attitude_needle == null:
		return
	var accent := resolve_style_color("objective", Color(0.55, 0.95, 1.0))
	var hull_tint := resolve_style_color("player", Color(0.45, 0.88, 1.0))
	attitude_display.modulate = Color(1, 1, 1, 0.96)
	if shaded_mode:
		var ball_mesh := SphereMesh.new()
		ball_mesh.radius = 2.35
		ball_mesh.height = 4.7
		ball_mesh.radial_segments = 30
		ball_mesh.rings = 22
		attitude_ball.mesh = ball_mesh
		var ball_material := StandardMaterial3D.new()
		ball_material.albedo_color = hull_tint.lerp(Color(0.04, 0.06, 0.1), 0.78)
		ball_material.metallic = 0.22
		ball_material.roughness = 0.18
		ball_material.emission_enabled = true
		ball_material.emission = accent * 0.12
		attitude_ball.material_override = ball_material
	else:
		attitude_ball.mesh = build_attitude_wire_mesh(2.4, 32)
		var ball_material := StandardMaterial3D.new()
		ball_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		ball_material.albedo_color = Color(accent.r, accent.g, accent.b, 0.86)
		ball_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		ball_material.emission_enabled = true
		ball_material.emission = accent * 1.12
		attitude_ball.material_override = ball_material
	var needle_material := StandardMaterial3D.new()
	needle_material.albedo_color = accent.lerp(Color.WHITE, 0.18)
	needle_material.emission_enabled = true
	needle_material.emission = accent * (0.8 if shaded_mode else 1.35)
	needle_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	attitude_needle.material_override = needle_material


func build_attitude_wire_mesh(radius: float, segments: int) -> ArrayMesh:
	var vertices := PackedVector3Array()
	for axis in [0, 1, 2]:
		for i in range(segments):
			var a0 := TAU * float(i) / float(segments)
			var a1 := TAU * float(i + 1) / float(segments)
			var p0 := Vector3.ZERO
			var p1 := Vector3.ZERO
			match axis:
				0:
					p0 = Vector3(0.0, cos(a0) * radius, sin(a0) * radius)
					p1 = Vector3(0.0, cos(a1) * radius, sin(a1) * radius)
				1:
					p0 = Vector3(cos(a0) * radius, 0.0, sin(a0) * radius)
					p1 = Vector3(cos(a1) * radius, 0.0, sin(a1) * radius)
				_:
					p0 = Vector3(cos(a0) * radius, sin(a0) * radius, 0.0)
					p1 = Vector3(cos(a1) * radius, sin(a1) * radius, 0.0)
			vertices.append(p0)
			vertices.append(p1)
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	return mesh


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
	environment.ssao_enabled = false
	world_environment.environment = environment


func setup_edge_pass() -> void:
	var material := ShaderMaterial.new()
	material.shader = load("res://shaders/edge_pass.gdshader")
	edge_pass.material = material
	edge_pass.visible = shaded_mode


func setup_blur_pass() -> void:
	var material := ShaderMaterial.new()
	material.shader = load("res://shaders/overlay_fog.gdshader")
	blur_pass.material = material
	blur_pass.visible = start_screen_active
	update_blur_pass_theme()


func update_overlay_blur() -> void:
	blur_pass.visible = start_screen_active or paused or settings_visible


func get_preset_name(index: int) -> String:
	match index:
		1:
			return "Neon Wireframe"
		2:
			return "Toon Combat"
		3:
			return "Hologram Drift"
		_:
			return "Deep Space"


func set_visual_preset(index: int) -> void:
	visual_preset_index = clamp(index, 0, 3)
	apply_visual_preset()


func toggle_shaded_mode() -> void:
	shaded_mode = not shaded_mode
	apply_visual_preset()
	set_alert("Render mode: %s" % ("shaded" if shaded_mode else "wireframe"), 0.45)


func apply_visual_preset() -> void:
	if world_environment.environment == null:
		setup_visual_environment()
	edge_pass.visible = shaded_mode
	update_edge_pass_theme()
	update_blur_pass_theme()
	update_attitude_indicator_theme()
	var environment := world_environment.environment
	match visual_preset_index:
		1:
			environment.background_color = Color(0.05, 0.07, 0.12)
			environment.ambient_light_color = Color(0.42, 0.84, 1.0)
			environment.ambient_light_energy = 0.45
			environment.fog_enabled = true
			environment.fog_light_color = Color(0.18, 0.54, 0.88)
			environment.fog_density = 0.000008
		2:
			environment.background_color = Color(0.08, 0.07, 0.09)
			environment.ambient_light_color = Color(0.95, 0.78, 0.58)
			environment.ambient_light_energy = 0.5
			environment.fog_enabled = true
			environment.fog_light_color = Color(0.46, 0.34, 0.22)
			environment.fog_density = 0.000009
		3:
			environment.background_color = Color(0.03, 0.12, 0.12)
			environment.ambient_light_color = Color(0.34, 0.95, 0.82)
			environment.ambient_light_energy = 0.42
			environment.fog_enabled = true
			environment.fog_light_color = Color(0.1, 0.66, 0.62)
			environment.fog_density = 0.000007
		_:
			environment.background_color = Color(0.005, 0.008, 0.014)
			environment.ambient_light_color = Color(0.46, 0.52, 0.62)
			environment.ambient_light_energy = 0.38
			environment.fog_enabled = false

	environment.glow_enabled = bloom_enabled
	environment.glow_intensity = 0.78 if bloom_enabled else 0.0
	environment.glow_strength = 0.95 if bloom_enabled else 0.0
	environment.glow_bloom = 0.18 if bloom_enabled else 0.0
	environment.tonemap_exposure = 1.18 if shaded_mode else (1.1 if visual_preset_index == 1 else 1.0)

	if sunlight != null:
		sunlight.visible = shaded_mode
		sunlight.light_energy = 1.85 if shaded_mode else 0.0

	for node in get_tree().get_nodes_in_group("style_mesh"):
		apply_mesh_style(node)
	for node in get_tree().get_nodes_in_group("style_label"):
		apply_label_style(node)
	apply_player_style()
	apply_hud_style()


func update_edge_pass_theme() -> void:
	var edge_material := edge_pass.material
	if not (edge_material is ShaderMaterial):
		return
	var tint := Color(0.82, 0.92, 1.0)
	var strength := 1.45
	var glow_strength := 1.0
	var halo_radius := 1.8
	match visual_preset_index:
		1:
			tint = Color(0.38, 1.0, 0.92)
			strength = 1.6
			glow_strength = 1.18
			halo_radius = 1.95
		2:
			tint = Color(1.0, 0.8, 0.34)
			strength = 1.52
			glow_strength = 0.96
			halo_radius = 1.7
		3:
			tint = Color(0.34, 1.0, 0.86)
			strength = 1.66
			glow_strength = 1.24
			halo_radius = 2.05
		_:
			tint = Color(0.84, 0.92, 1.0)
			strength = 1.42
			glow_strength = 1.02
			halo_radius = 1.78
	edge_material.set_shader_parameter("edge_tint", Vector3(tint.r, tint.g, tint.b))
	edge_material.set_shader_parameter("threshold", edge_threshold)
	edge_material.set_shader_parameter("strength", strength * edge_strength_scale)
	edge_material.set_shader_parameter("glow_strength", glow_strength * edge_glow_scale)
	edge_material.set_shader_parameter("halo_radius", halo_radius)


func update_blur_pass_theme() -> void:
	var blur_material := blur_pass.material
	if not (blur_material is ShaderMaterial):
		return
	var tint := Color(0.06, 0.11, 0.18, 0.26)
	match visual_preset_index:
		1:
			tint = Color(0.08, 0.24, 0.28, 0.42)
		2:
			tint = Color(0.22, 0.15, 0.08, 0.38)
		3:
			tint = Color(0.05, 0.22, 0.18, 0.42)
		_:
			tint = Color(0.08, 0.12, 0.2, 0.4)
	blur_material.set_shader_parameter("fog_density", blur_strength_scale)
	blur_material.set_shader_parameter("tint", tint)


func register_style_mesh(mesh: MeshInstance3D, role: String, base_color: Color) -> void:
	mesh.set_meta("style_role", role)
	mesh.set_meta("style_base_color", base_color)
	if not mesh.is_in_group("style_mesh"):
		mesh.add_to_group("style_mesh")
	apply_mesh_style(mesh)


func mark_mesh_wireframe_only(mesh: MeshInstance3D) -> void:
	mesh.set_meta("render_variant", "wire")


func mark_mesh_solid_only(mesh: MeshInstance3D) -> void:
	mesh.set_meta("render_variant", "solid")


func register_style_label(label: Label3D, role: String, base_color: Color = Color.WHITE) -> void:
	label.set_meta("style_role", role)
	label.set_meta("style_base_color", base_color)
	if not label.is_in_group("style_label"):
		label.add_to_group("style_label")
	apply_label_style(label)


func apply_mesh_style(mesh: MeshInstance3D) -> void:
	var role := str(mesh.get_meta("style_role", "world"))
	var base_color: Color = mesh.get_meta("style_base_color", Color.WHITE)
	var render_variant := str(mesh.get_meta("render_variant", "both"))
	mesh.visible = true
	if render_variant == "solid":
		mesh.visible = shaded_mode
	elif render_variant == "wire":
		mesh.visible = not shaded_mode
	mesh.material_override = build_style_material(role, base_color, render_variant)


func apply_label_style(label: Label3D) -> void:
	var role := str(label.get_meta("style_role", "label"))
	var base_color: Color = label.get_meta("style_base_color", Color.WHITE)
	label.modulate = resolve_style_color(role, base_color)


func build_style_material(role: String, base_color: Color, render_variant: String = "both") -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	var color := resolve_style_color(role, base_color)
	material.albedo_color = color
	var is_shaded_solid := shaded_mode and render_variant == "solid"
	if shaded_mode:
		if role == "station":
			material.albedo_color = color.lerp(Color(0.72, 0.78, 0.86), 0.78)
		material.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
		material.roughness = 0.28 if role in ["station", "player", "enemy", "target"] else 0.54
		material.metallic = 0.42 if role in ["station", "player", "enemy"] else 0.08
		material.emission_enabled = role in ["danger", "objective", "dock", "target", "enemy", "lane"]
		if material.emission_enabled:
			material.emission = color * (0.18 if role == "lane" else 0.35)
		if is_shaded_solid:
			material.cull_mode = BaseMaterial3D.CULL_BACK
			material.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_OPAQUE_ONLY
			material.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
			material.albedo_color.a = 1.0
	else:
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.emission_enabled = true
		material.emission = color
	if color.a < 0.99 and not is_shaded_solid:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if visual_preset_index == 3 and role not in ["enemy", "danger"] and not is_shaded_solid:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.albedo_color.a = 0.72 if shaded_mode else 0.58
	return material


func resolve_style_color(role: String, base_color: Color) -> Color:
	match visual_preset_index:
		1:
			if role in ["enemy", "danger", "alert"]:
				return Color(1.0, 0.5, 0.34)
			if role in ["target", "objective", "dock"]:
				return Color(0.58, 1.0, 0.84)
			if role == "lane":
				return base_color.lerp(Color(0.46, 0.82, 1.0, base_color.a), 0.1)
			return base_color.lerp(Color(0.36, 0.95, 1.0), 0.16)
		2:
			if role in ["enemy", "danger", "alert"]:
				return Color(1.0, 0.45, 0.26)
			if role in ["target", "objective", "dock"]:
				return Color(1.0, 0.86, 0.3)
			if role == "lane":
				return base_color.lerp(Color(0.82, 0.92, 1.0, base_color.a), 0.08)
			return quantize_color(base_color.lerp(Color(1.0, 0.82, 0.58), 0.22), 0.26)
		3:
			if role in ["enemy", "danger", "alert"]:
				return Color(1.0, 0.38, 0.44)
			if role in ["target", "objective", "dock"]:
				return Color(0.62, 1.0, 0.88)
			if role == "lane":
				return base_color.lerp(Color(0.48, 1.0, 0.94, base_color.a), 0.18)
			return base_color.lerp(Color(0.26, 1.0, 0.86), 0.5)
		_:
			if role in ["enemy", "danger", "alert"]:
				return Color(1.0, 0.4, 0.32)
			if role in ["target", "objective", "dock"]:
				return Color(0.82, 0.92, 1.0)
			if role == "lane":
				return base_color.lerp(Color(0.66, 0.82, 1.0, base_color.a), 0.18)
			return base_color.lerp(Color(0.78, 0.86, 0.98), 0.08)


func quantize_color(color: Color, step: float) -> Color:
	return Color(
		snappedf(color.r, step),
		snappedf(color.g, step),
		snappedf(color.b, step),
		color.a
	)


func apply_player_style() -> void:
	var hull_wire := player_visual.get_node_or_null("HullWire")
	if hull_wire is MeshInstance3D:
		mark_mesh_wireframe_only(hull_wire)
		register_style_mesh(hull_wire, "player", Color(0.45, 0.88, 1.0))
	var player_color := resolve_style_color("player", Color(0.45, 0.88, 1.0))
	player.call("set_cockpit_style", shaded_mode, player_color)
	var hull_solid := player_visual.get_node_or_null("HullSolid")
	if hull_solid is MeshInstance3D:
		mark_mesh_solid_only(hull_solid)
		register_style_mesh(hull_solid, "player", Color(0.45, 0.88, 1.0))
	var thruster_color := resolve_style_color("objective", Color(0.55, 0.95, 1.0))
	if shaded_mode:
		thruster_color = Color(1.0, 0.58, 0.18)
	player.call("set_thruster_style", shaded_mode, thruster_color)
	var engine_glow := player_visual.get_node_or_null("EngineGlow")
	if engine_glow is MeshInstance3D:
		register_style_mesh(engine_glow, "objective", thruster_color)
	var trail := player.get_node_or_null("Trail")
	if trail is MeshInstance3D:
		register_style_mesh(trail, "objective", thruster_color)


func apply_hud_style() -> void:
	var hud_color := Color(0.76, 0.92, 1.0)
	var accent_color := Color(0.56, 1.0, 0.86)
	var alert_color := Color(1.0, 0.58, 0.46)
	match visual_preset_index:
		1:
			hud_color = Color(0.76, 0.92, 1.0)
			accent_color = Color(0.56, 1.0, 0.86)
			alert_color = Color(1.0, 0.58, 0.46)
		2:
			hud_color = Color(1.0, 0.9, 0.72)
			accent_color = Color(1.0, 0.82, 0.34)
			alert_color = Color(1.0, 0.48, 0.3)
		3:
			hud_color = Color(0.68, 1.0, 0.9)
			accent_color = Color(0.32, 1.0, 0.82)
			alert_color = Color(1.0, 0.45, 0.54)
		_:
			hud_color = Color(0.84, 0.9, 1.0)
			accent_color = Color(0.96, 0.98, 1.0)
			alert_color = Color(1.0, 0.5, 0.45)
	apply_panel_styles(hud_color, accent_color, alert_color)
	title_label.modulate = accent_color
	dock_label.modulate = hud_color
	cargo_label.modulate = hud_color
	objective_label.modulate = accent_color
	scanner_label.modulate = hud_color
	message_label.modulate = hud_color
	combat_label.modulate = hud_color
	alert_label.modulate = alert_color
	hit_label.modulate = alert_color
	dock_value.modulate = hud_color
	route_value.modulate = hud_color
	scanner_value.modulate = hud_color
	combat_value.modulate = hud_color
	message_value.modulate = hud_color
	alert_value.modulate = alert_color
	hit_value.modulate = alert_color
	hull_bar.modulate = accent_color
	shield_bar.modulate = hud_color
	reticle.modulate = accent_color
	cockpit_mode_label.modulate = accent_color
	pause_label.modulate = accent_color
	start_label.modulate = accent_color
	start_sub_label.modulate = hud_color
	start_status_label.modulate = hud_color
	start_hint_label.modulate = accent_color
	settings_panel.modulate = Color(hud_color.r, hud_color.g, hud_color.b, 0.95)
	settings_title.modulate = accent_color
	preset_value.modulate = hud_color
	bloom_value.modulate = hud_color
	music_value.modulate = hud_color
	sfx_value.modulate = hud_color
	settings_hint.modulate = accent_color
	settings_hotkeys.modulate = hud_color
	start_progress_frame.add_theme_stylebox_override("panel", make_panel_stylebox(Color(0.04, 0.06, 0.09, 0.84), accent_color, 10))
	start_progress_bar.add_theme_stylebox_override("background", make_bar_stylebox(Color(0.08, 0.11, 0.16, 0.96), hud_color.darkened(0.55)))
	start_progress_bar.add_theme_stylebox_override("fill", make_bar_stylebox(Color(hud_color.r * 0.78, hud_color.g * 0.96, 1.0, 0.98), accent_color))


func apply_panel_styles(hud_color: Color, accent_color: Color, alert_color: Color) -> void:
	top_frame.add_theme_stylebox_override("panel", make_panel_stylebox(Color(0.05, 0.06, 0.08, 0.72), alert_color, 18))
	left_frame.add_theme_stylebox_override("panel", make_panel_stylebox(Color(0.03, 0.05, 0.08, 0.76), accent_color, 20))
	right_frame.add_theme_stylebox_override("panel", make_panel_stylebox(Color(0.03, 0.05, 0.08, 0.76), accent_color, 20))
	message_frame.add_theme_stylebox_override("panel", make_panel_stylebox(Color(0.02, 0.03, 0.05, 0.8), hud_color, 18))
	settings_panel.add_theme_stylebox_override("panel", make_panel_stylebox(Color(0.02, 0.03, 0.05, 0.88), accent_color, 16))
	pause_card.add_theme_stylebox_override("panel", make_panel_stylebox(Color(0.02, 0.03, 0.05, 0.9), alert_color, 24))
	start_card.add_theme_stylebox_override("panel", make_panel_stylebox(Color(0.02, 0.03, 0.05, 0.9), accent_color, 28))

	hull_bar.add_theme_stylebox_override("background", make_bar_stylebox(Color(0.1, 0.13, 0.18, 0.92), hud_color.darkened(0.55)))
	hull_bar.add_theme_stylebox_override("fill", make_bar_stylebox(Color(alert_color.r, alert_color.g * 0.85, alert_color.b * 0.85, 0.98), accent_color))
	shield_bar.add_theme_stylebox_override("background", make_bar_stylebox(Color(0.08, 0.11, 0.16, 0.92), hud_color.darkened(0.55)))
	shield_bar.add_theme_stylebox_override("fill", make_bar_stylebox(Color(hud_color.r * 0.72, hud_color.g * 0.9, 1.0, 0.98), accent_color))


func make_panel_stylebox(background: Color, border: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(2)
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_right = radius
	style.corner_radius_bottom_left = radius
	style.content_margin_left = 10.0
	style.content_margin_top = 8.0
	style.content_margin_right = 10.0
	style.content_margin_bottom = 8.0
	style.shadow_color = Color(0, 0, 0, 0.34)
	style.shadow_size = 10
	return style


func make_bar_stylebox(background: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(1)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left = 8
	return style


func _on_preset_prev_pressed() -> void:
	set_visual_preset((visual_preset_index + 3) % 4)


func _on_preset_next_pressed() -> void:
	set_visual_preset((visual_preset_index + 1) % 4)


func _on_render_mode_pressed() -> void:
	toggle_shaded_mode()


func _on_bloom_pressed() -> void:
	toggle_bloom()


func _on_music_pressed() -> void:
	toggle_music()


func _on_music_slider_changed(value: float) -> void:
	music_volume = clamp(value / 100.0, 0.0, 1.0)
	update_music_state()


func _on_sfx_pressed() -> void:
	toggle_sfx()


func _on_sfx_slider_changed(value: float) -> void:
	sfx_volume = clamp(value / 100.0, 0.0, 1.0)


func _on_trail_pressed() -> void:
	toggle_trail()


func _on_guidance_pressed() -> void:
	toggle_guidance()


func _on_invert_y_pressed() -> void:
	toggle_invert_y()


func _on_physics_mode_pressed() -> void:
	toggle_physics_mode()


func _on_edge_threshold_slider_changed(value: float) -> void:
	edge_threshold = clamp(value / 100.0, 0.05, 0.35)
	update_edge_pass_theme()


func _on_edge_strength_slider_changed(value: float) -> void:
	edge_strength_scale = clamp(value / 100.0, 0.5, 2.0)
	update_edge_pass_theme()


func _on_edge_glow_slider_changed(value: float) -> void:
	edge_glow_scale = clamp(value / 100.0, 0.5, 2.0)
	update_edge_pass_theme()


func _on_blur_amount_slider_changed(value: float) -> void:
	blur_strength_scale = clamp(value / 100.0, 0.5, 2.2)
	update_blur_pass_theme()


func toggle_bloom() -> void:
	bloom_enabled = not bloom_enabled
	apply_visual_preset()


func toggle_music() -> void:
	music_enabled = not music_enabled
	update_music_state()


func toggle_sfx() -> void:
	sfx_enabled = not sfx_enabled


func toggle_trail() -> void:
	var trail_enabled: bool = player.call("toggle_motion_trail")
	set_alert("Motion trail: %s" % ("on" if trail_enabled else "off"), 0.45)


func toggle_guidance() -> void:
	objective_guidance_enabled = not objective_guidance_enabled
	set_alert("Guidance line: %s" % ("on" if objective_guidance_enabled else "off"), 0.45)


func toggle_invert_y() -> void:
	invert_y_axis = not invert_y_axis
	set_alert("Invert Y: %s" % ("on" if invert_y_axis else "off"), 0.45)


func toggle_physics_mode() -> void:
	flight_physics_mode = "real" if flight_physics_mode == "game" else "game"
	if flight_physics_mode == "real" and autopilot_active:
		cancel_autopilot()
	player.call("set_physics_mode", flight_physics_mode)
	set_alert("Flight mode: %s" % flight_physics_mode, 0.45)


func update_settings_label() -> void:
	var trail_active = player.get("trail_enabled")
	settings_title.text = "Graphics + Flight"
	preset_value.text = "Theme: %s / %s" % [get_preset_name(visual_preset_index), "Shaded" if shaded_mode else "Wireframe"]
	bloom_value.text = "Bloom: %s" % ("On" if bloom_enabled else "Off")
	music_value.text = "Music: %s (%d%%)" % ["On" if music_enabled else "Off", int(round(music_volume * 100.0))]
	sfx_value.text = "SFX: %s (%d%%)" % ["On" if sfx_enabled else "Off", int(round(sfx_volume * 100.0))]
	trail_value.text = "Trail: %s" % ("On" if trail_active else "Off")
	guidance_value.text = "Guidance: %s" % ("On" if objective_guidance_enabled else "Off")
	invert_y_value.text = "Invert Y: %s" % ("On" if invert_y_axis else "Off")
	physics_mode_value.text = "Flight Mode: %s" % flight_physics_mode.capitalize()
	render_mode_button.text = "Mode: %s" % ("Shaded" if shaded_mode else "Wire")
	bloom_button.text = "Bloom: %s" % ("On" if bloom_enabled else "Off")
	music_button.text = "Music: %s" % ("On" if music_enabled else "Off")
	sfx_button.text = "SFX: %s" % ("On" if sfx_enabled else "Off")
	trail_button.text = "Trail: %s" % ("On" if trail_active else "Off")
	guidance_button.text = "Guide: %s" % ("On" if objective_guidance_enabled else "Off")
	invert_y_button.text = "Y: %s" % ("Inv" if invert_y_axis else "Norm")
	physics_mode_button.text = "Mode: %s" % flight_physics_mode.capitalize()
	edge_threshold_value.text = "Edge Threshold: %.2f" % edge_threshold
	edge_strength_value.text = "Edge Strength: %d%%" % int(round(edge_strength_scale * 100.0))
	edge_glow_value.text = "Edge Glow: %d%%" % int(round(edge_glow_scale * 100.0))
	blur_amount_value.text = "Fog Amount: %d%%" % int(round(blur_strength_scale * 100.0))
	if abs(music_slider.value - music_volume * 100.0) > 0.5:
		music_slider.value = music_volume * 100.0
	if abs(sfx_slider.value - sfx_volume * 100.0) > 0.5:
		sfx_slider.value = sfx_volume * 100.0
	if abs(edge_threshold_slider.value - edge_threshold * 100.0) > 0.5:
		edge_threshold_slider.value = edge_threshold * 100.0
	if abs(edge_strength_slider.value - edge_strength_scale * 100.0) > 0.5:
		edge_strength_slider.value = edge_strength_scale * 100.0
	if abs(edge_glow_slider.value - edge_glow_scale * 100.0) > 0.5:
		edge_glow_slider.value = edge_glow_scale * 100.0
	if abs(blur_amount_slider.value - blur_strength_scale * 100.0) > 0.5:
		blur_amount_slider.value = blur_strength_scale * 100.0


func update_hit_feedback(delta: float) -> void:
	if hit_timer > 0.0:
		hit_timer = max(hit_timer - delta, 0.0)
		if hit_timer == 0.0:
			hit_label.text = ""
			hit_value.text = ""


func show_hit_feedback(message: String) -> void:
	hit_label.text = message
	hit_value.text = message
	hit_timer = 0.55


func start_run() -> void:
	start_screen_active = false
	start_card.visible = false
	start_label.visible = false
	start_sub_label.visible = false
	start_status_label.visible = false
	start_progress_frame.visible = false
	start_hint_label.visible = false
	paused = false
	cancel_autopilot(false)
	title_label.text = "Wireframe System"
	update_status("Launch confirmed.\nHostile drones are still buried in the debris fields. Use the opening to scout the system.")
	update_mouse_mode()


func toggle_pause() -> void:
	if game_over_state or start_screen_active:
		return
	if autopilot_active and not paused:
		cancel_autopilot()
	paused = not paused
	pause_card.visible = paused
	pause_label.visible = paused
	if paused:
		pause_label.text = "Paused\nPress Esc to resume"
		title_label.text = "Paused"
	else:
		title_label.text = "Wireframe System"
	update_mouse_mode()


func update_boot_screen(delta: float) -> void:
	if not start_screen_active:
		return
	boot_screen_time += delta
	var progress: float = min(18.0 + boot_screen_time * 32.0, 100.0)
	start_progress_bar.value = progress
	if progress < 34.0:
		start_status_label.text = "Booting navigation mesh..."
	elif progress < 58.0:
		start_status_label.text = "Synchronizing orbital traffic lattice..."
	elif progress < 82.0:
		start_status_label.text = "Charging flight surfaces and weapon buses..."
	elif progress < 100.0:
		start_status_label.text = "Locking cockpit telemetry..."
	else:
		start_status_label.text = "Grid online. Press Enter or A to launch."


func toggle_camera_mode() -> void:
	camera_mode = (camera_mode + 1) % 3
	player.call("set_camera_view", camera_mode)
	var view_name := get_camera_mode_name()
	set_alert(view_name, 0.45)
	update_mouse_mode()


func reset_view() -> void:
	orbit_distance = 18.0
	var ship_basis: Basis = player.call("get_visual_basis")
	var ship_back: Vector3 = ship_basis.z.normalized()
	orbit_yaw = atan2(ship_back.x, ship_back.z)
	orbit_yaw_target = orbit_yaw
	orbit_pitch = -0.18
	orbit_pitch_target = orbit_pitch
	first_person_yaw = 0.0
	first_person_pitch = 0.0
	if camera_mode <= 1:
		var focus_point: Vector3 = player.global_position + ship_basis * CAMERA_FOCUS_OFFSET
		var distance := orbit_distance if camera_mode == 0 else orbit_distance * 0.62
		var orbit_local: Vector3 = Vector3(
			sin(orbit_yaw) * cos(orbit_pitch),
			sin(orbit_pitch),
			cos(orbit_yaw) * cos(orbit_pitch)
		) * distance
		camera.global_position = focus_point + orbit_local
		camera.look_at(focus_point, Vector3.UP)
	set_alert("View reset", 0.35)


func restart_game() -> void:
	cancel_autopilot(false)
	get_tree().reload_current_scene()


func toggle_autopilot() -> void:
	if start_screen_active or paused or game_over_state:
		return
	if flight_physics_mode == "real":
		set_alert("Autopilot unavailable in real mode", 0.45)
		return
	if autopilot_active:
		cancel_autopilot()
		return
	var target_station := get_target_station()
	if target_station == null:
		target_station = get_nearest_station()
	if target_station == null:
		set_alert("Autopilot: no station target", 0.45)
		return
	engage_autopilot(target_station)


func engage_autopilot(target_station: Area3D) -> void:
	autopilot_active = true
	autopilot_state = "arm"
	autopilot_station = target_station
	autopilot_timer = 0.0
	autopilot_fx_timer = 0.0
	objective_guidance_enabled = true
	player.call("set_control_lock", true)
	var station_name := str(target_station.get_meta("station_name"))
	update_status("Autopilot armed.\nCourse laid in for %s. Hold position while the flight computer solves the transfer and spins up attitude control." % station_name)
	set_alert("Autopilot armed", 0.45)
	play_sfx("autopilot_lock", -9.0)
	create_docking_effect(player.global_position, compute_autopilot_basis(get_station_corridor_direction(target_station) * -1.0), Color(0.52, 0.95, 1.0), 12.0, 0.7, "autopilot")


func cancel_autopilot(show_alert: bool = true) -> void:
	autopilot_active = false
	autopilot_state = ""
	autopilot_station = null
	autopilot_timer = 0.0
	autopilot_fx_timer = 0.0
	player.call("set_autopilot_pose", false)
	player.call("set_control_lock", false)
	if show_alert:
		set_alert("Autopilot offline", 0.35)


func compute_autopilot_seek_target(desired_velocity: Vector3, lead_time: float) -> Vector3:
	return player.global_position + desired_velocity * max(lead_time, 0.0)


func compute_autopilot_alignment(forward: Vector3) -> float:
	var ship_basis: Basis = player.call("get_visual_basis")
	var ship_forward := -ship_basis.z.normalized()
	var target_forward := forward.normalized()
	if ship_forward.length() <= 0.001 or target_forward.length() <= 0.001:
		return 0.0
	return ship_forward.dot(target_forward)


func compute_autopilot_ring_rate(distance_to_target: float, reference_distance: float) -> float:
	var far_distance: float = max(reference_distance * 1.9, 220.0)
	var near_distance: float = max(reference_distance * 0.08, 18.0)
	var closeness: float = clamp(inverse_lerp(far_distance, near_distance, distance_to_target), 0.0, 1.0)
	return lerp(0.18, 1.4, pow(closeness, 1.35))


func compute_autopilot_ring_interval(distance_to_target: float, reference_distance: float) -> float:
	var far_distance: float = max(reference_distance * 1.9, 220.0)
	var near_distance: float = max(reference_distance * 0.08, 18.0)
	var closeness: float = clamp(inverse_lerp(far_distance, near_distance, distance_to_target), 0.0, 1.0)
	return lerp(0.95, 0.18, pow(closeness, 1.25))


func update_autopilot(delta: float) -> bool:
	if not autopilot_active:
		return false
	if autopilot_station == null or not is_instance_valid(autopilot_station):
		cancel_autopilot()
		return false

	autopilot_timer += delta
	autopilot_fx_timer = max(autopilot_fx_timer - delta, 0.0)
	var dock_offset: Vector3 = autopilot_station.get_meta("dock_offset", Vector3(0, 0, 220))
	var dock_point: Vector3 = autopilot_station.global_position + dock_offset
	var corridor_dir: Vector3 = get_station_corridor_direction(autopilot_station)
	var approach_distance: float = clamp(dock_offset.length() * AUTOPILOT_APPROACH_FACTOR, AUTOPILOT_APPROACH_MIN, AUTOPILOT_APPROACH_MAX)
	var align_distance: float = clamp(dock_offset.length() * AUTOPILOT_ALIGN_FACTOR, AUTOPILOT_ALIGN_MIN, AUTOPILOT_ALIGN_MAX)
	var depart_distance: float = clamp(dock_offset.length() * AUTOPILOT_DEPART_FACTOR, AUTOPILOT_DEPART_MIN, AUTOPILOT_DEPART_MAX)
	var approach_point: Vector3 = dock_point + corridor_dir * approach_distance
	var align_point: Vector3 = dock_point + corridor_dir * align_distance
	var departure_point: Vector3 = dock_point + corridor_dir * depart_distance + autopilot_station.global_basis.y.normalized() * min(depart_distance * 0.12, 140.0)
	var dock_basis: Basis = compute_autopilot_basis(-corridor_dir)
	var launch_basis: Basis = compute_autopilot_basis(corridor_dir)
	var transfer_dir := (approach_point - player.global_position).normalized()
	if transfer_dir.length() <= 0.001:
		transfer_dir = -corridor_dir
	var transfer_basis: Basis = compute_autopilot_basis(transfer_dir)

	match autopilot_state:
		"arm":
			var settle_velocity: Vector3 = player.velocity * max(1.0 - delta * 3.2, 0.0)
			player.call("set_autopilot_pose", true, player.global_position, player.call("get_visual_basis"), settle_velocity)
			if autopilot_fx_timer == 0.0:
				autopilot_fx_timer = 0.9
				play_sfx("autopilot_lock", -16.0)
				create_docking_effect(player.global_position, transfer_basis, Color(0.5, 0.86, 1.0), 10.0, 0.55, "autopilot", 0.32)
			if autopilot_timer >= AUTOPILOT_ARM_DURATION:
				autopilot_state = "turn"
				autopilot_timer = 0.0
				update_status("Autopilot executing.\nTransfer solution converged. Rotating onto the departure vector before main drive ignition.")
				set_alert("AP execute", 0.35)
				play_sfx("autopilot_lock", -11.0)
		"turn":
			var settle_velocity: Vector3 = player.velocity * max(1.0 - delta * 3.8, 0.0)
			player.call("set_autopilot_pose", true, player.global_position, transfer_basis, settle_velocity)
			if autopilot_fx_timer == 0.0:
				autopilot_fx_timer = 0.28
				create_docking_effect(player.global_position + transfer_dir * 18.0, transfer_basis, Color(0.54, 0.94, 1.0), 11.0, 0.45, "autopilot", 0.55)
			if compute_autopilot_alignment(transfer_dir) > 0.992 or autopilot_timer >= AUTOPILOT_TURN_DURATION:
				autopilot_state = "approach"
				autopilot_timer = 0.0
				update_status("Autopilot transfer burn.\nAttitude locked and corridor acquired. Proceeding on a controlled intercept to the station approach gate.")
		"approach":
			var distance_to_approach: float = player.global_position.distance_to(approach_point)
			var ring_rate: float = compute_autopilot_ring_rate(distance_to_approach, approach_distance)
			var desired_speed: float = clamp(distance_to_approach * 0.54, 90.0, 360.0)
			var approach_velocity: Vector3 = (approach_point - player.global_position).normalized() * desired_speed if distance_to_approach > 1.0 else Vector3.ZERO
			var approach_basis := compute_autopilot_basis(approach_velocity if approach_velocity.length() > 1.0 else transfer_dir)
			var approach_target := compute_autopilot_seek_target(approach_velocity, AUTOPILOT_CRUISE_LEAD)
			player.call("set_autopilot_pose", true, approach_target, approach_basis, approach_velocity)
			if autopilot_fx_timer == 0.0:
				autopilot_fx_timer = compute_autopilot_ring_interval(distance_to_approach, approach_distance)
				create_docking_effect(approach_target, approach_basis, Color(0.46, 0.9, 1.0), 24.0, 0.8, "dock_lane", ring_rate)
			if distance_to_approach < 110.0 and player.velocity.length() < 220.0:
				autopilot_state = "align"
				autopilot_timer = 0.0
				play_sfx("autopilot_lock", -11.0)
				update_status("Autopilot final approach.\nRelative velocity is nominal. Aligning to the dock corridor now.")
		"align":
			var distance_to_align: float = player.global_position.distance_to(align_point)
			var ring_rate: float = compute_autopilot_ring_rate(distance_to_align, align_distance)
			var desired_speed: float = clamp(distance_to_align * 0.58, 34.0, 130.0)
			var align_velocity: Vector3 = (align_point - player.global_position).normalized() * desired_speed if distance_to_align > 1.0 else Vector3.ZERO
			var align_target := compute_autopilot_seek_target(align_velocity, AUTOPILOT_ALIGN_LEAD)
			player.call("set_autopilot_pose", true, align_target, dock_basis, align_velocity)
			if autopilot_fx_timer == 0.0:
				autopilot_fx_timer = compute_autopilot_ring_interval(distance_to_align, align_distance)
				create_docking_effect(align_point, dock_basis, Color(0.58, 1.0, 0.9), 18.0, 0.7, "dock_lane", ring_rate)
			if distance_to_align < 26.0 and player.velocity.length() < 65.0:
				autopilot_state = "dock"
				autopilot_timer = 0.0
				play_sfx("dock", -10.0)
				create_docking_effect(dock_point, dock_basis, Color(0.82, 1.0, 0.96), 28.0, 1.1, "dock_flash")
				update_status("Autopilot docking.\nMag-clamps are primed, alignment lasers stable, and docking collar is closing.")
		"dock":
			var t: float = clamp(autopilot_timer / AUTOPILOT_DOCK_DURATION, 0.0, 1.0)
			var smoothed: float = t * t * (3.0 - 2.0 * t)
			var position: Vector3 = align_point.lerp(dock_point, smoothed)
			var velocity: Vector3 = (dock_point - align_point).normalized() * lerp(32.0, 0.0, smoothed)
			player.call("set_autopilot_pose", true, position, dock_basis, velocity)
			if t >= 1.0:
				dock_at_station(autopilot_station)
				autopilot_state = "docked"
				autopilot_timer = 0.0
				play_sfx("dock", -7.0)
				create_docking_effect(dock_point, dock_basis, Color(1.0, 0.96, 0.82), 34.0, 1.2, "dock_flash")
				update_status("Docking complete.\nService umbilicals connected. Stand by for automatic launch and departure burn.")
		"docked":
			player.call("set_autopilot_pose", true, dock_point, dock_basis, Vector3.ZERO)
			if autopilot_timer >= AUTOPILOT_DOCK_HOLD:
				autopilot_state = "launch"
				autopilot_timer = 0.0
				play_sfx("launch", -8.0)
				create_docking_effect(dock_point, launch_basis, Color(0.55, 0.92, 1.0), 24.0, 1.0, "launch_flash")
				update_status("Launch authorized.\nClamps released, corridor clear, and departure burn is underway.")
		"launch":
			var t: float = clamp(autopilot_timer / AUTOPILOT_LAUNCH_DURATION, 0.0, 1.0)
			var eased: float = 1.0 - pow(1.0 - t, 3.0)
			var position: Vector3 = dock_point.lerp(departure_point, eased)
			var basis: Basis = dock_basis.slerp(launch_basis, eased)
			var velocity: Vector3 = corridor_dir * lerp(32.0, 260.0, eased)
			var launch_target := position.lerp(compute_autopilot_seek_target(velocity, AUTOPILOT_LAUNCH_LEAD), 0.55)
			player.call("set_autopilot_pose", true, launch_target, basis, velocity)
			if autopilot_fx_timer == 0.0:
				autopilot_fx_timer = 0.22
				create_docking_effect(position, basis, Color(0.44, 0.88, 1.0), 14.0 + eased * 10.0, 0.6, "launch_flash")
			if t >= 1.0:
				player.velocity = velocity
				player.call("set_autopilot_pose", false)
				player.call("set_control_lock", false)
				autopilot_active = false
				autopilot_state = ""
				autopilot_station = null
				autopilot_timer = 0.0
				autopilot_fx_timer = 0.0
				set_alert("Autopilot complete", 0.45)
				update_status("Autopilot departure complete.\nYou are clear of the dock and back on manual flight control.")
	return true


func get_station_corridor_direction(station: Area3D) -> Vector3:
	var dock_offset: Vector3 = station.get_meta("dock_offset", Vector3(0, 0, 220))
	if dock_offset.length() > 0.001:
		return dock_offset.normalized()
	return station.global_basis.z.normalized()


func compute_autopilot_basis(forward: Vector3) -> Basis:
	var fwd := forward.normalized()
	var up := get_safe_up_vector(fwd, Vector3.UP)
	var right := up.cross(-fwd).normalized()
	up = (-fwd).cross(right).normalized()
	return Basis(right, up, -fwd).orthonormalized()


func update_mouse_mode() -> void:
	if DisplayServer.get_name() == "headless":
		return
	if paused or start_screen_active or settings_visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		return
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func get_camera_mode_name() -> String:
	match camera_mode:
		1:
			return "Chase"
		2:
			return "Cockpit"
		_:
			return "Orbit"


func handle_camera_look(relative: Vector2) -> void:
	var pitch_sign := -1.0 if invert_y_axis else 1.0
	if camera_mode == 2:
		first_person_yaw = clamp(first_person_yaw + relative.x * FIRST_PERSON_MOUSE_SENSITIVITY, -1.35, 1.35)
		first_person_pitch = clamp(first_person_pitch + relative.y * FIRST_PERSON_MOUSE_SENSITIVITY * pitch_sign, -0.9, 0.55)
		return
	camera_manual_input_timer = CHASE_BIAS_DELAY
	orbit_yaw_target += relative.x * CAMERA_MOUSE_SENSITIVITY * 0.72
	orbit_pitch_target = clamp(orbit_pitch_target + relative.y * CAMERA_MOUSE_SENSITIVITY * 0.54 * pitch_sign, -0.72, 0.34)


func update_controller_camera(delta: float) -> void:
	var joypads := Input.get_connected_joypads()
	if joypads.is_empty():
		return
	var joypad := int(joypads[0])
	var look_x := apply_controller_deadzone(Input.get_joy_axis(joypad, JOY_AXIS_RIGHT_X))
	var look_y := apply_controller_deadzone(Input.get_joy_axis(joypad, JOY_AXIS_RIGHT_Y))
	if abs(look_x) < 0.001 and abs(look_y) < 0.001:
		return
	var pitch_sign := -1.0 if invert_y_axis else 1.0
	var relative := Vector2(-look_x * CONTROLLER_CAMERA_SPEED.x, look_y * CONTROLLER_CAMERA_SPEED.y * pitch_sign) * delta * 0.72
	if camera_mode == 2:
		first_person_yaw = clamp(first_person_yaw + relative.x, -1.35, 1.35)
		first_person_pitch = clamp(first_person_pitch + relative.y, -0.9, 0.55)
		return
	camera_manual_input_timer = CHASE_BIAS_DELAY
	orbit_yaw_target += relative.x
	orbit_pitch_target = clamp(orbit_pitch_target + relative.y * 0.72, -0.72, 0.34)


func apply_controller_deadzone(value: float) -> float:
	if abs(value) < CONTROLLER_CAMERA_DEADZONE:
		return 0.0
	return sign(value) * ((abs(value) - CONTROLLER_CAMERA_DEADZONE) / max(1.0 - CONTROLLER_CAMERA_DEADZONE, 0.001))


func update_combat_label() -> void:
	var target_info := "Target none"
	var target := get_primary_enemy_target()
	if target != null:
		target_info = "◎ %.0fm" % player.global_position.distance_to(target.global_position)
	var autopilot_info := "AP manual"
	if autopilot_active:
		var station_name := ""
		if autopilot_station != null and is_instance_valid(autopilot_station):
			station_name = str(autopilot_station.get_meta("station_name"))
		autopilot_info = "AP %s%s" % [get_autopilot_state_display(), "" if station_name.is_empty() else " %s" % station_name]
	hull_bar.value = player_hull
	shield_bar.value = player_shields
	combat_label.text = "H %d  S %d  ◎ %d\n# %d  × %d\n%s\n%s" % [
		int(round(player_hull)),
		int(round(player_shields)),
		enemy_nodes.size(),
		score,
		kills,
		target_info,
		autopilot_info
	]
	combat_value.text = "◎ %d\n× %d\n# %d\n%s\n%s" % [
		enemy_nodes.size(),
		kills,
		score,
		target_info,
		autopilot_info
	]


func update_player_combat(delta: float) -> void:
	fire_cooldown = max(fire_cooldown - delta, 0.0)
	shield_recharge_delay = max(shield_recharge_delay - delta, 0.0)
	if shield_recharge_delay == 0.0 and player_shields < PLAYER_MAX_SHIELDS:
		player_shields = min(player_shields + SHIELD_RECHARGE_RATE * delta, PLAYER_MAX_SHIELDS)


func try_fire_player_projectile() -> void:
	if game_over_state or fire_cooldown > 0.0 or autopilot_active:
		return
	fire_cooldown = PLAYER_FIRE_COOLDOWN
	var origin: Vector3 = player.call("get_muzzle_position")
	var direction: Vector3 = player.call("get_aim_direction")
	spawn_projectile(origin, direction * PLAYER_PROJECTILE_SPEED + player.velocity * 0.35, true)
	play_sfx("player_fire")
	set_alert("Laser fired", 0.2)


func spawn_initial_enemies() -> void:
	for i in range(ENEMY_SPAWN_COUNT):
		spawn_enemy(true)


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


func spawn_enemy(initial_wave: bool = false) -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var spawn_data := get_enemy_spawn_data(initial_wave, rng)
	var spawn_position: Vector3 = spawn_data["position"]

	var enemy := Node3D.new()
	enemy.name = "Drone"
	enemy.position = spawn_position
	enemy.set_meta("velocity", Vector3.ZERO)
	enemy.set_meta("hull", ENEMY_MAX_HULL)
	enemy.set_meta("fire_cooldown", rng.randf_range(0.8, 1.6))
	enemy.set_meta("orbit_bias", rng.randf_range(-1.0, 1.0))
	enemy.set_meta("ambush_mode", spawn_data["ambush_mode"])
	enemy.set_meta("field_center", spawn_data["field_center"])
	enemy.set_meta("field_anchor", spawn_position)
	enemy.set_meta("patrol_phase", rng.randf_range(0.0, TAU))

	var mesh := MeshInstance3D.new()
	mesh.mesh = build_enemy_ship_mesh()
	mark_mesh_wireframe_only(mesh)
	register_style_mesh(mesh, "enemy", Color(1.0, 0.46, 0.34))
	enemy.add_child(mesh)

	var solid_mesh := MeshInstance3D.new()
	solid_mesh.mesh = build_enemy_solid_mesh()
	mark_mesh_solid_only(solid_mesh)
	register_style_mesh(solid_mesh, "enemy", Color(1.0, 0.46, 0.34))
	enemy.add_child(solid_mesh)

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
		if enemy.get_meta("ambush_mode", false) and distance > ENEMY_AMBUSH_WAKE_RADIUS:
			update_enemy_ambush_patrol(enemy, delta)
			continue
		elif enemy.get_meta("ambush_mode", false):
			enemy.set_meta("ambush_mode", false)

		var direction := to_player.normalized() if distance > 0.001 else Vector3.FORWARD
		var lateral := Vector3(-direction.z, 0, direction.x) * float(enemy.get_meta("orbit_bias")) * 55.0
		var desired_velocity := direction * 130.0 + lateral
		if distance < 220.0:
			desired_velocity = -direction * 110.0 + lateral

		var velocity: Vector3 = enemy.get_meta("velocity")
		velocity = velocity.lerp(desired_velocity, min(delta * 1.4, 1.0))
		velocity += compute_gravity_at_position(enemy.global_position) * delta
		enemy.set_meta("velocity", velocity)
		enemy.global_position += velocity * delta
		if velocity.length() > 2.0:
			enemy.look_at(enemy.global_position + velocity.normalized(), get_safe_up_vector(velocity.normalized(), Vector3.UP), true)

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


func get_enemy_spawn_data(initial_wave: bool, rng: RandomNumberGenerator) -> Dictionary:
	var min_distance := ENEMY_FIELD_SPAWN_MIN_DISTANCE if initial_wave else ENEMY_FIELD_RESPAWN_MIN_DISTANCE
	var field_spawn := get_debris_field_spawn(min_distance, rng)
	if not field_spawn.is_empty():
		field_spawn["ambush_mode"] = initial_wave
		return field_spawn

	var radial := Vector3(
		rng.randf_range(-1.0, 1.0),
		rng.randf_range(-0.2, 0.2),
		rng.randf_range(-1.0, 1.0)
	).normalized()
	var tangent := Vector3(-radial.z, 0, radial.x).normalized()
	return {
		"position": player.global_position + radial * rng.randf_range(640.0, 920.0) + tangent * rng.randf_range(-220.0, 220.0),
		"field_center": Vector3.ZERO,
		"ambush_mode": false
	}


func get_debris_field_spawn(min_player_distance: float, rng: RandomNumberGenerator) -> Dictionary:
	if planet_bodies.is_empty():
		return {}

	var candidates: Array[Dictionary] = []
	for body in planet_bodies:
		var planet_node: Node3D = body["node"]
		var planet_position := planet_node.global_position
		if player.global_position.distance_to(planet_position) < min_player_distance:
			continue

		var to_player := player.global_position - planet_position
		var planar_to_player := Vector3(to_player.x, 0, to_player.z)
		var hide_direction := Vector3.FORWARD
		if planar_to_player.length() > 0.001:
			hide_direction = -planar_to_player.normalized()

		var tangent := Vector3(-hide_direction.z, 0, hide_direction.x).normalized()
		var ring_radius: float = body["radius"] + 54.0
		var position := planet_position
		position += hide_direction * ring_radius
		position += tangent * rng.randf_range(-DEBRIS_HAZARD_THICKNESS * 0.75, DEBRIS_HAZARD_THICKNESS * 0.75)
		position.y += rng.randf_range(-18.0, 18.0)

		if player.global_position.distance_to(position) < min_player_distance:
			continue

		candidates.append({
			"position": position,
			"field_center": planet_position,
			"distance": player.global_position.distance_to(position)
		})

	if candidates.is_empty():
		return {}

	candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a["distance"]) > float(b["distance"])
	)
	return candidates[rng.randi_range(0, min(1, candidates.size() - 1))]


func update_enemy_ambush_patrol(enemy: Node3D, delta: float) -> void:
	var center: Vector3 = enemy.get_meta("field_center", enemy.global_position)
	var anchor: Vector3 = enemy.get_meta("field_anchor", enemy.global_position)
	var radial := anchor - center
	if radial.length() <= 0.001:
		radial = Vector3.FORWARD * 24.0
	var tangent := Vector3(-radial.z, 0, radial.x).normalized()
	if tangent.length() <= 0.001:
		tangent = Vector3.RIGHT

	var phase: float = enemy.get_meta("patrol_phase", 0.0) + delta * (0.7 + abs(float(enemy.get_meta("orbit_bias", 0.0))) * 0.4)
	enemy.set_meta("patrol_phase", phase)

	var target_position := anchor
	target_position += tangent * sin(phase) * ENEMY_FIELD_PATROL_RADIUS
	target_position.y += cos(phase * 1.6) * 10.0

	var to_target := target_position - enemy.global_position
	var desired_velocity := Vector3.ZERO
	if to_target.length() > 0.001:
		desired_velocity = to_target.normalized() * ENEMY_FIELD_PATROL_SPEED

	var velocity: Vector3 = enemy.get_meta("velocity")
	velocity = velocity.lerp(desired_velocity, min(delta * 1.6, 1.0))
	velocity += compute_gravity_at_position(enemy.global_position) * delta
	enemy.set_meta("velocity", velocity)
	enemy.global_position += velocity * delta
	if velocity.length() > 2.0:
		enemy.look_at(enemy.global_position + velocity.normalized(), get_safe_up_vector(velocity.normalized(), Vector3.UP), true)


func spawn_projectile(origin: Vector3, velocity: Vector3, from_player: bool) -> void:
	var projectile := Node3D.new()
	projectile.name = "Pulse"
	projectile.set_meta("velocity", velocity)
	projectile.set_meta("from_player", from_player)
	projectile.set_meta("life", 0.0)

	var mesh := MeshInstance3D.new()
	mesh.mesh = build_projectile_mesh()
	mark_mesh_wireframe_only(mesh)
	register_style_mesh(mesh, "objective" if from_player else "enemy", Color(0.55, 0.95, 1.0) if from_player else Color(1.0, 0.54, 0.42))
	projectile.add_child(mesh)

	var solid_mesh := MeshInstance3D.new()
	solid_mesh.mesh = build_projectile_solid_mesh()
	solid_mesh.rotation_degrees.x = 90.0
	mark_mesh_solid_only(solid_mesh)
	register_style_mesh(solid_mesh, "objective" if from_player else "enemy", Color(0.55, 0.95, 1.0) if from_player else Color(1.0, 0.54, 0.42))
	projectile.add_child(solid_mesh)

	add_child(projectile)
	projectile.global_position = origin
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
		velocity += compute_gravity_at_position(projectile.global_position) * delta
		projectile.set_meta("velocity", velocity)
		projectile.global_position += velocity * delta
		projectile.look_at(projectile.global_position + velocity.normalized(), get_safe_up_vector(velocity.normalized(), Vector3.UP), true)

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
	pause_card.visible = true
	pause_label.visible = true
	pause_label.text = "Ship Lost\n%s\nPress Enter to restart" % reason
	play_sfx("loss")
	update_status("Run ended.\nPress Enter to restart the patrol.")


func setup_audio() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	if OS.has_feature("web"):
		music_player.stream = build_radio_loop_stream()
	else:
		var generator := AudioStreamGenerator.new()
		generator.mix_rate = AUDIO_MIX_RATE
		generator.buffer_length = MUSIC_BUFFER_SECONDS
		music_player.stream = generator
	music_player.volume_db = get_music_volume_db()
	add_child(music_player)
	music_player.play()
	if not OS.has_feature("web"):
		music_playback = music_player.get_stream_playback()
	sfx_streams["player_fire"] = build_player_fire_stream()
	sfx_streams["enemy_fire"] = build_enemy_fire_stream()
	sfx_streams["dock"] = build_dock_stream()
	sfx_streams["hit"] = build_hit_stream()
	sfx_streams["alert"] = build_alert_stream()
	sfx_streams["enemy_down"] = build_enemy_down_stream()
	sfx_streams["loss"] = build_loss_stream()
	sfx_streams["comms"] = build_comms_stream()
	sfx_streams["autopilot_lock"] = build_autopilot_lock_stream()
	sfx_streams["launch"] = build_launch_stream()
	update_music_state()
	update_music_stream()


func update_music_stream() -> void:
	if music_playback == null:
		return
	var frames_available := music_playback.get_frames_available()
	if frames_available <= 0:
		return

	var tracks := [
		{"name": "Drift", "progression": [55.0, 82.41, 73.42, 98.0], "accent": [220.0, 246.94, 196.0, 164.81], "pulse": 0.125},
		{"name": "Nebula FM", "progression": [61.74, 92.5, 82.41, 110.0], "accent": [164.81, 220.0, 246.94, 293.66], "pulse": 0.142},
		{"name": "Deep Relay", "progression": [49.0, 65.41, 73.42, 87.31], "accent": [146.83, 196.0, 220.0, 174.61], "pulse": 0.11}
	]
	var track_index := int(floor(music_time / 24.0)) % tracks.size()
	if track_index != radio_track_index:
		radio_track_index = track_index
		set_alert("Radio: %s" % tracks[track_index]["name"], 0.25)
	var progression: Array = tracks[track_index]["progression"]
	var accent: Array = tracks[track_index]["accent"]
	var pulse_rate: float = tracks[track_index]["pulse"]
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
		var pulse := sin(music_time * TAU * pulse_rate) * 0.022
		var sub := sin(music_phase_a * 0.5) * 0.035
		var sample: float = clamp(drone + shimmer + pulse + sub, -0.55, 0.55)
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
	player_node.volume_db = volume_db + get_sfx_volume_offset_db()
	add_child(player_node)
	player_node.finished.connect(player_node.queue_free)
	player_node.play()


func update_music_state() -> void:
	if music_player == null:
		return
	music_player.volume_db = get_music_volume_db()


func get_music_volume_db() -> float:
	if not music_enabled:
		return -80.0
	return linear_to_db(max(music_volume, 0.001)) + MUSIC_VOLUME_BIAS_DB


func get_sfx_volume_offset_db() -> float:
	if sfx_volume <= 0.0:
		return -80.0
	return linear_to_db(max(sfx_volume, 0.001))


func get_start_spawn_data() -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	if not planet_bodies.is_empty():
		for _attempt in range(24):
			var body: Dictionary = planet_bodies[rng.randi_range(0, planet_bodies.size() - 1)]
			var planet_node: Node3D = body["node"]
			var orbit_radius: float = float(body["radius"]) + 1400.0
			var angle := rng.randf_range(0.0, TAU)
			var candidate := planet_node.global_position + Vector3(
				cos(angle) * orbit_radius,
				rng.randf_range(220.0, 520.0),
				sin(angle) * orbit_radius
			)
			if is_position_safe_for_spawn(candidate):
				var radial: Vector3 = (candidate - planet_node.global_position).normalized()
				var tangent := Vector3(-radial.z, 0.0, radial.x).normalized()
				if tangent.length() <= 0.001:
					tangent = Vector3.RIGHT
				var forward: Vector3 = (tangent * 0.78 - radial * 0.58 + Vector3.UP * 0.05).normalized()
				return {
					"position": candidate,
					"planet_position": planet_node.global_position,
					"forward": forward
				}
	for _attempt in range(48):
		var candidate := Vector3(
			rng.randf_range(-WORLD_LIMIT.x * 0.72, WORLD_LIMIT.x * 0.72),
			rng.randf_range(-WORLD_LIMIT.y * 0.55, WORLD_LIMIT.y * 0.55),
			rng.randf_range(-WORLD_LIMIT.z * 0.72, WORLD_LIMIT.z * 0.72)
		)
		if is_position_safe_for_spawn(candidate):
			return {
				"position": candidate,
				"planet_position": Vector3.ZERO,
				"forward": (-candidate).normalized()
			}
	return {
		"position": Vector3(0, 240, STAR_DAMAGE_RADIUS + 260.0),
		"planet_position": Vector3.ZERO,
		"forward": Vector3(0, 0, -1)
	}


func apply_start_camera_framing(spawn_data: Dictionary) -> void:
	var forward: Vector3 = spawn_data.get("forward", Vector3.FORWARD)
	var ship_back: Vector3 = -forward.normalized()
	orbit_yaw = atan2(ship_back.x, ship_back.z)
	orbit_yaw_target = orbit_yaw
	orbit_pitch = -0.16
	orbit_pitch_target = orbit_pitch
	first_person_yaw = 0.0
	first_person_pitch = 0.0


func is_position_safe_for_spawn(position: Vector3) -> bool:
	if position.length() < STAR_DAMAGE_RADIUS + 2200.0:
		return false
	for body in planet_bodies:
		var node: Node3D = body["node"]
		if position.distance_to(node.global_position) < float(node.get_meta("collision_radius")) + 600.0:
			return false
	for station in station_order:
		if position.distance_to(station.global_position) < float(station.get_meta("collision_radius")) + 400.0:
			return false
	return true


func build_player_fire_stream() -> AudioStreamWAV:
	return build_tone_stream([1580.0, 1240.0, 980.0, 760.0], 0.08, 0.18, 0.05, 1.35)


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


func build_comms_stream() -> AudioStreamWAV:
	return build_tone_stream([880.0, 554.37, 698.46, 466.16], 0.26, 0.16, 0.08, 0.82)


func build_autopilot_lock_stream() -> AudioStreamWAV:
	return build_tone_stream([392.0, 523.25, 659.25, 783.99], 0.22, 0.18, 0.03, 1.05)


func build_launch_stream() -> AudioStreamWAV:
	return build_tone_stream([220.0, 330.0, 440.0, 554.37], 0.42, 0.24, 0.08, 0.95)


func build_radio_loop_stream() -> AudioStreamWAV:
	var duration := 24.0
	var sample_count := int(AUDIO_MIX_RATE * duration)
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	var phase_a := 0.0
	var phase_b := 0.0
	var phase_c := 0.0
	var progression := [55.0, 82.41, 73.42, 98.0, 61.74, 92.5, 82.41, 110.0]
	var accent := [220.0, 246.94, 196.0, 164.81, 146.83, 196.0, 220.0, 174.61]
	for i in range(sample_count):
		var t := float(i) / AUDIO_MIX_RATE
		var chord_index := int(floor(t / 3.0)) % progression.size()
		var beat_phase := fmod(t, 0.75) / 0.75
		var low_freq: float = progression[chord_index]
		var high_freq: float = accent[chord_index]
		phase_a += TAU * low_freq / AUDIO_MIX_RATE
		phase_b += TAU * (low_freq * 1.5) / AUDIO_MIX_RATE
		phase_c += TAU * high_freq / AUDIO_MIX_RATE
		var drone := sin(phase_a) * 0.18 + sin(phase_b) * 0.09
		var shimmer_gate := pow(max(0.0, sin(beat_phase * PI)), 3.0)
		var shimmer := sin(phase_c) * shimmer_gate * 0.04
		var pulse := sin(t * TAU * 0.13) * 0.02
		write_pcm16_sample(data, i, clamp(drone + shimmer + pulse, -0.55, 0.55))
	var stream := create_wav_stream(data)
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = sample_count
	return stream


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
	if enemy_target_marker == null or not is_instance_valid(enemy_target_marker):
		return
	var target := get_primary_enemy_target()
	if target == null:
		enemy_target_marker.visible = false
		if enemy_target_lead_marker != null:
			enemy_target_lead_marker.visible = false
		if enemy_target_label != null:
			enemy_target_label.visible = false
		return
	var distance: float = player.global_position.distance_to(target.global_position)
	var pulse := 1.0 + sin(Time.get_ticks_msec() * 0.004) * 0.08
	var vertical_offset := Vector3(0, 16.0 + sin(Time.get_ticks_msec() * 0.0028) * 1.6, 0)
	enemy_target_marker.visible = true
	enemy_target_marker.global_position = target.global_position + vertical_offset
	enemy_target_marker.mesh = build_enemy_target_marker_mesh(18.0 * pulse)
	enemy_target_marker.rotate_y(0.018)
	enemy_target_marker.rotate_z(0.01)
	var target_velocity: Vector3 = target.get_meta("velocity", Vector3.ZERO)
	var lead_position: Vector3 = target.global_position + target_velocity * clamp(distance / max(PLAYER_PROJECTILE_SPEED, 1.0), 0.18, 1.35)
	if enemy_target_lead_marker != null:
		enemy_target_lead_marker.visible = true
		enemy_target_lead_marker.global_position = lead_position
		enemy_target_lead_marker.mesh = build_target_lead_marker_mesh(7.0 + sin(Time.get_ticks_msec() * 0.006) * 0.6)
		enemy_target_lead_marker.look_at(player.global_position, Vector3.UP)
		enemy_target_lead_marker.rotate_z(Time.get_ticks_msec() * 0.0012)
	if enemy_target_label != null:
		enemy_target_label.visible = true
		enemy_target_label.global_position = target.global_position + Vector3(0, 28, 0)
		enemy_target_label.text = "LOCK  %.0fm\nLEAD" % distance


func create_burst(position: Vector3, color: Color) -> void:
	var burst := MeshInstance3D.new()
	burst.mesh = build_burst_mesh(8.0)
	add_child(burst)
	burst.global_position = position
	burst.set_meta("life", 0.0)
	register_style_mesh(burst, "alert", color)
	transient_effects.append(burst)


func create_docking_effect(position: Vector3, basis: Basis, color: Color, radius: float, duration: float, kind: String, progression_rate: float = 1.0) -> void:
	var effect := MeshInstance3D.new()
	effect.mesh = build_ring_mesh(radius, 48)
	effect.global_transform = Transform3D(basis, position)
	effect.set_meta("life", 0.0)
	effect.set_meta("duration", duration)
	effect.set_meta("effect_kind", kind)
	effect.set_meta("base_radius", radius)
	effect.set_meta("progression_rate", progression_rate)
	register_style_mesh(effect, "dock", Color(color.r, color.g, color.b, 0.9))
	add_child(effect)
	transient_effects.append(effect)


func update_effects(delta: float) -> void:
	for i in range(transient_effects.size() - 1, -1, -1):
		var effect: MeshInstance3D = transient_effects[i]
		if not is_instance_valid(effect):
			transient_effects.remove_at(i)
			continue
		var progression_rate: float = effect.get_meta("progression_rate", 1.0)
		var life: float = effect.get_meta("life") + delta * progression_rate
		effect.set_meta("life", life)
		var duration: float = effect.get_meta("duration", 0.35)
		var normalized_life: float = clamp(life / max(duration, 0.001), 0.0, 1.0)
		var effect_kind := str(effect.get_meta("effect_kind", "burst"))
		if effect_kind == "burst":
			effect.scale = Vector3.ONE * (1.0 + life * 3.2)
			effect.rotate_y(delta * 2.8)
		else:
			var base_radius: float = effect.get_meta("base_radius", 12.0)
			var alpha: float = (1.0 - normalized_life)
			effect.scale = Vector3.ONE * (1.0 + normalized_life * 2.6)
			effect.rotate_z(delta * 1.3)
			effect.rotate_y(delta * 0.9)
			effect.set_meta("style_base_color", Color(0.68, 0.96, 1.0, alpha * 0.78))
			apply_mesh_style(effect)
			effect.mesh = build_ring_mesh(base_radius * (1.0 + normalized_life * 0.42), 48)
		if life > duration:
			effect.queue_free()
			transient_effects.remove_at(i)


func get_cinematic_target_position() -> Vector3:
	if autopilot_station != null and is_instance_valid(autopilot_station):
		return autopilot_station.global_position
	var objective_station := get_target_station()
	if objective_station != null and is_instance_valid(objective_station):
		return objective_station.global_position
	var enemy_target := get_primary_enemy_target()
	if enemy_target != null and is_instance_valid(enemy_target):
		return enemy_target.global_position
	var nearest_station := get_nearest_station()
	if nearest_station != null and is_instance_valid(nearest_station):
		return nearest_station.global_position
	return player.global_position + player.call("get_visual_basis") * Vector3(0, 0, -800.0)


func compute_cinematic_camera_pose() -> Dictionary:
	var ship_basis: Basis = player.call("get_visual_basis")
	var ship_position: Vector3 = player.global_position
	var target_position: Vector3 = get_cinematic_target_position()
	var to_target: Vector3 = target_position - ship_position
	var target_distance: float = max(to_target.length(), 1.0)
	var midpoint: Vector3 = ship_position.lerp(target_position, 0.42)
	var forward_axis: Vector3 = to_target.normalized() if target_distance > 0.001 else -ship_basis.z.normalized()
	var right_axis: Vector3 = ship_basis.x.normalized()
	if right_axis.length() <= 0.001:
		right_axis = Vector3.RIGHT
	var up_axis: Vector3 = get_safe_up_vector(forward_axis, ship_basis.y)
	var phase: float = fmod(cinematic_time, 24.0)
	var shot_index: int = int(floor(phase / 6.0)) % 4
	var shot_t: float = fmod(phase, 6.0) / 6.0
	var wobble: float = sin(cinematic_time * 0.42) * 0.12
	var distance_scale: float = clamp(target_distance * 0.18, 46.0, 180.0)
	var offset := Vector3.ZERO
	var look_point := midpoint
	match shot_index:
		0:
			offset = -forward_axis * distance_scale + right_axis * distance_scale * 0.42 + up_axis * (18.0 + distance_scale * 0.18)
			look_point = ship_position.lerp(target_position, 0.55)
		1:
			offset = right_axis * distance_scale * 0.92 + up_axis * (10.0 + distance_scale * 0.1) + forward_axis * distance_scale * 0.16
			look_point = ship_position.lerp(target_position, 0.36)
		2:
			offset = -ship_basis.z.normalized() * distance_scale * 0.82 + up_axis * (22.0 + distance_scale * 0.22) - right_axis * distance_scale * 0.28
			look_point = ship_position.lerp(target_position, 0.48)
		_:
			offset = -forward_axis * distance_scale * 0.36 - right_axis * distance_scale * 0.88 + up_axis * (14.0 + distance_scale * 0.14)
			look_point = ship_position.lerp(target_position, 0.62)
	offset += right_axis * sin(shot_t * TAU) * distance_scale * 0.08
	offset += up_axis * wobble * distance_scale * 0.12
	return {
		"position": midpoint + offset,
		"look_point": look_point
	}


func update_camera(delta: float) -> void:
	var ship_basis: Basis = player.call("get_visual_basis")
	cockpit_overlay.visible = camera_mode == 2 and not start_screen_active and not paused and cinematic_blend < 0.02
	var base_position := camera.global_position
	var base_look_point := player.global_position + ship_basis * CAMERA_FOCUS_OFFSET
	if camera_mode == 2:
		camera.near = COCKPIT_CAMERA_NEAR
		var cockpit_position: Vector3 = player.call("get_true_cockpit_position")
		var head_basis := ship_basis * Basis(Vector3.UP, first_person_yaw) * Basis(Vector3.RIGHT, first_person_pitch)
		var aim_direction := -head_basis.z.normalized()
		base_position = cockpit_position
		base_look_point = cockpit_position + aim_direction * 220.0
	else:
		camera.near = CHASE_CAMERA_NEAR
		var focus_point: Vector3 = player.global_position + ship_basis * CAMERA_FOCUS_OFFSET
		if camera_mode == 1 and camera_manual_input_timer == 0.0:
			var ship_back: Vector3 = ship_basis.z.normalized()
			var desired_yaw: float = atan2(ship_back.x, ship_back.z)
			var chase_bias: float = clamp(delta * CHASE_BIAS_SPEED, 0.0, 1.0)
			orbit_yaw_target = lerp_angle(orbit_yaw_target, desired_yaw, chase_bias)
			orbit_pitch_target = lerp(orbit_pitch_target, CHASE_PITCH_TARGET, chase_bias * 0.8)
		var chase_distance: float = clamp(orbit_distance, 12.0, 24.0) if camera_mode == 0 else clamp(orbit_distance, 11.0, 20.0)
		var orbit_local: Vector3 = Vector3(
			sin(orbit_yaw) * cos(orbit_pitch),
			sin(orbit_pitch),
			cos(orbit_yaw) * cos(orbit_pitch)
		) * chase_distance
		base_position = focus_point + orbit_local
		base_look_point = focus_point

	if cinematic_blend > 0.001:
		var cinematic_pose: Dictionary = compute_cinematic_camera_pose()
		var cinematic_position: Vector3 = cinematic_pose["position"]
		var cinematic_look_point: Vector3 = cinematic_pose["look_point"]
		base_position = base_position.lerp(cinematic_position, cinematic_blend)
		base_look_point = base_look_point.lerp(cinematic_look_point, cinematic_blend)
	camera.global_position = base_position
	var look_direction: Vector3 = (base_look_point - base_position).normalized()
	camera.look_at(base_look_point, get_safe_up_vector(look_direction, ship_basis.y))
	reticle.visible = cinematic_blend < 0.02


func get_safe_up_vector(direction: Vector3, preferred_up: Vector3) -> Vector3:
	var forward := direction.normalized()
	if forward.length() <= 0.001:
		return Vector3.UP
	var up := preferred_up.normalized()
	if up.length() <= 0.001:
		up = Vector3.UP
	if abs(forward.dot(up)) > 0.98:
		up = Vector3.FORWARD if abs(forward.dot(Vector3.FORWARD)) < 0.98 else Vector3.RIGHT
	return up


func update_objective_visuals(delta: float) -> void:
	if objective_line == null or objective_marker == null:
		return
	if objective_flash_time > 0.0:
		objective_flash_time = max(objective_flash_time - delta, 0.0)
	if not objective_guidance_enabled:
		objective_line.visible = false
		objective_marker.visible = false
		return

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


func update_contextual_line_visibility() -> void:
	for i in range(shipping_lane_nodes.size() - 1, -1, -1):
		var lane := shipping_lane_nodes[i]
		if lane == null or not is_instance_valid(lane):
			shipping_lane_nodes.remove_at(i)
			continue
		var lane_parent := lane.get_parent()
		if lane_parent == null or not (lane_parent is Node3D):
			continue
		var local_midpoint: Vector3 = lane.get_meta("fade_local_midpoint", Vector3.ZERO)
		var global_midpoint: Vector3 = lane_parent.to_global(local_midpoint)
		var distance: float = player.global_position.distance_to(global_midpoint)
		var alpha: float = clamp(inverse_lerp(18000.0, 5200.0, distance), 0.0, 1.0)
		var base_color: Color = Color(0.34, 0.88, 0.76, alpha * 0.72)
		lane.set_meta("style_base_color", base_color)
		apply_mesh_style(lane)
		lane.visible = alpha > 0.02 and lane.visible


func update_scanner() -> void:
	var lines := PackedStringArray()
	lines.append("⌁")
	lines.append("☼ %.0f" % player.global_position.length())
	lines.append("g %.2f" % compute_ship_gravity().length())
	lines.append("v %.1f" % player.velocity.length())
	lines.append("⇧ %s" % ("on" if Input.is_key_pressed(KEY_SHIFT) else "idle"))
	if autopilot_active:
		lines.append("AP %s" % get_autopilot_state_display())
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
	objective_label.text = "◎ %s %s %.0fm" % [stage, target_name, distance]


func _on_station_body_entered(body: Node3D, station: Area3D) -> void:
	if body != player:
		return
	nearby_station = station
	title_label.text = "Approach"
	if not autopilot_active:
		update_status("Press E to dock at %s.\nYou are in %s orbit." % [str(station.get_meta("station_name")), str(station.get_meta("planet_name"))])


func _on_station_body_exited(body: Node3D, station: Area3D) -> void:
	if body != player:
		return
	if nearby_station == station:
		nearby_station = null
		title_label.text = "Wireframe System"
		if not autopilot_active:
			update_status("Mouse steers. WASD thrust, R/F vertical thrust.\nHold Shift to boost, Tab cycles views, and \\ swaps render mode. Press J for autopilot.")


func setup_cargo_route() -> void:
	if station_order.size() < 2:
		cargo_label.text = "▣ unavailable"
		objective_label.text = "◎ unavailable"
		return

	cargo_loaded = false
	pickup_station = str(station_order[0].get_meta("station_name"))
	var midpoint_index := int(station_order.size() / 2)
	delivery_station = str(station_order[midpoint_index].get_meta("station_name"))
	cargo_label.text = "▣ %s → %s" % [pickup_station, delivery_station]
	objective_label.text = "◎ pickup %s" % pickup_station


func handle_cargo_dock(station_name: String) -> void:
	if station_name == pickup_station and not cargo_loaded:
		cargo_loaded = true
		title_label.text = "Cargo Loaded"
		cargo_label.text = "▣ %s → %s" % [pickup_station, delivery_station]
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
	var station_count := station_order.size()
	var pickup_step := maxi(int(station_count / 2), 1)
	var delivery_step := maxi(int(station_count / 2) + 1, 1)

	pickup_station = str(station_order[(pickup_index + pickup_step) % station_count].get_meta("station_name"))
	delivery_station = str(station_order[(delivery_index + delivery_step) % station_count].get_meta("station_name"))
	if pickup_station == delivery_station:
		delivery_station = str(station_order[(delivery_index + 1) % station_count].get_meta("station_name"))

	cargo_label.text = "▣ %s → %s" % [pickup_station, delivery_station]
	objective_label.text = "◎ pickup %s" % pickup_station


func station_name_index(name: String) -> int:
	for i in range(station_order.size()):
		if str(station_order[i].get_meta("station_name")) == name:
			return i
	return 0


func hail_radio_contact() -> void:
	play_sfx("comms", -10.0)
	if nearby_station != null and is_instance_valid(nearby_station):
		var station_name := str(nearby_station.get_meta("station_name"))
		update_status("%s traffic, Station420 on local approach.\n%s: Dock corridor is live. Hold vector and proceed to the halo." % [station_name, station_name])
		set_alert("Comms: %s" % station_name, 0.35)
		return

	var nearest_station := get_nearest_station()
	if nearest_station != null and player.global_position.distance_to(nearest_station.global_position) < 12000.0:
		var station_name := str(nearest_station.get_meta("station_name"))
		update_status("Station420 hailing %s.\n%s: Traffic is moderate. Docking services available on request." % [station_name, station_name])
		set_alert("Comms: %s" % station_name, 0.35)
		return

	var nearest_destroyer := get_nearest_destroyer()
	if nearest_destroyer != null and player.global_position.distance_to(nearest_destroyer.global_position) < 24000.0:
		var destroyer_name := nearest_destroyer.name
		update_status("Station420 to %s.\n%s: Patrol lane is green. Report any hostile drone contacts on this channel." % [destroyer_name, destroyer_name])
		set_alert("Comms: %s" % destroyer_name, 0.35)
		return

	var hostile := get_primary_enemy_target()
	if hostile != null and player.global_position.distance_to(hostile.global_position) < 5000.0:
		update_status("Open broadcast on militia band.\nUnknown drone signal: carrier spike detected. Weapons wake confirmed.")
		set_alert("Comms: hostile traffic", 0.35)
		return

	update_status("Open comms band.\nNo local reply. Deep-space carrier noise and relay chatter only.")
	set_alert("Comms: open band", 0.35)


func get_nearest_station() -> Area3D:
	var closest: Area3D = null
	var closest_distance := INF
	for station in station_order:
		if not is_instance_valid(station):
			continue
		var distance := player.global_position.distance_to(station.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest = station
	return closest


func get_nearest_destroyer() -> Node3D:
	var closest: Node3D = null
	var closest_distance := INF
	for destroyer in destroyer_fleet:
		if not is_instance_valid(destroyer):
			continue
		var distance := player.global_position.distance_to(destroyer.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest = destroyer
	return closest


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


func build_planet_solid_mesh(radius: float) -> SphereMesh:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 48
	mesh.rings = 24
	return mesh


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


func build_station_solid_mesh(size: float) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var hub_radius := size * 0.28
	var hub_length := size * 1.15
	var ring_inner_radius := size * 0.8
	var ring_outer_radius := size * 1.08
	var ring_half_height := size * 0.12
	var spoke_thickness := size * 0.08
	var dock_boom_length := size * 1.35
	var hull_color := Color(0.74, 0.78, 0.84)

	append_box_to_surface(
		st,
		Transform3D(Basis.IDENTITY, Vector3.ZERO),
		Vector3(hub_radius * 1.25, hub_radius * 1.25, hub_length),
		hull_color.darkened(0.08)
	)
	append_box_to_surface(
		st,
		Transform3D(Basis.IDENTITY, Vector3(0, 0, -hub_length * 0.42)),
		Vector3(hub_radius * 0.78, hub_radius * 0.78, size * 0.4),
		hull_color.lightened(0.03)
	)
	append_box_to_surface(
		st,
		Transform3D(Basis.IDENTITY, Vector3(0, 0, hub_length * 0.45)),
		Vector3(hub_radius * 0.94, hub_radius * 0.94, size * 0.55),
		hull_color
	)

	var segments := 48
	for i in range(segments):
		var a0 := TAU * float(i) / float(segments)
		var a1 := TAU * float(i + 1) / float(segments)
		var c0 := cos(a0)
		var s0 := sin(a0)
		var c1 := cos(a1)
		var s1 := sin(a1)

		var p0 := Vector3(c0 * ring_outer_radius, s0 * ring_outer_radius, -ring_half_height)
		var p1 := Vector3(c1 * ring_outer_radius, s1 * ring_outer_radius, -ring_half_height)
		var p2 := Vector3(c1 * ring_outer_radius, s1 * ring_outer_radius, ring_half_height)
		var p3 := Vector3(c0 * ring_outer_radius, s0 * ring_outer_radius, ring_half_height)
		var p4 := Vector3(c0 * ring_inner_radius, s0 * ring_inner_radius, -ring_half_height)
		var p5 := Vector3(c1 * ring_inner_radius, s1 * ring_inner_radius, -ring_half_height)
		var p6 := Vector3(c1 * ring_inner_radius, s1 * ring_inner_radius, ring_half_height)
		var p7 := Vector3(c0 * ring_inner_radius, s0 * ring_inner_radius, ring_half_height)

		add_quad_to_surface(st, p0, p1, p2, p3, hull_color.lightened(0.02))
		add_quad_to_surface(st, p5, p4, p7, p6, hull_color.darkened(0.15))
		add_quad_to_surface(st, p3, p2, p6, p7, hull_color.lightened(0.08))
		add_quad_to_surface(st, p4, p5, p1, p0, hull_color.darkened(0.08))
		if i % 8 == 0:
			var spoke_angle := a0
			var spoke_transform := Transform3D(Basis().rotated(Vector3.FORWARD, spoke_angle), Vector3.ZERO)
			append_box_to_surface(
				st,
				spoke_transform,
				Vector3(spoke_thickness, ring_inner_radius * 1.85, spoke_thickness),
				hull_color.darkened(0.03)
			)
		if i % 12 == 0:
			var module_angle := a0 + TAU / float(segments) * 0.5
			var module_center := Vector3(cos(module_angle), sin(module_angle), 0.0) * ((ring_inner_radius + ring_outer_radius) * 0.5)
			append_box_to_surface(
				st,
				Transform3D(Basis().rotated(Vector3.FORWARD, module_angle), module_center),
				Vector3(size * 0.2, size * 0.38, ring_half_height * 1.6),
				hull_color.lightened(0.06)
			)

	var dock_positions := [
		Vector3(0, 0, hub_length * 0.9),
		Vector3(ring_outer_radius * 0.72, 0, 0),
		Vector3(-ring_outer_radius * 0.72, 0, 0)
	]
	for dock_position in dock_positions:
		var outward: Vector3 = dock_position.normalized()
		if outward.length() <= 0.001:
			outward = Vector3.FORWARD
		var boom_center: Vector3 = dock_position + outward * (dock_boom_length * 0.28)
		var boom_basis: Basis = Basis.looking_at(outward, Vector3.UP, true)
		append_box_to_surface(
			st,
			Transform3D(boom_basis, boom_center),
			Vector3(size * 0.16, size * 0.16, dock_boom_length * 0.56),
			hull_color.darkened(0.12)
		)
		append_box_to_surface(
			st,
			Transform3D(boom_basis, dock_position + outward * dock_boom_length * 0.65),
			Vector3(size * 0.26, size * 0.26, size * 0.22),
			hull_color.lightened(0.04)
		)

	st.generate_normals()
	return st.commit()


func build_ringworld_station_mesh(radius: float) -> ArrayMesh:
	var vertices := PackedVector3Array()
	vertices.append_array(build_circle_vertices(radius, 120, Vector3.RIGHT, Vector3.UP))
	vertices.append_array(build_circle_vertices(radius * 0.88, 120, Vector3.RIGHT, Vector3.UP))
	vertices.append_array(build_circle_vertices(radius * 1.12, 120, Vector3.RIGHT, Vector3.UP))

	for i in range(12):
		var angle := TAU * float(i) / 12.0
		var inner := Vector3(cos(angle), sin(angle), 0.0) * (radius * 0.76)
		var outer := Vector3(cos(angle), sin(angle), 0.0) * (radius * 1.16)
		vertices.append(inner)
		vertices.append(outer)

	var spine_half := radius * 0.16
	vertices.append_array([
		Vector3(-radius, 0, -spine_half), Vector3(radius, 0, -spine_half),
		Vector3(-radius, 0, spine_half), Vector3(radius, 0, spine_half),
		Vector3(-radius * 0.7, 0, -radius * 0.28), Vector3(radius * 0.7, 0, -radius * 0.28),
		Vector3(-radius * 0.7, 0, radius * 0.28), Vector3(radius * 0.7, 0, radius * 0.28)
	])
	return build_line_mesh(vertices)


func build_ringworld_station_solid_mesh(radius: float) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var ring_color := Color(0.92, 0.8, 0.38)

	var segments := 96
	var tube_half_height := radius * 0.08
	var inner_radius := radius * 0.88
	var outer_radius := radius * 1.12
	for i in range(segments):
		var a0 := TAU * float(i) / float(segments)
		var a1 := TAU * float(i + 1) / float(segments)
		var c0 := cos(a0)
		var s0 := sin(a0)
		var c1 := cos(a1)
		var s1 := sin(a1)

		var p0 := Vector3(c0 * outer_radius, s0 * outer_radius, -tube_half_height)
		var p1 := Vector3(c1 * outer_radius, s1 * outer_radius, -tube_half_height)
		var p2 := Vector3(c1 * outer_radius, s1 * outer_radius, tube_half_height)
		var p3 := Vector3(c0 * outer_radius, s0 * outer_radius, tube_half_height)
		var p4 := Vector3(c0 * inner_radius, s0 * inner_radius, -tube_half_height)
		var p5 := Vector3(c1 * inner_radius, s1 * inner_radius, -tube_half_height)
		var p6 := Vector3(c1 * inner_radius, s1 * inner_radius, tube_half_height)
		var p7 := Vector3(c0 * inner_radius, s0 * inner_radius, tube_half_height)

		add_quad_to_surface(st, p0, p1, p2, p3, ring_color)
		add_quad_to_surface(st, p5, p4, p7, p6, ring_color.darkened(0.12))
		add_quad_to_surface(st, p3, p2, p6, p7, ring_color.lightened(0.08))
		add_quad_to_surface(st, p4, p5, p1, p0, ring_color.darkened(0.08))

	var spine_size := Vector3(radius * 1.5, radius * 0.12, radius * 0.32)
	append_box_to_surface(st, Transform3D(Basis.IDENTITY, Vector3.ZERO), spine_size, ring_color.darkened(0.18))
	append_box_to_surface(st, Transform3D(Basis.IDENTITY, Vector3(0, 0, radius * 0.28)), Vector3(radius * 1.1, radius * 0.08, radius * 0.12), ring_color)
	append_box_to_surface(st, Transform3D(Basis.IDENTITY, Vector3(0, 0, -radius * 0.28)), Vector3(radius * 1.1, radius * 0.08, radius * 0.12), ring_color)

	st.generate_normals()
	return st.commit()


func build_dock_marker_mesh(radius: float) -> ArrayMesh:
	var vertices := PackedVector3Array([
		Vector3(-radius, 0, 0), Vector3(radius, 0, 0),
		Vector3(0, -radius, 0), Vector3(0, radius, 0),
		Vector3(0, 0, -radius), Vector3(0, 0, radius)
	])
	return build_line_mesh(vertices)


func build_dock_marker_solid_mesh(radius: float) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var color := Color(0.58, 0.96, 0.86)
	append_box_to_surface(st, Transform3D(Basis.IDENTITY, Vector3.ZERO), Vector3(radius * 1.3, radius * 0.08, radius * 0.08), color)
	append_box_to_surface(st, Transform3D(Basis.IDENTITY, Vector3.ZERO), Vector3(radius * 0.08, radius * 1.3, radius * 0.08), color.lightened(0.04))
	append_box_to_surface(st, Transform3D(Basis.IDENTITY, Vector3.ZERO), Vector3(radius * 0.08, radius * 0.08, radius * 1.3), color.darkened(0.08))
	append_box_to_surface(st, Transform3D(Basis.IDENTITY, Vector3.ZERO), Vector3(radius * 0.22, radius * 0.22, radius * 0.22), color.lightened(0.1))
	st.generate_normals()
	return st.commit()


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


func build_shipping_lane_solid_mesh(from_point: Vector3, to_point: Vector3) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var segments := 18
	var midpoint := (from_point + to_point) * 0.5
	var lift := midpoint.normalized() * 38.0
	var previous := from_point
	for i in range(1, segments + 1):
		var t := float(i) / float(segments)
		var point := from_point.lerp(to_point, t) + sin(t * PI) * lift
		append_tube_segment_to_surface(st, previous, point, 2.0, Color(0.34, 0.88, 0.76))
		previous = point
	st.generate_normals()
	return st.commit()


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


func build_nav_beacon_solid_mesh(radius: float) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var color := Color(0.68, 0.88, 1.0)
	append_box_to_surface(st, Transform3D(Basis.IDENTITY, Vector3.ZERO), Vector3(radius * 0.24, radius * 1.2, radius * 0.24), color.darkened(0.1))
	append_box_to_surface(st, Transform3D(Basis.IDENTITY, Vector3.ZERO), Vector3(radius * 0.96, radius * 0.18, radius * 0.18), color)
	append_box_to_surface(st, Transform3D(Basis.IDENTITY, Vector3(0, radius * 0.68, 0)), Vector3(radius * 0.3, radius * 0.3, radius * 0.3), color.lightened(0.12))
	append_box_to_surface(st, Transform3D(Basis.IDENTITY, Vector3(0, -radius * 0.68, 0)), Vector3(radius * 0.2, radius * 0.2, radius * 0.2), color.darkened(0.14))
	st.generate_normals()
	return st.commit()


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


func build_enemy_solid_mesh() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var color := Color(0.86, 0.46, 0.38)
	append_box_to_surface(st, Transform3D(Basis.IDENTITY, Vector3(0, 0.08, 0.8)), Vector3(5.4, 1.7, 10.6), color.darkened(0.1))
	append_box_to_surface(st, Transform3D(Basis.IDENTITY, Vector3(0, 0.62, 3.6)), Vector3(2.8, 1.3, 4.2), color.lightened(0.04))
	append_box_to_surface(st, Transform3D(Basis.IDENTITY, Vector3(0, -0.44, 4.0)), Vector3(3.0, 0.78, 4.5), color.darkened(0.18))
	for side in [-1.0, 1.0]:
		append_box_to_surface(st, Transform3D(Basis.IDENTITY, Vector3(3.7 * side, 0.0, 1.6)), Vector3(3.6, 0.42, 5.8), color.darkened(0.04))
		append_box_to_surface(st, Transform3D(Basis.IDENTITY, Vector3(1.85 * side, -0.32, 4.8)), Vector3(0.9, 0.9, 2.8), color.lightened(0.02))
	append_ship_nose_to_surface(st, 2.2, 0.55, -4.8, -8.1, color)
	st.generate_normals()
	return st.commit()


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


func build_destroyer_solid_mesh(length: float) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var beam := length * 0.14
	var color := Color(0.74, 0.8, 0.88)
	append_box_to_surface(st, Transform3D(Basis.IDENTITY, Vector3.ZERO), Vector3(beam * 1.7, beam * 0.82, length), color.darkened(0.08))
	append_box_to_surface(st, Transform3D(Basis.IDENTITY, Vector3(0, beam * 0.42, -length * 0.12)), Vector3(beam * 0.92, beam * 0.94, length * 0.3), color.lightened(0.04))
	append_box_to_surface(st, Transform3D(Basis.IDENTITY, Vector3(0, beam * 0.74, length * 0.1)), Vector3(beam * 0.56, beam * 1.14, length * 0.18), color.lightened(0.08))
	for side in [-1.0, 1.0]:
		append_box_to_surface(st, Transform3D(Basis.IDENTITY, Vector3(side * beam * 0.95, 0, length * 0.06)), Vector3(beam * 0.44, beam * 0.24, length * 0.74), color.darkened(0.03))
		append_box_to_surface(st, Transform3D(Basis.IDENTITY, Vector3(side * beam * 1.2, -beam * 0.14, length * 0.32)), Vector3(beam * 0.22, beam * 0.22, length * 0.16), color.darkened(0.14))
	append_ship_nose_to_surface(st, beam * 0.44, beam * 0.3, -length * 0.42, -length * 0.56, color)
	st.generate_normals()
	return st.commit()


func build_enemy_target_marker_mesh(radius: float) -> ArrayMesh:
	var inner := radius * 0.54
	var bracket := radius * 0.34
	var vertices := PackedVector3Array([
		Vector3(-radius, 0, -radius), Vector3(-radius + bracket, 0, -radius),
		Vector3(-radius, 0, -radius), Vector3(-radius, 0, -radius + bracket),
		Vector3(radius, 0, -radius), Vector3(radius - bracket, 0, -radius),
		Vector3(radius, 0, -radius), Vector3(radius, 0, -radius + bracket),
		Vector3(-radius, 0, radius), Vector3(-radius + bracket, 0, radius),
		Vector3(-radius, 0, radius), Vector3(-radius, 0, radius - bracket),
		Vector3(radius, 0, radius), Vector3(radius - bracket, 0, radius),
		Vector3(radius, 0, radius), Vector3(radius, 0, radius - bracket),
		Vector3(-inner, 0, 0), Vector3(inner, 0, 0),
		Vector3(0, 0, -inner), Vector3(0, 0, inner)
	])
	return build_line_mesh(vertices)


func build_target_lead_marker_mesh(radius: float) -> ArrayMesh:
	var vertices := PackedVector3Array([
		Vector3(-radius, 0, 0), Vector3(-radius * 0.2, 0, 0),
		Vector3(radius * 0.2, 0, 0), Vector3(radius, 0, 0),
		Vector3(0, -radius, 0), Vector3(0, -radius * 0.2, 0),
		Vector3(0, radius * 0.2, 0), Vector3(0, radius, 0),
		Vector3(-radius * 0.45, 0, -radius * 0.45), Vector3(radius * 0.45, 0, radius * 0.45),
		Vector3(-radius * 0.45, 0, radius * 0.45), Vector3(radius * 0.45, 0, -radius * 0.45)
	])
	return build_line_mesh(vertices)


func build_projectile_mesh() -> ArrayMesh:
	var vertices := PackedVector3Array([
		Vector3(0, 0, -7.0), Vector3(0, 0, 7.0),
		Vector3(-0.38, 0, -5.4), Vector3(0.38, 0, -5.4),
		Vector3(-0.38, 0, 5.4), Vector3(0.38, 0, 5.4),
		Vector3(0, -0.38, -5.4), Vector3(0, 0.38, -5.4),
		Vector3(0, -0.38, 5.4), Vector3(0, 0.38, 5.4)
	])
	return build_line_mesh(vertices)


func build_projectile_solid_mesh() -> CapsuleMesh:
	var mesh := CapsuleMesh.new()
	mesh.radius = 0.34
	mesh.height = 4.8
	mesh.radial_segments = 10
	mesh.rings = 4
	return mesh


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


func add_quad_to_surface(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, color: Color) -> void:
	st.set_color(color)
	st.add_vertex(a)
	st.set_color(color)
	st.add_vertex(b)
	st.set_color(color)
	st.add_vertex(c)
	st.set_color(color)
	st.add_vertex(a)
	st.set_color(color)
	st.add_vertex(c)
	st.set_color(color)
	st.add_vertex(d)


func append_box_to_surface(st: SurfaceTool, transform: Transform3D, size: Vector3, color: Color) -> void:
	var h := size * 0.5
	var points := [
		Vector3(-h.x, -h.y, -h.z),
		Vector3(h.x, -h.y, -h.z),
		Vector3(h.x, h.y, -h.z),
		Vector3(-h.x, h.y, -h.z),
		Vector3(-h.x, -h.y, h.z),
		Vector3(h.x, -h.y, h.z),
		Vector3(h.x, h.y, h.z),
		Vector3(-h.x, h.y, h.z)
	]
	for i in range(points.size()):
		points[i] = transform * points[i]

	add_quad_to_surface(st, points[4], points[5], points[6], points[7], color)
	add_quad_to_surface(st, points[1], points[0], points[3], points[2], color.darkened(0.08))
	add_quad_to_surface(st, points[0], points[4], points[7], points[3], color.darkened(0.12))
	add_quad_to_surface(st, points[5], points[1], points[2], points[6], color)
	add_quad_to_surface(st, points[3], points[7], points[6], points[2], color.lightened(0.08))
	add_quad_to_surface(st, points[0], points[1], points[5], points[4], color.darkened(0.18))


func append_tube_segment_to_surface(st: SurfaceTool, from_point: Vector3, to_point: Vector3, radius: float, color: Color) -> void:
	var direction: Vector3 = (to_point - from_point).normalized()
	if direction.length() <= 0.001:
		return
	var up := Vector3.UP if abs(direction.dot(Vector3.UP)) < 0.96 else Vector3.RIGHT
	var right := direction.cross(up).normalized() * radius
	var forward_up := right.cross(direction).normalized() * radius
	var start_points := [
		from_point + right,
		from_point + forward_up,
		from_point - right,
		from_point - forward_up
	]
	var end_points := [
		to_point + right,
		to_point + forward_up,
		to_point - right,
		to_point - forward_up
	]
	for i in range(4):
		add_quad_to_surface(st, start_points[i], start_points[(i + 1) % 4], end_points[(i + 1) % 4], end_points[i], color)


func append_ship_nose_to_surface(st: SurfaceTool, half_width: float, height: float, base_z: float, tip_z: float, color: Color) -> void:
	var tip_top := Vector3(0, height * 0.2, tip_z)
	var tip_bottom := Vector3(0, -height * 0.16, tip_z + abs(tip_z - base_z) * 0.08)
	var right_top := Vector3(half_width, height, base_z)
	var left_top := Vector3(-half_width, height, base_z)
	var right_mid := Vector3(half_width * 1.15, 0.0, base_z + abs(tip_z - base_z) * 0.34)
	var left_mid := Vector3(-half_width * 1.15, 0.0, base_z + abs(tip_z - base_z) * 0.34)
	add_quad_to_surface(st, left_top, right_top, tip_top, tip_top, color.lightened(0.08))
	add_quad_to_surface(st, right_mid, left_mid, tip_bottom, tip_bottom, color.darkened(0.16))
	add_quad_to_surface(st, right_top, right_mid, tip_top, tip_top, color)
	add_quad_to_surface(st, left_mid, left_top, tip_top, tip_top, color.darkened(0.04))
	add_quad_to_surface(st, left_top, left_mid, right_mid, right_top, color.darkened(0.08))


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
