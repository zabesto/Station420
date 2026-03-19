extends CharacterBody3D

const SHIP_VISUAL_SCALE := 1.6
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
@export var banking_angle := 0.24
@export var pitch_angle := 0.12
@export var arena_limit := Vector3(8400, 1800, 8400)

@onready var visual: MeshInstance3D = $Visual

var solid_hull_instance: MeshInstance3D
var trail_points := PackedVector3Array()
var trail_mesh_instance: MeshInstance3D
var trail_accumulator := 0.0
var gravity_acceleration := Vector3.ZERO
var engine_mesh_instance: MeshInstance3D
var boost_active := false
var trail_enabled := false
var yaw := 0.0
var pitch := 0.0
var look_input := Vector2.ZERO
var mouse_look_priority_timer := 0.0
var controller_look_state := Vector2.ZERO
var cockpit_render_active := false


func _ready() -> void:
	visual.mesh = build_ship_mesh()
	visual.material_override = make_ship_material()
	engine_mesh_instance = MeshInstance3D.new()
	engine_mesh_instance.name = "EngineGlow"
	engine_mesh_instance.position = Vector3(0, 0, 3.0)
	engine_mesh_instance.mesh = build_engine_mesh()
	engine_mesh_instance.material_override = make_engine_material()
	visual.add_child(engine_mesh_instance)
	trail_mesh_instance = MeshInstance3D.new()
	trail_mesh_instance.name = "Trail"
	trail_mesh_instance.material_override = make_trail_material()
	add_child(trail_mesh_instance)
	trail_points.append(global_position)


func _physics_process(delta: float) -> void:
	mouse_look_priority_timer = max(mouse_look_priority_timer - delta, 0.0)
	apply_keyboard_look(delta)
	apply_controller_look(delta)

	var move_input := get_flight_input()
	boost_active = Input.is_key_pressed(KEY_SHIFT) or is_controller_boost_pressed()
	var target_basis := Basis(Vector3.UP, yaw) * Basis(Vector3.RIGHT, pitch)
	visual.global_basis = visual.global_basis.orthonormalized().slerp(
		target_basis.orthonormalized(),
		clamp(delta * turn_speed, 0.0, 1.0)
	)

	var thrust_vector := get_thrust_vector(move_input)
	velocity += (thrust_vector + gravity_acceleration) * delta
	var damping := boost_damping if boost_active else linear_damping
	velocity *= 1.0 / (1.0 + damping * delta)
	velocity = velocity.limit_length(max_speed * boost_multiplier if boost_active else max_speed)
	move_and_slide()

	global_position = wrap_position(global_position)
	update_engine_visual()
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
	look_input += keyboard_look


func apply_controller_look(delta: float) -> void:
	if mouse_look_priority_timer > 0.0:
		controller_look_state = controller_look_state.lerp(Vector2.ZERO, min(delta * controller_look_response, 1.0))
		yaw += look_input.x
		pitch = clamp(pitch + look_input.y, -0.95, 0.95)
		look_input = Vector2.ZERO
		return

	var joypad := get_primary_joypad()
	if joypad != -1:
		var look_x := apply_deadzone(Input.get_joy_axis(joypad, JOY_AXIS_RIGHT_X), CONTROLLER_LOOK_DEADZONE)
		var look_y := apply_deadzone(Input.get_joy_axis(joypad, JOY_AXIS_RIGHT_Y), CONTROLLER_LOOK_DEADZONE)
		var target_look := Vector2(-look_x * controller_look_speed.x, -look_y * controller_look_speed.y)
		controller_look_state = controller_look_state.lerp(target_look, min(delta * controller_look_response, 1.0))
	else:
		controller_look_state = controller_look_state.lerp(Vector2.ZERO, min(delta * controller_look_response, 1.0))

	look_input += controller_look_state * delta

	yaw += look_input.x
	pitch = clamp(pitch + look_input.y, -0.95, 0.95)
	look_input = Vector2.ZERO


func set_gravity_acceleration(value: Vector3) -> void:
	gravity_acceleration = value


func set_world_limit(value: Vector3) -> void:
	arena_limit = value


func toggle_motion_trail() -> bool:
	trail_enabled = not trail_enabled
	if not trail_enabled:
		trail_points.clear()
		trail_mesh_instance.mesh = null
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
		var move_x := apply_deadzone(Input.get_joy_axis(joypad, JOY_AXIS_LEFT_X))
		var move_y := apply_deadzone(Input.get_joy_axis(joypad, JOY_AXIS_LEFT_Y))
		var rise: float = clamp(Input.get_joy_axis(joypad, JOY_AXIS_TRIGGER_RIGHT), 0.0, 1.0)
		var descend: float = clamp(Input.get_joy_axis(joypad, JOY_AXIS_TRIGGER_LEFT), 0.0, 1.0)
		input_direction.x += move_x
		input_direction.z += move_y
		input_direction.y += rise - descend

	return input_direction.limit_length(1.0)


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
	return global_position + ship_basis * Vector3(0, 2.8, -1.8)


func get_chase_target() -> Vector3:
	var ship_basis := get_visual_basis()
	return global_position + ship_basis * Vector3(0, 2.4, -42.0)


func set_cockpit_render(active: bool) -> void:
	cockpit_render_active = active


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
	material.albedo_color = Color(0.55, 0.95, 1.0, 0.75)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.emission_enabled = true
	material.emission = Color(0.4, 0.85, 1.0)
	return material


func make_engine_material() -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(0.45, 0.9, 1.0, 0.8)
	material.emission_enabled = true
	material.emission = Color(0.5, 0.95, 1.0)
	return material


func update_engine_visual() -> void:
	var speed_ratio: float = clamp(velocity.length() / max_speed, 0.0, 1.6)
	var flare_length: float = lerp(0.75, 2.3, speed_ratio)
	if boost_active:
		flare_length += 0.85
	var pulse := 0.88 + sin(Time.get_ticks_msec() * 0.012) * 0.08
	engine_mesh_instance.scale = Vector3(1.0, 1.0, flare_length * pulse)
	engine_mesh_instance.position = Vector3(0, 0, 2.5 + flare_length * 0.35)


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


func build_ship_solid_mesh() -> BoxMesh:
	var mesh := BoxMesh.new()
	mesh.size = Vector3(3.8, 1.5, 7.4)
	return mesh


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
