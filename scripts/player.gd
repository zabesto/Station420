extends CharacterBody3D

@export var thrust := 110.0
@export var max_speed := 260.0
@export var damping := 0.55
@export var arena_limit := Vector3(4800, 1200, 4800)

@onready var visual: MeshInstance3D = $Visual

var trail_points := PackedVector3Array()
var trail_mesh_instance: MeshInstance3D
var trail_accumulator := 0.0
var gravity_acceleration := Vector3.ZERO


func _ready() -> void:
	visual.mesh = build_ship_mesh()
	visual.material_override = make_ship_material()
	trail_mesh_instance = MeshInstance3D.new()
	trail_mesh_instance.name = "Trail"
	trail_mesh_instance.material_override = make_trail_material()
	add_child(trail_mesh_instance)
	trail_points.append(global_position)


func _physics_process(delta: float) -> void:
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

	var thrust_vector := input_direction.normalized() * thrust if input_direction.length() > 0.0 else Vector3.ZERO
	velocity += (thrust_vector + gravity_acceleration) * delta
	velocity *= 1.0 / (1.0 + damping * delta)
	velocity = velocity.limit_length(max_speed)
	move_and_slide()

	global_position = wrap_position(global_position)

	if input_direction.length() > 0.05:
		visual.look_at(global_position + input_direction + gravity_acceleration * 0.03, Vector3.UP, true)
	elif velocity.length() > 0.2:
		visual.look_at(global_position + velocity.normalized(), Vector3.UP, true)

	update_trail(delta, input_direction)


func set_gravity_acceleration(value: Vector3) -> void:
	gravity_acceleration = value


func set_world_limit(value: Vector3) -> void:
	arena_limit = value


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


func update_trail(delta: float, input_direction: Vector3) -> void:
	trail_accumulator += delta
	if velocity.length() > 1.5 and trail_accumulator >= 0.05:
		trail_accumulator = 0.0
		trail_points.append(global_position + Vector3(0, 0, 1.6))
		while trail_points.size() > 18:
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

	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices

	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	return mesh
