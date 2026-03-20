extends Node3D

const BuildInfo = preload("res://scripts/build_info.gd")
const TRIPPY_SURFACE_SHADER = preload("res://shaders/trippy_surface.gdshader")
const TacticalMapScript = preload("res://scripts/ui/tactical_map.gd")
const AttitudeIndicatorScript = preload("res://scripts/ui/attitude_indicator.gd")

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
const PHONE_LAYOUT_BREAKPOINT := 760.0
const PORTRAIT_LAYOUT_BREAKPOINT := 1.05
const SHOW_DEBUG_SAVE_BUTTON := false
const VISUAL_PRESET_COUNT := 7
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
const PIRATE_WAKE_RADIUS := 2200.0
const PIRATE_DISENGAGE_RADIUS := 3400.0
const PIRATE_PATROL_RADIUS := 420.0
const PIRATE_PATROL_SPEED := 74.0
const PIRATE_TAUNT_MIN_INTERVAL := 8.0
const PIRATE_TAUNT_MAX_INTERVAL := 16.0
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
const PROXIMITY_ALARM_COOLDOWN := 3.2
const PLANET_COLLISION_MARGIN := 120.0
const STAR_COLLISION_MARGIN := 320.0
const STATION_COLLISION_RADIUS := 120.0
const AUDIO_MIX_RATE := 22050.0
const MUSIC_BUFFER_SECONDS := 0.35
const MUSIC_VOLUME_BIAS_DB := -4.0
const RADIO_TRACK_DURATION := 24.0
const RADIO_CROSSFADE_DURATION := 4.5
const RADIO_CHATTER_MIN_INTERVAL := 24.0
const RADIO_CHATTER_MAX_INTERVAL := 52.0
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
		"tilt": -0.02,
		"atmosphere_color": Color(0.68, 1.0, 0.76, 0.2),
		"storm_color": Color(0.92, 1.0, 0.84, 0.85),
		"storm_bands": 2,
		"storm_cells": 3,
		"weather_spin": 0.11
	},
	{
		"name": "Tempest",
		"orbit_radius": 2860.0,
		"phase": 2.35,
		"mass": 24600.0,
		"radius": 74.0,
		"color": Color(0.4, 0.82, 1.0),
		"orbit_tint": Color(0.28, 0.7, 1.0),
		"tilt": 0.08,
		"atmosphere_color": Color(0.52, 0.88, 1.0, 0.24),
		"storm_color": Color(0.9, 0.98, 1.0, 0.9),
		"storm_bands": 4,
		"storm_cells": 6,
		"weather_spin": 0.22
	},
	{
		"name": "Brim",
		"orbit_radius": 3320.0,
		"phase": 0.94,
		"mass": 31200.0,
		"radius": 92.0,
		"color": Color(0.96, 0.68, 0.34),
		"orbit_tint": Color(0.92, 0.54, 0.22),
		"tilt": -0.06,
		"atmosphere_color": Color(1.0, 0.78, 0.42, 0.2),
		"storm_color": Color(1.0, 0.92, 0.74, 0.88),
		"storm_bands": 5,
		"storm_cells": 5,
		"weather_spin": 0.16
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
@onready var hud: Control = $CanvasLayer/HUD
@onready var title_label: Label = $CanvasLayer/HUD/TitleLabel
@onready var debug_save_defaults_button: Button = $CanvasLayer/HUD/DebugSaveDefaultsButton
@onready var help_button: Button = $CanvasLayer/HUD/HelpButton
@onready var settings_button: Button = $CanvasLayer/HUD/SettingsButton
@onready var shader_button: Button = $CanvasLayer/HUD/ShaderButton
@onready var fullscreen_button: Button = $CanvasLayer/HUD/FullscreenButton
@onready var cinematic_top_bar: ColorRect = $CanvasLayer/HUD/CinematicTopBar
@onready var cinematic_bottom_bar: ColorRect = $CanvasLayer/HUD/CinematicBottomBar
@onready var backdrop_top: ColorRect = $CanvasLayer/HUD/BackdropTop
@onready var backdrop_bottom: ColorRect = $CanvasLayer/HUD/BackdropBottom
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
@onready var attitude_frame: Panel = $CanvasLayer/HUD/AttitudeFrame
@onready var left_frame: Panel = $CanvasLayer/HUD/LeftFrame
@onready var right_frame: Panel = $CanvasLayer/HUD/RightFrame
@onready var message_frame: Panel = $CanvasLayer/HUD/MessageFrame
@onready var hull_bar: ProgressBar = $CanvasLayer/HUD/LeftFrame/HullBar
@onready var shield_bar: ProgressBar = $CanvasLayer/HUD/LeftFrame/ShieldBar
@onready var dock_value: Label = $CanvasLayer/HUD/LeftFrame/DockValue
@onready var route_value: Label = $CanvasLayer/HUD/LeftFrame/RouteValue
@onready var scanner_value: Label = $CanvasLayer/HUD/LeftFrame/ScannerValue
@onready var combat_title: Label = $CanvasLayer/HUD/RightFrame/CombatTitle
@onready var combat_value: Label = $CanvasLayer/HUD/RightFrame/CombatValue
@onready var build_value: Label = $CanvasLayer/HUD/RightFrame/BuildValue
@onready var message_value: Label = $CanvasLayer/HUD/MessageFrame/MessageValue
@onready var alert_value: Label = $CanvasLayer/HUD/TopFrame/AlertValue
@onready var hit_value: Label = $CanvasLayer/HUD/TopFrame/HitValue
@onready var attitude_viewport: SubViewport = $CanvasLayer/HUD/AttitudeFrame/AttitudeViewport
@onready var attitude_display: TextureRect = $CanvasLayer/HUD/AttitudeFrame/AttitudeDisplay
@onready var attitude_ball: MeshInstance3D = $CanvasLayer/HUD/AttitudeFrame/AttitudeViewport/AttitudeRoot/AttitudeBall
@onready var attitude_needle: MeshInstance3D = $CanvasLayer/HUD/AttitudeFrame/AttitudeViewport/AttitudeRoot/AttitudeNeedle
@onready var reticle: Control = $CanvasLayer/HUD/Reticle
@onready var cockpit_overlay: Control = $CanvasLayer/HUD/CockpitOverlay
@onready var cockpit_mode_label: Label = $CanvasLayer/HUD/CockpitOverlay/CockpitModeLabel
@onready var settings_panel: Panel = $CanvasLayer/HUD/SettingsPanel
@onready var settings_title: Label = $CanvasLayer/HUD/SettingsPanel/SettingsTitle
@onready var controls_button: Button = $CanvasLayer/HUD/SettingsPanel/ControlsButton
@onready var display_tab_button: Button = $CanvasLayer/HUD/SettingsPanel/DisplayTabButton
@onready var audio_tab_button: Button = $CanvasLayer/HUD/SettingsPanel/AudioTabButton
@onready var flight_tab_button: Button = $CanvasLayer/HUD/SettingsPanel/FlightTabButton
@onready var render_tab_button: Button = $CanvasLayer/HUD/SettingsPanel/RenderTabButton
@onready var display_group: Panel = $CanvasLayer/HUD/SettingsPanel/DisplayGroup
@onready var display_group_title: Label = $CanvasLayer/HUD/SettingsPanel/DisplayGroup/DisplayGroupTitle
@onready var audio_group: Panel = $CanvasLayer/HUD/SettingsPanel/AudioGroup
@onready var audio_group_title: Label = $CanvasLayer/HUD/SettingsPanel/AudioGroup/AudioGroupTitle
@onready var flight_group: Panel = $CanvasLayer/HUD/SettingsPanel/FlightGroup
@onready var flight_group_title: Label = $CanvasLayer/HUD/SettingsPanel/FlightGroup/FlightGroupTitle
@onready var render_group: Panel = $CanvasLayer/HUD/SettingsPanel/RenderGroup
@onready var render_group_title: Label = $CanvasLayer/HUD/SettingsPanel/RenderGroup/RenderGroupTitle
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
@onready var settings_hint: Label = $CanvasLayer/HUD/SettingsPanel/SettingsHint
@onready var settings_hotkeys: Label = $CanvasLayer/HUD/SettingsPanel/SettingsHotkeys
@onready var controls_panel: Panel = $CanvasLayer/HUD/ControlsPanel
@onready var controls_title: Label = $CanvasLayer/HUD/ControlsPanel/ControlsTitle
@onready var controls_close_button: Button = $CanvasLayer/HUD/ControlsPanel/ControlsCloseButton
@onready var controls_keyboard_label: Label = $CanvasLayer/HUD/ControlsPanel/ControlsKeyboardLabel
@onready var controls_keyboard_text: Label = $CanvasLayer/HUD/ControlsPanel/ControlsKeyboardText
@onready var controls_controller_label: Label = $CanvasLayer/HUD/ControlsPanel/ControlsControllerLabel
@onready var controls_controller_text: Label = $CanvasLayer/HUD/ControlsPanel/ControlsControllerText
@onready var controls_hint: Label = $CanvasLayer/HUD/ControlsPanel/ControlsHint
@onready var shader_panel: Panel = $CanvasLayer/HUD/ShaderPanel
@onready var shader_title: Label = $CanvasLayer/HUD/ShaderPanel/ShaderTitle
@onready var shader_close_button: Button = $CanvasLayer/HUD/ShaderPanel/ShaderCloseButton
@onready var post_fx_value: Label = $CanvasLayer/HUD/ShaderPanel/PostFxValue
@onready var post_fx_button: Button = $CanvasLayer/HUD/ShaderPanel/PostFxButton
@onready var blur_fx_value: Label = $CanvasLayer/HUD/ShaderPanel/BlurFxValue
@onready var blur_fx_button: Button = $CanvasLayer/HUD/ShaderPanel/BlurFxButton
@onready var attitude_shader_value: Label = $CanvasLayer/HUD/ShaderPanel/AttitudeShaderValue
@onready var attitude_shader_button: Button = $CanvasLayer/HUD/ShaderPanel/AttitudeShaderButton
@onready var edge_threshold_value: Label = $CanvasLayer/HUD/ShaderPanel/EdgeThresholdValue
@onready var shader_mode_option: OptionButton = $CanvasLayer/HUD/ShaderPanel/ShaderModeOption
@onready var edge_threshold_slider: HSlider = $CanvasLayer/HUD/ShaderPanel/EdgeThresholdSlider
@onready var edge_strength_value: Label = $CanvasLayer/HUD/ShaderPanel/EdgeStrengthValue
@onready var edge_strength_slider: HSlider = $CanvasLayer/HUD/ShaderPanel/EdgeStrengthSlider
@onready var edge_glow_value: Label = $CanvasLayer/HUD/ShaderPanel/EdgeGlowValue
@onready var edge_glow_slider: HSlider = $CanvasLayer/HUD/ShaderPanel/EdgeGlowSlider
@onready var glow_amount_value: Label = $CanvasLayer/HUD/ShaderPanel/GlowAmountValue
@onready var blur_amount_value: Label = $CanvasLayer/HUD/ShaderPanel/BlurAmountValue
@onready var blur_amount_slider: HSlider = $CanvasLayer/HUD/ShaderPanel/BlurAmountSlider
@onready var shader_aux_value: Label = $CanvasLayer/HUD/ShaderPanel/ShaderAuxValue
@onready var shader_aux_slider: HSlider = $CanvasLayer/HUD/ShaderPanel/ShaderAuxSlider
@onready var shader_hint: Label = $CanvasLayer/HUD/ShaderPanel/ShaderHint

var nearby_station: Area3D = null
var dock_count := 0
var station_order: Array[Area3D] = []
var station_nodes_by_name := {}
var pirate_stations: Array[Area3D] = []
var traffic_ships: Array[Node3D] = []
var selected_target_station_name := ""
var shipping_lane_nodes: Array[MeshInstance3D] = []
var pickup_station := ""
var delivery_station := ""
var cargo_loaded := false
var objective_line: MeshInstance3D
var objective_marker: MeshInstance3D
var objective_flash_time := 0.0
var objective_guidance_enabled := false
var star_node: Node3D
var star_beacon_root: Node3D
var star_beacon_nodes: Array[MeshInstance3D] = []
var star_flare_root: Node3D
var star_flare_nodes: Array[MeshInstance3D] = []
var sunlight: DirectionalLight3D
var planet_bodies := []
var planet_nodes_by_name := {}
var planet_weather_effects: Array[Dictionary] = []
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
var autopilot_doppler_player: AudioStreamPlayer
var sfx_streams := {}
var music_time := 0.0
var music_phase_a := 0.0
var music_phase_b := 0.0
var music_phase_c := 0.0
var radio_track_index := -1
var radio_start_track_index := 0
var station_navigation_meshes: Array[MeshInstance3D] = []
var station_navigation_lights: Array[OmniLight3D] = []
var station_strobe_meshes: Array[MeshInstance3D] = []
var station_strobe_lights: Array[OmniLight3D] = []
var player_hull := PLAYER_MAX_HULL
var player_shields := PLAYER_MAX_SHIELDS
var kills := 0
var score := 0
var fire_cooldown := 0.0
var shield_recharge_delay := 0.0
var enemy_respawn_timer := 0.0
var alert_timer := 0.0
var proximity_alarm_timer := 0.0
var hit_timer := 0.0
var paused := false
var game_over_state := false
var start_screen_active := true
var boot_screen_time := 0.0
var settings_visible := false
var controls_visible := false
var shader_panel_visible := false
var help_panel_seen := false
var help_panel_autoshow_timer := -1.0
var settings_tab_index := 0
var visual_preset_index := 0
var shaded_mode := false
var bloom_enabled := false
var music_enabled := true
var sfx_enabled := true
var speech_synthesis_enabled := true
var music_volume := 0.72
var sfx_volume := 0.85
var invert_y_axis := false
var flight_physics_mode := "game"
var edge_threshold := 0.2
var edge_strength_scale := 0.64
var edge_glow_scale := 0.24
var blur_strength_scale := 0.22
var wire_shader_scale := 0.14
var edge_shader_enabled := true
var blur_shader_enabled := true
var attitude_shader_enabled := true
var shader_mode_index := 1
var autopilot_active := false
var autopilot_state := ""
var autopilot_station: Area3D = null
var autopilot_timer := 0.0
var autopilot_fx_timer := 0.0
var autopilot_doppler_rate := 0.0
var autopilot_doppler_mix := 0.0
var autopilot_doppler_current_rate := 0.0
var autopilot_doppler_current_mix := 0.0
var radio_chatter_timer := 18.0
var pirate_taunt_timer := 9.0
var autopilot_comms_stage := 0
var autopilot_rate_status_band := -1
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
var pause_camera_blend := 0.0
var pause_camera_time := 0.0
var pause_camera_distance := 22.0
var pause_camera_yaw := 0.0
var pause_camera_pitch := -0.18
var idle_input_timer := 0.0
var cinematic_mode_active := false
var idle_theme_override_active := false
var idle_theme_restore_index := 0
var cinematic_blend := 0.0
var cinematic_time := 0.0
var hud_stats_refresh_timer := 0.0
var fps_display := 0.0
var last_viewport_size := Vector2.ZERO
var objective_marker_base_mesh: Mesh
var enemy_target_marker_base_mesh: Mesh
var enemy_target_lead_base_mesh: Mesh
var attitude_indicator_widget: Control
var tactical_map_radius_current := 12000.0
var touch_controls_root: Control
var touch_move_pad: Control
var touch_move_knob: ColorRect
var touch_look_pad: Control
var touch_look_knob: ColorRect
var touch_fire_button: Button
var touch_boost_button: Button
var touch_ap_button: Button
var touch_camera_button: Button
var touch_dock_button: Button
var touch_target_button: Button
var touch_up_button: Button
var touch_down_button: Button
var tactical_map: Control
var inspector_button: Button
var inspector_panel: Panel
var inspector_title: Label
var inspector_close_button: Button
var inspector_hint: Label
var inspector_object_name: Label
var inspector_object_info: Label
var inspector_screen_fx_button: Button
var inspector_blur_button: Button
var inspector_bloom_button: Button
var inspector_solo_button: Button
var inspector_trippy_button: Button
var inspector_reset_button: Button
var touch_move_pointer := -1
var touch_look_pointer := -1
var touch_move_axis := Vector2.ZERO
var touch_look_axis := Vector2.ZERO
var touch_vertical_axis := 0.0
var touch_fire_held := false
var touch_phone_layout_active := false
var touch_device_active := false
var settings_label_refresh_timer := 0.0
var cinematic_overlay_nodes: Array[CanvasItem] = []
var settings_tab_groups: Array[Control] = []
var settings_tab_buttons: Array[Button] = []
var settings_tab_page_controls: Array = []
var utility_buttons: Array[Button] = []
var runtime_rng := RandomNumberGenerator.new()
var cached_ship_gravity := Vector3.ZERO
var cached_ship_gravity_magnitude := 0.0
var inspector_visible := false
var inspector_solo_mode := false
var inspector_selected_subject: Node = null


func _ready() -> void:
	configure_window_for_platform()
	runtime_rng.randomize()
	player.call("set_world_limit", WORLD_LIMIT)
	alert_label.text = ""
	hit_label.text = ""
	pause_card.visible = false
	pause_label.visible = false
	start_card.visible = true
	start_label.visible = true
	settings_panel.visible = false
	controls_panel.visible = false
	shader_panel.visible = false
	debug_save_defaults_button.visible = SHOW_DEBUG_SAVE_BUTTON
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
	create_pirate_hideouts()
	create_shipping_lanes()
	create_navigation_beacons()
	create_destroyer_fleet()
	create_traffic_ships()
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
	apply_shader_runtime_settings()
	if DisplayServer.get_name() != "headless":
		get_window().size_changed.connect(_on_window_size_changed)
	player.call("set_camera_view", camera_mode)
	connect_settings_controls()
	setup_tactical_map()
	create_touch_controls()
	create_inspector_ui()
	apply_hud_style()
	cinematic_overlay_nodes = [
		debug_save_defaults_button,
		shader_button,
		inspector_button,
		help_button,
		fullscreen_button,
		top_frame,
		attitude_frame,
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
		touch_controls_root,
		settings_panel,
		controls_panel,
		shader_panel,
		inspector_panel
	]
	settings_tab_groups = [display_group, audio_group, flight_group, render_group]
	settings_tab_buttons = [display_tab_button, audio_tab_button, flight_tab_button, render_tab_button]
	settings_tab_page_controls = [
		[preset_value, preset_prev_button, preset_next_button],
		[music_value, music_slider, music_button, sfx_value, sfx_slider, sfx_button],
		[trail_value, trail_button, guidance_value, guidance_button, invert_y_value, invert_y_button, physics_mode_value, physics_mode_button],
		[render_mode_button, bloom_value, bloom_button]
	]
	utility_buttons = [fullscreen_button, help_button, settings_button, inspector_button, shader_button, debug_save_defaults_button]
	update_responsive_hud_layout(true)
	update_window_controls()

	paused = true
	title_label.text = "Station420"
	update_combat_label()
	update_build_label()
	update_settings_label()
	settings_label_refresh_timer = 0.12
	update_status("Press Enter to launch.\nMouse steers. Use Space to fire and Esc to pause once you are underway.")
	update_mouse_mode()


func configure_window_for_platform() -> void:
	if DisplayServer.get_name() == "headless":
		return
	var window := get_window()
	if window == null:
		return
	if OS.has_feature("web"):
		sync_mobile_web_content_scale()
		return
	window.min_size = Vector2i(1280, 720)
	window.mode = Window.MODE_MAXIMIZED


func sync_mobile_web_content_scale() -> void:
	if DisplayServer.get_name() == "headless" or not OS.has_feature("web"):
		return
	var window := get_window()
	if window == null:
		return
	var window_size: Vector2i = window.size
	if window_size.x <= 0 or window_size.y <= 0:
		return
	var is_phone_like: bool = window_size.x <= 900 or float(window_size.y) / max(float(window_size.x), 1.0) >= PORTRAIT_LAYOUT_BREAKPOINT
	var target_size: Vector2i = window_size if is_phone_like else Vector2i(1920, 1080)
	if window.content_scale_size != target_size:
		window.content_scale_size = target_size


func _on_window_size_changed() -> void:
	sync_mobile_web_content_scale()
	update_responsive_hud_layout(true)


func _exit_tree() -> void:
	if music_player != null:
		music_player.stop()
	if autopilot_doppler_player != null:
		autopilot_doppler_player.stop()
	music_playback = null


func connect_settings_controls() -> void:
	shader_button.pressed.connect(_on_shader_panel_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	controls_button.pressed.connect(_on_controls_pressed)
	display_tab_button.pressed.connect(_on_display_tab_pressed)
	audio_tab_button.pressed.connect(_on_audio_tab_pressed)
	flight_tab_button.pressed.connect(_on_flight_tab_pressed)
	render_tab_button.pressed.connect(_on_render_tab_pressed)
	controls_close_button.pressed.connect(_on_controls_close_pressed)
	shader_close_button.pressed.connect(_on_shader_close_pressed)
	post_fx_button.pressed.connect(_on_post_fx_pressed)
	blur_fx_button.pressed.connect(_on_blur_fx_pressed)
	attitude_shader_button.pressed.connect(_on_attitude_shader_pressed)
	preset_prev_button.pressed.connect(_on_preset_prev_pressed)
	preset_next_button.pressed.connect(_on_preset_next_pressed)
	debug_save_defaults_button.pressed.connect(_on_debug_save_defaults_pressed)
	help_button.pressed.connect(_on_help_pressed)
	fullscreen_button.pressed.connect(_on_fullscreen_pressed)
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
	shader_mode_option.item_selected.connect(_on_shader_mode_selected)
	edge_threshold_slider.value_changed.connect(_on_edge_threshold_slider_changed)
	edge_strength_slider.value_changed.connect(_on_edge_strength_slider_changed)
	edge_glow_slider.value_changed.connect(_on_edge_glow_slider_changed)
	blur_amount_slider.value_changed.connect(_on_blur_amount_slider_changed)
	shader_aux_slider.value_changed.connect(_on_shader_aux_slider_changed)
	populate_shader_mode_option()
	music_slider.value = music_volume * 100.0
	sfx_slider.value = sfx_volume * 100.0
	edge_threshold_slider.value = edge_threshold * 100.0
	edge_strength_slider.value = edge_strength_scale * 100.0
	edge_glow_slider.value = edge_glow_scale * 100.0
	blur_amount_slider.value = wire_shader_scale * 100.0
	shader_aux_slider.value = blur_strength_scale * 100.0
	apply_settings_tab_visibility()


func create_touch_controls() -> void:
	if DisplayServer.get_name() == "headless" or hud == null or touch_controls_root != null:
		return
	touch_controls_root = Control.new()
	touch_controls_root.name = "TouchControls"
	touch_controls_root.anchor_right = 1.0
	touch_controls_root.anchor_bottom = 1.0
	touch_controls_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	touch_controls_root.visible = false
	hud.add_child(touch_controls_root)
	hud.move_child(touch_controls_root, hud.get_child_count() - 1)

	touch_move_pad = make_touch_pad("THRUST")
	touch_move_knob = touch_move_pad.get_node("Knob") as ColorRect
	touch_controls_root.add_child(touch_move_pad)

	touch_look_pad = make_touch_pad("LOOK")
	touch_look_knob = touch_look_pad.get_node("Knob") as ColorRect
	touch_controls_root.add_child(touch_look_pad)

	touch_fire_button = make_touch_button("FIRE")
	touch_boost_button = make_touch_button("BOOST")
	touch_ap_button = make_touch_button("AP")
	touch_camera_button = make_touch_button("CAM")
	touch_dock_button = make_touch_button("DOCK")
	touch_target_button = make_touch_button("TGT")
	touch_up_button = make_touch_button("UP")
	touch_down_button = make_touch_button("DN")
	for button in [
		touch_fire_button,
		touch_boost_button,
		touch_ap_button,
		touch_camera_button,
		touch_dock_button,
		touch_target_button,
		touch_up_button,
		touch_down_button
	]:
		touch_controls_root.add_child(button)

	touch_fire_button.button_down.connect(_on_touch_fire_down)
	touch_fire_button.button_up.connect(_on_touch_fire_up)
	touch_boost_button.button_down.connect(_on_touch_boost_down)
	touch_boost_button.button_up.connect(_on_touch_boost_up)
	touch_ap_button.pressed.connect(_on_touch_ap_pressed)
	touch_camera_button.pressed.connect(_on_touch_camera_pressed)
	touch_dock_button.pressed.connect(_on_touch_dock_pressed)
	touch_target_button.pressed.connect(_on_touch_target_pressed)
	touch_up_button.button_down.connect(_on_touch_up_down)
	touch_up_button.button_up.connect(_on_touch_up_up)
	touch_down_button.button_down.connect(_on_touch_down_down)
	touch_down_button.button_up.connect(_on_touch_down_up)
	update_touch_controls_visibility()


func create_inspector_ui() -> void:
	if DisplayServer.get_name() == "headless" or hud == null or inspector_button != null:
		return
	inspector_button = Button.new()
	inspector_button.name = "InspectorButton"
	inspector_button.text = "INS"
	inspector_button.tooltip_text = "Open visual inspector"
	hud.add_child(inspector_button)
	inspector_button.pressed.connect(_on_inspector_pressed)

	inspector_panel = Panel.new()
	inspector_panel.name = "InspectorPanel"
	inspector_panel.visible = false
	inspector_panel.clip_contents = true
	hud.add_child(inspector_panel)

	inspector_title = Label.new()
	inspector_title.text = "Visual Inspector"
	inspector_panel.add_child(inspector_title)

	inspector_close_button = Button.new()
	inspector_close_button.text = "Close"
	inspector_close_button.tooltip_text = "Close inspector"
	inspector_close_button.pressed.connect(_on_inspector_close_pressed)
	inspector_panel.add_child(inspector_close_button)

	inspector_hint = Label.new()
	inspector_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inspector_hint.text = "Click a visible object in the scene to inspect its style stack."
	inspector_panel.add_child(inspector_hint)

	inspector_object_name = Label.new()
	inspector_object_name.text = "No object selected"
	inspector_panel.add_child(inspector_object_name)

	inspector_object_info = Label.new()
	inspector_object_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inspector_object_info.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	inspector_object_info.text = "Pick a ship, station, world, or marker to see active render layers."
	inspector_panel.add_child(inspector_object_info)

	inspector_screen_fx_button = Button.new()
	inspector_screen_fx_button.text = "Screen FX"
	inspector_screen_fx_button.pressed.connect(_on_post_fx_pressed)
	inspector_panel.add_child(inspector_screen_fx_button)

	inspector_blur_button = Button.new()
	inspector_blur_button.text = "Blur"
	inspector_blur_button.pressed.connect(_on_blur_fx_pressed)
	inspector_panel.add_child(inspector_blur_button)

	inspector_bloom_button = Button.new()
	inspector_bloom_button.text = "Bloom"
	inspector_bloom_button.pressed.connect(_on_bloom_pressed)
	inspector_panel.add_child(inspector_bloom_button)

	inspector_solo_button = Button.new()
	inspector_solo_button.text = "Solo"
	inspector_solo_button.pressed.connect(_on_inspector_solo_pressed)
	inspector_panel.add_child(inspector_solo_button)

	inspector_trippy_button = Button.new()
	inspector_trippy_button.text = "Trippy"
	inspector_trippy_button.pressed.connect(_on_inspector_trippy_pressed)
	inspector_panel.add_child(inspector_trippy_button)

	inspector_reset_button = Button.new()
	inspector_reset_button.text = "Reset"
	inspector_reset_button.pressed.connect(_on_inspector_reset_pressed)
	inspector_panel.add_child(inspector_reset_button)

	update_inspector_panel_labels()


func setup_tactical_map() -> void:
	if DisplayServer.get_name() == "headless" or right_frame == null or tactical_map != null:
		return
	tactical_map = Control.new()
	tactical_map.name = "TacticalMap"
	tactical_map.set_script(TacticalMapScript)
	right_frame.add_child(tactical_map)
	right_frame.move_child(tactical_map, 1)
	combat_title.text = "TACTICAL MAP"
	combat_value.visible = false
	apply_hud_style()


func make_touch_pad(label_text: String) -> Panel:
	var pad := Panel.new()
	pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var label := Label.new()
	label.name = "Label"
	label.text = label_text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.anchor_left = 0.0
	label.anchor_top = 0.0
	label.anchor_right = 1.0
	label.anchor_bottom = 0.0
	label.offset_top = 10.0
	label.offset_bottom = 30.0
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pad.add_child(label)
	var knob := ColorRect.new()
	knob.name = "Knob"
	knob.color = Color(0.9, 0.95, 1.0, 0.18)
	knob.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pad.add_child(knob)
	return pad


func make_touch_button(text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	return button


func populate_shader_mode_option() -> void:
	if shader_mode_option == null:
		return
	shader_mode_option.clear()
	for name in [
		"PBR Lite",
		"Neon Edge",
		"Cartoon",
		"Glass",
		"Blur",
		"ASCII",
		"Metal Scan",
		"CRT Grid",
		"Night Vision",
		"Thermal",
		"Blueprint"
	]:
		shader_mode_option.add_item(name)
	shader_mode_option.selected = clamp(shader_mode_index, 0, shader_mode_option.item_count - 1)


func apply_shader_runtime_settings() -> void:
	edge_pass.visible = edge_shader_enabled
	update_overlay_blur()
	update_attitude_indicator_theme()
	update_shader_panel_labels()
	update_inspector_panel_labels()


func update_shader_panel_labels() -> void:
	shader_title.text = "Shaders"
	post_fx_value.text = "Screen FX: %s" % ("On" if edge_shader_enabled else "Off")
	post_fx_button.text = "On" if edge_shader_enabled else "Off"
	blur_fx_value.text = "Overlay Blur: %s" % ("On" if blur_shader_enabled else "Off")
	blur_fx_button.text = "On" if blur_shader_enabled else "Off"
	attitude_shader_value.text = "Attitude Ball: %s" % ("On" if attitude_shader_enabled else "Off")
	attitude_shader_button.text = "On" if attitude_shader_enabled else "Off"
	edge_threshold_value.text = "Shader"
	edge_strength_value.text = "Intensity: %d%%" % int(round(edge_threshold * 100.0))
	edge_glow_value.text = "Detail: %d%%" % int(round(edge_strength_scale * 100.0))
	glow_amount_value.text = "Glow: %d%%" % int(round(edge_glow_scale * 100.0))
	blur_amount_value.text = "Wire Intensity: %d%%" % int(round(wire_shader_scale * 100.0))
	shader_aux_value.text = "Aux Mix: %d%%" % int(round(blur_strength_scale * 100.0))
	if shader_mode_option.selected != shader_mode_index:
		shader_mode_option.selected = shader_mode_index
	if abs(edge_threshold_slider.value - edge_threshold * 100.0) > 0.5:
		edge_threshold_slider.value = edge_threshold * 100.0
	if abs(edge_strength_slider.value - edge_strength_scale * 100.0) > 0.5:
		edge_strength_slider.value = edge_strength_scale * 100.0
	if abs(edge_glow_slider.value - edge_glow_scale * 100.0) > 0.5:
		edge_glow_slider.value = edge_glow_scale * 100.0
	if abs(blur_amount_slider.value - wire_shader_scale * 100.0) > 0.5:
		blur_amount_slider.value = wire_shader_scale * 100.0
	if abs(shader_aux_slider.value - blur_strength_scale * 100.0) > 0.5:
		shader_aux_slider.value = blur_strength_scale * 100.0
	shader_hint.text = "Browse built-in and experimental screen modes here. Settings keeps gameplay; FX owns shader experiments."


func set_settings_tab(index: int) -> void:
	settings_tab_index = clamp(index, 0, 3)
	apply_settings_tab_visibility()
	update_responsive_hud_layout(true)


func apply_settings_tab_visibility() -> void:
	for i in range(settings_tab_groups.size()):
		var group: Control = settings_tab_groups[i]
		if group != null:
			group.visible = i == settings_tab_index
	for i in range(settings_tab_page_controls.size()):
		var page_controls = settings_tab_page_controls[i]
		var page_visible := i == settings_tab_index
		for control in page_controls:
			if control is Control:
				(control as Control).visible = page_visible
	for i in range(settings_tab_buttons.size()):
		var button: Button = settings_tab_buttons[i]
		if button == null:
			continue
		button.text = get_settings_tab_name(i)
		button.disabled = i == settings_tab_index
	settings_title.text = "Settings"


func get_settings_tab_name(index: int) -> String:
	match index:
		1:
			return "Audio"
		2:
			return "Flight"
		3:
			return "Render"
		_:
			return "Display"


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
	help_panel_seen = bool(data.get("help_panel_seen", help_panel_seen))
	invert_y_axis = bool(data.get("invert_y_axis", invert_y_axis))
	flight_physics_mode = str(data.get("flight_physics_mode", flight_physics_mode))
	shader_mode_index = int(data.get("shader_mode_index", shader_mode_index))
	edge_threshold = float(data.get("edge_threshold", edge_threshold))
	edge_strength_scale = float(data.get("edge_strength_scale", edge_strength_scale))
	edge_glow_scale = float(data.get("edge_glow_scale", edge_glow_scale))
	blur_strength_scale = float(data.get("blur_strength_scale", blur_strength_scale))
	wire_shader_scale = float(data.get("wire_shader_scale", wire_shader_scale))
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
		"help_panel_seen": help_panel_seen,
		"invert_y_axis": invert_y_axis,
		"flight_physics_mode": flight_physics_mode,
		"shader_mode_index": shader_mode_index,
		"edge_threshold": edge_threshold,
		"edge_strength_scale": edge_strength_scale,
		"edge_glow_scale": edge_glow_scale,
		"blur_strength_scale": blur_strength_scale,
		"wire_shader_scale": wire_shader_scale,
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
	update_status("Current visual defaults saved to disk.")


func _on_debug_save_defaults_pressed() -> void:
	save_current_defaults()


func _on_help_pressed() -> void:
	toggle_controls_panel()


func _on_settings_pressed() -> void:
	toggle_settings_panel()


func _on_shader_panel_pressed() -> void:
	toggle_shader_panel()


func _on_inspector_pressed() -> void:
	toggle_inspector_panel()


func _on_display_tab_pressed() -> void:
	set_settings_tab(0)


func _on_audio_tab_pressed() -> void:
	set_settings_tab(1)


func _on_flight_tab_pressed() -> void:
	set_settings_tab(2)


func _on_render_tab_pressed() -> void:
	set_settings_tab(3)


func _on_controls_pressed() -> void:
	toggle_controls_panel()


func _on_controls_close_pressed() -> void:
	if controls_visible:
		toggle_controls_panel()


func _on_shader_close_pressed() -> void:
	if shader_panel_visible:
		toggle_shader_panel()


func _on_post_fx_pressed() -> void:
	edge_shader_enabled = not edge_shader_enabled
	apply_shader_runtime_settings()


func _on_blur_fx_pressed() -> void:
	blur_shader_enabled = not blur_shader_enabled
	apply_shader_runtime_settings()


func _on_attitude_shader_pressed() -> void:
	attitude_shader_enabled = not attitude_shader_enabled
	apply_shader_runtime_settings()
	update_inspector_panel_labels()


func _on_fullscreen_pressed() -> void:
	toggle_fullscreen_mode()


func _on_inspector_close_pressed() -> void:
	toggle_inspector_panel()


func _on_inspector_solo_pressed() -> void:
	inspector_solo_mode = not inspector_solo_mode
	refresh_debug_visual_overrides()
	update_inspector_panel_labels()


func _on_inspector_trippy_pressed() -> void:
	if inspector_selected_subject == null or not is_instance_valid(inspector_selected_subject):
		return
	var meshes := get_debug_subject_meshes(inspector_selected_subject)
	if meshes.is_empty():
		return
	var enable_override := false
	for mesh in meshes:
		if not bool(mesh.get_meta("debug_force_trippy", false)):
			enable_override = true
			break
	for mesh in meshes:
		mesh.set_meta("debug_force_trippy", enable_override)
	refresh_debug_visual_overrides()
	update_inspector_panel_labels()


func _on_inspector_reset_pressed() -> void:
	clear_debug_subject_overrides()
	refresh_debug_visual_overrides()
	update_inspector_panel_labels()


func _process(delta: float) -> void:
	update_responsive_hud_layout()
	update_boot_screen(delta)
	update_music_stream()
	update_autopilot_doppler(delta)
	update_ambient_radio(delta)
	update_alert(delta)
	update_hit_feedback(delta)
	if settings_visible:
		settings_label_refresh_timer = max(settings_label_refresh_timer - delta, 0.0)
		if settings_label_refresh_timer == 0.0:
			update_settings_label()
			settings_label_refresh_timer = 0.12
	update_overlay_blur()
	update_attitude_indicator()
	update_touch_controls_visibility()
	update_touch_player_input()
	update_help_panel_autoshow(delta)
	camera_manual_input_timer = max(camera_manual_input_timer - delta, 0.0)
	update_pause_camera(delta)
	update_idle_cinematic(delta)
	if paused:
		update_camera(delta)
		return
	if touch_fire_held:
		try_fire_player_projectile()

	update_controller_camera(delta)
	var camera_smooth: float = clamp(delta * 9.5, 0.0, 1.0)
	orbit_yaw = lerp_angle(orbit_yaw, orbit_yaw_target, camera_smooth)
	orbit_pitch = lerp(orbit_pitch, orbit_pitch_target, camera_smooth)
	update_camera(delta)
	update_contextual_line_visibility()
	update_objective_visuals(delta)
	update_enemy_target_marker()
	update_station_navigation_lights()
	update_planet_weather_effects(delta)
	update_station_spin(delta)
	update_destroyer_fleet(delta)
	update_traffic_ships(delta)
	hud_stats_refresh_timer = max(hud_stats_refresh_timer - delta, 0.0)
	if hud_stats_refresh_timer == 0.0:
		update_debug_overlay()
		update_scanner()
		update_combat_label()
		update_tactical_map()
		update_build_label()
		hud_stats_refresh_timer = 0.12


func note_player_activity() -> void:
	idle_input_timer = 0.0
	if cinematic_mode_active:
		cinematic_mode_active = false
	restore_idle_theme_override()


func apply_idle_theme_override() -> void:
	if idle_theme_override_active or VISUAL_PRESET_COUNT <= 1:
		return
	idle_theme_restore_index = visual_preset_index
	var random_index := idle_theme_restore_index
	var attempts := 0
	while random_index == idle_theme_restore_index and attempts < 12:
		random_index = runtime_rng.randi_range(0, VISUAL_PRESET_COUNT - 1)
		attempts += 1
	if random_index == idle_theme_restore_index:
		return
	idle_theme_override_active = true
	set_visual_preset(random_index)


func restore_idle_theme_override() -> void:
	if not idle_theme_override_active:
		return
	idle_theme_override_active = false
	set_visual_preset(idle_theme_restore_index)


func update_idle_cinematic(delta: float) -> void:
	var allow_cinematic := not paused and not start_screen_active and not settings_visible and not autopilot_active and not game_over_state
	if allow_cinematic:
		idle_input_timer += delta
		if idle_input_timer >= CINEMATIC_IDLE_DELAY:
			if not cinematic_mode_active:
				apply_idle_theme_override()
			cinematic_mode_active = true
			cinematic_time += delta
	else:
		idle_input_timer = 0.0
		cinematic_mode_active = false
		restore_idle_theme_override()
		cinematic_time = 0.0
	var target_blend: float = 1.0 if paused or cinematic_mode_active else 0.0
	var blend_speed: float = CINEMATIC_BLEND_IN_SPEED if target_blend > cinematic_blend else CINEMATIC_BLEND_OUT_SPEED
	cinematic_blend = move_toward(cinematic_blend, target_blend, delta * blend_speed)
	if cinematic_blend <= 0.001 and not cinematic_mode_active:
		cinematic_time = 0.0
	update_cinematic_overlay()


func update_help_panel_autoshow(delta: float) -> void:
	if help_panel_autoshow_timer < 0.0:
		return
	if paused or start_screen_active or game_over_state:
		return
	if settings_visible or controls_visible or shader_panel_visible or inspector_visible:
		return
	help_panel_autoshow_timer = max(help_panel_autoshow_timer - delta, 0.0)
	if help_panel_autoshow_timer > 0.0:
		return
	help_panel_autoshow_timer = -1.0
	if help_panel_seen:
		return
	help_panel_seen = true
	toggle_controls_panel()
	save_current_defaults()


func update_cinematic_overlay() -> void:
	var hud_alpha: float = 1.0 - cinematic_blend
	for node in cinematic_overlay_nodes:
		if node != null:
			node.modulate.a = hud_alpha
	if paused:
		if pause_card != null:
			pause_card.modulate.a = 1.0
		if pause_label != null:
			pause_label.modulate.a = 1.0
	cinematic_top_bar.visible = cinematic_blend > 0.001
	cinematic_bottom_bar.visible = cinematic_blend > 0.001
	cinematic_top_bar.modulate.a = cinematic_blend
	cinematic_bottom_bar.modulate.a = cinematic_blend
	if backdrop_top != null:
		backdrop_top.modulate.a = hud_alpha
	if backdrop_bottom != null:
		backdrop_bottom.modulate.a = hud_alpha
	var top_cover_height: float = max(CINEMATIC_BAR_HEIGHT, backdrop_top.size.y if backdrop_top != null else 0.0)
	var bottom_cover_height: float = max(CINEMATIC_BAR_HEIGHT, backdrop_bottom.size.y if backdrop_bottom != null else 0.0)
	cinematic_top_bar.position.y = 0.0
	cinematic_top_bar.size.y = top_cover_height * cinematic_blend
	cinematic_bottom_bar.position.y = get_viewport().get_visible_rect().size.y - bottom_cover_height * cinematic_blend
	cinematic_bottom_bar.size.y = bottom_cover_height * cinematic_blend


func _physics_process(delta: float) -> void:
	if paused:
		if start_screen_active:
			simulate_planets(delta)
			cached_ship_gravity = compute_ship_gravity()
			cached_ship_gravity_magnitude = cached_ship_gravity.length()
			player.call("set_gravity_acceleration", cached_ship_gravity * SHIP_GRAVITY_SCALE)
			update_effects(delta)
		return

	simulate_planets(delta)
	cached_ship_gravity = compute_ship_gravity()
	cached_ship_gravity_magnitude = cached_ship_gravity.length()
	player.call("set_gravity_acceleration", cached_ship_gravity * SHIP_GRAVITY_SCALE)
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


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		if not touch_device_active:
			touch_device_active = true
			update_responsive_hud_layout(true)
	if touch_phone_layout_active and touch_controls_root != null and touch_controls_root.visible:
		if handle_touch_controls_input(event):
			get_viewport().set_input_as_handled()
			return
	if inspector_visible and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_event := event as InputEventMouseButton
		if inspector_panel == null or not inspector_panel.get_global_rect().has_point(mouse_event.position):
			pick_inspector_object(mouse_event.position)
			get_viewport().set_input_as_handled()
			return
	if event is InputEventScreenTouch and event.pressed:
		note_player_activity()
		if shader_panel_visible or controls_visible or inspector_visible:
			return
		if start_screen_active:
			start_run()
			get_viewport().set_input_as_handled()
			return
		if game_over_state:
			restart_game()
			get_viewport().set_input_as_handled()
			return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			return
		if shader_panel_visible or controls_visible:
			return
		if start_screen_active:
			start_run()
			get_viewport().set_input_as_handled()
			return
		if game_over_state:
			restart_game()
			get_viewport().set_input_as_handled()
			return


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and event.relative.length() > 0.01:
		note_player_activity()
	elif event is InputEventMouseButton and event.pressed:
		note_player_activity()
	elif event is InputEventScreenTouch and event.pressed:
		note_player_activity()
	elif event is InputEventKey and event.pressed and not event.echo:
		note_player_activity()
	elif event is InputEventJoypadButton and event.pressed:
		note_player_activity()

	if event is InputEventScreenTouch and event.pressed:
		if shader_panel_visible:
			return
		if controls_visible:
			return
		if start_screen_active:
			start_run()
			return
		if game_over_state:
			restart_game()
			return

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
			if inspector_visible:
				toggle_inspector_panel()
				return
			if shader_panel_visible:
				toggle_shader_panel()
				return
			if controls_visible:
				toggle_controls_panel()
			else:
				toggle_settings_panel()
			return
		if event.button_index == JOY_BUTTON_LEFT_SHOULDER:
			set_visual_preset((visual_preset_index + VISUAL_PRESET_COUNT - 1) % VISUAL_PRESET_COUNT)
			return
		if event.button_index == JOY_BUTTON_RIGHT_SHOULDER:
			set_visual_preset((visual_preset_index + 1) % VISUAL_PRESET_COUNT)
			return
		if event.button_index == JOY_BUTTON_DPAD_UP:
			if nearby_station:
				dock_at_station(nearby_station)
			else:
				update_status("No station in range.\nApproach a station halo, then press dock to moor.")
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
		if inspector_visible:
			toggle_inspector_panel()
			return
		if shader_panel_visible:
			toggle_shader_panel()
			return
		if controls_visible:
			toggle_controls_panel()
			return
		toggle_pause()
		return

	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_TAB:
		toggle_camera_mode()
		return

	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_V:
		reset_view()
		return

	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_H:
		if inspector_visible:
			toggle_inspector_panel()
			return
		if shader_panel_visible:
			toggle_shader_panel()
			return
		toggle_controls_panel()
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
		if event.keycode == KEY_5:
			set_visual_preset(4)
			return
			if event.keycode == KEY_6:
				set_visual_preset(5)
				return
			if event.keycode == KEY_7:
				set_visual_preset(6)
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
			cycle_autopilot_target()
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
	star_mesh.name = "StarWire"
	star_mesh.mesh = build_planet_mesh(STAR_RADIUS)
	mark_mesh_wireframe_only(star_mesh)
	register_style_mesh(star_mesh, "star", Color(1.0, 0.84, 0.28))
	star_node.add_child(star_mesh)

	var star_solid := MeshInstance3D.new()
	star_solid.name = "StarSolid"
	star_solid.mesh = build_planet_solid_mesh(STAR_RADIUS)
	mark_mesh_solid_only(star_solid)
	register_style_mesh(star_solid, "star", Color(1.0, 0.84, 0.28))
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

	star_beacon_root = Node3D.new()
	star_beacon_root.name = "StarBeacon"
	star_node.add_child(star_beacon_root)
	star_beacon_nodes.clear()
	var beacon_specs := [
		{"size": 6800.0, "color": Color(1.0, 0.86, 0.38, 0.16)},
		{"size": 3200.0, "color": Color(1.0, 0.74, 0.22, 0.12)}
	]
	for beacon_spec in beacon_specs:
		var beacon := MeshInstance3D.new()
		var quad := QuadMesh.new()
		quad.size = Vector2(beacon_spec["size"], beacon_spec["size"])
		beacon.mesh = quad
		var beacon_material := StandardMaterial3D.new()
		beacon_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		beacon_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		beacon_material.cull_mode = BaseMaterial3D.CULL_DISABLED
		beacon_material.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
		beacon_material.albedo_color = beacon_spec["color"]
		beacon_material.emission_enabled = true
		beacon_material.emission = Color(beacon_spec["color"].r, beacon_spec["color"].g, beacon_spec["color"].b) * 2.2
		beacon.material_override = beacon_material
		star_beacon_root.add_child(beacon)
		star_beacon_nodes.append(beacon)

	star_flare_root = Node3D.new()
	star_flare_root.name = "SolarFlare"
	star_node.add_child(star_flare_root)
	star_flare_nodes.clear()
	var flare_specs := [
		{"size": 9800.0, "offset": 0.0, "color": Color(1.0, 0.82, 0.42, 0.12)},
		{"size": 5200.0, "offset": 8600.0, "color": Color(1.0, 0.62, 0.28, 0.1)},
		{"size": 2600.0, "offset": -6200.0, "color": Color(1.0, 0.92, 0.6, 0.08)},
		{"size": 1400.0, "offset": 12400.0, "color": Color(1.0, 0.52, 0.24, 0.07)}
	]
	for flare_spec in flare_specs:
		var flare := MeshInstance3D.new()
		var quad := QuadMesh.new()
		quad.size = Vector2(flare_spec["size"], flare_spec["size"])
		flare.mesh = quad
		var flare_material := StandardMaterial3D.new()
		flare_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		flare_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		flare_material.cull_mode = BaseMaterial3D.CULL_DISABLED
		flare_material.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
		flare_material.albedo_color = flare_spec["color"]
		flare_material.emission_enabled = true
		flare_material.emission = Color(flare_spec["color"].r, flare_spec["color"].g, flare_spec["color"].b) * 1.7
		flare.material_override = flare_material
		flare.set_meta("flare_offset", float(flare_spec["offset"]))
		star_flare_root.add_child(flare)
		star_flare_nodes.append(flare)

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
		create_planet_weather_effects(root, planet_data, planet_radius)

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


func create_planet_weather_effects(root: Node3D, planet_data: Dictionary, planet_radius: float) -> void:
	if not planet_data.has("atmosphere_color") and not planet_data.has("storm_color"):
		return
	var weather_root := Node3D.new()
	weather_root.name = "%sWeather" % str(planet_data["name"])
	root.add_child(weather_root)

	var atmosphere_shell := MeshInstance3D.new()
	var shell_mesh := SphereMesh.new()
	shell_mesh.radius = planet_radius * 1.08
	shell_mesh.height = planet_radius * 2.16
	shell_mesh.radial_segments = 24
	shell_mesh.rings = 12
	atmosphere_shell.mesh = shell_mesh
	var atmosphere_material := StandardMaterial3D.new()
	atmosphere_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	atmosphere_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	atmosphere_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	atmosphere_material.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
	atmosphere_material.albedo_color = planet_data.get("atmosphere_color", Color(1.0, 1.0, 1.0, 0.14))
	atmosphere_material.emission_enabled = true
	atmosphere_material.emission = Color(atmosphere_material.albedo_color.r, atmosphere_material.albedo_color.g, atmosphere_material.albedo_color.b) * 0.5
	atmosphere_shell.material_override = atmosphere_material
	weather_root.add_child(atmosphere_shell)

	var storm_bands: Array[MeshInstance3D] = []
	var band_count := int(planet_data.get("storm_bands", 0))
	for band_index in range(band_count):
		var band := MeshInstance3D.new()
		var band_radius := planet_radius * (0.84 + 0.08 * band_index)
		band.mesh = build_ring_mesh(band_radius, 72)
		register_style_mesh(band, "danger", planet_data.get("storm_color", Color.WHITE))
		band.rotation = Vector3(
			deg_to_rad(-38.0 + band_index * 19.0),
			deg_to_rad(planet_radius * 0.02 + band_index * 31.0),
			deg_to_rad(12.0 + band_index * 17.0)
		)
		weather_root.add_child(band)
		storm_bands.append(band)

	var storm_cells: Array[MeshInstance3D] = []
	var storm_count := int(planet_data.get("storm_cells", 0))
	for storm_index in range(storm_count):
		var cell := MeshInstance3D.new()
		var cell_mesh := SphereMesh.new()
		var cell_radius := planet_radius * (0.08 + 0.018 * float(storm_index % 3))
		cell_mesh.radius = cell_radius
		cell_mesh.height = cell_radius * 2.0
		cell.mesh = cell_mesh
		var cell_material := StandardMaterial3D.new()
		cell_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		cell_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		cell_material.cull_mode = BaseMaterial3D.CULL_DISABLED
		cell_material.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
		var storm_color: Color = planet_data.get("storm_color", Color.WHITE)
		cell_material.albedo_color = Color(storm_color.r, storm_color.g, storm_color.b, 0.2)
		cell_material.emission_enabled = true
		cell_material.emission = Color(storm_color.r, storm_color.g, storm_color.b) * 1.1
		cell.material_override = cell_material
		var angle: float = TAU * float(storm_index) / max(float(storm_count), 1.0) + float(planet_data.get("phase", 0.0)) * 0.4
		var elevation: float = lerp(-0.55, 0.55, float(storm_index + 1) / float(storm_count + 1))
		var shell_radius := planet_radius * 0.92
		cell.position = Vector3(cos(angle) * shell_radius, elevation * shell_radius, sin(angle) * shell_radius)
		cell.set_meta("pulse_phase", angle * 1.7)
		weather_root.add_child(cell)
		storm_cells.append(cell)

	planet_weather_effects.append({
		"root": weather_root,
		"atmosphere": atmosphere_shell,
		"storm_bands": storm_bands,
		"storm_cells": storm_cells,
		"spin_rate": float(planet_data.get("weather_spin", 0.08))
	})


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
		add_station_navigation_lights(station, 22.0 * STATION_SCALE)

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
	add_station_navigation_lights(station, RINGWORLD_STATION_RADIUS * 0.42)

	station_order.append(station)
	station_nodes_by_name["Eidolon Ring"] = station


func create_pirate_hideouts() -> void:
	var outer_planet := planet_nodes_by_name.get("Aster", null) as Node3D
	if outer_planet == null:
		return
	var hideouts := [
		{
			"name": "Black Invoice",
			"offset": Vector3(1180.0, 260.0, -1420.0),
			"station_color": Color(0.92, 0.48, 0.34),
			"dock_color": Color(1.0, 0.84, 0.42),
			"field_radius": 620.0,
			"field_spread": 180.0,
			"pirates": ["Captain Tax Evasion", "Knuckles Mercy", "Auntie Hullbreach"]
		},
		{
			"name": "Rust Garden",
			"offset": Vector3(-1540.0, -180.0, 1680.0),
			"station_color": Color(0.88, 0.62, 0.32),
			"dock_color": Color(0.96, 0.9, 0.48),
			"field_radius": 780.0,
			"field_spread": 240.0,
			"pirates": ["Minty Vane", "Quartermaster Bluster", "Six-Gun Spreadsheet"]
		}
	]
	for hideout_data in hideouts:
		var anchor := Node3D.new()
		anchor.name = "%sAnchor" % hideout_data["name"]
		anchor.position = hideout_data["offset"]
		outer_planet.add_child(anchor)

		var field := MeshInstance3D.new()
		field.mesh = build_debris_belt_mesh(float(hideout_data["field_radius"]), float(hideout_data["field_spread"]), 84)
		register_style_mesh(field, "danger", Color(0.86, 0.72, 0.52, 0.78))
		field.rotation = Vector3(0.24, 0.65, 0.12)
		anchor.add_child(field)

		var station := Area3D.new()
		station.name = str(hideout_data["name"])
		station.collision_layer = 0
		station.collision_mask = 1
		station.set_meta("station_name", hideout_data["name"])
		station.set_meta("planet_name", "Aster")
		station.set_meta("dock_offset", Vector3(0, 0, 220))
		station.set_meta("collision_radius", STATION_COLLISION_RADIUS)
		station.set_meta("spin_speed", randf_range(0.09, 0.18))
		station.set_meta("pirate_hideout", true)
		station.body_entered.connect(_on_station_body_entered.bind(station))
		station.body_exited.connect(_on_station_body_exited.bind(station))
		anchor.add_child(station)

		var collision := CollisionShape3D.new()
		var shape := SphereShape3D.new()
		shape.radius = STATION_COLLISION_RADIUS
		collision.shape = shape
		station.add_child(collision)

		var wireframe := MeshInstance3D.new()
		wireframe.mesh = build_station_mesh(18.0 * STATION_SCALE)
		mark_mesh_wireframe_only(wireframe)
		register_style_mesh(wireframe, "danger", hideout_data["station_color"])
		station.add_child(wireframe)

		var station_solid := MeshInstance3D.new()
		station_solid.mesh = build_station_solid_mesh(18.0 * STATION_SCALE)
		mark_mesh_solid_only(station_solid)
		register_style_mesh(station_solid, "danger", hideout_data["station_color"])
		station.add_child(station_solid)

		var dock_marker := MeshInstance3D.new()
		dock_marker.position = Vector3(0, 0, 220)
		dock_marker.mesh = build_dock_marker_mesh(18.0)
		register_style_mesh(dock_marker, "objective", hideout_data["dock_color"])
		station.add_child(dock_marker)

		var station_label := Label3D.new()
		station_label.position = Vector3(0, 148.0, 0)
		station_label.text = "%s\npirate haven" % str(hideout_data["name"])
		station_label.font_size = 32
		station_label.no_depth_test = true
		register_style_label(station_label, "danger", Color.WHITE)
		station.add_child(station_label)
		add_station_navigation_lights(station, 18.0 * STATION_SCALE)

		pirate_stations.append(station)
		create_pirate_raiders(station, hideout_data["pirates"])


func create_pirate_raiders(station: Area3D, pirate_names: Array) -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for pirate_name in pirate_names:
		var enemy := Node3D.new()
		enemy.name = str(pirate_name)
		var angle: float = rng.randf_range(0.0, TAU)
		var radius: float = rng.randf_range(PIRATE_PATROL_RADIUS * 0.42, PIRATE_PATROL_RADIUS)
		var local_offset: Vector3 = Vector3(cos(angle) * radius, rng.randf_range(-120.0, 120.0), sin(angle) * radius)
		enemy.position = station.position + local_offset
		enemy.set_meta("velocity", Vector3.ZERO)
		enemy.set_meta("hull", ENEMY_MAX_HULL * 1.15)
		enemy.set_meta("fire_cooldown", rng.randf_range(0.6, 1.2))
		enemy.set_meta("orbit_bias", rng.randf_range(-1.0, 1.0))
		enemy.set_meta("ambush_mode", false)
		enemy.set_meta("field_center", station.position)
		enemy.set_meta("field_anchor", enemy.position)
		enemy.set_meta("patrol_phase", rng.randf_range(0.0, TAU))
		enemy.set_meta("pirate_guard", true)
		enemy.set_meta("pirate_station", station)
		enemy.set_meta("pirate_name", str(pirate_name))
		enemy.set_meta("pirate_chasing", false)

		var mesh := MeshInstance3D.new()
		mesh.mesh = build_enemy_ship_mesh()
		mark_mesh_wireframe_only(mesh)
		register_style_mesh(mesh, "danger", Color(1.0, 0.58, 0.34))
		enemy.add_child(mesh)

		var solid_mesh := MeshInstance3D.new()
		solid_mesh.mesh = build_enemy_solid_mesh()
		mark_mesh_solid_only(solid_mesh)
		register_style_mesh(solid_mesh, "danger", Color(1.0, 0.58, 0.34))
		enemy.add_child(solid_mesh)

		add_child(enemy)
		enemy_nodes.append(enemy)


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


func create_traffic_ships() -> void:
	var traffic_layout := [
		{"name": "Patrol Ilex", "class": "police_interceptor", "speed": 420.0, "role": "target", "color": Color(0.56, 0.88, 1.0)},
		{"name": "Vigil Lance", "class": "police_interceptor", "speed": 390.0, "role": "target", "color": Color(0.52, 0.84, 1.0)},
		{"name": "Morrow Cartage", "class": "heavy_hauler", "speed": 165.0, "role": "station", "color": Color(0.9, 0.84, 0.62)},
		{"name": "Bulkrunner Saint Vesta", "class": "heavy_hauler", "speed": 150.0, "role": "station", "color": Color(0.86, 0.8, 0.66)},
		{"name": "Kestrel Ward", "class": "corvette", "speed": 245.0, "role": "station", "color": Color(0.74, 0.86, 1.0)},
		{"name": "Signal Kite", "class": "courier", "speed": 520.0, "role": "objective", "color": Color(0.74, 1.0, 0.86)},
		{"name": "Pilgrim Tender", "class": "salvage_tug", "speed": 185.0, "role": "lane", "color": Color(0.72, 0.9, 0.94)}
	]
	var rng := RandomNumberGenerator.new()
	rng.randomize()

	for ship_data in traffic_layout:
		var ship := Node3D.new()
		ship.name = str(ship_data["name"])
		ship.set_meta("traffic_class", ship_data["class"])
		ship.set_meta("traffic_speed", ship_data["speed"])
		ship.set_meta("velocity", Vector3.ZERO)
		ship.set_meta("traffic_role", ship_data["role"])
		ship.position = get_random_system_waypoint(rng)

		var wire_mesh := MeshInstance3D.new()
		wire_mesh.mesh = build_traffic_ship_mesh(str(ship_data["class"]))
		mark_mesh_wireframe_only(wire_mesh)
		register_style_mesh(wire_mesh, str(ship_data["role"]), ship_data["color"])
		ship.add_child(wire_mesh)

		var solid_mesh := MeshInstance3D.new()
		solid_mesh.mesh = build_traffic_ship_solid_mesh(str(ship_data["class"]))
		mark_mesh_solid_only(solid_mesh)
		register_style_mesh(solid_mesh, str(ship_data["role"]), ship_data["color"])
		ship.add_child(solid_mesh)

		var label := Label3D.new()
		label.text = "%s\n%s" % [str(ship_data["name"]), format_traffic_class_name(str(ship_data["class"]))]
		label.position = Vector3(0, 22, 0)
		label.font_size = 22
		label.no_depth_test = true
		register_style_label(label, "label", Color.WHITE)
		ship.add_child(label)

		add_traffic_nav_lights(ship, str(ship_data["class"]), ship_data["color"])
		assign_traffic_destination(ship, rng, true)
		add_child(ship)
		traffic_ships.append(ship)


func create_objective_visuals() -> void:
	objective_line = MeshInstance3D.new()
	objective_line.name = "ObjectiveLine"
	register_style_mesh(objective_line, "objective", Color(0.5, 0.95, 0.7))
	add_child(objective_line)

	objective_marker = MeshInstance3D.new()
	objective_marker.name = "ObjectiveMarker"
	objective_marker_base_mesh = build_ring_mesh(8.5, 36)
	objective_marker.mesh = objective_marker_base_mesh
	register_style_mesh(objective_marker, "objective", Color(0.45, 1.0, 0.85))
	add_child(objective_marker)

	enemy_target_marker = MeshInstance3D.new()
	enemy_target_marker.name = "EnemyTargetMarker"
	enemy_target_marker_base_mesh = build_enemy_target_marker_mesh(18.0)
	enemy_target_marker.mesh = enemy_target_marker_base_mesh
	register_style_mesh(enemy_target_marker, "target", Color(1.0, 0.52, 0.42))
	enemy_target_marker.visible = false
	add_child(enemy_target_marker)

	enemy_target_lead_marker = MeshInstance3D.new()
	enemy_target_lead_marker.name = "EnemyTargetLeadMarker"
	enemy_target_lead_base_mesh = build_target_lead_marker_mesh(8.0)
	enemy_target_lead_marker.mesh = enemy_target_lead_base_mesh
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


func update_traffic_ships(delta: float) -> void:
	for ship in traffic_ships:
		if not is_instance_valid(ship):
			continue
		var target: Vector3 = ship.get_meta("traffic_target", ship.global_position)
		var to_target: Vector3 = target - ship.global_position
		if to_target.length() < 140.0:
			assign_traffic_destination(ship, runtime_rng)
			target = ship.get_meta("traffic_target", ship.global_position)
			to_target = target - ship.global_position
		var desired_velocity := Vector3.ZERO
		if to_target.length() > 1.0:
			desired_velocity = to_target.normalized() * float(ship.get_meta("traffic_speed", 180.0))
		var velocity: Vector3 = ship.get_meta("velocity", Vector3.ZERO)
		velocity = velocity.lerp(desired_velocity, min(delta * 0.55, 1.0))
		ship.set_meta("velocity", velocity)
		ship.global_position += velocity * delta
		if velocity.length() > 4.0:
			ship.look_at(ship.global_position + velocity.normalized() * 22.0, Vector3.UP, true)


func compute_destroyer_position(orbit_radius: float, phase: float, height: float) -> Vector3:
	return Vector3(
		cos(phase) * orbit_radius,
		height + sin(phase * 2.0) * 42.0,
		sin(phase) * orbit_radius
	)


func assign_traffic_destination(ship: Node3D, rng: RandomNumberGenerator, initial: bool = false) -> void:
	if ship == null:
		return
	var destination := get_random_system_waypoint(rng)
	if not initial:
		var attempts := 0
		while ship.global_position.distance_to(destination) < 2600.0 and attempts < 6:
			destination = get_random_system_waypoint(rng)
			attempts += 1
	ship.set_meta("traffic_target", destination)


func get_random_system_waypoint(rng: RandomNumberGenerator) -> Vector3:
	if station_order.size() > 0 and rng.randf() < 0.62:
		var station: Area3D = station_order[rng.randi_range(0, station_order.size() - 1)]
		if station != null and is_instance_valid(station):
			var offset := Vector3(
				rng.randf_range(-1800.0, 1800.0),
				rng.randf_range(-260.0, 260.0),
				rng.randf_range(-1800.0, 1800.0)
			)
			return station.global_position + offset
	return Vector3(
		rng.randf_range(-WORLD_LIMIT.x * 0.72, WORLD_LIMIT.x * 0.72),
		rng.randf_range(-WORLD_LIMIT.y * 0.38, WORLD_LIMIT.y * 0.38),
		rng.randf_range(-WORLD_LIMIT.z * 0.72, WORLD_LIMIT.z * 0.72)
	)


func add_traffic_nav_lights(ship: Node3D, traffic_class: String, accent_color: Color) -> void:
	var span := 11.0
	var aft := 6.0
	match traffic_class:
		"heavy_hauler":
			span = 18.0
			aft = 11.0
		"corvette":
			span = 15.0
			aft = 9.0
		"courier":
			span = 9.0
			aft = 5.0
		"salvage_tug":
			span = 13.0
			aft = 8.0
	for light_data in [
		{"name": "PortLight", "position": Vector3(-span, 1.2, 0), "color": Color(1.0, 0.22, 0.22)},
		{"name": "StarboardLight", "position": Vector3(span, 1.2, 0), "color": Color(0.22, 1.0, 0.34)},
		{"name": "WakeLight", "position": Vector3(0, 0.6, aft), "color": accent_color.lightened(0.08)}
	]:
		var light := OmniLight3D.new()
		light.name = str(light_data["name"])
		light.position = light_data["position"]
		light.light_color = light_data["color"]
		light.light_energy = 0.55
		light.omni_range = 34.0
		light.omni_attenuation = 1.6
		light.shadow_enabled = false
		ship.add_child(light)


func format_traffic_class_name(traffic_class: String) -> String:
	match traffic_class:
		"police_interceptor":
			return "Police Interceptor"
		"heavy_hauler":
			return "Heavy Hauler"
		"corvette":
			return "Escort Corvette"
		"courier":
			return "Express Courier"
		"salvage_tug":
			return "Salvage Tug"
		_:
			return "Traffic"


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
	dock_label.text = "Docked: %s (%d)" % [station_name, dock_count]
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
	alert_value.text = "%s  |  %s  |  %s  |  %s" % [view_name.to_upper(), render_name.to_upper(), preset_name.to_upper(), ap_state]
	hit_value.text = get_target_telemetry_text()


func get_target_telemetry_text() -> String:
	var target_station := get_target_station()
	if target_station == null or not is_instance_valid(target_station):
		return "TARGET NONE"
	var offset: Vector3 = target_station.global_position - player.global_position
	var distance: float = offset.length()
	var closing_rate := get_target_closing_rate(target_station)
	var target_name := str(target_station.get_meta("station_name"))
	var rate_status := ""
	if autopilot_active and target_station == autopilot_station:
		rate_status = "  |  %s" % get_autopilot_rate_status_text(closing_rate)
	return "%s  |  %.0fm  |  closing %.0fm/s%s" % [target_name.to_upper(), distance, closing_rate, rate_status]


func get_target_closing_rate(target_station: Area3D) -> float:
	if target_station == null or not is_instance_valid(target_station):
		return 0.0
	var offset: Vector3 = target_station.global_position - player.global_position
	if offset.length() <= 0.001:
		return 0.0
	return max(player.velocity.dot(offset.normalized()), 0.0)


func get_autopilot_rate_status_band(closing_rate: float) -> int:
	if closing_rate < 18.0:
		return 0
	if closing_rate < 65.0:
		return 1
	if closing_rate < 150.0:
		return 2
	return 3


func get_autopilot_rate_status_text(closing_rate: float) -> String:
	match get_autopilot_rate_status_band(closing_rate):
		0:
			return "HOLD"
		1:
			return "STABLE"
		2:
			return "FAST"
		_:
			return "HOT"


func maybe_report_autopilot_rate_status(closing_rate: float) -> void:
	if not autopilot_active or autopilot_station == null or not is_instance_valid(autopilot_station):
		return
	var band := get_autopilot_rate_status_band(closing_rate)
	if band == autopilot_rate_status_band:
		return
	autopilot_rate_status_band = band
	var station_name := str(autopilot_station.get_meta("station_name"))
	match band:
		0:
			play_radio_message("%s Approach" % station_name, "Closure nearly nil. Holding you on a civilized crawl. No need to terrify the dockhands.", "comms_station", -15.0)
		1:
			play_radio_message("%s Approach" % station_name, "Closure rate nominal. Sensible, steady, and only faintly alarming.", "comms_station", -15.0)
		2:
			play_radio_message("%s Approach" % station_name, "Closure is brisk. Entirely workable, provided you continue pretending this was the plan.", "comms_station", -14.0)
		_:
			play_radio_message("%s Approach" % station_name, "Closure is rather hot. Do bleed some speed before you arrive as an anecdote.", "comms_station", -13.0)
	set_alert("AP %s" % get_autopilot_rate_status_text(closing_rate), 0.4)


func get_autopilot_state_display() -> String:
	if not autopilot_active:
		return "MANUAL"
	if autopilot_state == "arm":
		var countdown: float = max(ceil(AUTOPILOT_ARM_DURATION - autopilot_timer), 0.0)
		return "ARM T-%d" % int(countdown)
	return autopilot_state.to_upper()


func setup_attitude_indicator() -> void:
	attitude_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	attitude_display.visible = false
	attitude_ball.visible = false
	attitude_needle.visible = false
	if attitude_indicator_widget == null and DisplayServer.get_name() != "headless":
		var widget := Control.new()
		widget.name = "AttitudeIndicator2D"
		widget.set_script(AttitudeIndicatorScript)
		widget.anchor_right = 1.0
		widget.anchor_bottom = 1.0
		attitude_frame.add_child(widget)
		attitude_indicator_widget = widget
	update_attitude_indicator_theme()


func update_attitude_indicator() -> void:
	if attitude_indicator_widget == null or not is_instance_valid(attitude_indicator_widget):
		return
	var ship_basis: Basis = player.call("get_visual_basis")
	var reference_basis := get_attitude_reference_basis()
	var relative_basis := reference_basis.inverse() * ship_basis.orthonormalized()
	var roll_angle: float = atan2(relative_basis.y.x, relative_basis.y.y)
	var pitch_normalized: float = clampf(relative_basis.z.y, -1.0, 1.0)
	var sun_direction: Vector3 = Vector3.UP
	if star_node != null and is_instance_valid(star_node):
		sun_direction = (star_node.global_position - player.global_position).normalized()
	var local_sun: Vector3 = ship_basis.inverse() * sun_direction
	var sun_angle: float = atan2(local_sun.x, -local_sun.y)
	attitude_indicator_widget.call("set_indicator_state", roll_angle, pitch_normalized, sun_angle, attitude_shader_enabled)


func get_attitude_reference_basis() -> Basis:
	var solar_up := Vector3.UP
	var sun_direction := (-player.global_position).normalized()
	if star_node != null and is_instance_valid(star_node):
		sun_direction = (star_node.global_position - player.global_position).normalized()
	if sun_direction.length() <= 0.001:
		sun_direction = Vector3.FORWARD
	var sun_on_plane := sun_direction - solar_up * sun_direction.dot(solar_up)
	if sun_on_plane.length() <= 0.001:
		sun_on_plane = Vector3.FORWARD
	sun_on_plane = sun_on_plane.normalized()
	var solar_right := solar_up.cross(-sun_on_plane).normalized()
	if solar_right.length() <= 0.001:
		solar_right = Vector3.RIGHT
	var forward := solar_right.cross(solar_up).normalized()
	return Basis(solar_right, solar_up, -forward).orthonormalized()


func update_attitude_indicator_theme() -> void:
	if attitude_indicator_widget == null or not is_instance_valid(attitude_indicator_widget):
		return
	var accent := resolve_style_color("objective", Color(0.55, 0.95, 1.0))
	var hud := resolve_style_color("hud", Color(0.78, 0.92, 1.0))
	var upper_color := accent.lerp(Color(0.12, 0.62, 1.0), 0.55)
	var lower_color := accent.lerp(Color(1.0, 0.46, 0.14), 0.72)
	var sun_color := accent.lerp(Color(1.0, 0.92, 0.58), 0.62)
	attitude_indicator_widget.call("set_theme_colors", hud, accent, upper_color, lower_color, sun_color)


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
	edge_pass.visible = true


func setup_blur_pass() -> void:
	var material := ShaderMaterial.new()
	material.shader = load("res://shaders/overlay_fog.gdshader")
	blur_pass.material = material
	blur_pass.visible = start_screen_active
	update_blur_pass_theme()


func update_overlay_blur() -> void:
	blur_pass.visible = blur_shader_enabled and (start_screen_active or paused or settings_visible or controls_visible or shader_panel_visible or inspector_visible)


func update_overlay_button_visibility() -> void:
	var show_utilities := not (settings_visible or controls_visible or shader_panel_visible or inspector_visible)
	fullscreen_button.visible = show_utilities and not (touch_device_active and OS.has_feature("web"))
	help_button.visible = show_utilities
	settings_button.visible = show_utilities
	shader_button.visible = show_utilities
	if inspector_button != null:
		inspector_button.visible = show_utilities
	debug_save_defaults_button.visible = SHOW_DEBUG_SAVE_BUTTON and show_utilities and not touch_phone_layout_active


func handle_touch_controls_input(event: InputEvent) -> bool:
	if event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch
		if touch_event.pressed:
			return begin_touch_pad_tracking(touch_event.index, touch_event.position)
		return end_touch_pad_tracking(touch_event.index)
	if event is InputEventScreenDrag:
		var drag_event := event as InputEventScreenDrag
		return update_touch_pad_tracking(drag_event.index, drag_event.position)
	return false


func begin_touch_pad_tracking(pointer_index: int, screen_position: Vector2) -> bool:
	if touch_move_pad != null and touch_move_pointer == -1 and touch_move_pad.get_global_rect().has_point(screen_position):
		touch_move_pointer = pointer_index
		update_touch_pad_axis(touch_move_pad, touch_move_knob, screen_position, true)
		note_player_activity()
		return true
	if touch_look_pad != null and touch_look_pointer == -1 and touch_look_pad.get_global_rect().has_point(screen_position):
		touch_look_pointer = pointer_index
		update_touch_pad_axis(touch_look_pad, touch_look_knob, screen_position, false)
		note_player_activity()
		return true
	return false


func update_touch_pad_tracking(pointer_index: int, screen_position: Vector2) -> bool:
	var handled := false
	if pointer_index == touch_move_pointer and touch_move_pad != null:
		update_touch_pad_axis(touch_move_pad, touch_move_knob, screen_position, true)
		handled = true
	if pointer_index == touch_look_pointer and touch_look_pad != null:
		update_touch_pad_axis(touch_look_pad, touch_look_knob, screen_position, false)
		handled = true
	if handled:
		note_player_activity()
	return handled


func end_touch_pad_tracking(pointer_index: int) -> bool:
	var handled := false
	if pointer_index == touch_move_pointer:
		touch_move_pointer = -1
		touch_move_axis = Vector2.ZERO
		reset_touch_pad_knob(touch_move_pad, touch_move_knob)
		handled = true
	if pointer_index == touch_look_pointer:
		touch_look_pointer = -1
		touch_look_axis = Vector2.ZERO
		reset_touch_pad_knob(touch_look_pad, touch_look_knob)
		handled = true
	return handled


func update_touch_pad_axis(pad: Control, knob: ColorRect, screen_position: Vector2, move_pad: bool) -> void:
	if pad == null or knob == null:
		return
	var rect := pad.get_global_rect()
	var center := rect.position + rect.size * 0.5
	var radius: float = min(rect.size.x, rect.size.y) * 0.34
	if radius <= 0.0:
		return
	var local_axis: Vector2 = (screen_position - center) / radius
	local_axis.x = clamp(local_axis.x, -1.0, 1.0)
	local_axis.y = clamp(local_axis.y, -1.0, 1.0)
	if local_axis.length() > 1.0:
		local_axis = local_axis.normalized()
	if move_pad:
		touch_move_axis = Vector2(local_axis.x, local_axis.y)
	else:
		touch_look_axis = Vector2(local_axis.x, local_axis.y)
	update_touch_pad_knob(pad, knob, local_axis)


func update_touch_pad_knob(pad: Control, knob: ColorRect, axis: Vector2) -> void:
	if pad == null or knob == null:
		return
	var center := pad.size * 0.5
	var travel: float = min(pad.size.x, pad.size.y) * 0.28
	knob.position = center + axis * travel - knob.size * 0.5


func reset_touch_pad_knob(pad: Control, knob: ColorRect) -> void:
	update_touch_pad_knob(pad, knob, Vector2.ZERO)


func update_touch_controls_visibility() -> void:
	if touch_controls_root == null:
		return
	var show_controls: bool = touch_device_active and not paused and not start_screen_active and not settings_visible and not controls_visible and not shader_panel_visible and not inspector_visible and not game_over_state
	touch_controls_root.visible = show_controls
	if not show_controls:
		reset_touch_controls_state()


func reset_touch_controls_state() -> void:
	touch_move_pointer = -1
	touch_look_pointer = -1
	touch_move_axis = Vector2.ZERO
	touch_look_axis = Vector2.ZERO
	touch_vertical_axis = 0.0
	touch_fire_held = false
	if player != null:
		player.call("set_touch_move_input", Vector3.ZERO)
		player.call("set_touch_look_input", Vector2.ZERO)
		player.call("set_touch_boost", false)
	if touch_move_pad != null:
		reset_touch_pad_knob(touch_move_pad, touch_move_knob)
	if touch_look_pad != null:
		reset_touch_pad_knob(touch_look_pad, touch_look_knob)


func update_touch_player_input() -> void:
	if player == null:
		return
	if not touch_device_active or touch_controls_root == null or not touch_controls_root.visible:
		player.call("set_touch_move_input", Vector3.ZERO)
		player.call("set_touch_look_input", Vector2.ZERO)
		player.call("set_touch_boost", false)
		return
	var move_input: Vector3 = Vector3(touch_move_axis.x, touch_vertical_axis, touch_move_axis.y)
	player.call("set_touch_move_input", move_input)
	player.call("set_touch_look_input", touch_look_axis)


func layout_touch_controls(viewport_size: Vector2, margin: float, is_phone_portrait: bool, compact: bool) -> void:
	if touch_controls_root == null:
		return
	update_touch_controls_visibility()
	if not touch_device_active:
		return

	var pad_size: float = min(228.0 if is_phone_portrait else 186.0, max(164.0, viewport_size.x * (0.39 if is_phone_portrait else 0.24)))
	var pad_bottom: float = 108.0 if is_phone_portrait else 36.0
	var pad_left: float = margin
	var pad_right: float = viewport_size.x - margin - pad_size
	touch_move_pad.position = Vector2(pad_left, viewport_size.y - pad_bottom - pad_size)
	touch_move_pad.size = Vector2.ONE * pad_size
	touch_look_pad.position = Vector2(pad_right, viewport_size.y - pad_bottom - pad_size)
	touch_look_pad.size = Vector2.ONE * pad_size
	var knob_size: Vector2 = Vector2.ONE * (pad_size * 0.33)
	touch_move_knob.size = knob_size
	touch_look_knob.size = knob_size
	reset_touch_pad_knob(touch_move_pad, touch_move_knob)
	reset_touch_pad_knob(touch_look_pad, touch_look_knob)

	var button_size: Vector2 = Vector2(
		88.0 if is_phone_portrait else 74.0,
		72.0 if is_phone_portrait else 60.0
	)
	var button_gap: float = 10.0 if is_phone_portrait else 8.0
	var cluster_width: float = button_size.x * 2.0 + button_gap
	var cluster_left: float = clamp((viewport_size.x - cluster_width) * 0.5, touch_move_pad.position.x + pad_size + 10.0, touch_look_pad.position.x - cluster_width - 10.0)
	var cluster_bottom: float = viewport_size.y - (102.0 if is_phone_portrait else 32.0)
	var top_row_y: float = cluster_bottom - button_size.y * 4.0 - button_gap * 3.0
	position_touch_button(touch_boost_button, cluster_left, top_row_y, button_size)
	position_touch_button(touch_fire_button, cluster_left + button_size.x + button_gap, top_row_y, button_size)
	position_touch_button(touch_up_button, cluster_left, top_row_y + button_size.y + button_gap, button_size)
	position_touch_button(touch_down_button, cluster_left + button_size.x + button_gap, top_row_y + button_size.y + button_gap, button_size)
	position_touch_button(touch_ap_button, cluster_left, top_row_y + (button_size.y + button_gap) * 2.0, button_size)
	position_touch_button(touch_camera_button, cluster_left + button_size.x + button_gap, top_row_y + (button_size.y + button_gap) * 2.0, button_size)
	position_touch_button(touch_dock_button, cluster_left, top_row_y + (button_size.y + button_gap) * 3.0, button_size)
	position_touch_button(touch_target_button, cluster_left + button_size.x + button_gap, top_row_y + (button_size.y + button_gap) * 3.0, button_size)


func position_touch_button(button: Button, x: float, y: float, size: Vector2) -> void:
	if button == null:
		return
	button.position = Vector2(x, y)
	button.size = size
	button.custom_minimum_size = size


func _on_touch_fire_down() -> void:
	touch_fire_held = true
	note_player_activity()


func _on_touch_fire_up() -> void:
	touch_fire_held = false


func _on_touch_boost_down() -> void:
	player.call("set_touch_boost", true)
	note_player_activity()


func _on_touch_boost_up() -> void:
	player.call("set_touch_boost", false)


func _on_touch_ap_pressed() -> void:
	note_player_activity()
	toggle_autopilot()


func _on_touch_camera_pressed() -> void:
	note_player_activity()
	toggle_camera_mode()


func _on_touch_dock_pressed() -> void:
	note_player_activity()
	if nearby_station != null:
		dock_at_station(nearby_station)
	else:
		update_status("No station in range.\nApproach a station halo, then tap DOCK to moor.")


func _on_touch_target_pressed() -> void:
	note_player_activity()
	cycle_autopilot_target()


func _on_touch_up_down() -> void:
	touch_vertical_axis = 1.0
	note_player_activity()


func _on_touch_up_up() -> void:
	if touch_vertical_axis > 0.0:
		touch_vertical_axis = 0.0


func _on_touch_down_down() -> void:
	touch_vertical_axis = -1.0
	note_player_activity()


func _on_touch_down_up() -> void:
	if touch_vertical_axis < 0.0:
		touch_vertical_axis = 0.0


func get_preset_name(index: int) -> String:
	match index:
		1:
			return "Neon Wireframe"
		2:
			return "Toon Combat"
		3:
			return "Hologram Drift"
		4:
			return "Cobalt Neon"
		5:
			return "Trippy Prism"
		6:
			return "Violet Pulse"
		_:
			return "Deep Space"


func set_visual_preset(index: int) -> void:
	visual_preset_index = clamp(index, 0, VISUAL_PRESET_COUNT - 1)
	apply_visual_preset()


func toggle_shaded_mode() -> void:
	shaded_mode = not shaded_mode
	apply_visual_preset()
	set_alert("Render mode: %s" % ("shaded" if shaded_mode else "wireframe"), 0.45)


func apply_visual_preset() -> void:
	if world_environment.environment == null:
		setup_visual_environment()
	edge_pass.visible = edge_shader_enabled
	update_edge_pass_theme()
	update_blur_pass_theme()
	update_attitude_indicator_theme()
	var environment := world_environment.environment
	match visual_preset_index:
		1:
			environment.background_color = Color(0.03, 0.06, 0.1)
			environment.ambient_light_color = Color(0.42, 0.84, 1.0)
			environment.ambient_light_energy = 0.52
			environment.fog_enabled = false
			environment.fog_light_color = Color(0.18, 0.54, 0.88)
			environment.fog_density = 0.0
		2:
			environment.background_color = Color(0.07, 0.06, 0.08)
			environment.ambient_light_color = Color(0.95, 0.78, 0.58)
			environment.ambient_light_energy = 0.58
			environment.fog_enabled = false
			environment.fog_light_color = Color(0.46, 0.34, 0.22)
			environment.fog_density = 0.0
		3:
			environment.background_color = Color(0.02, 0.11, 0.11)
			environment.ambient_light_color = Color(0.34, 0.95, 0.82)
			environment.ambient_light_energy = 0.5
			environment.fog_enabled = false
			environment.fog_light_color = Color(0.1, 0.66, 0.62)
			environment.fog_density = 0.0
		4:
			environment.background_color = Color(0.004, 0.03, 0.08)
			environment.ambient_light_color = Color(0.4, 0.74, 1.0)
			environment.ambient_light_energy = 0.56
			environment.fog_enabled = false
			environment.fog_light_color = Color(0.08, 0.4, 0.92)
			environment.fog_density = 0.0
		5:
			environment.background_color = Color(0.01, 0.015, 0.035)
			environment.ambient_light_color = Color(0.36, 0.72, 1.0)
			environment.ambient_light_energy = 0.5
			environment.fog_enabled = false
			environment.fog_light_color = Color(0.18, 0.54, 1.0)
			environment.fog_density = 0.0
		6:
			environment.background_color = Color(0.018, 0.008, 0.04)
			environment.ambient_light_color = Color(0.78, 0.56, 1.0)
			environment.ambient_light_energy = 0.52
			environment.fog_enabled = false
			environment.fog_light_color = Color(0.5, 0.22, 0.88)
			environment.fog_density = 0.0
		_:
			environment.background_color = Color(0.005, 0.008, 0.014)
			environment.ambient_light_color = Color(0.46, 0.52, 0.62)
			environment.ambient_light_energy = 0.44
			environment.fog_enabled = false

	environment.glow_enabled = bloom_enabled
	environment.glow_intensity = 0.92 if bloom_enabled else 0.0
	environment.glow_strength = 1.12 if bloom_enabled else 0.0
	environment.glow_bloom = 0.22 if bloom_enabled else 0.0
	var tonemap_exposure := 1.0
	if visual_preset_index == 5:
		tonemap_exposure = 1.06
	elif visual_preset_index == 6:
		tonemap_exposure = 1.08
	elif shaded_mode:
		tonemap_exposure = 1.18
	elif visual_preset_index == 1:
		tonemap_exposure = 1.1
	environment.tonemap_exposure = tonemap_exposure

	if sunlight != null:
		sunlight.visible = shaded_mode
		var sun_energy := 1.85
		if visual_preset_index == 5:
			sun_energy = 1.2
		elif visual_preset_index == 6:
			sun_energy = 1.35
		sunlight.light_energy = sun_energy if shaded_mode else 0.0

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
	var halo_radius := 1.8
	match visual_preset_index:
		1:
			tint = Color(0.38, 1.0, 0.92)
			halo_radius = 2.15
		2:
			tint = Color(1.0, 0.8, 0.34)
			halo_radius = 1.9
		3:
			tint = Color(0.34, 1.0, 0.86)
			halo_radius = 2.3
		4:
			tint = Color(0.38, 0.76, 1.0)
			halo_radius = 2.22
		5:
			tint = Color(0.16, 0.74, 1.0)
			halo_radius = 2.38
		6:
			tint = Color(0.78, 0.5, 1.0)
			halo_radius = 2.16
		_:
			tint = Color(0.84, 0.92, 1.0)
			halo_radius = 1.95
	var darken := 0.06 if shaded_mode else 0.08
	var mode_threshold := 0.16 + edge_strength_scale * (0.22 if shaded_mode else 0.12)
	var mode_strength := 0.74 + edge_threshold * (0.9 if shaded_mode else 0.42 + wire_shader_scale * 0.22)
	var mode_glow := 0.14 + edge_glow_scale * (0.95 if shaded_mode else 0.32 + wire_shader_scale * 0.18)
	if visual_preset_index == 5:
		darken = 0.04 if shaded_mode else 0.05
		mode_threshold = 0.12 + edge_strength_scale * (0.18 if shaded_mode else 0.09)
		mode_strength += 0.1
		mode_glow += 0.08
	edge_material.set_shader_parameter("effect_mode", shader_mode_index)
	edge_material.set_shader_parameter("edge_tint", Vector3(tint.r, tint.g, tint.b))
	edge_material.set_shader_parameter("threshold", mode_threshold)
	edge_material.set_shader_parameter("strength", mode_strength)
	edge_material.set_shader_parameter("glow_strength", mode_glow)
	edge_material.set_shader_parameter("halo_radius", halo_radius)
	edge_material.set_shader_parameter("darken", darken)
	edge_material.set_shader_parameter("aux_mix", blur_strength_scale)


func update_blur_pass_theme() -> void:
	var blur_material := blur_pass.material
	if not (blur_material is ShaderMaterial):
		return
	var tint := Color(0.06, 0.11, 0.18, 0.26)
	match visual_preset_index:
		1:
			tint = Color(0.08, 0.24, 0.28, 0.1)
		2:
			tint = Color(0.22, 0.15, 0.08, 0.08)
		3:
			tint = Color(0.05, 0.22, 0.18, 0.1)
		4:
			tint = Color(0.04, 0.14, 0.32, 0.1)
		5:
			tint = Color(0.02, 0.08, 0.2, 0.08)
		6:
			tint = Color(0.12, 0.06, 0.22, 0.1)
		_:
			tint = Color(0.08, 0.12, 0.2, 0.08)
	blur_material.set_shader_parameter("fog_density", blur_strength_scale * 0.18)
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
	if mesh == null or not is_instance_valid(mesh):
		return
	var role := str(mesh.get_meta("style_role", "world"))
	var base_color: Color = mesh.get_meta("style_base_color", Color.WHITE)
	var render_variant := str(mesh.get_meta("render_variant", "both"))
	mesh.visible = true
	if render_variant == "solid":
		mesh.visible = shaded_mode
	elif render_variant == "wire":
		mesh.visible = not shaded_mode
	if inspector_solo_mode and inspector_selected_subject != null and is_instance_valid(inspector_selected_subject):
		mesh.visible = mesh.visible and inspector_selected_subject.is_ancestor_of(mesh)
	if bool(mesh.get_meta("debug_hidden", false)):
		mesh.visible = false
		return
	if bool(mesh.get_meta("debug_force_trippy", false)):
		mesh.material_override = build_trippy_style_material(role, resolve_style_color(role, base_color), render_variant)
		return
	mesh.material_override = build_style_material(role, base_color, render_variant)


func apply_label_style(label: Label3D) -> void:
	var role := str(label.get_meta("style_role", "label"))
	var base_color: Color = label.get_meta("style_base_color", Color.WHITE)
	label.modulate = resolve_style_color(role, base_color)


func build_style_material(role: String, base_color: Color, render_variant: String = "both") -> Material:
	var material := StandardMaterial3D.new()
	var color := resolve_style_color(role, base_color)
	material.albedo_color = color
	var is_shaded_solid := shaded_mode and render_variant == "solid"
	if role == "star":
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.emission_enabled = true
		material.emission = color * (2.8 if shaded_mode else 1.85)
		if render_variant == "solid":
			material.cull_mode = BaseMaterial3D.CULL_BACK
			material.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_OPAQUE_ONLY
			material.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
			material.albedo_color = color.lerp(Color(1.0, 0.72, 0.18), 0.18)
		return material
	if visual_preset_index == 5 and role in ["world", "player", "enemy", "target", "station", "danger", "objective", "dock"]:
		return build_trippy_style_material(role, color, render_variant)
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
		var line_boost := 1.06
		match visual_preset_index:
			1:
				line_boost = 1.22
			2:
				line_boost = 1.14
			3:
				line_boost = 1.26
			4:
				line_boost = 1.18
			5:
				line_boost = 1.16
			_:
				line_boost = 1.08
		material.emission = color * line_boost
	if color.a < 0.99 and not is_shaded_solid:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if visual_preset_index == 3 and role not in ["enemy", "danger"] and not is_shaded_solid:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.albedo_color.a = 0.72 if shaded_mode else 0.58
	return material


func build_trippy_style_material(role: String, color: Color, render_variant: String) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = TRIPPY_SURFACE_SHADER
	var accent := color.lerp(Color(0.04, 0.68, 1.0, color.a), 0.48)
	if role in ["enemy", "danger"]:
		accent = color.lerp(Color(0.36, 0.96, 1.0, color.a), 0.24)
	elif role in ["objective", "dock", "target"]:
		accent = color.lerp(Color(0.82, 1.0, 1.0, color.a), 0.34)
	var is_wire := not shaded_mode or render_variant == "wire"
	var pulse := 0.54
	var glow := 1.05
	if role in ["enemy", "danger"]:
		pulse = 0.72
		glow = 1.2
	elif role in ["objective", "dock", "target"]:
		pulse = 0.64
		glow = 1.14
	material.set_shader_parameter("base_color", color)
	material.set_shader_parameter("accent_color", accent)
	material.set_shader_parameter("pulse_strength", pulse)
	material.set_shader_parameter("glow_strength", glow)
	material.set_shader_parameter("pattern_scale", 0.05 if is_wire else 0.03)
	material.set_shader_parameter("rim_strength", 1.1 if is_wire else 0.82)
	material.set_shader_parameter("wire_mix", 1.0 if is_wire else 0.0)
	material.set_shader_parameter("alpha_strength", 0.96 if is_wire else 1.0)
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
		4:
			if role in ["enemy", "danger", "alert"]:
				return Color(1.0, 0.54, 0.4)
			if role in ["target", "objective", "dock"]:
				return Color(0.54, 0.84, 1.0)
			if role == "lane":
				return base_color.lerp(Color(0.46, 0.76, 1.0, base_color.a), 0.18)
			return base_color.lerp(Color(0.42, 0.72, 1.0), 0.26)
		5:
			if role in ["enemy", "danger", "alert"]:
				return Color(0.68, 0.96, 1.0)
			if role in ["target", "objective", "dock"]:
				return Color(0.86, 0.98, 1.0)
			if role == "lane":
				return base_color.lerp(Color(0.48, 0.88, 1.0, base_color.a), 0.24)
			return base_color.lerp(Color(0.34, 0.76, 1.0), 0.34)
		6:
			if role in ["enemy", "danger", "alert"]:
				return Color(1.0, 0.48, 0.82)
			if role in ["target", "objective", "dock"]:
				return Color(0.9, 0.72, 1.0)
			if role == "lane":
				return base_color.lerp(Color(0.74, 0.58, 1.0, base_color.a), 0.22)
			return base_color.lerp(Color(0.72, 0.46, 1.0), 0.3)
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
		4:
			hud_color = Color(0.78, 0.9, 1.0)
			accent_color = Color(0.4, 0.72, 1.0)
			alert_color = Color(1.0, 0.58, 0.44)
		5:
			hud_color = Color(0.78, 0.92, 1.0)
			accent_color = Color(0.24, 0.74, 1.0)
			alert_color = Color(0.76, 0.98, 1.0)
		6:
			hud_color = Color(0.94, 0.84, 1.0)
			accent_color = Color(0.74, 0.46, 1.0)
			alert_color = Color(1.0, 0.54, 0.82)
		_:
			hud_color = Color(0.84, 0.9, 1.0)
			accent_color = Color(0.96, 0.98, 1.0)
			alert_color = Color(1.0, 0.5, 0.45)
	apply_panel_styles(hud_color, accent_color, alert_color)
	title_label.modulate = accent_color
	cinematic_top_bar.color = Color(accent_color.r, accent_color.g, accent_color.b, 0.22)
	cinematic_bottom_bar.color = Color(accent_color.r, accent_color.g, accent_color.b, 0.22)
	top_frame.modulate = Color(accent_color.r, accent_color.g, accent_color.b, 0.98)
	attitude_frame.modulate = Color(accent_color.r, accent_color.g, accent_color.b, 0.98)
	left_frame.modulate = Color(accent_color.r, accent_color.g, accent_color.b, 0.98)
	right_frame.modulate = Color(accent_color.r, accent_color.g, accent_color.b, 0.98)
	message_frame.modulate = Color(hud_color.r, hud_color.g, hud_color.b, 0.98)
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
	build_value.modulate = accent_color
	message_value.modulate = hud_color
	alert_value.modulate = accent_color
	hit_value.modulate = hud_color
	hull_bar.modulate = accent_color
	shield_bar.modulate = hud_color
	reticle.modulate = accent_color
	cockpit_mode_label.modulate = accent_color
	cockpit_overlay.modulate = Color(accent_color.r, accent_color.g, accent_color.b, 0.98)
	pause_card.modulate = Color(accent_color.r, accent_color.g, accent_color.b, 0.98)
	pause_label.modulate = hud_color
	start_card.modulate = Color(accent_color.r, accent_color.g, accent_color.b, 0.98)
	start_label.modulate = accent_color
	start_sub_label.modulate = hud_color
	start_status_label.modulate = hud_color
	start_hint_label.modulate = accent_color
	start_progress_bar.modulate = Color(accent_color.r, accent_color.g, accent_color.b, 0.98)
	settings_panel.modulate = Color(hud_color.r, hud_color.g, hud_color.b, 0.95)
	controls_panel.modulate = Color(hud_color.r, hud_color.g, hud_color.b, 0.96)
	shader_panel.modulate = Color(hud_color.r, hud_color.g, hud_color.b, 0.96)
	if inspector_panel != null:
		inspector_panel.modulate = Color(hud_color.r, hud_color.g, hud_color.b, 0.96)
	settings_title.modulate = accent_color
	display_group.modulate = Color(hud_color.r, hud_color.g, hud_color.b, 0.94)
	audio_group.modulate = Color(hud_color.r, hud_color.g, hud_color.b, 0.94)
	flight_group.modulate = Color(hud_color.r, hud_color.g, hud_color.b, 0.94)
	render_group.modulate = Color(hud_color.r, hud_color.g, hud_color.b, 0.94)
	display_group_title.modulate = accent_color
	audio_group_title.modulate = accent_color
	flight_group_title.modulate = accent_color
	render_group_title.modulate = accent_color
	combat_title.modulate = accent_color
	controls_title.modulate = accent_color
	controls_keyboard_label.modulate = accent_color
	controls_controller_label.modulate = accent_color
	controls_keyboard_text.modulate = hud_color
	controls_controller_text.modulate = hud_color
	controls_hint.modulate = accent_color
	shader_title.modulate = accent_color
	if inspector_title != null:
		inspector_title.modulate = accent_color
	if inspector_hint != null:
		inspector_hint.modulate = accent_color
	if inspector_object_name != null:
		inspector_object_name.modulate = accent_color
	if inspector_object_info != null:
		inspector_object_info.modulate = hud_color
	post_fx_value.modulate = hud_color
	blur_fx_value.modulate = hud_color
	attitude_shader_value.modulate = hud_color
	shader_hint.modulate = accent_color
	preset_value.modulate = hud_color
	bloom_value.modulate = hud_color
	music_value.modulate = hud_color
	sfx_value.modulate = hud_color
	trail_value.modulate = hud_color
	guidance_value.modulate = hud_color
	invert_y_value.modulate = hud_color
	physics_mode_value.modulate = hud_color
	edge_threshold_value.modulate = hud_color
	edge_strength_value.modulate = hud_color
	edge_glow_value.modulate = hud_color
	glow_amount_value.modulate = hud_color
	blur_amount_value.modulate = hud_color
	shader_aux_value.modulate = hud_color
	settings_hint.modulate = accent_color
	settings_hotkeys.modulate = hud_color
	if tactical_map != null and is_instance_valid(tactical_map):
		tactical_map.call("set_theme_colors", hud_color, accent_color, alert_color)
	apply_button_styles(hud_color, accent_color, alert_color)
	apply_slider_theme(hud_color, accent_color)
	start_progress_frame.add_theme_stylebox_override("panel", make_panel_stylebox(Color(0.04, 0.06, 0.09, 0.84), accent_color, 10))
	start_progress_bar.add_theme_stylebox_override("background", make_bar_stylebox(Color(0.08, 0.11, 0.16, 0.96), hud_color.darkened(0.55)))
	start_progress_bar.add_theme_stylebox_override("fill", make_bar_stylebox(Color(hud_color.r * 0.78, hud_color.g * 0.96, 1.0, 0.98), accent_color))


func apply_panel_styles(hud_color: Color, accent_color: Color, alert_color: Color) -> void:
	top_frame.add_theme_stylebox_override("panel", make_panel_stylebox(Color(0.02, 0.03, 0.05, 0.8), accent_color, 18))
	attitude_frame.add_theme_stylebox_override("panel", make_panel_stylebox(Color(0.03, 0.05, 0.08, 0.82), accent_color, 22))
	left_frame.add_theme_stylebox_override("panel", make_panel_stylebox(Color(0.03, 0.05, 0.08, 0.76), accent_color, 20))
	right_frame.add_theme_stylebox_override("panel", make_panel_stylebox(Color(0.03, 0.05, 0.08, 0.76), accent_color, 20))
	message_frame.add_theme_stylebox_override("panel", make_panel_stylebox(Color(0.02, 0.03, 0.05, 0.82), hud_color, 18))
	settings_panel.add_theme_stylebox_override("panel", make_panel_stylebox(Color(0.02, 0.03, 0.05, 0.88), accent_color, 16))
	display_group.add_theme_stylebox_override("panel", make_panel_stylebox(Color(0.04, 0.06, 0.09, 0.7), hud_color, 14))
	audio_group.add_theme_stylebox_override("panel", make_panel_stylebox(Color(0.04, 0.06, 0.09, 0.7), hud_color, 14))
	flight_group.add_theme_stylebox_override("panel", make_panel_stylebox(Color(0.04, 0.06, 0.09, 0.7), hud_color, 14))
	render_group.add_theme_stylebox_override("panel", make_panel_stylebox(Color(0.04, 0.06, 0.09, 0.7), hud_color, 14))
	controls_panel.add_theme_stylebox_override("panel", make_panel_stylebox(Color(0.02, 0.03, 0.05, 0.94), accent_color, 22))
	shader_panel.add_theme_stylebox_override("panel", make_panel_stylebox(Color(0.02, 0.03, 0.05, 0.94), accent_color, 18))
	if inspector_panel != null:
		inspector_panel.add_theme_stylebox_override("panel", make_panel_stylebox(Color(0.02, 0.03, 0.05, 0.94), accent_color, 18))
	pause_card.add_theme_stylebox_override("panel", make_panel_stylebox(Color(0.02, 0.03, 0.05, 0.9), accent_color, 24))
	start_card.add_theme_stylebox_override("panel", make_panel_stylebox(Color(0.02, 0.03, 0.05, 0.9), accent_color, 28))

	hull_bar.add_theme_stylebox_override("background", make_bar_stylebox(Color(0.1, 0.13, 0.18, 0.92), hud_color.darkened(0.55)))
	hull_bar.add_theme_stylebox_override("fill", make_bar_stylebox(Color(alert_color.r, alert_color.g * 0.85, alert_color.b * 0.85, 0.98), accent_color))
	shield_bar.add_theme_stylebox_override("background", make_bar_stylebox(Color(0.08, 0.11, 0.16, 0.92), hud_color.darkened(0.55)))
	shield_bar.add_theme_stylebox_override("fill", make_bar_stylebox(Color(hud_color.r * 0.72, hud_color.g * 0.9, 1.0, 0.98), accent_color))
	apply_touch_control_styles(hud_color, accent_color, alert_color)


func apply_button_styles(hud_color: Color, accent_color: Color, alert_color: Color) -> void:
	var primary_style := make_button_stylebox(Color(0.03, 0.05, 0.08, 0.86), accent_color)
	var hot_style := make_button_stylebox(Color(0.08, 0.06, 0.06, 0.9), alert_color)
	for button in [
		controls_button,
			controls_close_button,
			inspector_button,
			inspector_close_button,
		inspector_screen_fx_button,
		inspector_blur_button,
		inspector_bloom_button,
		inspector_solo_button,
		inspector_trippy_button,
		inspector_reset_button,
		shader_button,
		shader_close_button,
		post_fx_button,
		blur_fx_button,
		attitude_shader_button,
		help_button,
		settings_button,
		fullscreen_button,
		display_tab_button,
		audio_tab_button,
		flight_tab_button,
		render_tab_button,
		preset_prev_button,
		preset_next_button,
		shader_mode_option,
		render_mode_button,
		bloom_button,
		music_button,
		sfx_button,
		trail_button,
		guidance_button,
			invert_y_button,
			physics_mode_button
		]:
		if button == null:
			continue
		button.add_theme_stylebox_override("normal", primary_style)
		button.add_theme_stylebox_override("hover", make_button_stylebox(Color(0.07, 0.09, 0.13, 0.96), accent_color.lightened(0.1)))
		button.add_theme_stylebox_override("pressed", make_button_stylebox(Color(0.12, 0.15, 0.2, 0.98), accent_color))
		button.add_theme_stylebox_override("disabled", make_button_stylebox(Color(0.12, 0.15, 0.2, 0.98), accent_color))
		button.add_theme_color_override("font_color", accent_color)
		button.add_theme_color_override("font_hover_color", Color.WHITE)
		button.add_theme_color_override("font_pressed_color", Color.WHITE)
		button.add_theme_color_override("font_disabled_color", Color.WHITE)
		button.add_theme_font_size_override("font_size", 18)
	for button in [display_tab_button, audio_tab_button, flight_tab_button, render_tab_button]:
		if button == null:
			continue
		button.add_theme_font_size_override("font_size", 13)
	debug_save_defaults_button.add_theme_stylebox_override("normal", hot_style)
	debug_save_defaults_button.add_theme_stylebox_override("hover", make_button_stylebox(Color(0.12, 0.08, 0.08, 0.94), alert_color.lightened(0.12)))
	debug_save_defaults_button.add_theme_stylebox_override("pressed", make_button_stylebox(Color(0.16, 0.1, 0.1, 0.98), alert_color))
	debug_save_defaults_button.add_theme_color_override("font_color", alert_color)
	debug_save_defaults_button.add_theme_color_override("font_hover_color", Color.WHITE)
	debug_save_defaults_button.add_theme_color_override("font_pressed_color", Color.WHITE)
	debug_save_defaults_button.add_theme_font_size_override("font_size", 18)
	for button in [
		touch_fire_button,
		touch_boost_button,
		touch_ap_button,
		touch_camera_button,
		touch_dock_button,
		touch_target_button,
		touch_up_button,
		touch_down_button
	]:
		if button == null:
			continue
		button.add_theme_stylebox_override("normal", primary_style)
		button.add_theme_stylebox_override("hover", make_button_stylebox(Color(0.07, 0.09, 0.13, 0.96), accent_color.lightened(0.1)))
		button.add_theme_stylebox_override("pressed", make_button_stylebox(Color(0.12, 0.15, 0.2, 0.98), accent_color))
		button.add_theme_color_override("font_color", accent_color)
		button.add_theme_color_override("font_hover_color", Color.WHITE)
		button.add_theme_color_override("font_pressed_color", Color.WHITE)
		button.add_theme_font_size_override("font_size", 22)


func apply_touch_control_styles(hud_color: Color, accent_color: Color, alert_color: Color) -> void:
	for pad in [touch_move_pad, touch_look_pad]:
		if pad == null:
			continue
		pad.add_theme_stylebox_override("panel", make_panel_stylebox(Color(0.03, 0.05, 0.08, 0.38), accent_color, 999))
		var label := pad.get_node_or_null("Label") as Label
		if label != null:
			label.modulate = accent_color
			label.add_theme_font_size_override("font_size", 18)
	if touch_move_knob != null:
		touch_move_knob.color = Color(accent_color.r, accent_color.g, accent_color.b, 0.28)
	if touch_look_knob != null:
		touch_look_knob.color = Color(hud_color.r, hud_color.g, hud_color.b, 0.24)
	if touch_fire_button != null:
		touch_fire_button.add_theme_stylebox_override("normal", make_button_stylebox(Color(0.14, 0.07, 0.06, 0.94), alert_color))
		touch_fire_button.add_theme_stylebox_override("hover", make_button_stylebox(Color(0.18, 0.09, 0.08, 0.98), alert_color.lightened(0.08)))
		touch_fire_button.add_theme_stylebox_override("pressed", make_button_stylebox(Color(0.24, 0.11, 0.09, 0.98), alert_color))
		touch_fire_button.add_theme_color_override("font_color", alert_color)


func apply_slider_theme(hud_color: Color, accent_color: Color) -> void:
	for slider in [
		music_slider,
		sfx_slider,
		edge_threshold_slider,
		edge_strength_slider,
		edge_glow_slider,
		blur_amount_slider,
		shader_aux_slider
	]:
		if slider == null:
			continue
		slider.modulate = Color(accent_color.r, accent_color.g, accent_color.b, 0.96)


func make_panel_stylebox(background: Color, border: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(2)
	style.anti_aliasing = true
	style.anti_aliasing_size = 1.2
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_right = radius
	style.corner_radius_bottom_left = radius
	style.content_margin_left = 10.0
	style.content_margin_top = 8.0
	style.content_margin_right = 10.0
	style.content_margin_bottom = 8.0
	style.shadow_color = Color(0, 0, 0, 0.0)
	style.shadow_size = 0
	return style


func make_bar_stylebox(background: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(1)
	style.anti_aliasing = true
	style.anti_aliasing_size = 1.1
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left = 8
	return style


func make_button_stylebox(background: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(2)
	style.anti_aliasing = true
	style.anti_aliasing_size = 1.1
	style.corner_radius_top_left = 14
	style.corner_radius_top_right = 14
	style.corner_radius_bottom_right = 14
	style.corner_radius_bottom_left = 14
	style.content_margin_left = 8.0
	style.content_margin_top = 4.0
	style.content_margin_right = 8.0
	style.content_margin_bottom = 4.0
	style.shadow_color = Color(0, 0, 0, 0.0)
	style.shadow_size = 0
	return style


func _on_preset_prev_pressed() -> void:
	set_visual_preset((visual_preset_index + VISUAL_PRESET_COUNT - 1) % VISUAL_PRESET_COUNT)


func _on_preset_next_pressed() -> void:
	set_visual_preset((visual_preset_index + 1) % VISUAL_PRESET_COUNT)


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


func _on_shader_mode_selected(index: int) -> void:
	shader_mode_index = index
	update_edge_pass_theme()
	update_settings_label()


func _on_edge_threshold_slider_changed(value: float) -> void:
	edge_threshold = clamp(value / 100.0, 0.0, 1.0)
	update_edge_pass_theme()


func _on_edge_strength_slider_changed(value: float) -> void:
	edge_strength_scale = clamp(value / 100.0, 0.0, 1.0)
	update_edge_pass_theme()


func _on_edge_glow_slider_changed(value: float) -> void:
	edge_glow_scale = clamp(value / 100.0, 0.0, 1.0)
	update_edge_pass_theme()


func _on_blur_amount_slider_changed(value: float) -> void:
	wire_shader_scale = clamp(value / 100.0, 0.0, 1.0)
	update_edge_pass_theme()


func _on_shader_aux_slider_changed(value: float) -> void:
	blur_strength_scale = clamp(value / 100.0, 0.0, 1.0)
	update_edge_pass_theme()
	update_blur_pass_theme()


func toggle_bloom() -> void:
	bloom_enabled = not bloom_enabled
	apply_visual_preset()
	update_inspector_panel_labels()


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
	settings_title.text = "Settings"
	controls_title.text = "Keyboard + Controller"
	apply_settings_tab_visibility()
	preset_value.text = "Theme: %s / %s" % [get_preset_name(visual_preset_index), "Shaded" if shaded_mode else "Wireframe"]
	bloom_value.text = "Bloom: %s" % ("On" if bloom_enabled else "Off")
	music_value.text = "Music: %s (%d%%)" % ["On" if music_enabled else "Off", int(round(music_volume * 100.0))]
	sfx_value.text = "SFX: %s (%d%%)" % ["On" if sfx_enabled else "Off", int(round(sfx_volume * 100.0))]
	trail_value.text = "Trail: %s" % ("On" if trail_active else "Off")
	guidance_value.text = "Guidance: %s" % ("On" if objective_guidance_enabled else "Off")
	invert_y_value.text = "Invert Y: %s" % ("On" if invert_y_axis else "Off")
	physics_mode_value.text = "Flight Mode: %s" % flight_physics_mode.capitalize()
	preset_prev_button.text = "Prev"
	preset_next_button.text = "Next"
	render_mode_button.text = "Mode"
	bloom_button.text = "Toggle"
	music_button.text = "Toggle"
	sfx_button.text = "Toggle"
	trail_button.text = "Toggle"
	guidance_button.text = "Toggle"
	invert_y_button.text = "Toggle"
	physics_mode_button.text = "Cycle"
	settings_hint.text = "Use ? or H for controls help. Use FX for shader experiments."
	settings_hotkeys.text = "Quick actions: Tab views, V reset, J autopilot, E dock, Esc pause\nRender: \\ mode, B bloom, 1-7 themes, mouse wheel zoom"
	controls_keyboard_text.text = "Flight\nArrow keys  steer / pitch\nW A S D  move\nR / F  rise / descend\nQ / Z  roll\nShift  boost\nSpace  fire\n\nView\nTab  cycle camera\nV  reset view\n\nSystems\nE  dock\nJ  autopilot\nT  trail\nG  guidance\nB  bloom\nP  flight mode\nC  hail comms\nH / ?  controls\nEsc  pause"
	controls_controller_text.text = "Flight\nLeft stick  steer / pitch\nRT / LT  thrust / reverse\nA  fire / launch\n\nView\nRight stick  camera look\nY  cycle camera\nR3  reset view\n\nSystems\nX  cycle AP target\nD-pad Right  autopilot\nD-pad Down  trail\nL3  guidance\nB  render mode\nBack  controls/settings panels\nStart  pause"
	controls_hint.text = "Close with Esc, H, ?, Back, or the Close button."
	if abs(music_slider.value - music_volume * 100.0) > 0.5:
		music_slider.value = music_volume * 100.0
	if abs(sfx_slider.value - sfx_volume * 100.0) > 0.5:
		sfx_slider.value = sfx_volume * 100.0
	update_shader_panel_labels()


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
	if not help_panel_seen:
		help_panel_autoshow_timer = 5.0
	else:
		help_panel_autoshow_timer = -1.0
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
	update_touch_controls_visibility()


func toggle_pause() -> void:
	if game_over_state or start_screen_active:
		return
	if autopilot_active and not paused:
		cancel_autopilot()
	paused = not paused
	player.call("set_control_lock", paused)
	pause_card.visible = paused
	pause_label.visible = paused
	if paused:
		var ship_basis: Basis = player.call("get_visual_basis")
		var ship_back: Vector3 = ship_basis.z.normalized()
		pause_camera_time = 0.0
		pause_camera_yaw = atan2(ship_back.x, ship_back.z)
		pause_camera_pitch = -0.18 if camera_mode == 2 else clamp(orbit_pitch, -0.34, -0.1)
		pause_camera_distance = 24.0 if camera_mode == 2 else max(orbit_distance + 4.0, 20.0)
		pause_camera_blend = 1.0
		cinematic_blend = 1.0
		cinematic_mode_active = false
		pause_label.text = "Paused\nPress Esc to resume"
		title_label.text = "Paused"
	else:
		pause_camera_blend = 0.0
		title_label.text = "Wireframe System"
	update_cinematic_overlay()
	update_camera(0.0)
	update_mouse_mode()
	update_touch_controls_visibility()


func update_pause_camera(delta: float) -> void:
	var target_blend: float = 1.0 if paused else 0.0
	var blend_speed: float = 1.8 if paused else 3.2
	pause_camera_blend = move_toward(pause_camera_blend, target_blend, delta * blend_speed)
	if paused:
		var pause_time_scale := 0.62 if start_screen_active else 1.0
		pause_camera_time += delta * pause_time_scale
	if not paused and pause_camera_blend <= 0.001:
		pause_camera_time = 0.0


func toggle_settings_panel() -> void:
	if controls_visible:
		controls_visible = false
		controls_panel.visible = false
	if shader_panel_visible:
		shader_panel_visible = false
		shader_panel.visible = false
	if inspector_visible:
		inspector_visible = false
		if inspector_panel != null:
			inspector_panel.visible = false
	settings_visible = not settings_visible
	settings_panel.visible = settings_visible
	if settings_visible:
		update_settings_label()
		settings_label_refresh_timer = 0.12
	update_overlay_button_visibility()
	call_deferred("refresh_mouse_mode_after_ui_toggle")
	update_touch_controls_visibility()


func toggle_controls_panel() -> void:
	if settings_visible:
		settings_visible = false
		settings_panel.visible = false
	if shader_panel_visible:
		shader_panel_visible = false
		shader_panel.visible = false
	if inspector_visible:
		inspector_visible = false
		if inspector_panel != null:
			inspector_panel.visible = false
	controls_visible = not controls_visible
	controls_panel.visible = controls_visible
	update_overlay_button_visibility()
	call_deferred("refresh_mouse_mode_after_ui_toggle")
	update_touch_controls_visibility()


func toggle_shader_panel() -> void:
	if controls_visible:
		controls_visible = false
		controls_panel.visible = false
	if inspector_visible:
		inspector_visible = false
		if inspector_panel != null:
			inspector_panel.visible = false
	shader_panel_visible = not shader_panel_visible
	shader_panel.visible = shader_panel_visible
	update_overlay_button_visibility()
	call_deferred("refresh_mouse_mode_after_ui_toggle")
	update_touch_controls_visibility()


func toggle_inspector_panel() -> void:
	if controls_visible:
		controls_visible = false
		controls_panel.visible = false
	if shader_panel_visible:
		shader_panel_visible = false
		shader_panel.visible = false
	inspector_visible = not inspector_visible
	if inspector_panel != null:
		inspector_panel.visible = inspector_visible
	if inspector_visible:
		update_inspector_panel_labels()
	update_overlay_button_visibility()
	call_deferred("refresh_mouse_mode_after_ui_toggle")
	update_touch_controls_visibility()


func update_boot_screen(delta: float) -> void:
	if not start_screen_active:
		return
	boot_screen_time += delta
	var progress: float = min(18.0 + boot_screen_time * 26.0, 100.0)
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


func cycle_autopilot_target() -> void:
	if station_order.is_empty():
		set_alert("No AP targets", 0.35)
		return
	var current_station := get_target_station()
	var start_index := 0
	if current_station != null:
		start_index = maxi(station_order.find(current_station), 0)
	var next_station: Area3D = null
	for step in range(1, station_order.size() + 1):
		var candidate: Area3D = station_order[(start_index + step) % station_order.size()]
		if candidate == null or not is_instance_valid(candidate):
			continue
		next_station = candidate
		break
	if next_station == null:
		set_alert("No AP targets", 0.35)
		return
	selected_target_station_name = str(next_station.get_meta("station_name"))
	objective_flash_time = 0.4
	var planet_name := str(next_station.get_meta("planet_name"))
	set_alert("Target: %s" % selected_target_station_name, 0.35)
	update_status("Autopilot target cycled.\n%s selected%s." % [
		selected_target_station_name,
		"" if planet_name.is_empty() else " in %s orbit" % planet_name
	])


func engage_autopilot(target_station: Area3D) -> void:
	autopilot_active = true
	autopilot_state = "arm"
	autopilot_station = target_station
	autopilot_timer = 0.0
	autopilot_fx_timer = 0.0
	autopilot_doppler_rate = 0.24
	autopilot_doppler_mix = 0.16
	autopilot_comms_stage = 0
	autopilot_rate_status_band = -1
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
	autopilot_doppler_rate = 0.0
	autopilot_doppler_mix = 0.0
	autopilot_comms_stage = 0
	autopilot_rate_status_band = -1
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
	return lerp(0.08, 0.72, pow(closeness, 1.45))


func compute_autopilot_ring_interval(distance_to_target: float, reference_distance: float) -> float:
	var far_distance: float = max(reference_distance * 1.9, 220.0)
	var near_distance: float = max(reference_distance * 0.08, 18.0)
	var closeness: float = clamp(inverse_lerp(far_distance, near_distance, distance_to_target), 0.0, 1.0)
	return lerp(1.45, 0.34, pow(closeness, 1.2))


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
	var target_doppler_rate := 0.24
	var target_doppler_mix := 0.14

	match autopilot_state:
		"arm":
			target_doppler_rate = 0.22
			target_doppler_mix = 0.14
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
			target_doppler_rate = 0.34
			target_doppler_mix = 0.16
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
			target_doppler_rate = ring_rate
			target_doppler_mix = lerp(0.12, 0.28, clamp(inverse_lerp(0.18, 1.4, ring_rate), 0.0, 1.0))
			maybe_report_autopilot_rate_status(get_target_closing_rate(autopilot_station))
			maybe_play_autopilot_station_comms("approach", distance_to_approach, approach_distance)
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
			target_doppler_rate = ring_rate * 1.06
			target_doppler_mix = lerp(0.14, 0.33, clamp(inverse_lerp(0.18, 1.45, target_doppler_rate), 0.0, 1.0))
			maybe_report_autopilot_rate_status(get_target_closing_rate(autopilot_station))
			maybe_play_autopilot_station_comms("align", distance_to_align, align_distance)
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
			target_doppler_rate = 0.96
			target_doppler_mix = 0.18
			maybe_play_autopilot_station_comms("dock", player.global_position.distance_to(dock_point), max(dock_offset.length(), 1.0))
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
			target_doppler_rate = 0.12
			target_doppler_mix = 0.06
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
			target_doppler_rate = lerp(0.34, 0.92, eased)
			target_doppler_mix = lerp(0.08, 0.2, eased)
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
				autopilot_doppler_rate = 0.0
				autopilot_doppler_mix = 0.0
				autopilot_comms_stage = 0
				autopilot_rate_status_band = -1
				set_alert("Autopilot complete", 0.45)
				update_status("Autopilot departure complete.\nYou are clear of the dock and back on manual flight control.")
	autopilot_doppler_rate = target_doppler_rate
	autopilot_doppler_mix = target_doppler_mix
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
	if paused or start_screen_active or settings_visible or controls_visible or shader_panel_visible or inspector_visible or touch_phone_layout_active:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		return
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func refresh_mouse_mode_after_ui_toggle() -> void:
	update_mouse_mode()
	if DisplayServer.get_name() == "headless":
		return
	if paused or start_screen_active or settings_visible or controls_visible or shader_panel_visible or inspector_visible or touch_phone_layout_active:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


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
	var target_info := "Target: none"
	var target := get_primary_enemy_target()
	if target != null:
		target_info = "Target: %.0fm" % player.global_position.distance_to(target.global_position)
	var autopilot_info := "Autopilot: manual"
	if autopilot_active:
		var station_name := ""
		if autopilot_station != null and is_instance_valid(autopilot_station):
			station_name = str(autopilot_station.get_meta("station_name"))
		autopilot_info = "Autopilot: %s%s" % [get_autopilot_state_display(), "" if station_name.is_empty() else " to %s" % station_name]
	hull_bar.value = player_hull
	shield_bar.value = player_shields
	combat_label.text = "Hull %d%%  Shields %d%%\nHostiles %d  Score %d\nKills %d\n%s\n%s" % [
		int(round(player_hull)),
		int(round(player_shields)),
		enemy_nodes.size(),
		score,
		kills,
		target_info,
		autopilot_info
	]
	combat_value.text = "Hostiles: %d\nKills: %d\nScore: %d\n%s\n%s" % [
		enemy_nodes.size(),
		kills,
		score,
		target_info,
		autopilot_info
	]


func update_tactical_map() -> void:
	if tactical_map == null or not is_instance_valid(tactical_map):
		return
	var ship_basis: Basis = player.call("get_visual_basis")
	var ship_right := ship_basis.x.normalized()
	var ship_forward := -ship_basis.z.normalized()
	var player_pos := player.global_position
	var target_station := get_target_station()
	var desired_map_radius := 12000.0
	if target_station != null and is_instance_valid(target_station):
		var target_distance: float = player_pos.distance_to(target_station.global_position)
		desired_map_radius = clampf(target_distance * 1.3, 700.0, 12000.0)
	tactical_map_radius_current = move_toward(tactical_map_radius_current, desired_map_radius, max(600.0, abs(desired_map_radius - tactical_map_radius_current) * 0.18))
	var map_radius: float = tactical_map_radius_current
	var station_markers: Array[Dictionary] = []
	for station in station_order:
		if station == null or not is_instance_valid(station):
			continue
		var station_name := str(station.get_meta("station_name", ""))
		station_markers.append({
			"pos": project_world_to_tactical_map(player_pos, station.global_position, ship_right, ship_forward, map_radius),
			"target": station_name == selected_target_station_name
		})
	var hostile_markers: Array[Dictionary] = []
	for enemy in enemy_nodes:
		if enemy == null or not is_instance_valid(enemy):
			continue
		hostile_markers.append({
			"pos": project_world_to_tactical_map(player_pos, enemy.global_position, ship_right, ship_forward, map_radius)
		})
	var target_pos := Vector2.ZERO
	var has_target := false
	if target_station != null and is_instance_valid(target_station):
		target_pos = project_world_to_tactical_map(player_pos, target_station.global_position, ship_right, ship_forward, map_radius)
		has_target = true
	var star_pos := Vector2.ZERO
	if star_node != null and is_instance_valid(star_node):
		star_pos = project_world_to_tactical_map(player_pos, star_node.global_position, ship_right, ship_forward, map_radius)
	tactical_map.call("set_map_data", star_pos, station_markers, hostile_markers, target_pos, has_target)


func project_world_to_tactical_map(origin: Vector3, world_pos: Vector3, ship_right: Vector3, ship_forward: Vector3, map_radius: float) -> Vector2:
	var delta := world_pos - origin
	var local := Vector2(delta.dot(ship_right), delta.dot(ship_forward))
	local /= max(map_radius, 1.0)
	if local.length() > 0.96:
		local = local.normalized() * 0.96
	return Vector2(local.x, -local.y)


func update_build_label() -> void:
	var current_fps: float = Engine.get_frames_per_second()
	if fps_display <= 0.001:
		fps_display = current_fps
	else:
		fps_display = lerp(fps_display, current_fps, 0.24)
	var version := str(BuildInfo.BUILD_LABEL)
	var runtime := "WEB" if OS.has_feature("web") else "DESKTOP"
	var build_flavor := "DBG" if OS.has_feature("debug") else "REL"
	var build_number := str(BuildInfo.BUILD_NUMBER)
	build_value.text = "%s %s  %s+%s  |  fps %d" % [runtime, build_flavor, version, build_number, int(round(fps_display))]


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
	pirate_taunt_timer = max(pirate_taunt_timer - delta, 0.0)
	for i in range(enemy_nodes.size() - 1, -1, -1):
		var enemy: Node3D = enemy_nodes[i]
		if not is_instance_valid(enemy):
			enemy_nodes.remove_at(i)
			continue

		var to_player := player.global_position - enemy.global_position
		var distance := to_player.length()
		if bool(enemy.get_meta("pirate_guard", false)):
			update_pirate_raider_behavior(enemy, delta, distance, to_player)
			continue
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


func update_pirate_raider_behavior(enemy: Node3D, delta: float, distance: float, to_player: Vector3) -> void:
	var station := enemy.get_meta("pirate_station", null) as Area3D
	if station == null or not is_instance_valid(station):
		update_enemy_ambush_patrol(enemy, delta)
		return

	var chasing := bool(enemy.get_meta("pirate_chasing", false))
	if not chasing and distance <= PIRATE_WAKE_RADIUS:
		chasing = true
		enemy.set_meta("pirate_chasing", true)
		maybe_play_pirate_taunt(enemy)
	elif chasing and distance >= PIRATE_DISENGAGE_RADIUS:
		chasing = false
		enemy.set_meta("pirate_chasing", false)

	if not chasing:
		update_pirate_raider_patrol(enemy, station, delta)
		return

	var direction := to_player.normalized() if distance > 0.001 else Vector3.FORWARD
	var lateral := Vector3(-direction.z, 0, direction.x) * float(enemy.get_meta("orbit_bias", 0.0)) * 68.0
	var desired_velocity := direction * 168.0 + lateral
	if distance < 260.0:
		desired_velocity = -direction * 96.0 + lateral
	var velocity: Vector3 = enemy.get_meta("velocity", Vector3.ZERO)
	velocity = velocity.lerp(desired_velocity, min(delta * 1.8, 1.0))
	velocity += compute_gravity_at_position(enemy.global_position) * delta
	enemy.set_meta("velocity", velocity)
	enemy.global_position += velocity * delta
	if velocity.length() > 2.0:
		enemy.look_at(enemy.global_position + velocity.normalized(), get_safe_up_vector(velocity.normalized(), Vector3.UP), true)

	var cooldown: float = enemy.get_meta("fire_cooldown", 0.0)
	cooldown = max(cooldown - delta, 0.0)
	if distance <= ENEMY_FIRE_RADIUS and cooldown == 0.0 and not game_over_state:
		spawn_projectile(enemy.global_position - enemy.global_basis.z * 6.0, direction * ENEMY_PROJECTILE_SPEED, false)
		play_sfx("enemy_fire", -9.0)
		cooldown = randf_range(0.7, 1.4)
	enemy.set_meta("fire_cooldown", cooldown)
	if pirate_taunt_timer == 0.0 and distance < PIRATE_WAKE_RADIUS * 0.72:
		maybe_play_pirate_taunt(enemy)


func update_pirate_raider_patrol(enemy: Node3D, station: Area3D, delta: float) -> void:
	var phase: float = float(enemy.get_meta("patrol_phase", 0.0)) + delta * 0.72
	enemy.set_meta("patrol_phase", phase)
	var radius := PIRATE_PATROL_RADIUS * (0.68 + 0.22 * sin(phase * 0.7 + float(enemy.get_meta("orbit_bias", 0.0))))
	var target := station.global_position + Vector3(cos(phase) * radius, sin(phase * 0.6) * 120.0, sin(phase) * radius)
	var desired_velocity := (target - enemy.global_position).normalized() * PIRATE_PATROL_SPEED
	var velocity: Vector3 = enemy.get_meta("velocity", Vector3.ZERO)
	velocity = velocity.lerp(desired_velocity, min(delta * 1.6, 1.0))
	velocity += compute_gravity_at_position(enemy.global_position) * delta
	enemy.set_meta("velocity", velocity)
	enemy.global_position += velocity * delta
	if velocity.length() > 2.0:
		enemy.look_at(enemy.global_position + velocity.normalized(), get_safe_up_vector(velocity.normalized(), Vector3.UP), true)
	var cooldown: float = max(float(enemy.get_meta("fire_cooldown", 0.0)) - delta, 0.0)
	enemy.set_meta("fire_cooldown", cooldown)


func maybe_play_pirate_taunt(enemy: Node3D) -> void:
	if pirate_taunt_timer > 0.0:
		return
	var station := enemy.get_meta("pirate_station", null) as Area3D
	var station_name := "somewhere disreputable"
	if station != null and is_instance_valid(station):
		station_name = str(station.get_meta("station_name", station_name))
	var pirate_name := str(enemy.get_meta("pirate_name", enemy.name))
	play_radio_message(pirate_name, get_random_pirate_taunt(station_name), "comms_hauler", -11.0)
	reset_pirate_taunt_timer()


func reset_pirate_taunt_timer() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	pirate_taunt_timer = rng.randf_range(PIRATE_TAUNT_MIN_INTERVAL, PIRATE_TAUNT_MAX_INTERVAL)


func get_random_pirate_taunt(station_name: String) -> String:
	var taunts := [
		"Welcome to %s. Kindly hand over your cargo, your fuel, and whichever brave thought brought you here." % station_name,
		"That ship looks expensive. Excellent. We adore a customer who arrives pre-looted.",
		"Easy now, hero. We only want your money, your pride, and maybe the shiny bit bolted to the left side.",
		"Turn around and we'll only mock your flying. Keep coming and we'll have to become proactive.",
		"You've wandered into pirate space, which is like normal space but with more initiative and worse bookkeeping.",
		"Stand by for a complimentary weapons inspection. If anything survives, we'll inspect it twice.",
		"Lovely silhouette on your ship. Shame if it acquired ventilation.",
		"We clocked you from half an orbit away. You fly like a tax refund trying to escape customs."
	]
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	return taunts[rng.randi_range(0, taunts.size() - 1)]


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
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var tracks := get_radio_tracks()
	radio_start_track_index = rng.randi_range(0, tracks.size() - 1)
	music_time = radio_start_track_index * RADIO_TRACK_DURATION + rng.randf_range(0.0, 3.0)
	music_phase_a = rng.randf_range(0.0, TAU)
	music_phase_b = rng.randf_range(0.0, TAU)
	music_phase_c = rng.randf_range(0.0, TAU)
	radio_track_index = -1
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	if OS.has_feature("web"):
		music_player.stream = build_radio_loop_stream(radio_start_track_index)
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
	sfx_streams["comms_station"] = build_station_comms_stream()
	sfx_streams["comms_news"] = build_news_comms_stream()
	sfx_streams["comms_hauler"] = build_hauler_comms_stream()
	sfx_streams["autopilot_lock"] = build_autopilot_lock_stream()
	sfx_streams["launch"] = build_launch_stream()
	autopilot_doppler_player = AudioStreamPlayer.new()
	autopilot_doppler_player.name = "AutopilotDopplerPlayer"
	autopilot_doppler_player.stream = build_autopilot_doppler_stream()
	autopilot_doppler_player.volume_db = -80.0
	autopilot_doppler_player.pitch_scale = 0.82
	add_child(autopilot_doppler_player)
	update_music_state()
	update_music_stream()
	reset_radio_chatter_timer(RADIO_CHATTER_MIN_INTERVAL * 0.55, RADIO_CHATTER_MAX_INTERVAL * 0.7)


func update_music_stream() -> void:
	if music_playback == null:
		return
	var frames_available := music_playback.get_frames_available()
	if frames_available <= 0:
		return

	var tracks := get_radio_tracks()
	var track_index := int(floor(music_time / RADIO_TRACK_DURATION)) % tracks.size()
	if track_index != radio_track_index:
		radio_track_index = track_index
		set_alert("Radio: %s" % tracks[track_index]["name"], 0.25)
	for i in range(frames_available):
		var current_track_index := int(floor(music_time / RADIO_TRACK_DURATION)) % tracks.size()
		var next_track_index := (current_track_index + 1) % tracks.size()
		var current_track: Dictionary = tracks[current_track_index]
		var next_track: Dictionary = tracks[next_track_index]
		var track_local_time := fmod(music_time, RADIO_TRACK_DURATION)
		var crossfade: float = clamp((track_local_time - (RADIO_TRACK_DURATION - RADIO_CROSSFADE_DURATION)) / RADIO_CROSSFADE_DURATION, 0.0, 1.0)
		var current_sample := generate_radio_sample(current_track, music_time)
		var next_sample := generate_radio_sample(next_track, music_time)
		var sample: float = clamp(lerp(current_sample, next_sample, crossfade), -0.55, 0.55)
		music_playback.push_frame(Vector2(sample, sample))
		music_time += 1.0 / AUDIO_MIX_RATE


func update_autopilot_doppler(delta: float) -> void:
	if autopilot_doppler_player == null:
		return
	var target_mix: float = autopilot_doppler_mix if autopilot_active and not paused and sfx_enabled else 0.0
	var target_rate: float = autopilot_doppler_rate if autopilot_active and not paused and sfx_enabled else 0.0
	autopilot_doppler_current_mix = move_toward(autopilot_doppler_current_mix, target_mix, delta * 0.45)
	autopilot_doppler_current_rate = move_toward(autopilot_doppler_current_rate, target_rate, delta * 1.6)
	if autopilot_doppler_current_mix > 0.003:
		if not autopilot_doppler_player.playing:
			autopilot_doppler_player.play()
		var normalized_rate: float = clamp(inverse_lerp(0.18, 1.45, autopilot_doppler_current_rate), 0.0, 1.0)
		autopilot_doppler_player.pitch_scale = lerp(0.74, 1.42, normalized_rate)
		var intensity: float = max(autopilot_doppler_current_mix * 0.12, 0.001)
		autopilot_doppler_player.volume_db = linear_to_db(intensity) + get_sfx_volume_offset_db() - 2.0
	else:
		autopilot_doppler_player.volume_db = -80.0
		if autopilot_doppler_player.playing:
			autopilot_doppler_player.stop()


func reset_radio_chatter_timer(minimum: float = RADIO_CHATTER_MIN_INTERVAL, maximum: float = RADIO_CHATTER_MAX_INTERVAL) -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	radio_chatter_timer = rng.randf_range(minimum, maximum)


func update_ambient_radio(delta: float) -> void:
	if start_screen_active or paused or game_over_state or not sfx_enabled:
		return
	if autopilot_active:
		radio_chatter_timer = max(radio_chatter_timer, 7.0)
		return
	radio_chatter_timer -= delta
	if radio_chatter_timer > 0.0:
		return
	broadcast_ambient_radio()
	reset_radio_chatter_timer()


func broadcast_ambient_radio() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var dispatches := [
		{"voice": "comms_news", "speaker": "Relay Nine News", "message": "Shipping bulletin: customs has again clarified that declaring contraband as 'morale equipment' remains, technically, rather illegal."},
		{"voice": "comms_news", "speaker": "Helios Late", "message": "Market watch: reactor salts are up three percent, tea is flat, and ring-toll clerks remain as chirpy as a tax audit."},
		{"voice": "comms_news", "speaker": "Cinder Evening Service", "message": "Public notice: the mayor denies rumours of pirates in civic office, which was sporting of him considering the evidence."},
		{"voice": "comms_news", "speaker": "Outer System Bulletin", "message": "Astronomy desk: the star continues to burn with vulgar competence. Experts are monitoring the situation with the usual alarm and sandwiches."}
	]
	var haulers := [
		{"voice": "comms_hauler", "speaker": "Freighter Magpie Seven", "message": "Anyone bound for Orion Gate, mind the queue. They call it express docking, which is adorable if you've not seen a calendar."},
		{"voice": "comms_hauler", "speaker": "Tug Beryl Jane", "message": "Cargo run log: thirty tonnes of machine parts, one suspicious goat, and a manifest written by an optimist."},
		{"voice": "comms_hauler", "speaker": "Hauler Distant Complaints", "message": "To the pilot shedding panels in lane three: do keep the bits attached. Some of us are trying to die of old age."},
		{"voice": "comms_hauler", "speaker": "Courier Bent Spoon", "message": "If station control asks, I've absolutely filed my approach paperwork. Whether they can find it is a theological matter."}
	]
	var chatter_pool := dispatches if rng.randf() < 0.48 else haulers
	var entry: Dictionary = chatter_pool[rng.randi_range(0, chatter_pool.size() - 1)]
	play_radio_message(str(entry["speaker"]), str(entry["message"]), str(entry["voice"]))


func play_radio_message(speaker: String, body: String, voice_name: String = "comms", volume_db: float = -15.0) -> void:
	play_sfx(voice_name, volume_db)
	update_status("%s\n%s" % [speaker, body])
	set_alert("Comms: %s" % speaker, 0.35)
	speak_radio_message(speaker, body)


func speak_radio_message(speaker: String, body: String) -> void:
	if not speech_synthesis_enabled or not OS.has_feature("web"):
		return
	var message := "%s. %s" % [speaker, body]
	var script := """
		(function() {
			if (typeof window === 'undefined' || !('speechSynthesis' in window)) {
				return false;
			}
			const text = %s;
			if (!text) {
				return false;
			}
			window.speechSynthesis.cancel();
			const utterance = new SpeechSynthesisUtterance(text);
			utterance.rate = 1.02;
			utterance.pitch = 0.92;
			utterance.volume = 0.72;
			const voices = window.speechSynthesis.getVoices();
			const preferred = voices.find((voice) => /en/i.test(voice.lang) && /samantha|ava|karen|daniel|alex/i.test(voice.name))
				|| voices.find((voice) => /en/i.test(voice.lang))
				|| null;
			if (preferred) {
				utterance.voice = preferred;
			}
			window.speechSynthesis.speak(utterance);
			return true;
		}())
	""" % js_quote(message)
	JavaScriptBridge.eval(script, true)


func js_quote(text: String) -> String:
	var escaped := text.replace("\\", "\\\\")
	escaped = escaped.replace("\"", "\\\"")
	escaped = escaped.replace("\n", "\\n")
	escaped = escaped.replace("\r", "")
	return "\"" + escaped + "\""


func maybe_play_autopilot_station_comms(stage: String, distance_to_target: float, reference_distance: float) -> void:
	if autopilot_station == null or not is_instance_valid(autopilot_station):
		return
	var station_name := str(autopilot_station.get_meta("station_name"))
	var closeness: float = clamp(inverse_lerp(max(reference_distance * 1.4, 160.0), max(reference_distance * 0.08, 18.0), distance_to_target), 0.0, 1.0)
	if stage == "approach":
		if autopilot_comms_stage < 1 and closeness > 0.18:
			autopilot_comms_stage = 1
			play_radio_message(
				"%s Approach" % station_name,
				"Station420, your corridor solution is in the box. Do try to arrive with the same number of wings you left with.",
				"comms_station",
				-13.0
			)
		elif autopilot_comms_stage < 2 and closeness > 0.62:
			autopilot_comms_stage = 2
			play_radio_message(
				"%s Approach" % station_name,
				"Range is tightening nicely. You are almost respectable. Hold the lane and we'll pretend this was all entirely intentional.",
				"comms_station",
				-13.0
			)
	elif stage == "align" and autopilot_comms_stage < 3:
		autopilot_comms_stage = 3
		play_radio_message(
			"%s Dock Control" % station_name,
			"Alignment looks tidy. Keep it there, old thing. The collar is expensive and we'd rather not test it against your paintwork.",
			"comms_station",
			-12.0
		)
	elif stage == "dock" and autopilot_comms_stage < 4:
		autopilot_comms_stage = 4
		play_radio_message(
			"%s Dock Control" % station_name,
			"Clamp sequence is green. Mind the bump. We call it character when the docking ring shudders like that.",
			"comms_station",
			-12.0
		)


func get_radio_tracks() -> Array:
	return [
		{"name": "Drift", "progression": [55.0, 82.41, 73.42, 98.0], "accent": [220.0, 246.94, 196.0, 164.81], "pulse": 0.125},
		{"name": "Nebula FM", "progression": [61.74, 92.5, 82.41, 110.0], "accent": [164.81, 220.0, 246.94, 293.66], "pulse": 0.142},
		{"name": "Deep Relay", "progression": [49.0, 65.41, 73.42, 87.31], "accent": [146.83, 196.0, 220.0, 174.61], "pulse": 0.11},
		{"name": "Blue Shift", "progression": [69.3, 92.5, 103.83, 82.41], "accent": [277.18, 329.63, 246.94, 220.0], "pulse": 0.133},
		{"name": "Night Freight", "progression": [41.2, 55.0, 61.74, 73.42], "accent": [123.47, 164.81, 185.0, 146.83], "pulse": 0.098},
		{"name": "Helios Late", "progression": [58.27, 87.31, 77.78, 116.54], "accent": [233.08, 261.63, 311.13, 196.0], "pulse": 0.152},
		{"name": "Ion Caravan", "progression": [46.25, 69.3, 58.27, 77.78], "accent": [138.59, 174.61, 207.65, 233.08], "pulse": 0.104},
		{"name": "Starwake", "progression": [65.41, 98.0, 87.31, 130.81], "accent": [196.0, 261.63, 293.66, 246.94], "pulse": 0.148},
		{"name": "Port Authority After Dark", "progression": [51.91, 77.78, 69.3, 92.5], "accent": [155.56, 207.65, 233.08, 185.0], "pulse": 0.119},
		{"name": "Cold Dock Lights", "progression": [43.65, 58.27, 65.41, 73.42], "accent": [130.81, 174.61, 196.0, 155.56], "pulse": 0.094},
		{"name": "Mercury Static", "progression": [73.42, 110.0, 98.0, 82.41], "accent": [246.94, 329.63, 277.18, 220.0], "pulse": 0.162},
		{"name": "Lagrange Velvet", "progression": [52.0, 69.3, 82.41, 61.74], "accent": [207.65, 233.08, 261.63, 174.61], "pulse": 0.128}
	]


func generate_radio_sample(track: Dictionary, time_value: float) -> float:
	var progression: Array = track["progression"]
	var accent: Array = track["accent"]
	var pulse_rate: float = track["pulse"]
	var chord_index := int(floor(time_value / 3.2)) % progression.size()
	var beat_phase := fmod(time_value, 0.8) / 0.8
	var low_freq: float = progression[chord_index]
	var high_freq: float = accent[chord_index]
	var drift_a := sin(time_value * TAU * (0.021 + low_freq * 0.00008))
	var drift_b := sin(time_value * TAU * (0.015 + high_freq * 0.00004))
	var drone := sin(time_value * TAU * low_freq) * 0.13 + sin(time_value * TAU * (low_freq * 1.5 + drift_a * 0.7)) * 0.06
	var shimmer_gate := pow(max(0.0, sin(beat_phase * PI)), 3.0)
	var shimmer := sin(time_value * TAU * (high_freq + drift_b * 1.6)) * shimmer_gate * 0.032
	var pulse := sin(time_value * TAU * pulse_rate) * 0.024
	var sub := sin(time_value * TAU * (low_freq * 0.5)) * 0.032
	return drone + shimmer + pulse + sub


func add_station_navigation_lights(station: Node3D, span: float) -> void:
	var port_color := Color(1.0, 0.18, 0.16)
	var starboard_color := Color(0.18, 1.0, 0.34)
	for side in [-1.0, 1.0]:
		var nav_color := port_color if side < 0.0 else starboard_color
		var nav_mesh := MeshInstance3D.new()
		var bulb := SphereMesh.new()
		bulb.radius = span * 0.012
		bulb.height = span * 0.024
		nav_mesh.mesh = bulb
		nav_mesh.position = Vector3(span * 0.88 * side, span * 0.16, 0.0)
		register_style_mesh(nav_mesh, "dock", nav_color)
		station.add_child(nav_mesh)
		station_navigation_meshes.append(nav_mesh)

		var nav_light := OmniLight3D.new()
		nav_light.light_color = nav_color
		nav_light.light_energy = 2.2
		nav_light.omni_range = max(span * 2.2, 120.0)
		nav_light.omni_attenuation = 1.7
		nav_light.position = nav_mesh.position
		station.add_child(nav_light)
		station_navigation_lights.append(nav_light)

	for offset in [Vector3(0.0, span * 0.54, span * 0.2), Vector3(0.0, -span * 0.24, -span * 0.18)]:
		var strobe_mesh := MeshInstance3D.new()
		var strobe_ball := SphereMesh.new()
		strobe_ball.radius = span * 0.013
		strobe_ball.height = span * 0.026
		strobe_mesh.mesh = strobe_ball
		strobe_mesh.position = offset
		register_style_mesh(strobe_mesh, "dock", Color.WHITE)
		station.add_child(strobe_mesh)
		station_strobe_meshes.append(strobe_mesh)

		var strobe_light := OmniLight3D.new()
		strobe_light.light_color = Color.WHITE
		strobe_light.light_energy = 5.4
		strobe_light.omni_range = max(span * 2.8, 180.0)
		strobe_light.omni_attenuation = 1.28
		strobe_light.position = offset
		station.add_child(strobe_light)
		station_strobe_lights.append(strobe_light)


func update_station_navigation_lights() -> void:
	var pulse_time := Time.get_ticks_msec() * 0.001
	var nav_wave := 0.7 + 0.3 * sin(pulse_time * 0.55)
	var strobe_phase := fmod(pulse_time * 0.9, 1.0)
	var strobe_on := strobe_phase < 0.06 or (strobe_phase > 0.14 and strobe_phase < 0.2)
	for i in range(station_navigation_meshes.size()):
		var mesh := station_navigation_meshes[i]
		if mesh == null or not is_instance_valid(mesh):
			continue
		var material := mesh.material_override as StandardMaterial3D
		if material != null:
			material.emission = material.albedo_color * (1.4 + nav_wave * 1.6)
		if i < station_navigation_lights.size():
			var light := station_navigation_lights[i]
			if light != null and is_instance_valid(light):
				light.light_energy = 1.5 + nav_wave * 1.2
	for mesh in station_strobe_meshes:
		if mesh == null or not is_instance_valid(mesh):
			continue
		mesh.visible = strobe_on
		var strobe_material := mesh.material_override as StandardMaterial3D
		if strobe_material != null:
			strobe_material.emission = Color.WHITE * (4.2 if strobe_on else 0.2)
	for light in station_strobe_lights:
		if light == null or not is_instance_valid(light):
			continue
		light.visible = strobe_on


func update_planet_weather_effects(delta: float) -> void:
	var pulse_time := Time.get_ticks_msec() * 0.001
	for effect in planet_weather_effects:
		var weather_root := effect.get("root", null) as Node3D
		if weather_root == null or not is_instance_valid(weather_root):
			continue
		var spin_rate := float(effect.get("spin_rate", 0.08))
		weather_root.rotate_y(delta * spin_rate)
		weather_root.rotate_x(delta * spin_rate * 0.15)
		var atmosphere := effect.get("atmosphere", null) as MeshInstance3D
		if atmosphere != null and is_instance_valid(atmosphere):
			var atmosphere_material := atmosphere.material_override as StandardMaterial3D
			if atmosphere_material != null:
				var shimmer := 0.42 + 0.12 * sin(pulse_time * (0.7 + spin_rate))
				atmosphere_material.emission = Color(
					atmosphere_material.albedo_color.r,
					atmosphere_material.albedo_color.g,
					atmosphere_material.albedo_color.b
				) * shimmer
		var storm_bands: Array = effect.get("storm_bands", [])
		for band_index in range(storm_bands.size()):
			var band := storm_bands[band_index] as MeshInstance3D
			if band == null or not is_instance_valid(band):
				continue
			band.rotate_z(delta * (0.18 + band_index * 0.05))
			band.rotate_y(delta * (0.06 + band_index * 0.03))
		var storm_cells: Array = effect.get("storm_cells", [])
		for storm_index in range(storm_cells.size()):
			var cell := storm_cells[storm_index] as MeshInstance3D
			if cell == null or not is_instance_valid(cell):
				continue
			var phase := float(cell.get_meta("pulse_phase", 0.0))
			var pulse := 0.76 + 0.28 * sin(pulse_time * (1.1 + storm_index * 0.13) + phase)
			cell.scale = Vector3.ONE * pulse
			var cell_material := cell.material_override as StandardMaterial3D
			if cell_material != null:
				cell_material.emission = Color(
					cell_material.albedo_color.r * 4.2,
					cell_material.albedo_color.g * 4.2,
					cell_material.albedo_color.b * 4.2
				) * pulse


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
			var orbit_radius: float = float(body["radius"]) + 2200.0
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
		"position": Vector3(0, 260, STAR_DAMAGE_RADIUS + 6200.0),
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
	if position.length() < STAR_DAMAGE_RADIUS + 6200.0:
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


func build_station_comms_stream() -> AudioStreamWAV:
	return build_tone_stream([620.0, 708.0, 802.0, 714.0, 588.0], 0.34, 0.11, 0.16, 0.7)


func build_news_comms_stream() -> AudioStreamWAV:
	return build_tone_stream([412.0, 438.0, 492.0, 522.0], 0.42, 0.1, 0.1, 0.85)


func build_hauler_comms_stream() -> AudioStreamWAV:
	return build_tone_stream([188.0, 210.0, 176.0, 196.0], 0.36, 0.13, 0.2, 0.9)


func build_autopilot_lock_stream() -> AudioStreamWAV:
	return build_tone_stream([392.0, 523.25, 659.25, 783.99], 0.22, 0.18, 0.03, 1.05)


func build_launch_stream() -> AudioStreamWAV:
	return build_tone_stream([220.0, 330.0, 440.0, 554.37], 0.42, 0.24, 0.08, 0.95)


func build_autopilot_doppler_stream() -> AudioStreamWAV:
	var duration := 1.0
	var sample_count := int(AUDIO_MIX_RATE * duration)
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	for i in range(sample_count):
		var t := float(i) / AUDIO_MIX_RATE
		var phase := t / duration
		var envelope := pow(max(0.0, sin(phase * PI)), 1.45)
		var swell := 0.55 + 0.45 * sin(phase * TAU)
		var carrier := sin(t * TAU * (126.0 + swell * 48.0))
		var shimmer := sin(t * TAU * (244.0 + sin(phase * TAU * 2.0) * 18.0)) * 0.38
		var bed := sin(t * TAU * 62.0) * 0.22
		var sample := (carrier * 0.62 + shimmer * 0.22 + bed * 0.16) * envelope * 0.34
		write_pcm16_sample(data, i, sample)
	var stream := create_wav_stream(data)
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = sample_count
	return stream


func build_radio_loop_stream(track_index: int = 0) -> AudioStreamWAV:
	var duration := 24.0
	var sample_count := int(AUDIO_MIX_RATE * duration)
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	var phase_a := 0.0
	var phase_b := 0.0
	var phase_c := 0.0
	var tracks := get_radio_tracks()
	var selected_track: Dictionary = tracks[clamp(track_index, 0, tracks.size() - 1)]
	var progression: Array = selected_track["progression"]
	var accent: Array = selected_track["accent"]
	var pulse_rate: float = selected_track["pulse"]
	for i in range(sample_count):
		var t := float(i) / AUDIO_MIX_RATE
		var chord_index := int(floor(t / 3.2)) % progression.size()
		var beat_phase := fmod(t, 0.8) / 0.8
		var low_freq: float = progression[chord_index]
		var high_freq: float = accent[chord_index]
		phase_a += TAU * low_freq / AUDIO_MIX_RATE
		phase_b += TAU * (low_freq * 1.5) / AUDIO_MIX_RATE
		phase_c += TAU * high_freq / AUDIO_MIX_RATE
		var drone := sin(phase_a) * 0.18 + sin(phase_b) * 0.09
		var shimmer_gate := pow(max(0.0, sin(beat_phase * PI)), 3.0)
		var shimmer := sin(phase_c) * shimmer_gate * 0.04
		var pulse := sin(t * TAU * pulse_rate) * 0.02
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
	enemy_target_marker.scale = Vector3.ONE * pulse
	enemy_target_marker.rotate_y(0.018)
	enemy_target_marker.rotate_z(0.01)
	var target_velocity: Vector3 = target.get_meta("velocity", Vector3.ZERO)
	var lead_position: Vector3 = target.global_position + target_velocity * clamp(distance / max(PLAYER_PROJECTILE_SPEED, 1.0), 0.18, 1.35)
	if enemy_target_lead_marker != null:
		enemy_target_lead_marker.visible = true
		enemy_target_lead_marker.global_position = lead_position
		var lead_pulse: float = 0.88 + sin(Time.get_ticks_msec() * 0.006) * 0.08
		enemy_target_lead_marker.scale = Vector3.ONE * lead_pulse
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
			var alpha: float = (1.0 - normalized_life)
			effect.scale = Vector3.ONE * (1.0 + normalized_life * 2.6)
			effect.rotate_z(delta * 1.3)
			effect.rotate_y(delta * 0.9)
			effect.set_meta("style_base_color", Color(0.68, 0.96, 1.0, alpha * 0.78))
			apply_mesh_style(effect)
		if life > duration:
			effect.queue_free()
			transient_effects.remove_at(i)


func update_star_flare() -> void:
	if star_node == null or not is_instance_valid(star_node):
		return
	var to_star: Vector3 = star_node.global_position - camera.global_position
	var distance: float = max(to_star.length(), 1.0)
	var direction: Vector3 = to_star / distance
	var camera_forward: Vector3 = -camera.global_basis.z.normalized()
	var alignment: float = clamp(camera_forward.dot(direction), 0.0, 1.0)
	var visibility: float = pow(alignment, 2.4)
	if star_beacon_root != null and not star_beacon_nodes.is_empty():
		star_beacon_root.visible = true
		var beacon_up: Vector3 = get_safe_up_vector(direction, camera.global_basis.y)
		star_beacon_root.global_basis = Basis.looking_at(direction, beacon_up, true)
		for beacon in star_beacon_nodes:
			if beacon == null or not is_instance_valid(beacon):
				continue
			var beacon_material := beacon.material_override as StandardMaterial3D
			if beacon_material != null:
				var beacon_color := beacon_material.albedo_color
				beacon_color.a = clamp(0.06 + visibility * 0.16, 0.0, 0.22)
				beacon_material.albedo_color = beacon_color
				beacon_material.emission = Color(beacon_color.r, beacon_color.g, beacon_color.b) * (1.5 + visibility * 2.1)
	if star_flare_root == null or star_flare_nodes.is_empty():
		return
	star_flare_root.visible = visibility > 0.01
	if not star_flare_root.visible:
		return
	var up: Vector3 = get_safe_up_vector(direction, camera.global_basis.y)
	star_flare_root.global_basis = Basis.looking_at(direction, up, true)
	for flare in star_flare_nodes:
		if flare == null or not is_instance_valid(flare):
			continue
		var flare_offset: float = float(flare.get_meta("flare_offset", 0.0))
		flare.position = Vector3(0, 0, flare_offset)
		var material := flare.material_override as StandardMaterial3D
		if material != null:
			var color := material.albedo_color
			color.a = clamp(visibility * color.a * 6.5, 0.0, 0.34)
			material.albedo_color = color
			material.emission = Color(color.r, color.g, color.b) * (0.8 + visibility * 1.4)


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

	if pause_camera_blend > 0.001:
		var pause_focus_point: Vector3 = player.global_position + ship_basis * CAMERA_FOCUS_OFFSET
		var pause_pitch_live: float = clamp(pause_camera_pitch + sin(pause_camera_time * 0.34) * 0.035, -0.42, 0.12)
		var pause_distance_live: float = pause_camera_distance + sin(pause_camera_time * 0.22) * 1.6
		var pause_yaw_live: float = pause_camera_yaw + pause_camera_time * 0.16
		var pause_offset: Vector3 = Vector3(
			sin(pause_yaw_live) * cos(pause_pitch_live),
			sin(pause_pitch_live),
			cos(pause_yaw_live) * cos(pause_pitch_live)
		) * pause_distance_live
		var pause_position: Vector3 = pause_focus_point + pause_offset
		var pause_look_point: Vector3 = pause_focus_point + player.velocity * 0.08
		base_position = base_position.lerp(pause_position, pause_camera_blend)
		base_look_point = base_look_point.lerp(pause_look_point, pause_camera_blend)

	if cinematic_blend > 0.001:
		var cinematic_pose: Dictionary = compute_cinematic_camera_pose()
		var cinematic_position: Vector3 = cinematic_pose["position"]
		var cinematic_look_point: Vector3 = cinematic_pose["look_point"]
		base_position = base_position.lerp(cinematic_position, cinematic_blend)
		base_look_point = base_look_point.lerp(cinematic_look_point, cinematic_blend)
	camera.global_position = base_position
	var look_direction: Vector3 = (base_look_point - base_position).normalized()
	camera.look_at(base_look_point, get_safe_up_vector(look_direction, ship_basis.y))
	update_star_flare()
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
	objective_marker.scale = Vector3.ONE * pulse
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


func layout_settings_panel_content(settings_width: float, compact: bool, is_phone_portrait: bool) -> float:
	var padding := 18.0
	var inner_width := settings_width - padding * 2.0
	var button_width := 102.0 if is_phone_portrait else (84.0 if compact else 94.0)
	var tab_width := (inner_width - 18.0) / 4.0
	var row_height := 34.0 if is_phone_portrait else (28.0 if compact else 30.0)
	var slider_height := 16.0
	var row_gap := 8.0 if compact else 10.0
	var section_gap := 10.0 if compact else 12.0
	var title_height := 18.0 if compact else 20.0
	var section_padding := 12.0 if compact else 14.0
	var group_width := inner_width
	var label_width: float = max(120.0, inner_width - button_width - 18.0)
	var slider_width := inner_width - button_width - 18.0
	var settings_y := 14.0

	settings_title.offset_left = padding
	settings_title.offset_top = settings_y
	settings_title.offset_right = padding + max(168.0, inner_width - button_width - 18.0)
	settings_title.offset_bottom = settings_y + 26.0
	controls_button.offset_left = padding + group_width - button_width
	controls_button.offset_top = settings_y
	controls_button.offset_right = padding + group_width
	controls_button.offset_bottom = settings_y + row_height
	settings_y += 40.0 if compact else 44.0

	var tab_y := settings_y
	var tab_buttons: Array[Button] = [display_tab_button, audio_tab_button, flight_tab_button, render_tab_button]
	for i in range(tab_buttons.size()):
		var button: Button = tab_buttons[i]
		if button == null:
			continue
		var left := padding + i * (tab_width + 6.0)
		button.offset_left = left
		button.offset_top = tab_y
		button.offset_right = left + tab_width
		button.offset_bottom = tab_y + row_height
	settings_y += row_height + (8.0 if compact else 10.0)

	var group_top := settings_y
	var display_height := section_padding + title_height + 8.0 + 26.0 + row_gap + row_height + section_padding
	display_group.offset_left = padding
	display_group.offset_top = group_top
	display_group.offset_right = padding + group_width
	display_group.offset_bottom = group_top + display_height
	display_group_title.offset_left = section_padding
	display_group_title.offset_top = 10.0
	display_group_title.offset_right = group_width - section_padding
	display_group_title.offset_bottom = 30.0
	var display_row_y := group_top + section_padding + title_height + 8.0
	preset_value.offset_left = padding + section_padding
	preset_value.offset_top = display_row_y
	preset_value.offset_right = padding + group_width - section_padding
	preset_value.offset_bottom = display_row_y + 24.0
	display_row_y += 30.0
	preset_prev_button.offset_left = padding + section_padding
	preset_prev_button.offset_top = display_row_y
	preset_prev_button.offset_right = padding + section_padding + button_width
	preset_prev_button.offset_bottom = display_row_y + row_height
	preset_next_button.offset_left = padding + section_padding + button_width + 8.0
	preset_next_button.offset_top = display_row_y
	preset_next_button.offset_right = padding + section_padding + button_width * 2.0 + 8.0
	preset_next_button.offset_bottom = display_row_y + row_height
	render_mode_button.offset_left = padding + group_width - section_padding - button_width
	render_mode_button.offset_top = display_row_y
	render_mode_button.offset_right = padding + group_width - section_padding
	render_mode_button.offset_bottom = display_row_y + row_height
	var display_end := group_top + display_height

	var audio_height := section_padding + title_height + 8.0 + 2.0 * (24.0 + 20.0 + row_gap) + section_padding - 4.0
	audio_group.offset_left = padding
	audio_group.offset_top = group_top
	audio_group.offset_right = padding + group_width
	audio_group.offset_bottom = group_top + audio_height
	audio_group_title.offset_left = section_padding
	audio_group_title.offset_top = 10.0
	audio_group_title.offset_right = group_width - section_padding
	audio_group_title.offset_bottom = 30.0
	var audio_row_y := group_top + section_padding + title_height + 8.0
	music_value.offset_left = padding + section_padding
	music_value.offset_top = audio_row_y
	music_value.offset_right = padding + section_padding + label_width
	music_value.offset_bottom = audio_row_y + 24.0
	music_button.offset_left = padding + group_width - section_padding - button_width
	music_button.offset_top = audio_row_y - 4.0
	music_button.offset_right = padding + group_width - section_padding
	music_button.offset_bottom = audio_row_y - 4.0 + row_height
	audio_row_y += 26.0
	music_slider.offset_left = padding + section_padding
	music_slider.offset_top = audio_row_y
	music_slider.offset_right = padding + section_padding + slider_width
	music_slider.offset_bottom = audio_row_y + slider_height
	audio_row_y += 34.0
	sfx_value.offset_left = padding + section_padding
	sfx_value.offset_top = audio_row_y
	sfx_value.offset_right = padding + section_padding + label_width
	sfx_value.offset_bottom = audio_row_y + 24.0
	sfx_button.offset_left = padding + group_width - section_padding - button_width
	sfx_button.offset_top = audio_row_y - 4.0
	sfx_button.offset_right = padding + group_width - section_padding
	sfx_button.offset_bottom = audio_row_y - 4.0 + row_height
	audio_row_y += 26.0
	sfx_slider.offset_left = padding + section_padding
	sfx_slider.offset_top = audio_row_y
	sfx_slider.offset_right = padding + section_padding + slider_width
	sfx_slider.offset_bottom = audio_row_y + slider_height
	var audio_end := group_top + audio_height

	var flight_height := section_padding + title_height + 8.0 + 4.0 * (row_height + row_gap) + section_padding - row_gap
	flight_group.offset_left = padding
	flight_group.offset_top = group_top
	flight_group.offset_right = padding + group_width
	flight_group.offset_bottom = group_top + flight_height
	flight_group_title.offset_left = section_padding
	flight_group_title.offset_top = 10.0
	flight_group_title.offset_right = group_width - section_padding
	flight_group_title.offset_bottom = 30.0
	var flight_row_y := group_top + section_padding + title_height + 8.0
	for pair in [
		[trail_value, trail_button],
		[guidance_value, guidance_button],
		[invert_y_value, invert_y_button],
		[physics_mode_value, physics_mode_button]
	]:
		var value_label := pair[0] as Control
		var action_button := pair[1] as Control
		value_label.offset_left = padding + section_padding
		value_label.offset_top = flight_row_y + 3.0
		value_label.offset_right = padding + section_padding + label_width
		value_label.offset_bottom = flight_row_y + 27.0
		action_button.offset_left = padding + group_width - section_padding - button_width
		action_button.offset_top = flight_row_y
		action_button.offset_right = padding + group_width - section_padding
		action_button.offset_bottom = flight_row_y + row_height
		flight_row_y += row_height + row_gap
	var flight_end := group_top + flight_height

	var render_height := section_padding + title_height + 8.0 + 2.0 * (row_height + row_gap) + section_padding - row_gap
	render_group.offset_left = padding
	render_group.offset_top = group_top
	render_group.offset_right = padding + group_width
	render_group.offset_bottom = group_top + render_height
	render_group_title.offset_left = section_padding
	render_group_title.offset_top = 10.0
	render_group_title.offset_right = group_width - section_padding
	render_group_title.offset_bottom = 30.0
	var render_row_y := group_top + section_padding + title_height + 8.0
	render_mode_button.offset_left = padding + group_width - section_padding - button_width
	render_mode_button.offset_top = render_row_y
	render_mode_button.offset_right = padding + group_width - section_padding
	render_mode_button.offset_bottom = render_row_y + row_height
	bloom_value.offset_left = padding + section_padding
	bloom_value.offset_top = render_row_y + row_height + row_gap + 3.0
	bloom_value.offset_right = padding + section_padding + label_width
	bloom_value.offset_bottom = render_row_y + row_height + row_gap + 27.0
	bloom_button.offset_left = padding + group_width - section_padding - button_width
	bloom_button.offset_top = render_row_y + row_height + row_gap
	bloom_button.offset_right = padding + group_width - section_padding
	bloom_button.offset_bottom = render_row_y + row_height + row_gap + row_height
	render_group_title.text = "Render"
	render_group_title.tooltip_text = "General rendering settings. Use FX for shader experiments."
	var render_end := group_top + render_height

	var active_end := display_end
	match settings_tab_index:
		1:
			active_end = audio_end
		2:
			active_end = flight_end
		3:
			active_end = render_end
		_:
			active_end = display_end
	var footer_y := active_end + (4.0 if compact else 8.0)
	settings_hint.offset_left = padding
	settings_hint.offset_top = footer_y
	settings_hint.offset_right = padding + group_width
	settings_hint.offset_bottom = footer_y + (34.0 if compact else 20.0)
	if compact:
		settings_hotkeys.visible = false
		return settings_hint.offset_bottom + 12.0
	footer_y += 24.0
	settings_hotkeys.visible = true
	settings_hotkeys.offset_left = padding
	settings_hotkeys.offset_top = footer_y
	settings_hotkeys.offset_right = padding + group_width
	settings_hotkeys.offset_bottom = footer_y + 40.0
	return settings_hotkeys.offset_bottom + 16.0


func update_responsive_hud_layout(force: bool = false) -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	if not force and viewport_size == last_viewport_size:
		return
	last_viewport_size = viewport_size
	var portrait: bool = viewport_size.y / max(viewport_size.x, 1.0) >= PORTRAIT_LAYOUT_BREAKPOINT
	var compact: bool = viewport_size.x <= PHONE_LAYOUT_BREAKPOINT or portrait
	var is_phone_portrait: bool = portrait and viewport_size.x <= 900.0
	var phone_touch_ui := OS.has_feature("web") and (viewport_size.x <= 980.0 or compact or touch_device_active)
	touch_phone_layout_active = phone_touch_ui
	update_overlay_button_visibility()
	var margin := 12.0 if compact else 22.0
	var side_width: float = min(320.0 if is_phone_portrait else 256.0, max(196.0 if is_phone_portrait else 172.0, viewport_size.x * (0.7 if is_phone_portrait else (0.46 if compact else 0.22))))
	var attitude_size: float = min(188.0 if is_phone_portrait else (156.0 if compact else 176.0), max(132.0 if is_phone_portrait else (108.0 if compact else 136.0), viewport_size.x * (0.24 if is_phone_portrait else (0.18 if compact else 0.1))))
	var side_height := 156.0 if is_phone_portrait else (124.0 if portrait else (166.0 if compact else 214.0))
	var bottom_margin := 18.0 if portrait else (14.0 if compact else 22.0)
	var top_height := 84.0 if is_phone_portrait else (72.0 if compact else 92.0)
	var visible_utility_buttons: Array[Button] = []
	for button in utility_buttons:
		if button != null and button.visible:
			visible_utility_buttons.append(button)
	var utility_count := visible_utility_buttons.size()
	var utility_width := 72.0 if is_phone_portrait else (56.0 if compact else 48.0)
	var utility_height := 48.0 if is_phone_portrait else (36.0 if compact else 28.0)
	var utility_gap := 10.0 if is_phone_portrait else (8.0 if compact else 10.0)
	var stacked_utilities := compact or viewport_size.x < 1500.0 or utility_count > 4
	var utility_lane_width := utility_width
	if stacked_utilities and utility_count > 0:
		utility_lane_width = utility_width
	var top_width: float = min(viewport_size.x - margin * 2.0 - utility_lane_width - (24.0 if utility_count > 0 else 0.0), 700.0 if compact else 720.0)
	top_frame.offset_left = -top_width * 0.5
	top_frame.offset_right = top_width * 0.5
	top_frame.offset_top = margin
	top_frame.offset_bottom = margin + top_height
	alert_value.offset_left = 20.0
	alert_value.offset_top = 10.0
	alert_value.offset_right = top_width - 20.0
	alert_value.offset_bottom = 34.0
	hit_value.offset_left = 20.0
	hit_value.offset_top = 40.0
	hit_value.offset_right = top_width - 20.0
	hit_value.offset_bottom = 66.0
	alert_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hit_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	alert_value.add_theme_font_size_override("font_size", 13 if is_phone_portrait else (11 if compact else 13))
	hit_value.add_theme_font_size_override("font_size", 12 if is_phone_portrait else (10 if compact else 12))
	attitude_frame.offset_left = margin
	attitude_frame.offset_top = margin + 52.0
	attitude_frame.offset_right = margin + attitude_size
	attitude_frame.offset_bottom = margin + 52.0 + attitude_size
	var viewport_pixels := int(round(attitude_size * 1.45))
	attitude_viewport.size = Vector2i(viewport_pixels, viewport_pixels)
	var attitude_half: float = attitude_size * 0.495
	attitude_display.offset_left = -attitude_half
	attitude_display.offset_top = -attitude_half
	attitude_display.offset_right = attitude_half
	attitude_display.offset_bottom = attitude_half
	if portrait:
		var portrait_width: float = viewport_size.x - margin * 2.0
		left_frame.offset_left = margin
		left_frame.offset_right = margin + portrait_width
		left_frame.offset_top = -side_height * 2.0 - bottom_margin - 8.0
		left_frame.offset_bottom = -side_height - bottom_margin - 8.0
		right_frame.offset_left = margin
		right_frame.offset_right = margin + portrait_width
		right_frame.offset_top = -side_height - bottom_margin
		right_frame.offset_bottom = -bottom_margin
	else:
		left_frame.offset_left = margin
		left_frame.offset_right = margin + side_width
		left_frame.offset_top = -side_height - bottom_margin
		left_frame.offset_bottom = -bottom_margin
		right_frame.offset_left = -margin - side_width
		right_frame.offset_right = -margin
		right_frame.offset_top = -side_height - bottom_margin
		right_frame.offset_bottom = -bottom_margin
	var message_width: float = min(viewport_size.x - margin * 2.0 - (0.0 if compact else side_width * 1.8), 720.0 if not compact else viewport_size.x - margin * 2.0)
	message_width = max(message_width, 320.0 if compact else 420.0)
	message_frame.offset_left = -message_width * 0.5
	message_frame.offset_right = message_width * 0.5
	message_frame.offset_top = -(76.0 if portrait else (86.0 if compact else 92.0))
	message_frame.offset_bottom = -(10.0 if portrait else (18.0 if compact else 24.0))
	message_value.offset_left = 18.0
	message_value.offset_right = message_width - 18.0
	message_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_value.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var utility_right := -margin
	if stacked_utilities:
		var utility_top := margin
		for button in visible_utility_buttons:
			button.offset_right = utility_right
			button.offset_left = utility_right - utility_width
			button.offset_top = utility_top
			button.offset_bottom = utility_top + utility_height
			utility_top += utility_height + utility_gap
	else:
		for button in visible_utility_buttons:
			button.offset_right = utility_right
			button.offset_left = utility_right - utility_width
			button.offset_top = margin
			button.offset_bottom = margin + utility_height
			utility_right = button.offset_left - utility_gap
	var settings_width := viewport_size.x - margin * 2.0 if compact else 392.0
	settings_panel.anchor_left = 0.0 if compact else 1.0
	settings_panel.anchor_right = 1.0
	settings_panel.offset_left = margin if compact else -settings_width - 24.0
	settings_panel.offset_right = -margin if compact else -24.0
	settings_panel.offset_top = margin
	var settings_content_height := layout_settings_panel_content(settings_width, compact, is_phone_portrait)
	var settings_height: float = min(viewport_size.y - margin * 2.0, settings_content_height)
	settings_panel.offset_bottom = margin + settings_height
	var shader_panel_width: float = min(viewport_size.x - margin * 2.0, 440.0 if not compact else viewport_size.x - margin * 2.0)
	var shader_panel_height: float = min(viewport_size.y - margin * 2.0, 620.0 if is_phone_portrait else 576.0)
	shader_panel.offset_left = -shader_panel_width * 0.5
	shader_panel.offset_right = shader_panel_width * 0.5
	shader_panel.offset_top = -shader_panel_height * 0.5
	shader_panel.offset_bottom = shader_panel_height * 0.5
	shader_close_button.offset_left = shader_panel_width - 104.0
	shader_close_button.offset_right = shader_panel_width - 20.0
	post_fx_value.offset_right = shader_panel_width - 126.0
	post_fx_button.offset_left = shader_panel_width - 124.0
	post_fx_button.offset_right = shader_panel_width - 20.0
	blur_fx_value.offset_right = shader_panel_width - 126.0
	blur_fx_button.offset_left = shader_panel_width - 124.0
	blur_fx_button.offset_right = shader_panel_width - 20.0
	attitude_shader_value.offset_right = shader_panel_width - 126.0
	attitude_shader_button.offset_left = shader_panel_width - 124.0
	attitude_shader_button.offset_right = shader_panel_width - 20.0
	edge_threshold_value.offset_left = 18.0
	edge_threshold_value.offset_right = shader_panel_width - 20.0
	shader_mode_option.offset_left = 18.0
	shader_mode_option.offset_right = shader_panel_width - 20.0
	edge_strength_value.offset_left = 18.0
	edge_strength_value.offset_right = shader_panel_width - 20.0
	edge_threshold_slider.offset_left = 18.0
	edge_threshold_slider.offset_right = shader_panel_width - 20.0
	edge_glow_value.offset_left = 18.0
	edge_glow_value.offset_right = shader_panel_width - 20.0
	edge_strength_slider.offset_left = 18.0
	edge_strength_slider.offset_right = shader_panel_width - 20.0
	glow_amount_value.offset_left = 18.0
	glow_amount_value.offset_right = shader_panel_width - 20.0
	edge_glow_slider.offset_left = 18.0
	edge_glow_slider.offset_right = shader_panel_width - 20.0
	blur_amount_value.offset_left = 18.0
	blur_amount_value.offset_right = shader_panel_width - 20.0
	shader_aux_value.offset_left = 18.0
	shader_aux_value.offset_right = shader_panel_width - 20.0
	blur_amount_slider.offset_left = 18.0
	blur_amount_slider.offset_right = shader_panel_width - 20.0
	shader_aux_slider.offset_left = 18.0
	shader_aux_slider.offset_right = shader_panel_width - 20.0
	var shader_control_top := 180.0
	edge_threshold_value.offset_top = shader_control_top
	edge_threshold_value.offset_bottom = shader_control_top + 24.0
	shader_mode_option.offset_top = shader_control_top + 26.0
	shader_mode_option.offset_bottom = shader_control_top + 58.0
	edge_strength_value.offset_top = shader_control_top + 74.0
	edge_strength_value.offset_bottom = shader_control_top + 98.0
	edge_threshold_slider.offset_top = shader_control_top + 100.0
	edge_threshold_slider.offset_bottom = shader_control_top + 116.0
	edge_glow_value.offset_top = shader_control_top + 132.0
	edge_glow_value.offset_bottom = shader_control_top + 156.0
	edge_strength_slider.offset_top = shader_control_top + 158.0
	edge_strength_slider.offset_bottom = shader_control_top + 174.0
	glow_amount_value.offset_top = shader_control_top + 190.0
	glow_amount_value.offset_bottom = shader_control_top + 214.0
	edge_glow_slider.offset_top = shader_control_top + 216.0
	edge_glow_slider.offset_bottom = shader_control_top + 232.0
	blur_amount_value.offset_top = shader_control_top + 248.0
	blur_amount_value.offset_bottom = shader_control_top + 272.0
	blur_amount_slider.offset_top = shader_control_top + 274.0
	blur_amount_slider.offset_bottom = shader_control_top + 290.0
	shader_aux_value.offset_top = shader_control_top + 306.0
	shader_aux_value.offset_bottom = shader_control_top + 330.0
	shader_aux_slider.offset_top = shader_control_top + 332.0
	shader_aux_slider.offset_bottom = shader_control_top + 348.0
	shader_hint.offset_right = shader_panel_width - 20.0
	shader_hint.offset_top = shader_panel_height - 54.0
	shader_hint.offset_bottom = shader_panel_height - 18.0
	var inspector_panel_width: float = min(viewport_size.x - margin * 2.0, 460.0 if not compact else viewport_size.x - margin * 2.0)
	var inspector_panel_height: float = min(viewport_size.y - margin * 2.0, 360.0 if is_phone_portrait else 328.0)
	if inspector_panel != null:
		inspector_panel.offset_left = -inspector_panel_width * 0.5
		inspector_panel.offset_right = inspector_panel_width * 0.5
		inspector_panel.offset_top = -inspector_panel_height * 0.5
		inspector_panel.offset_bottom = inspector_panel_height * 0.5
		inspector_title.offset_left = 18.0
		inspector_title.offset_top = 16.0
		inspector_title.offset_right = inspector_panel_width - 120.0
		inspector_title.offset_bottom = 40.0
		inspector_close_button.offset_left = inspector_panel_width - 104.0
		inspector_close_button.offset_right = inspector_panel_width - 20.0
		inspector_close_button.offset_top = 14.0
		inspector_close_button.offset_bottom = 44.0
		inspector_hint.offset_left = 18.0
		inspector_hint.offset_top = 56.0
		inspector_hint.offset_right = inspector_panel_width - 18.0
		inspector_hint.offset_bottom = 92.0
		inspector_object_name.offset_left = 18.0
		inspector_object_name.offset_top = 102.0
		inspector_object_name.offset_right = inspector_panel_width - 18.0
		inspector_object_name.offset_bottom = 128.0
		inspector_object_info.offset_left = 18.0
		inspector_object_info.offset_top = 136.0
		inspector_object_info.offset_right = inspector_panel_width - 18.0
		inspector_object_info.offset_bottom = inspector_panel_height - 120.0
		var inspector_button_width := (inspector_panel_width - 18.0 * 2.0 - 10.0 * 2.0) / 3.0
		var inspector_row_y := inspector_panel_height - 96.0
		var inspector_top_buttons: Array[Button] = [inspector_screen_fx_button, inspector_blur_button, inspector_bloom_button]
		for i in range(3):
			var left := 18.0 + i * (inspector_button_width + 10.0)
			var button: Button = inspector_top_buttons[i]
			button.offset_left = left
			button.offset_right = left + inspector_button_width
			button.offset_top = inspector_row_y
			button.offset_bottom = inspector_row_y + 32.0
		inspector_row_y += 40.0
		var inspector_bottom_buttons: Array[Button] = [inspector_solo_button, inspector_trippy_button, inspector_reset_button]
		for i in range(3):
			var left := 18.0 + i * (inspector_button_width + 10.0)
			var button: Button = inspector_bottom_buttons[i]
			button.offset_left = left
			button.offset_right = left + inspector_button_width
			button.offset_top = inspector_row_y
			button.offset_bottom = inspector_row_y + 32.0
	var controls_width: float = min(viewport_size.x - margin * 2.0, 620.0 if not compact else viewport_size.x - margin * 2.0)
	var controls_height: float = min(viewport_size.y - margin * 2.0, 520.0 if is_phone_portrait else (472.0 if not compact else viewport_size.y - margin * 2.0))
	controls_panel.offset_left = -controls_width * 0.5
	controls_panel.offset_right = controls_width * 0.5
	controls_panel.offset_top = -controls_height * 0.5
	controls_panel.offset_bottom = controls_height * 0.5
	var controls_column_width: float = controls_width * (0.5 if compact else 0.44)
	controls_close_button.offset_left = controls_width - 104.0
	controls_close_button.offset_right = controls_width - 20.0
	controls_controller_label.offset_left = 20.0 if compact else controls_width * 0.53
	controls_controller_label.offset_right = controls_width - 20.0
	controls_controller_text.offset_left = 20.0 if compact else controls_width * 0.53
	controls_controller_text.offset_right = controls_width - 20.0
	controls_controller_label.offset_top = 226.0 if compact else 58.0
	controls_controller_label.offset_bottom = controls_controller_label.offset_top + 22.0
	controls_controller_text.offset_top = 252.0 if compact else 84.0
	controls_controller_text.offset_bottom = controls_height - 54.0
	controls_keyboard_text.offset_right = 20.0 + controls_column_width if compact else controls_width * 0.47
	controls_keyboard_text.offset_bottom = 220.0 if compact else controls_height - 54.0
	controls_keyboard_label.offset_right = controls_keyboard_text.offset_right
	controls_hint.offset_top = controls_height - 34.0
	controls_hint.offset_bottom = controls_height - 12.0
	var frame_title_size := 15 if is_phone_portrait else 11
	var panel_text_size := 14 if is_phone_portrait else 11
	var panel_small_size := 12 if is_phone_portrait else 10
	var utility_button_font := 24 if is_phone_portrait else 18
	var panel_button_font := 20 if is_phone_portrait else 18
	var panel_button_height := 54.0 if is_phone_portrait else 0.0
	($CanvasLayer/HUD/LeftFrame/ShipTitle as Label).add_theme_font_size_override("font_size", frame_title_size)
	($CanvasLayer/HUD/RightFrame/CombatTitle as Label).add_theme_font_size_override("font_size", frame_title_size)
	dock_value.add_theme_font_size_override("font_size", panel_text_size)
	route_value.add_theme_font_size_override("font_size", panel_text_size)
	scanner_value.add_theme_font_size_override("font_size", panel_small_size)
	combat_value.add_theme_font_size_override("font_size", panel_text_size)
	combat_value.visible = false
	build_value.add_theme_font_size_override("font_size", panel_small_size)
	var right_width: float = abs(right_frame.offset_right - right_frame.offset_left)
	var right_height: float = abs(right_frame.offset_bottom - right_frame.offset_top)
	combat_title.offset_left = 16.0
	combat_title.offset_top = 12.0
	combat_title.offset_right = right_width - 16.0
	combat_title.offset_bottom = 30.0
	if tactical_map != null and is_instance_valid(tactical_map):
		var map_margin := 16.0
		var map_top := 40.0
		var build_height := 24.0
		var map_width: float = max(right_width - map_margin * 2.0, 96.0)
		var map_height: float = max(right_height - map_top - build_height - 18.0, 96.0)
		tactical_map.position = Vector2(map_margin, map_top)
		tactical_map.size = Vector2(map_width, map_height)
	build_value.offset_left = 16.0
	build_value.offset_right = right_width - 16.0
	build_value.offset_top = right_height - 30.0
	build_value.offset_bottom = right_height - 8.0
	message_value.add_theme_font_size_override("font_size", panel_text_size)
	debug_save_defaults_button.add_theme_font_size_override("font_size", utility_button_font)
	shader_button.add_theme_font_size_override("font_size", utility_button_font)
	help_button.add_theme_font_size_override("font_size", utility_button_font)
	settings_button.add_theme_font_size_override("font_size", utility_button_font)
	fullscreen_button.add_theme_font_size_override("font_size", utility_button_font)
	settings_title.add_theme_font_size_override("font_size", 24 if is_phone_portrait else 20)
	controls_title.add_theme_font_size_override("font_size", 24 if is_phone_portrait else 20)
	shader_title.add_theme_font_size_override("font_size", 24 if is_phone_portrait else 20)
	if inspector_title != null:
		inspector_title.add_theme_font_size_override("font_size", 24 if is_phone_portrait else 20)
	for label in [
		preset_value,
		bloom_value,
		music_value,
		sfx_value,
		trail_value,
		guidance_value,
		invert_y_value,
		physics_mode_value,
		edge_threshold_value,
		edge_strength_value,
		edge_glow_value,
		glow_amount_value,
		blur_amount_value,
		shader_aux_value,
		settings_hint,
		settings_hotkeys,
		post_fx_value,
		blur_fx_value,
		attitude_shader_value,
		shader_hint,
		controls_keyboard_label,
		controls_keyboard_text,
		controls_controller_label,
		controls_controller_text,
		controls_hint,
		inspector_hint,
		inspector_object_name,
		inspector_object_info
	]:
		if label == null:
			continue
		label.add_theme_font_size_override("font_size", 16 if is_phone_portrait else 12)
	for button in [
		controls_button,
		controls_close_button,
		shader_close_button,
		post_fx_button,
		blur_fx_button,
		attitude_shader_button,
		preset_prev_button,
		preset_next_button,
		render_mode_button,
		bloom_button,
		music_button,
		sfx_button,
		trail_button,
		guidance_button,
		invert_y_button,
		physics_mode_button
	]:
		if button == null:
			continue
		button.add_theme_font_size_override("font_size", panel_button_font)
		if panel_button_height > 0.0:
			button.custom_minimum_size.y = panel_button_height
	if compact:
		cockpit_overlay.scale = Vector2(0.92, 0.92) if is_phone_portrait else Vector2(0.82, 0.82)
	else:
		cockpit_overlay.scale = Vector2.ONE
	layout_touch_controls(viewport_size, margin, is_phone_portrait, compact)


func toggle_fullscreen_mode() -> void:
	var window := get_window()
	if window == null:
		return
	if window.mode == Window.MODE_FULLSCREEN or window.mode == Window.MODE_EXCLUSIVE_FULLSCREEN:
		window.mode = Window.MODE_WINDOWED
	else:
		window.mode = Window.MODE_FULLSCREEN
	update_window_controls()


func update_window_controls() -> void:
	var window := get_window()
	if window == null:
		return
	var is_fullscreen := window.mode == Window.MODE_FULLSCREEN or window.mode == Window.MODE_EXCLUSIVE_FULLSCREEN
	fullscreen_button.text = "❐" if is_fullscreen else "⛶"
	fullscreen_button.tooltip_text = "Exit fullscreen" if is_fullscreen else "Enter fullscreen"


func pick_inspector_object(screen_position: Vector2) -> void:
	var best_mesh: MeshInstance3D = null
	var best_score := INF
	for candidate in get_tree().get_nodes_in_group("style_mesh"):
		var mesh := candidate as MeshInstance3D
		if mesh == null or not is_instance_valid(mesh) or not mesh.visible:
			continue
		if camera.is_position_behind(mesh.global_position):
			continue
		var projected: Vector2 = camera.unproject_position(mesh.global_position)
		var pixel_distance: float = projected.distance_to(screen_position)
		if pixel_distance > 72.0:
			continue
		var depth_bias: float = camera.global_position.distance_to(mesh.global_position) * 0.01
		var score: float = pixel_distance + depth_bias
		if score < best_score:
			best_score = score
			best_mesh = mesh
	if best_mesh == null:
		inspector_selected_subject = null
	else:
		inspector_selected_subject = get_debug_subject_for_mesh(best_mesh)
	update_inspector_panel_labels()
	refresh_debug_visual_overrides()


func get_debug_subject_for_mesh(mesh: MeshInstance3D) -> Node:
	var current: Node = mesh
	while current != null:
		if current == player:
			return current
		if current.has_meta("station_name") or current.has_meta("pirate_hideout") or current.has_meta("traffic_class") or current.has_meta("hull"):
			return current
		current = current.get_parent()
	return mesh


func get_debug_subject_meshes(subject: Node) -> Array[MeshInstance3D]:
	var meshes: Array[MeshInstance3D] = []
	if subject == null or not is_instance_valid(subject):
		return meshes
	if subject is MeshInstance3D:
		meshes.append(subject)
	for child in subject.get_children():
		if child is MeshInstance3D and child.is_in_group("style_mesh"):
			meshes.append(child)
	return meshes


func clear_debug_subject_overrides() -> void:
	if inspector_selected_subject != null and is_instance_valid(inspector_selected_subject):
		for mesh in get_debug_subject_meshes(inspector_selected_subject):
			mesh.set_meta("debug_hidden", false)
			mesh.set_meta("debug_force_trippy", false)
	inspector_solo_mode = false


func refresh_debug_visual_overrides() -> void:
	for candidate in get_tree().get_nodes_in_group("style_mesh"):
		var mesh := candidate as MeshInstance3D
		if mesh == null or not is_instance_valid(mesh):
			continue
		apply_mesh_style(mesh)


func update_inspector_panel_labels() -> void:
	if inspector_panel == null:
		return
	var selected_name := "No object selected"
	var selected_info := "Click a visible ship, station, world, or marker to inspect it.\n\nLayers\nObject material\nTheme preset\nScreen FX\nOverlay blur\nBloom"
	if inspector_selected_subject != null and is_instance_valid(inspector_selected_subject):
		selected_name = str(inspector_selected_subject.name)
		var meshes := get_debug_subject_meshes(inspector_selected_subject)
		var primary_mesh: MeshInstance3D = meshes[0] if not meshes.is_empty() else null
		var role := "n/a"
		var material_name := "n/a"
		if primary_mesh != null:
			role = str(primary_mesh.get_meta("style_role", "world"))
			if bool(primary_mesh.get_meta("debug_force_trippy", false)):
				material_name = "Trippy Override"
			elif primary_mesh.material_override != null:
				material_name = primary_mesh.material_override.get_class()
		var layer_lines := PackedStringArray([
			"Type: %s" % inspector_selected_subject.get_class(),
			"Role: %s" % role,
			"Meshes: %d" % meshes.size(),
			"Material: %s" % material_name,
			"Layers: %s / %s / Bloom %s" % [
				"ScreenFX On" if edge_shader_enabled else "ScreenFX Off",
				"Blur On" if blur_shader_enabled else "Blur Off",
				"On" if bloom_enabled else "Off"
			]
		])
		if inspector_selected_subject.has_meta("station_name"):
			layer_lines.append("Station: %s" % str(inspector_selected_subject.get_meta("station_name")))
		selected_info = "\n".join(layer_lines)
	inspector_object_name.text = selected_name
	inspector_object_info.text = selected_info
	inspector_screen_fx_button.text = "Screen FX: %s" % ("On" if edge_shader_enabled else "Off")
	inspector_blur_button.text = "Blur: %s" % ("On" if blur_shader_enabled else "Off")
	inspector_bloom_button.text = "Bloom: %s" % ("On" if bloom_enabled else "Off")
	inspector_solo_button.text = "Solo: %s" % ("On" if inspector_solo_mode else "Off")
	var trippy_active := false
	if inspector_selected_subject != null and is_instance_valid(inspector_selected_subject):
		for mesh in get_debug_subject_meshes(inspector_selected_subject):
			if bool(mesh.get_meta("debug_force_trippy", false)):
				trippy_active = true
				break
	inspector_trippy_button.text = "Trippy: %s" % ("On" if trippy_active else "Off")


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
	lines.append("Speed: %.1f" % player.velocity.length())
	lines.append("Gravity: %.2f" % cached_ship_gravity_magnitude)
	lines.append("Range: %.0f" % player.global_position.length())
	lines.append("Boost: %s" % ("on" if Input.is_key_pressed(KEY_SHIFT) else "idle"))
	if autopilot_active:
		lines.append("AP: %s" % get_autopilot_state_display())

	for station in station_order:
		var station_name := str(station.get_meta("station_name"))
		var planet_name := str(station.get_meta("planet_name"))
		var distance := player.global_position.distance_to(station.global_position)
		var marker := "  "
		if station_name == pickup_station and not cargo_loaded:
			marker = "> "
		elif station_name == delivery_station and cargo_loaded:
			marker = "> "
		lines.append("%s%s (%s) %.0fm" % [marker, station_name, planet_name, distance])

	scanner_label.text = "\n".join(lines)


func get_target_station() -> Area3D:
	if not selected_target_station_name.is_empty():
		var selected_station: Area3D = station_nodes_by_name.get(selected_target_station_name, null)
		if selected_station != null and is_instance_valid(selected_station):
			return selected_station
		selected_target_station_name = ""
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
	objective_label.text = "Objective: %s %s (%.0fm)" % [stage, target_name, distance]


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
		cargo_label.text = "Route: unavailable"
		objective_label.text = "Objective: unavailable"
		return

	cargo_loaded = false
	selected_target_station_name = ""
	pickup_station = str(station_order[0].get_meta("station_name"))
	var midpoint_index := int(station_order.size() / 2)
	delivery_station = str(station_order[midpoint_index].get_meta("station_name"))
	cargo_label.text = "Route: %s to %s" % [pickup_station, delivery_station]
	objective_label.text = "Objective: pickup %s" % pickup_station


func handle_cargo_dock(station_name: String) -> void:
	if station_name == selected_target_station_name:
		selected_target_station_name = ""
	if station_name == pickup_station and not cargo_loaded:
		cargo_loaded = true
		title_label.text = "Cargo Loaded"
		cargo_label.text = "Route: %s to %s" % [pickup_station, delivery_station]
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

	cargo_label.text = "Route: %s to %s" % [pickup_station, delivery_station]
	objective_label.text = "Objective: pickup %s" % pickup_station


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


func build_traffic_ship_mesh(traffic_class: String) -> ArrayMesh:
	match traffic_class:
		"police_interceptor":
			return build_line_mesh(PackedVector3Array([
				Vector3(0, 0, -11), Vector3(6, 0, 4),
				Vector3(6, 0, 4), Vector3(0, 2.5, 8),
				Vector3(0, 2.5, 8), Vector3(-6, 0, 4),
				Vector3(-6, 0, 4), Vector3(0, 0, -11),
				Vector3(-9, 0, 0), Vector3(-3, 0, 3),
				Vector3(9, 0, 0), Vector3(3, 0, 3),
				Vector3(0, -1.8, 5), Vector3(0, 2.5, 8)
			]))
		"heavy_hauler":
			return build_line_mesh(PackedVector3Array([
				Vector3(-10, -2, -18), Vector3(10, -2, -18),
				Vector3(10, -2, -18), Vector3(12, 3, 18),
				Vector3(12, 3, 18), Vector3(-12, 3, 18),
				Vector3(-12, 3, 18), Vector3(-10, -2, -18),
				Vector3(-8, 5, -6), Vector3(8, 5, -6),
				Vector3(8, 5, -6), Vector3(6, 8, 8),
				Vector3(6, 8, 8), Vector3(-6, 8, 8),
				Vector3(-6, 8, 8), Vector3(-8, 5, -6),
				Vector3(-16, 0, -2), Vector3(-12, 0, -2),
				Vector3(16, 0, -2), Vector3(12, 0, -2)
			]))
		"corvette":
			return build_destroyer_mesh(28.0)
		"courier":
			return build_line_mesh(PackedVector3Array([
				Vector3(0, 0, -13), Vector3(4, 0, 2),
				Vector3(4, 0, 2), Vector3(2.5, 0, 10),
				Vector3(2.5, 0, 10), Vector3(-2.5, 0, 10),
				Vector3(-2.5, 0, 10), Vector3(-4, 0, 2),
				Vector3(-4, 0, 2), Vector3(0, 0, -13),
				Vector3(-7, 0, 3), Vector3(7, 0, 3),
				Vector3(0, -1.4, 8), Vector3(0, 2.0, 7)
			]))
		"salvage_tug":
			return build_line_mesh(PackedVector3Array([
				Vector3(-5, -2, -10), Vector3(5, -2, -10),
				Vector3(5, -2, -10), Vector3(7, 2, 8),
				Vector3(7, 2, 8), Vector3(-7, 2, 8),
				Vector3(-7, 2, 8), Vector3(-5, -2, -10),
				Vector3(-2, 4, -2), Vector3(2, 4, -2),
				Vector3(0, 4, -2), Vector3(0, 8, 3),
				Vector3(-10, 0, 6), Vector3(10, 0, 6)
			]))
		_:
			return build_enemy_ship_mesh()


func build_traffic_ship_solid_mesh(traffic_class: String) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	match traffic_class:
		"police_interceptor":
			var interceptor_color := Color(0.68, 0.82, 0.96)
			append_box_to_surface(st, Transform3D(Basis.IDENTITY, Vector3.ZERO), Vector3(7.2, 1.8, 15.0), interceptor_color.darkened(0.08))
			append_box_to_surface(st, Transform3D(Basis.IDENTITY, Vector3(0, 0.7, -2.0)), Vector3(3.0, 1.4, 5.6), interceptor_color.lightened(0.06))
			for side in [-1.0, 1.0]:
				append_box_to_surface(st, Transform3D(Basis.IDENTITY, Vector3(4.2 * side, 0.0, 1.0)), Vector3(3.8, 0.3, 9.2), interceptor_color.darkened(0.02))
			append_ship_nose_to_surface(st, 2.4, 0.65, -6.2, -11.2, interceptor_color)
		"heavy_hauler":
			var hauler_color := Color(0.84, 0.78, 0.64)
			append_box_to_surface(st, Transform3D(Basis.IDENTITY, Vector3.ZERO), Vector3(12.0, 5.2, 33.0), hauler_color.darkened(0.1))
			append_box_to_surface(st, Transform3D(Basis.IDENTITY, Vector3(0, 4.4, -4.0)), Vector3(7.4, 3.0, 12.0), hauler_color.lightened(0.04))
			append_box_to_surface(st, Transform3D(Basis.IDENTITY, Vector3(0, -1.8, 5.0)), Vector3(9.0, 2.0, 16.0), hauler_color.darkened(0.16))
			for side in [-1.0, 1.0]:
				append_box_to_surface(st, Transform3D(Basis.IDENTITY, Vector3(9.4 * side, 0.4, -1.5)), Vector3(3.0, 0.8, 14.0), hauler_color.darkened(0.06))
			append_ship_nose_to_surface(st, 4.0, 1.2, -11.0, -18.0, hauler_color)
		"corvette":
			return build_destroyer_solid_mesh(28.0)
		"courier":
			var courier_color := Color(0.66, 0.9, 0.82)
			append_box_to_surface(st, Transform3D(Basis.IDENTITY, Vector3.ZERO), Vector3(4.6, 1.5, 18.0), courier_color.darkened(0.06))
			append_box_to_surface(st, Transform3D(Basis.IDENTITY, Vector3(0, 0.42, 2.8)), Vector3(2.1, 1.1, 7.4), courier_color.lightened(0.05))
			for side in [-1.0, 1.0]:
				append_box_to_surface(st, Transform3D(Basis.IDENTITY, Vector3(2.6 * side, -0.1, 1.4)), Vector3(2.8, 0.2, 9.4), courier_color.darkened(0.02))
			append_ship_nose_to_surface(st, 1.5, 0.44, -7.6, -13.2, courier_color)
		"salvage_tug":
			var tug_color := Color(0.72, 0.8, 0.86)
			append_box_to_surface(st, Transform3D(Basis.IDENTITY, Vector3(0, 0.2, 0)), Vector3(8.0, 3.4, 18.0), tug_color.darkened(0.08))
			append_box_to_surface(st, Transform3D(Basis.IDENTITY, Vector3(0, 3.0, -1.0)), Vector3(3.6, 3.2, 5.2), tug_color.lightened(0.02))
			append_box_to_surface(st, Transform3D(Basis.IDENTITY, Vector3(0, 0.0, 8.6)), Vector3(13.0, 0.5, 1.1), tug_color.darkened(0.16))
			append_ship_nose_to_surface(st, 2.2, 0.7, -6.0, -10.4, tug_color)
		_:
			return build_enemy_solid_mesh()
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
