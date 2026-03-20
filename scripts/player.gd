extends CharacterBody3D

const SHIP_VISUAL_SCALE := 1.6
const ENGINE_AUDIO_MIX_RATE := 22050
const CONTROLLER_DEADZONE := 0.18
const CONTROLLER_LOOK_DEADZONE := 0.28
const MOUSE_LOOK_PRIORITY_TIME := 0.35

@export var forward_thrust := 240.0
@export var reverse_thrust := 150.0
@export var strafe_thrust := 180.0
@export var vertical_thrust := 180.0
@export var max_speed := 520.0
@export var linear_damping := 0.32
@export var boost_multiplier := 1.8
@export var boost_damping := 0.18
@export var turn_speed := 10.0
@export var mouse_sensitivity := 0.0026
@export var keyboard_look_speed := 1.8
@export var controller_look_speed := Vector2(2.2, 1.6)
@export var controller_look_response := 10.0
@export var roll_speed := 1.9
@export var banking_angle := 0.24
@export var pitch_angle := 0.12
@export var arena_limit := Vector3(8400, 1800, 8400)

@onready var visual: MeshInstance3D = $Visual

var wire_hull_instance: MeshInstance3D
var solid_hull_instance: MeshInstance3D
var trail_points := PackedVector3Array()
var trail_mesh_instance: MeshInstance3D
var trail_accumulator := 0.0
var trail_dirty := false
var gravity_acceleration := Vector3.ZERO
var engine_mesh_instance: MeshInstance3D
var main_thruster_audio: AudioStreamPlayer3D
var retro_thruster_audio: AudioStreamPlayer3D
var boost_active := false
var trail_enabled := false
var yaw := 0.0
var pitch := 0.0
var roll := 0.0
var look_input := Vector2.ZERO
var mouse_look_priority_timer := 0.0
var controller_look_state := Vector2.ZERO
var touch_look_state := Vector2.ZERO
var forward_thrust_amount := 0.0
var reverse_thrust_amount := 0.0
var control_lock := false
var autopilot_pose_active := false
var autopilot_target_position := Vector3.ZERO
var autopilot_target_basis := Basis.IDENTITY
var autopilot_target_velocity := Vector3.ZERO
var cockpit_mode := 0
var cockpit_interior_root: Node3D
var cockpit_frame_meshes: Array[MeshInstance3D] = []
var cockpit_glow_meshes: Array[MeshInstance3D] = []
var cockpit_canopy_meshes: Array[MeshInstance3D] = []
var cockpit_lights: Array[OmniLight3D] = []
var navigation_light_meshes: Array[MeshInstance3D] = []
var navigation_lights: Array[OmniLight3D] = []
var strobe_meshes: Array[MeshInstance3D] = []
var strobe_lights: Array[OmniLight3D] = []
var thruster_accent_color := Color(0.55, 0.95, 1.0)
var thruster_shaded_mode := false
var touch_move_input := Vector3.ZERO
var touch_boost_active := false


func _ready() -> void:
	visual.mesh = null
	visual.material_override = null
	wire_hull_instance = MeshInstance3D.new()
	wire_hull_instance.name = "HullWire"
	wire_hull_instance.mesh = build_ship_mesh()
	wire_hull_instance.material_override = make_ship_material()
	visual.add_child(wire_hull_instance)
	solid_hull_instance = MeshInstance3D.new()
	solid_hull_instance.name = "HullSolid"
	solid_hull_instance.mesh = build_ship_solid_mesh()
	solid_hull_instance.scale = Vector3.ONE * SHIP_VISUAL_SCALE
	visual.add_child(solid_hull_instance)
	engine_mesh_instance = MeshInstance3D.new()
	engine_mesh_instance.name = "EngineGlow"
	engine_mesh_instance.position = Vector3(0, 0, 3.0)
	engine_mesh_instance.mesh = build_engine_mesh()
	engine_mesh_instance.material_override = make_engine_material()
	visual.add_child(engine_mesh_instance)
	main_thruster_audio = AudioStreamPlayer3D.new()
	main_thruster_audio.name = "MainThrusterAudio"
	main_thruster_audio.stream = build_thruster_loop_stream(74.0, 128.0, 0.18, 0.36)
	main_thruster_audio.unit_size = 18.0
	main_thruster_audio.max_distance = 260.0
	main_thruster_audio.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
	main_thruster_audio.volume_db = -60.0
	main_thruster_audio.position = Vector3(0, 0.0, 3.2)
	visual.add_child(main_thruster_audio)
	main_thruster_audio.play()
	retro_thruster_audio = AudioStreamPlayer3D.new()
	retro_thruster_audio.name = "RetroThrusterAudio"
	retro_thruster_audio.stream = build_thruster_loop_stream(112.0, 188.0, 0.12, 0.24)
	retro_thruster_audio.unit_size = 18.0
	retro_thruster_audio.max_distance = 220.0
	retro_thruster_audio.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
	retro_thruster_audio.volume_db = -60.0
	retro_thruster_audio.position = Vector3(0, 0.0, -1.8)
	visual.add_child(retro_thruster_audio)
	retro_thruster_audio.play()
	build_navigation_lights()
	cockpit_interior_root = build_cockpit_interior()
	cockpit_interior_root.visible = false
	add_child(cockpit_interior_root)
	trail_mesh_instance = MeshInstance3D.new()
	trail_mesh_instance.name = "Trail"
	trail_mesh_instance.material_override = make_trail_material()
	add_child(trail_mesh_instance)
	trail_points.append(global_position)


func _physics_process(delta: float) -> void:
	if autopilot_pose_active:
		boost_active = false
		velocity = velocity.lerp(autopilot_target_velocity, min(delta * 4.4, 1.0))
		global_position = global_position.lerp(autopilot_target_position, min(delta * 3.8, 1.0))
		visual.global_basis = visual.global_basis.orthonormalized().slerp(
			autopilot_target_basis.orthonormalized(),
			clamp(delta * turn_speed * 0.8, 0.0, 1.0)
		)
		var local_target_velocity: Vector3 = visual.global_basis.orthonormalized().inverse() * autopilot_target_velocity
		forward_thrust_amount = clamp(-local_target_velocity.z / max(max_speed, 1.0), 0.0, 1.0)
		reverse_thrust_amount = clamp(local_target_velocity.z / max(max_speed, 1.0), 0.0, 1.0)
		cockpit_interior_root.global_transform = visual.global_transform
		update_engine_visual()
		update_engine_audio()
		update_navigation_lights()
		update_trail(delta)
		return

	mouse_look_priority_timer = max(mouse_look_priority_timer - delta, 0.0)
	if not control_lock:
		apply_keyboard_look(delta)
		apply_controller_look(delta)
		apply_touch_look(delta)
	else:
		look_input = Vector2.ZERO
		controller_look_state = controller_look_state.lerp(Vector2.ZERO, min(delta * controller_look_response, 1.0))
		touch_look_state = touch_look_state.lerp(Vector2.ZERO, min(delta * controller_look_response, 1.0))

	var move_input := get_flight_input() if not control_lock else Vector3.ZERO
	boost_active = Input.is_key_pressed(KEY_SHIFT) or is_controller_boost_pressed() or touch_boost_active
	if control_lock:
		boost_active = false
	var target_basis := Basis(Vector3.UP, yaw) * Basis(Vector3.RIGHT, pitch) * Basis(Vector3.BACK, roll)
	visual.global_basis = visual.global_basis.orthonormalized().slerp(
		target_basis.orthonormalized(),
		clamp(delta * turn_speed, 0.0, 1.0)
	)
	forward_thrust_amount = max(-move_input.z, 0.0)
	reverse_thrust_amount = max(move_input.z, 0.0)

	var thrust_vector := get_thrust_vector(move_input)
	velocity += (thrust_vector + gravity_acceleration) * delta
	var damping := boost_damping if boost_active else linear_damping
	velocity *= 1.0 / (1.0 + damping * delta)
	velocity = velocity.limit_length(max_speed * boost_multiplier if boost_active else max_speed)
	move_and_slide()

	global_position = wrap_position(global_position)
	cockpit_interior_root.global_transform = visual.global_transform
	update_engine_visual()
	update_engine_audio()
	update_navigation_lights()
	update_trail(delta)


func apply_look_input(delta_x: float, delta_y: float) -> void:
	look_input += Vector2(-delta_x * mouse_sensitivity, -delta_y * mouse_sensitivity)
	mouse_look_priority_timer = MOUSE_LOOK_PRIORITY_TIME


func apply_keyboard_look(delta: float) -> void:
	var keyboard_look := Vector2.ZERO
	if Input.is_key_pressed(KEY_LEFT):
		keyboard_look.x += keyboard_look_speed * delta
	if Input.is_key_pressed(KEY_RIGHT):
		keyboard_look.x -= keyboard_look_speed * delta
	if Input.is_key_pressed(KEY_UP):
		keyboard_look.y += keyboard_look_speed * delta * 0.75
	if Input.is_key_pressed(KEY_DOWN):
		keyboard_look.y -= keyboard_look_speed * delta * 0.75
	if Input.is_key_pressed(KEY_Q):
		roll += roll_speed * delta
	if Input.is_key_pressed(KEY_E):
		roll -= roll_speed * delta
	roll = wrapf(roll, -PI, PI)
	look_input += keyboard_look


func apply_controller_look(delta: float) -> void:
	var joypad := get_primary_joypad()
	if joypad != -1:
		var steer_x := apply_deadzone(Input.get_joy_axis(joypad, JOY_AXIS_LEFT_X))
		var steer_y := apply_deadzone(Input.get_joy_axis(joypad, JOY_AXIS_LEFT_Y))
		var target_look := Vector2(-steer_x * controller_look_speed.x, -steer_y * controller_look_speed.y)
		controller_look_state = controller_look_state.lerp(target_look, min(delta * controller_look_response, 1.0))
	else:
		controller_look_state = controller_look_state.lerp(Vector2.ZERO, min(delta * controller_look_response, 1.0))
	look_input += controller_look_state * delta
	yaw += look_input.x
	pitch = clamp(pitch + look_input.y, -0.95, 0.95)
	look_input = Vector2.ZERO


func apply_touch_look(delta: float) -> void:
	if touch_look_state.length() <= 0.001:
		return
	look_input += Vector2(-touch_look_state.x * controller_look_speed.x, -touch_look_state.y * controller_look_speed.y) * delta
	yaw += look_input.x
	pitch = clamp(pitch + look_input.y, -0.95, 0.95)
	look_input = Vector2.ZERO


func set_gravity_acceleration(value: Vector3) -> void:
	gravity_acceleration = value


func set_world_limit(value: Vector3) -> void:
	arena_limit = value


func set_physics_mode(mode: String) -> void:
	if mode == "real":
		forward_thrust = 220.0
		reverse_thrust = 140.0
		strafe_thrust = 155.0
		vertical_thrust = 155.0
		max_speed = 1400.0
		linear_damping = 0.035
		boost_multiplier = 1.28
		boost_damping = 0.02
		turn_speed = 7.5
	else:
		forward_thrust = 240.0
		reverse_thrust = 150.0
		strafe_thrust = 180.0
		vertical_thrust = 180.0
		max_speed = 680.0
		linear_damping = 0.12
		boost_multiplier = 1.55
		boost_damping = 0.08
		turn_speed = 9.8


func set_control_lock(enabled: bool) -> void:
	control_lock = enabled
	if enabled:
		look_input = Vector2.ZERO
		controller_look_state = Vector2.ZERO
		touch_look_state = Vector2.ZERO
		forward_thrust_amount = 0.0
		reverse_thrust_amount = 0.0


func set_autopilot_pose(active: bool, position: Vector3 = Vector3.ZERO, basis: Basis = Basis.IDENTITY, new_velocity: Vector3 = Vector3.ZERO) -> void:
	autopilot_pose_active = active
	if active:
		autopilot_target_position = position
		autopilot_target_basis = basis.orthonormalized()
		autopilot_target_velocity = new_velocity
	else:
		autopilot_target_velocity = Vector3.ZERO


func get_control_lock() -> bool:
	return control_lock


func toggle_motion_trail() -> bool:
	trail_enabled = not trail_enabled
	if not trail_enabled:
		trail_points.clear()
		trail_dirty = false
		trail_mesh_instance.mesh = null
	else:
		trail_points.clear()
		trail_points.append(global_position)
		trail_dirty = true
	return trail_enabled


func get_flight_input() -> Vector3:
	var input_direction := Vector3.ZERO

	if Input.is_key_pressed(KEY_A):
		input_direction.x -= 1.0
	if Input.is_key_pressed(KEY_D):
		input_direction.x += 1.0
	if Input.is_key_pressed(KEY_W):
		input_direction.z -= 1.0
	if Input.is_key_pressed(KEY_S):
		input_direction.z += 1.0
	if Input.is_key_pressed(KEY_R):
		input_direction.y += 1.0
	if Input.is_key_pressed(KEY_F):
		input_direction.y -= 1.0

	var joypad := get_primary_joypad()
	if joypad != -1:
		var forward_trigger: float = clamp(Input.get_joy_axis(joypad, JOY_AXIS_TRIGGER_RIGHT), 0.0, 1.0)
		var reverse_trigger: float = clamp(Input.get_joy_axis(joypad, JOY_AXIS_TRIGGER_LEFT), 0.0, 1.0)
		input_direction.z += reverse_trigger - forward_trigger

	input_direction += touch_move_input

	return input_direction.limit_length(1.0)


func set_touch_move_input(input_direction: Vector3) -> void:
	touch_move_input = input_direction.limit_length(1.0)


func set_touch_look_input(input_vector: Vector2) -> void:
	touch_look_state = input_vector.limit_length(1.0)


func set_touch_boost(active: bool) -> void:
	touch_boost_active = active


func get_primary_joypad() -> int:
	var joypads := Input.get_connected_joypads()
	if joypads.is_empty():
		return -1
	return int(joypads[0])


func apply_deadzone(value: float, deadzone: float = CONTROLLER_DEADZONE) -> float:
	if abs(value) < deadzone:
		return 0.0
	return sign(value) * ((abs(value) - deadzone) / max(1.0 - deadzone, 0.001))


func is_controller_boost_pressed() -> bool:
	var joypad := get_primary_joypad()
	if joypad == -1:
		return false
	return Input.is_joy_button_pressed(joypad, JOY_BUTTON_RIGHT_SHOULDER)


func get_thrust_vector(input_direction: Vector3) -> Vector3:
	var ship_basis := visual.global_basis.orthonormalized()
	var throttle_scale := boost_multiplier if boost_active else 1.0
	var thrust_vector := Vector3.ZERO
	thrust_vector += ship_basis.x * input_direction.x * strafe_thrust * throttle_scale
	thrust_vector += ship_basis.y * input_direction.y * vertical_thrust * throttle_scale

	if input_direction.z < 0.0:
		thrust_vector += -ship_basis.z * -input_direction.z * forward_thrust * throttle_scale
	elif input_direction.z > 0.0:
		thrust_vector += ship_basis.z * input_direction.z * reverse_thrust

	return thrust_vector


func get_visual_basis() -> Basis:
	return visual.global_basis.orthonormalized()


func get_aim_direction() -> Vector3:
	return -get_visual_basis().z.normalized()


func get_muzzle_position() -> Vector3:
	return global_position + get_aim_direction() * 7.4


func get_cockpit_position() -> Vector3:
	var ship_basis := get_visual_basis()
	return global_position + ship_basis * Vector3(0, 2.5, -6.2)


func get_true_cockpit_position() -> Vector3:
	var ship_basis := get_visual_basis()
	return global_position + ship_basis * Vector3(0, 2.15, -1.65)


func get_chase_target() -> Vector3:
	var ship_basis := get_visual_basis()
	return global_position + ship_basis * Vector3(0, 2.4, -42.0)


func get_chase_camera_anchor() -> Vector3:
	var ship_basis := get_visual_basis()
	return global_position + ship_basis * Vector3(0, 7.5, 18.0)


func set_camera_view(mode: int) -> void:
	cockpit_mode = mode
	if cockpit_interior_root != null:
		cockpit_interior_root.visible = mode == 2
	visual.visible = mode != 2


func set_spawn_orientation(forward: Vector3) -> void:
	var target_forward: Vector3 = forward.normalized()
	if target_forward.length() <= 0.001:
		target_forward = Vector3.FORWARD
	yaw = atan2(-target_forward.x, -target_forward.z)
	pitch = clamp(asin(target_forward.y), -0.95, 0.95)
	roll = 0.0
	var target_basis := Basis(Vector3.UP, yaw) * Basis(Vector3.RIGHT, pitch) * Basis(Vector3.BACK, roll)
	visual.global_basis = target_basis.orthonormalized()


func set_cockpit_style(shaded: bool, accent_color: Color) -> void:
	var frame_color := Color(0.08, 0.1, 0.13) if shaded else accent_color.lerp(Color.WHITE, 0.12)
	var glow_color := accent_color.lerp(Color(0.78, 0.9, 1.0), 0.28)
	for mesh in cockpit_frame_meshes:
		if mesh == null:
			continue
		mesh.material_override = make_cockpit_frame_material(shaded, frame_color)
	for mesh in cockpit_glow_meshes:
		if mesh == null:
			continue
		mesh.material_override = make_cockpit_glow_material(shaded, glow_color)
	for mesh in cockpit_canopy_meshes:
		if mesh == null:
			continue
		mesh.material_override = make_cockpit_canopy_material(shaded, glow_color)
	for light in cockpit_lights:
		if light == null:
			continue
		light.visible = shaded


func set_thruster_style(shaded: bool, accent_color: Color) -> void:
	thruster_shaded_mode = shaded
	thruster_accent_color = accent_color
	if engine_mesh_instance != null:
		engine_mesh_instance.material_override = make_engine_material()
	if trail_mesh_instance != null:
		trail_mesh_instance.material_override = make_trail_material()
	for mesh in navigation_light_meshes:
		if mesh != null:
			mesh.material_override = make_navigation_light_material(mesh.get_meta("nav_color", Color.WHITE), 1.0)
	for mesh in strobe_meshes:
		if mesh != null:
			mesh.material_override = make_navigation_light_material(Color.WHITE, 1.35)


func make_ship_material() -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(0.45, 0.88, 1.0)
	material.emission_enabled = true
	material.emission = Color(0.45, 0.88, 1.0)
	return material


func make_trail_material() -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var alpha := 0.86 if thruster_shaded_mode else 0.75
	material.albedo_color = Color(thruster_accent_color.r, thruster_accent_color.g, thruster_accent_color.b, alpha)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.emission_enabled = true
	material.emission = thruster_accent_color * (1.45 if thruster_shaded_mode else 1.0)
	return material


func make_engine_material() -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var alpha := 0.94 if thruster_shaded_mode else 0.8
	material.albedo_color = Color(thruster_accent_color.r, thruster_accent_color.g, thruster_accent_color.b, alpha)
	material.emission_enabled = true
	material.emission = thruster_accent_color * (1.85 if thruster_shaded_mode else 1.1)
	return material


func make_navigation_light_material(color: Color, intensity: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color * intensity * (1.1 if thruster_shaded_mode else 1.7)
	return material


func make_cockpit_frame_material(shaded: bool, color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	if shaded:
		material.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
		material.metallic = 0.58
		material.roughness = 0.32
	else:
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.emission_enabled = true
		material.emission = color * 0.65
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.albedo_color.a = 0.42
	return material


func make_cockpit_glow_material(shaded: bool, color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(color.r, color.g, color.b, 0.22 if shaded else 0.14)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.emission_enabled = true
	material.emission = color * (0.45 if shaded else 0.9)
	if shaded:
		material.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
		material.roughness = 0.04
	else:
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return material


func make_cockpit_canopy_material(shaded: bool, color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_DISABLED
	material.emission_enabled = true
	if shaded:
		material.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
		material.albedo_color = Color(color.r, color.g, color.b, 0.06)
		material.emission = color * 0.12
		material.roughness = 0.02
		material.metallic = 0.0
	else:
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.albedo_color = Color(color.r, color.g, color.b, 0.08)
		material.emission = color * 0.38
	return material


func update_engine_visual() -> void:
	var thrust_level: float = clamp(forward_thrust_amount + (0.26 if boost_active and forward_thrust_amount > 0.0 else 0.0), 0.0, 1.3)
	var speed_ratio: float = clamp(velocity.length() / max(max_speed, 1.0), 0.0, 1.0)
	var idle_length: float = lerp(0.16, 0.34, speed_ratio)
	var flare_length: float = lerp(idle_length, 2.3, thrust_level)
	if boost_active and forward_thrust_amount > 0.0:
		flare_length += 0.55
	var pulse := 0.88 + sin(Time.get_ticks_msec() * 0.012) * 0.08
	if thruster_shaded_mode:
		var width: float = lerp(0.56, 1.95, clamp(thrust_level * 0.95 + 0.08, 0.0, 1.0))
		engine_mesh_instance.scale = Vector3(width, width, max(flare_length * 2.35 * pulse, 0.12))
		engine_mesh_instance.position = Vector3(0, 0, 2.78 + flare_length * 0.62)
	else:
		var width: float = lerp(0.36, 1.0, clamp(thrust_level + 0.06, 0.0, 1.0))
		engine_mesh_instance.scale = Vector3(width, width, max(flare_length * pulse, 0.08))
		engine_mesh_instance.position = Vector3(0, 0, 2.26 + flare_length * 0.3)


func update_engine_audio() -> void:
	if main_thruster_audio != null:
		var forward_level: float = clamp(forward_thrust_amount + (0.22 if boost_active and forward_thrust_amount > 0.0 else 0.0), 0.0, 1.3)
		main_thruster_audio.volume_db = lerp(-42.0, -6.0, min(forward_level, 1.0))
		main_thruster_audio.pitch_scale = lerp(0.88, 1.32, min(forward_level, 1.0))
	if retro_thruster_audio != null:
		var retro_level: float = clamp(reverse_thrust_amount, 0.0, 1.0)
		retro_thruster_audio.volume_db = lerp(-44.0, -9.0, retro_level)
		retro_thruster_audio.pitch_scale = lerp(0.92, 1.08, retro_level)


func build_navigation_lights() -> void:
	var port_color := Color(1.0, 0.18, 0.16)
	var starboard_color := Color(0.18, 1.0, 0.32)
	for side in [-1.0, 1.0]:
		var nav_color := port_color if side < 0.0 else starboard_color
		var light_mesh := MeshInstance3D.new()
		light_mesh.name = "NavLight%s" % ("Port" if side < 0.0 else "Starboard")
		var mesh := SphereMesh.new()
		mesh.radius = 0.22
		mesh.height = 0.44
		light_mesh.mesh = mesh
		light_mesh.position = Vector3(3.35 * side, 0.2, -0.45)
		light_mesh.material_override = make_navigation_light_material(nav_color, 1.0)
		light_mesh.set_meta("nav_color", nav_color)
		visual.add_child(light_mesh)
		navigation_light_meshes.append(light_mesh)

		var omni := OmniLight3D.new()
		omni.light_color = nav_color
		omni.light_energy = 1.6
		omni.omni_range = 34.0
		omni.omni_attenuation = 1.8
		omni.position = light_mesh.position
		visual.add_child(omni)
		navigation_lights.append(omni)

	for offset in [Vector3(0.0, 1.05, 2.45), Vector3(0.0, 0.72, -2.1)]:
		var strobe_mesh := MeshInstance3D.new()
		strobe_mesh.name = "StrobeLight"
		var strobe_ball := SphereMesh.new()
		strobe_ball.radius = 0.24
		strobe_ball.height = 0.48
		strobe_mesh.mesh = strobe_ball
		strobe_mesh.position = offset
		strobe_mesh.material_override = make_navigation_light_material(Color.WHITE, 1.35)
		visual.add_child(strobe_mesh)
		strobe_meshes.append(strobe_mesh)

		var strobe := OmniLight3D.new()
		strobe.light_color = Color.WHITE
		strobe.light_energy = 4.6
		strobe.omni_range = 56.0
		strobe.omni_attenuation = 1.35
		strobe.position = offset
		visual.add_child(strobe)
		strobe_lights.append(strobe)


func update_navigation_lights() -> void:
	var pulse_time := Time.get_ticks_msec() * 0.001
	var nav_wave := 0.72 + 0.28 * sin(pulse_time * 0.8)
	var strobe_phase := fmod(pulse_time * 1.45, 1.0)
	var strobe_on := strobe_phase < 0.08 or (strobe_phase > 0.18 and strobe_phase < 0.24)
	for i in range(navigation_light_meshes.size()):
		var mesh := navigation_light_meshes[i]
		if mesh == null:
			continue
		var nav_color: Color = mesh.get_meta("nav_color", Color.WHITE)
		var material := mesh.material_override as StandardMaterial3D
		if material != null:
			material.emission = nav_color * (1.2 + nav_wave * (1.0 if thruster_shaded_mode else 1.8))
		if i < navigation_lights.size() and navigation_lights[i] != null:
			navigation_lights[i].light_energy = 1.2 + nav_wave * 0.9
	for mesh in strobe_meshes:
		if mesh == null:
			continue
		mesh.visible = strobe_on
		var material := mesh.material_override as StandardMaterial3D
		if material != null:
			material.emission = Color.WHITE * (3.6 if strobe_on else 0.18)
	for strobe in strobe_lights:
		if strobe == null:
			continue
		strobe.visible = strobe_on


func build_thruster_loop_stream(low_frequency: float, high_frequency: float, noise_mix: float, pulse_mix: float) -> AudioStreamWAV:
	var length := int(ENGINE_AUDIO_MIX_RATE * 1.4)
	var data := PackedByteArray()
	data.resize(length * 2)
	var phase_a := 0.0
	var phase_b := 0.0
	var pulse_phase := 0.0
	for i in range(length):
		phase_a += TAU * low_frequency / ENGINE_AUDIO_MIX_RATE
		phase_b += TAU * high_frequency / ENGINE_AUDIO_MIX_RATE
		pulse_phase += TAU * 6.0 / ENGINE_AUDIO_MIX_RATE
		var rumble: float = sin(phase_a) * 0.42 + sin(phase_b) * 0.16
		var pulse: float = sin(pulse_phase) * pulse_mix
		var hiss: float = randf_range(-1.0, 1.0) * noise_mix
		var sample: float = clamp((rumble + pulse + hiss) * 0.42, -1.0, 1.0)
		var pcm := int(round(sample * 32767.0))
		data[i * 2] = pcm & 0xFF
		data[i * 2 + 1] = (pcm >> 8) & 0xFF
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = ENGINE_AUDIO_MIX_RATE
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = data.size()
	stream.data = data
	stream.stereo = false
	return stream


func update_trail(delta: float) -> void:
	if not trail_enabled:
		trail_mesh_instance.mesh = null
		return
	trail_accumulator += delta
	var trail_interval := 0.028 if boost_active else 0.05
	if velocity.length() > 1.5 and trail_accumulator >= trail_interval:
		trail_accumulator = 0.0
		trail_points.append(global_position + get_visual_basis() * Vector3(0, 0, 2.8))
		while trail_points.size() > (26 if boost_active else 18):
			trail_points.remove_at(0)
		trail_dirty = true

	if not trail_dirty:
		return

	var vertices := PackedVector3Array()
	for i in range(trail_points.size() - 1):
		vertices.append(to_local(trail_points[i]))
		vertices.append(to_local(trail_points[i + 1]))

	if vertices.size() < 2:
		return

	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices

	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	trail_mesh_instance.mesh = mesh
	trail_dirty = false


func wrap_position(value: Vector3) -> Vector3:
	var wrapped := value
	if wrapped.x > arena_limit.x:
		wrapped.x = -arena_limit.x
	elif wrapped.x < -arena_limit.x:
		wrapped.x = arena_limit.x
	if wrapped.y > arena_limit.y:
		wrapped.y = -arena_limit.y
	elif wrapped.y < -arena_limit.y:
		wrapped.y = arena_limit.y
	if wrapped.z > arena_limit.z:
		wrapped.z = -arena_limit.z
	elif wrapped.z < -arena_limit.z:
		wrapped.z = arena_limit.z
	return wrapped


func build_ship_mesh() -> ArrayMesh:
	var vertices := PackedVector3Array([
		Vector3(0, 0, -2.4), Vector3(1.2, 0.5, 1.6),
		Vector3(1.2, 0.5, 1.6), Vector3(-1.2, 0.5, 1.6),
		Vector3(-1.2, 0.5, 1.6), Vector3(0, 0, -2.4),
		Vector3(0, 0, -2.4), Vector3(0, -0.7, 1.8),
		Vector3(0, -0.7, 1.8), Vector3(1.2, 0.5, 1.6),
		Vector3(0, -0.7, 1.8), Vector3(-1.2, 0.5, 1.6),
		Vector3(-2.3, 0, 0.7), Vector3(-1.0, 0.2, 1.2),
		Vector3(2.3, 0, 0.7), Vector3(1.0, 0.2, 1.2),
		Vector3(-2.3, 0, 0.7), Vector3(-0.7, 0, -0.5),
		Vector3(2.3, 0, 0.7), Vector3(0.7, 0, -0.5)
	])
	for i in range(vertices.size()):
		vertices[i] *= SHIP_VISUAL_SCALE

	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices

	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	return mesh


func build_ship_solid_mesh() -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var hull_color := Color(0.58, 0.84, 0.96)
	append_box_to_surface(
		st,
		Transform3D(Basis.IDENTITY, Vector3(0, 0.04, 0.1)),
		Vector3(1.7, 0.74, 6.1),
		hull_color.darkened(0.1)
	)
	append_box_to_surface(
		st,
		Transform3D(Basis.IDENTITY, Vector3(0, 0.44, -0.9)),
		Vector3(1.02, 0.46, 3.1),
		hull_color.lightened(0.03)
	)
	append_box_to_surface(
		st,
		Transform3D(Basis.IDENTITY, Vector3(0, -0.24, 2.0)),
		Vector3(1.1, 0.34, 2.3),
		hull_color.darkened(0.16)
	)
	append_box_to_surface(
		st,
		Transform3D(Basis.IDENTITY, Vector3(0, 0.22, 2.5)),
		Vector3(0.86, 0.22, 1.2),
		hull_color
	)

	for side in [-1.0, 1.0]:
		append_box_to_surface(
			st,
			Transform3D(Basis.IDENTITY, Vector3(1.84 * side, 0.0, 0.9)),
			Vector3(2.1, 0.18, 3.6),
			hull_color.darkened(0.04)
		)
		append_box_to_surface(
			st,
			Transform3D(Basis.IDENTITY, Vector3(1.08 * side, 0.34, 0.2)),
			Vector3(0.44, 0.72, 2.2),
			hull_color.lightened(0.02)
		)
		append_box_to_surface(
			st,
			Transform3D(Basis.IDENTITY, Vector3(2.45 * side, -0.1, 2.25)),
			Vector3(0.78, 0.34, 1.5),
			hull_color.darkened(0.12)
		)
		append_box_to_surface(
			st,
			Transform3D(Basis.IDENTITY, Vector3(0.78 * side, -0.36, 2.9)),
			Vector3(0.3, 0.54, 1.8),
			hull_color.darkened(0.2)
		)

	append_wedge_to_surface(
		st,
		Vector3(0, 0.5, -4.6),
		Vector3(0.0, 0.04, -6.7),
		Vector3(1.04, 0.36, -2.6),
		Vector3(-1.04, 0.36, -2.6),
		hull_color.lightened(0.1)
	)
	append_wedge_to_surface(
		st,
		Vector3(0, -0.22, -4.2),
		Vector3(0.0, -0.12, -6.4),
		Vector3(0.82, -0.12, -2.5),
		Vector3(-0.82, -0.12, -2.5),
		hull_color.darkened(0.2)
	)
	append_wedge_to_surface(
		st,
		Vector3(0, 0.58, 1.1),
		Vector3(0.0, 0.34, -2.2),
		Vector3(0.72, 0.52, 2.7),
		Vector3(-0.72, 0.52, 2.7),
		hull_color.lightened(0.06)
	)

	st.generate_normals()
	return st.commit()


func build_engine_mesh() -> ArrayMesh:
	var vertices := PackedVector3Array([
		Vector3(-0.36, -0.2, 0.0), Vector3(0.36, -0.2, 0.0),
		Vector3(0.36, -0.2, 0.0), Vector3(0.0, 0.0, 1.0),
		Vector3(0.0, 0.0, 1.0), Vector3(-0.36, -0.2, 0.0),
		Vector3(-0.24, 0.18, 0.0), Vector3(0.24, 0.18, 0.0),
		Vector3(0.24, 0.18, 0.0), Vector3(0.0, 0.0, 1.0),
		Vector3(0.0, 0.0, 1.0), Vector3(-0.24, 0.18, 0.0)
	])
	for i in range(vertices.size()):
		vertices[i] *= SHIP_VISUAL_SCALE

	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices

	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	return mesh


func build_cockpit_interior() -> Node3D:
	var root := Node3D.new()
	root.name = "CockpitInterior"
	var frame_material := make_cockpit_frame_material(true, Color(0.07, 0.09, 0.12))
	var glow_material := make_cockpit_glow_material(true, Color(0.34, 0.82, 1.0))
	var canopy_material := make_cockpit_canopy_material(true, Color(0.34, 0.82, 1.0))

	var rear_bulkhead := MeshInstance3D.new()
	var rear_bulkhead_mesh := BoxMesh.new()
	rear_bulkhead_mesh.size = Vector3(2.8, 2.4, 0.18)
	rear_bulkhead.mesh = rear_bulkhead_mesh
	rear_bulkhead.material_override = frame_material
	rear_bulkhead.position = Vector3(0, 1.62, 1.78)
	root.add_child(rear_bulkhead)
	cockpit_frame_meshes.append(rear_bulkhead)

	var seat_back := MeshInstance3D.new()
	var seat_back_mesh := BoxMesh.new()
	seat_back_mesh.size = Vector3(1.02, 1.22, 0.24)
	seat_back.mesh = seat_back_mesh
	seat_back.material_override = frame_material
	seat_back.position = Vector3(0, 1.32, 1.26)
	seat_back.rotation.x = deg_to_rad(-10.0)
	root.add_child(seat_back)
	cockpit_frame_meshes.append(seat_back)

	var seat_base := MeshInstance3D.new()
	var seat_base_mesh := BoxMesh.new()
	seat_base_mesh.size = Vector3(1.06, 0.18, 1.02)
	seat_base.mesh = seat_base_mesh
	seat_base.material_override = frame_material
	seat_base.position = Vector3(0, 0.78, 0.92)
	root.add_child(seat_base)
	cockpit_frame_meshes.append(seat_base)

	var canopy_roof := MeshInstance3D.new()
	var canopy_roof_mesh := BoxMesh.new()
	canopy_roof_mesh.size = Vector3(2.24, 0.1, 3.28)
	canopy_roof.mesh = canopy_roof_mesh
	canopy_roof.material_override = frame_material
	canopy_roof.position = Vector3(0, 2.84, -0.68)
	root.add_child(canopy_roof)
	cockpit_frame_meshes.append(canopy_roof)

	var windshield_header := MeshInstance3D.new()
	var windshield_header_mesh := BoxMesh.new()
	windshield_header_mesh.size = Vector3(1.92, 0.08, 0.14)
	windshield_header.mesh = windshield_header_mesh
	windshield_header.material_override = frame_material
	windshield_header.position = Vector3(0, 2.48, -2.54)
	root.add_child(windshield_header)
	cockpit_frame_meshes.append(windshield_header)

	var center_frame := MeshInstance3D.new()
	var center_mesh := BoxMesh.new()
	center_mesh.size = Vector3(0.1, 1.22, 0.12)
	center_frame.mesh = center_mesh
	center_frame.material_override = frame_material
	center_frame.position = Vector3(0, 1.96, -2.42)
	root.add_child(center_frame)
	cockpit_frame_meshes.append(center_frame)

	for side in [-1.0, 1.0]:
		var front_pillar := MeshInstance3D.new()
		var front_pillar_mesh := BoxMesh.new()
		front_pillar_mesh.size = Vector3(0.12, 1.34, 0.14)
		front_pillar.mesh = front_pillar_mesh
		front_pillar.material_override = frame_material
		front_pillar.position = Vector3(0.86 * side, 1.92, -2.34)
		front_pillar.rotation.z = deg_to_rad(-14.0 * side)
		root.add_child(front_pillar)
		cockpit_frame_meshes.append(front_pillar)

		var side_roof_rail := MeshInstance3D.new()
		var side_roof_rail_mesh := BoxMesh.new()
		side_roof_rail_mesh.size = Vector3(0.12, 0.1, 3.12)
		side_roof_rail.mesh = side_roof_rail_mesh
		side_roof_rail.material_override = frame_material
		side_roof_rail.position = Vector3(1.02 * side, 2.66, -0.82)
		root.add_child(side_roof_rail)
		cockpit_frame_meshes.append(side_roof_rail)

		var lower_window_sill := MeshInstance3D.new()
		var lower_window_sill_mesh := BoxMesh.new()
		lower_window_sill_mesh.size = Vector3(0.16, 0.16, 2.96)
		lower_window_sill.mesh = lower_window_sill_mesh
		lower_window_sill.material_override = frame_material
		lower_window_sill.position = Vector3(0.96 * side, 1.54, -0.72)
		root.add_child(lower_window_sill)
		cockpit_frame_meshes.append(lower_window_sill)

		var side_window := MeshInstance3D.new()
		var side_window_mesh := QuadMesh.new()
		side_window_mesh.size = Vector2(2.4, 1.05)
		side_window.mesh = side_window_mesh
		side_window.material_override = canopy_material
		side_window.position = Vector3(0.9 * side, 2.02, -0.96)
		side_window.rotation = Vector3(deg_to_rad(-3.0), deg_to_rad(90.0 * side), deg_to_rad(8.0 * side))
		root.add_child(side_window)
		cockpit_canopy_meshes.append(side_window)

		var windshield_pane := MeshInstance3D.new()
		var windshield_pane_mesh := QuadMesh.new()
		windshield_pane_mesh.size = Vector2(0.92, 1.42)
		windshield_pane.mesh = windshield_pane_mesh
		windshield_pane.material_override = canopy_material
		windshield_pane.position = Vector3(0.44 * side, 1.9, -2.5)
		windshield_pane.rotation = Vector3(deg_to_rad(-18.0), 0.0, deg_to_rad(9.0 * side))
		root.add_child(windshield_pane)
		cockpit_canopy_meshes.append(windshield_pane)

	for side in [-1.0, 1.0]:
		var side_frame := MeshInstance3D.new()
		var side_mesh := BoxMesh.new()
		side_mesh.size = Vector3(0.1, 0.92, 2.42)
		side_frame.mesh = side_mesh
		side_frame.material_override = frame_material
		side_frame.position = Vector3(0.96 * side, 1.98, 0.12)
		root.add_child(side_frame)
		cockpit_frame_meshes.append(side_frame)

		var side_console := MeshInstance3D.new()
		var console_mesh := BoxMesh.new()
		console_mesh.size = Vector3(0.98, 0.24, 2.26)
		side_console.mesh = console_mesh
		side_console.material_override = frame_material
		side_console.position = Vector3(0.72 * side, 1.04, -0.32)
		side_console.rotation = Vector3(deg_to_rad(3.0), 0.0, deg_to_rad(-20.0 * side))
		root.add_child(side_console)
		cockpit_frame_meshes.append(side_console)

		var side_console_light := MeshInstance3D.new()
		var side_light_mesh := BoxMesh.new()
		side_light_mesh.size = Vector3(0.74, 0.02, 0.92)
		side_console_light.mesh = side_light_mesh
		side_console_light.material_override = glow_material
		side_console_light.position = Vector3(0.61 * side, 1.18, -0.4)
		side_console_light.rotation = Vector3(deg_to_rad(3.0), 0.0, deg_to_rad(-20.0 * side))
		root.add_child(side_console_light)
		cockpit_glow_meshes.append(side_console_light)

		var side_screen := MeshInstance3D.new()
		var side_screen_mesh := QuadMesh.new()
		side_screen_mesh.size = Vector2(0.72, 0.46)
		side_screen.mesh = side_screen_mesh
		side_screen.material_override = glow_material
		side_screen.position = Vector3(0.54 * side, 1.26, -0.68)
		side_screen.rotation = Vector3(deg_to_rad(-72.0), 0.0, deg_to_rad(-18.0 * side))
		root.add_child(side_screen)
		cockpit_glow_meshes.append(side_screen)

	var dash := MeshInstance3D.new()
	var dash_mesh := BoxMesh.new()
	dash_mesh.size = Vector3(2.34, 0.42, 2.1)
	dash.mesh = dash_mesh
	dash.material_override = frame_material
	dash.position = Vector3(0, 1.28, -0.58)
	dash.rotation.x = deg_to_rad(7.0)
	root.add_child(dash)
	cockpit_frame_meshes.append(dash)

	var dash_hood := MeshInstance3D.new()
	var dash_hood_mesh := BoxMesh.new()
	dash_hood_mesh.size = Vector3(1.82, 0.18, 1.06)
	dash_hood.mesh = dash_hood_mesh
	dash_hood.material_override = frame_material
	dash_hood.position = Vector3(0, 1.66, -1.44)
	dash_hood.rotation.x = deg_to_rad(-18.0)
	root.add_child(dash_hood)
	cockpit_frame_meshes.append(dash_hood)

	var dash_glow := MeshInstance3D.new()
	var dash_glow_mesh := QuadMesh.new()
	dash_glow_mesh.size = Vector2(1.52, 0.54)
	dash_glow.mesh = dash_glow_mesh
	dash_glow.material_override = glow_material
	dash_glow.position = Vector3(0, 1.54, -1.14)
	dash_glow.rotation.x = deg_to_rad(-70.0)
	root.add_child(dash_glow)
	cockpit_glow_meshes.append(dash_glow)

	var center_mfd := MeshInstance3D.new()
	var center_mfd_mesh := QuadMesh.new()
	center_mfd_mesh.size = Vector2(0.62, 0.54)
	center_mfd.mesh = center_mfd_mesh
	center_mfd.material_override = glow_material
	center_mfd.position = Vector3(0, 1.48, -0.92)
	center_mfd.rotation.x = deg_to_rad(-68.0)
	root.add_child(center_mfd)
	cockpit_glow_meshes.append(center_mfd)

	var cockpit_floor := MeshInstance3D.new()
	var cockpit_floor_mesh := BoxMesh.new()
	cockpit_floor_mesh.size = Vector3(2.16, 0.14, 3.46)
	cockpit_floor.mesh = cockpit_floor_mesh
	cockpit_floor.material_override = frame_material
	cockpit_floor.position = Vector3(0, 0.66, 0.22)
	root.add_child(cockpit_floor)
	cockpit_frame_meshes.append(cockpit_floor)

	var footwell := MeshInstance3D.new()
	var footwell_mesh := BoxMesh.new()
	footwell_mesh.size = Vector3(1.2, 0.28, 1.86)
	footwell.mesh = footwell_mesh
	footwell.material_override = frame_material
	footwell.position = Vector3(0, 0.82, -0.92)
	root.add_child(footwell)
	cockpit_frame_meshes.append(footwell)

	var dash_flood := OmniLight3D.new()
	dash_flood.light_color = Color(0.5, 0.82, 1.0)
	dash_flood.light_energy = 0.45
	dash_flood.omni_range = 6.5
	dash_flood.omni_attenuation = 1.6
	dash_flood.position = Vector3(0, 1.72, -0.22)
	root.add_child(dash_flood)
	cockpit_lights.append(dash_flood)

	var ambient_fill := OmniLight3D.new()
	ambient_fill.light_color = Color(0.28, 0.52, 0.9)
	ambient_fill.light_energy = 0.7
	ambient_fill.omni_range = 7.8
	ambient_fill.omni_attenuation = 1.25
	ambient_fill.position = Vector3(0, 1.86, -0.38)
	root.add_child(ambient_fill)
	cockpit_lights.append(ambient_fill)

	var canopy_arch := MeshInstance3D.new()
	var arch_mesh := BoxMesh.new()
	arch_mesh.size = Vector3(2.06, 0.08, 0.12)
	canopy_arch.mesh = arch_mesh
	canopy_arch.material_override = frame_material
	canopy_arch.position = Vector3(0, 2.58, -1.46)
	root.add_child(canopy_arch)
	cockpit_frame_meshes.append(canopy_arch)

	var control_stick := MeshInstance3D.new()
	var control_stick_mesh := BoxMesh.new()
	control_stick_mesh.size = Vector3(0.12, 0.6, 0.12)
	control_stick.mesh = control_stick_mesh
	control_stick.material_override = frame_material
	control_stick.position = Vector3(0, 1.0, -0.6)
	control_stick.rotation.x = deg_to_rad(8.0)
	root.add_child(control_stick)
	cockpit_frame_meshes.append(control_stick)

	var control_head := MeshInstance3D.new()
	var control_head_mesh := BoxMesh.new()
	control_head_mesh.size = Vector3(0.34, 0.12, 0.24)
	control_head.mesh = control_head_mesh
	control_head.material_override = frame_material
	control_head.position = Vector3(0, 1.32, -0.68)
	root.add_child(control_head)
	cockpit_frame_meshes.append(control_head)

	for side in [-1.0, 1.0]:
		var canopy_light := OmniLight3D.new()
		canopy_light.light_color = Color(0.24, 0.38, 0.62)
		canopy_light.light_energy = 0.4
		canopy_light.omni_range = 5.8
		canopy_light.omni_attenuation = 2.1
		canopy_light.position = Vector3(0.72 * side, 2.18, -1.34)
		root.add_child(canopy_light)
		cockpit_lights.append(canopy_light)

		var console_fill := OmniLight3D.new()
		console_fill.light_color = Color(0.2, 0.46, 0.86)
		console_fill.light_energy = 0.22
		console_fill.omni_range = 3.8
		console_fill.omni_attenuation = 1.7
		console_fill.position = Vector3(0.7 * side, 1.02, -0.34)
		root.add_child(console_fill)
		cockpit_lights.append(console_fill)

	var status_colors := [
		Color(0.26, 0.9, 1.0),
		Color(0.26, 1.0, 0.6),
		Color(1.0, 0.44, 0.24)
	]
	for i in range(status_colors.size()):
		var indicator := MeshInstance3D.new()
		var indicator_mesh := SphereMesh.new()
		indicator_mesh.radius = 0.045
		indicator_mesh.height = 0.09
		indicator.mesh = indicator_mesh
		var indicator_material := StandardMaterial3D.new()
		indicator_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		indicator_material.emission_enabled = true
		indicator_material.emission = status_colors[i] * 1.4
		indicator_material.albedo_color = status_colors[i]
		indicator.material_override = indicator_material
		indicator.position = Vector3(-0.28 + i * 0.28, 1.57, -0.52)
		root.add_child(indicator)
		cockpit_glow_meshes.append(indicator)

	return root


func append_box_to_surface(st: SurfaceTool, transform: Transform3D, size: Vector3, color: Color) -> void:
	var extents := size * 0.5
	var corners := [
		Vector3(-extents.x, -extents.y, -extents.z),
		Vector3(extents.x, -extents.y, -extents.z),
		Vector3(extents.x, extents.y, -extents.z),
		Vector3(-extents.x, extents.y, -extents.z),
		Vector3(-extents.x, -extents.y, extents.z),
		Vector3(extents.x, -extents.y, extents.z),
		Vector3(extents.x, extents.y, extents.z),
		Vector3(-extents.x, extents.y, extents.z)
	]
	for i in range(corners.size()):
		corners[i] = transform * corners[i]

	append_quad(st, corners[0], corners[1], corners[2], corners[3], color.darkened(0.08))
	append_quad(st, corners[5], corners[4], corners[7], corners[6], color)
	append_quad(st, corners[4], corners[0], corners[3], corners[7], color.darkened(0.14))
	append_quad(st, corners[1], corners[5], corners[6], corners[2], color.lightened(0.03))
	append_quad(st, corners[3], corners[2], corners[6], corners[7], color.lightened(0.08))
	append_quad(st, corners[4], corners[5], corners[1], corners[0], color.darkened(0.2))


func append_wedge_to_surface(st: SurfaceTool, top: Vector3, nose: Vector3, right: Vector3, left: Vector3, color: Color) -> void:
	append_triangle(st, top, right, nose, color.lightened(0.06))
	append_triangle(st, top, nose, left, color.lightened(0.02))
	append_triangle(st, left, nose, right, color.darkened(0.16))
	append_triangle(st, left, right, top, color.darkened(0.08))


func append_quad(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, color: Color) -> void:
	append_triangle(st, a, b, c, color)
	append_triangle(st, a, c, d, color)


func append_triangle(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, color: Color) -> void:
	st.set_color(color)
	st.add_vertex(a)
	st.set_color(color)
	st.add_vertex(b)
	st.set_color(color)
	st.add_vertex(c)
