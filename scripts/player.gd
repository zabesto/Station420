extends CharacterBody3D

const SHIP_VISUAL_SCALE := 1.6
const CONTROLLER_DEADZONE := 0.18

@export var thrust := 170.0
@export var max_speed := 440.0
@export var damping := 0.42
@export var boost_multiplier := 1.85
@export var boost_damping := 0.24
@export var turn_speed := 4.8
@export var banking_angle := 0.38
@export var pitch_angle := 0.22
@export var arena_limit := Vector3(8400, 1800, 8400)

@onready var visual: MeshInstance3D = $Visual

var trail_points := PackedVector3Array()
var trail_mesh_instance: MeshInstance3D
var trail_accumulator := 0.0
var gravity_acceleration := Vector3.ZERO
var engine_mesh_instance: MeshInstance3D
var boost_active := false


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
	var input_direction := get_flight_input()
	boost_active = Input.is_key_pressed(KEY_SHIFT) or is_controller_boost_pressed()
	var current_thrust := thrust * boost_multiplier if boost_active else thrust
	var thrust_vector := input_direction.normalized() * current_thrust if input_direction.length() > 0.0 else Vector3.ZERO
	velocity += (thrust_vector + gravity_acceleration) * delta
	var current_damping := boost_damping if boost_active else damping
	velocity *= 1.0 / (1.0 + current_damping * delta)
	velocity = velocity.limit_length(max_speed * boost_multiplier if boost_active else max_speed)
	move_and_slide()

	global_position = wrap_position(global_position)
	update_visual_orientation(delta, input_direction)
	update_engine_visual(delta)

	update_trail(delta, input_direction)


func set_gravity_acceleration(value: Vector3) -> void:
	gravity_acceleration = value


func set_world_limit(value: Vector3) -> void:
	arena_limit = value


func get_flight_input() -> Vector3:
	var input_direction := Vector3.ZERO

	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		input_direction.x -= 1.0
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		input_direction.x += 1.0
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		input_direction.z -= 1.0
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		input_direction.z += 1.0
	if Input.is_key_pressed(KEY_R):
		input_direction.y += 1.0
	if Input.is_key_pressed(KEY_F):
		input_direction.y -= 1.0

	var joypad := get_primary_joypad()
	if joypad != -1:
		var stick_x := apply_deadzone(Input.get_joy_axis(joypad, JOY_AXIS_LEFT_X))
		var stick_y := apply_deadzone(Input.get_joy_axis(joypad, JOY_AXIS_LEFT_Y))
		var rise: float = clamp(Input.get_joy_axis(joypad, JOY_AXIS_TRIGGER_RIGHT), 0.0, 1.0)
		var descend: float = clamp(Input.get_joy_axis(joypad, JOY_AXIS_TRIGGER_LEFT), 0.0, 1.0)
		input_direction.x += stick_x
		input_direction.z += stick_y
		input_direction.y += rise - descend

	return input_direction.limit_length(1.0)


func get_primary_joypad() -> int:
	var joypads := Input.get_connected_joypads()
	if joypads.is_empty():
		return -1
	return int(joypads[0])


func apply_deadzone(value: float) -> float:
	if abs(value) < CONTROLLER_DEADZONE:
		return 0.0
	return value


func is_controller_boost_pressed() -> bool:
	var joypad := get_primary_joypad()
	if joypad == -1:
		return false
	return Input.is_joy_button_pressed(joypad, JOY_BUTTON_RIGHT_SHOULDER)


func get_aim_direction() -> Vector3:
	return -visual.global_basis.z.normalized()


func get_muzzle_position() -> Vector3:
	return global_position + get_aim_direction() * 7.4


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


func update_visual_orientation(delta: float, input_direction: Vector3) -> void:
	var desired_forward := -visual.global_basis.z
	if velocity.length() > 12.0:
		desired_forward = velocity.normalized()
	elif input_direction.length() > 0.05:
		desired_forward = input_direction.normalized()
	elif gravity_acceleration.length() > 0.1:
		desired_forward = (desired_forward + gravity_acceleration.normalized() * 0.15).normalized()

	var target_basis := Basis.looking_at(desired_forward, Vector3.UP)
	var local_input := global_basis.inverse() * input_direction
	var bank := -local_input.x * banking_angle
	var pitch := local_input.z * pitch_angle + local_input.y * pitch_angle * 0.7
	target_basis = target_basis.rotated(target_basis.z.normalized(), bank)
	target_basis = target_basis.rotated(target_basis.x.normalized(), pitch)
	visual.global_basis = visual.global_basis.orthonormalized().slerp(target_basis.orthonormalized(), clamp(delta * turn_speed, 0.0, 1.0))


func update_engine_visual(delta: float) -> void:
	var speed_ratio: float = clamp(velocity.length() / max_speed, 0.0, 1.6)
	var flare_length: float = lerp(0.75, 2.3, speed_ratio)
	if boost_active:
		flare_length += 0.85
	var pulse := 0.88 + sin(Time.get_ticks_msec() * 0.012) * 0.08
	engine_mesh_instance.scale = Vector3(1.0, 1.0, flare_length * pulse)
	engine_mesh_instance.position = Vector3(0, 0, 2.5 + flare_length * 0.35)


func update_trail(delta: float, input_direction: Vector3) -> void:
	trail_accumulator += delta
	var trail_interval := 0.028 if boost_active else 0.05
	if velocity.length() > 1.5 and trail_accumulator >= trail_interval:
		trail_accumulator = 0.0
		trail_points.append(global_position + Vector3(0, 0, 2.8))
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
