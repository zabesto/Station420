extends Node3D

const WORLD_LIMIT := Vector3(4800, 1200, 4800)
const CAMERA_OFFSET := Vector3(0, 86, 150)
const STAR_MASS := 620000.0
const STAR_RADIUS := 90.0
const SHIP_GRAVITY_SCALE := 0.32
const GRAVITY_CONSTANT := 2.4
const GRAVITY_SOFTENING := 1200.0

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
@onready var camera: Camera3D = $Camera3D
@onready var title_label: Label = $CanvasLayer/HUD/TitleLabel
@onready var dock_label: Label = $CanvasLayer/HUD/DockLabel
@onready var cargo_label: Label = $CanvasLayer/HUD/CargoLabel
@onready var objective_label: Label = $CanvasLayer/HUD/ObjectiveLabel
@onready var scanner_label: Label = $CanvasLayer/HUD/ScannerLabel
@onready var message_label: Label = $CanvasLayer/HUD/MessageLabel

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


func _ready() -> void:
	player.call("set_world_limit", WORLD_LIMIT)
	create_starfield()
	create_star()
	create_planets()
	create_stations()
	create_objective_visuals()
	setup_cargo_route()

	if station_order.size() > 0:
		player.global_position = station_order[0].global_position + Vector3(0, 0, 30)

	update_status("WASD move, R/F rise and descend.\nEverything orbits the star now, so distances are much larger.")


func _process(delta: float) -> void:
	update_camera(delta)
	update_objective_visuals(delta)
	update_scanner()


func _physics_process(delta: float) -> void:
	simulate_planets(delta)
	player.call("set_gravity_acceleration", compute_ship_gravity() * SHIP_GRAVITY_SCALE)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
		if nearby_station:
			dock_at_station(nearby_station)
		else:
			update_status("No station in range.\nApproach a station halo, then press E to dock.")


func create_starfield() -> void:
	var stars := MeshInstance3D.new()
	stars.name = "Stars"
	stars.mesh = build_star_mesh()
	stars.material_override = make_line_material(Color(0.82, 0.9, 1.0))
	add_child(stars)


func create_star() -> void:
	star_node = Node3D.new()
	star_node.name = "HeliosPrime"
	add_child(star_node)

	var star_mesh := MeshInstance3D.new()
	star_mesh.mesh = build_planet_mesh(STAR_RADIUS)
	star_mesh.material_override = make_line_material(Color(1.0, 0.84, 0.28))
	star_node.add_child(star_mesh)

	var star_halo := MeshInstance3D.new()
	star_halo.mesh = build_ring_mesh(STAR_RADIUS * 1.5, 48)
	star_halo.material_override = make_line_material(Color(1.0, 0.64, 0.18))
	star_halo.rotation = Vector3(PI * 0.5, 0, 0)
	star_node.add_child(star_halo)

	var star_label := Label3D.new()
	star_label.position = Vector3(0, STAR_RADIUS + 18, 0)
	star_label.text = "Helios Prime"
	star_label.font_size = 48
	star_label.no_depth_test = true
	star_node.add_child(star_label)


func create_planets() -> void:
	var planets_root := Node3D.new()
	planets_root.name = "Planets"
	add_child(planets_root)

	for planet_data in PLANET_LAYOUT:
		var root := Node3D.new()
		root.name = planet_data["name"]

		var orbit_radius := float(planet_data["orbit_radius"])
		var phase := float(planet_data["phase"])
		var tilt := float(planet_data["tilt"])
		var y_position := sin(phase * 1.7) * orbit_radius * tilt
		var start_position := Vector3(cos(phase) * orbit_radius, y_position, sin(phase) * orbit_radius)
		root.position = start_position

		var planet_mesh := MeshInstance3D.new()
		planet_mesh.mesh = build_planet_mesh(planet_data["radius"])
		planet_mesh.material_override = make_line_material(planet_data["color"])
		root.add_child(planet_mesh)

		var orbit_ring := MeshInstance3D.new()
		orbit_ring.mesh = build_ring_mesh(orbit_radius, 96)
		orbit_ring.material_override = make_line_material(planet_data["orbit_tint"])
		orbit_ring.rotation = Vector3(tilt, 0, 0)
		add_child(orbit_ring)

		var planet_label := Label3D.new()
		planet_label.position = Vector3(0, planet_data["radius"] + 12.0, 0)
		planet_label.text = planet_data["name"]
		planet_label.font_size = 42
		planet_label.no_depth_test = true
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
			"mass": planet_data["mass"],
			"radius": planet_data["radius"],
			"velocity": velocity
		}
		planet_bodies.append(body)
		planet_nodes_by_name[planet_data["name"]] = root


func create_stations() -> void:
	for station_data in STATION_LAYOUT:
		var parent_planet: Node3D = planet_nodes_by_name[station_data["planet"]]
		var orbit_anchor := Node3D.new()
		orbit_anchor.name = "%sAnchor" % station_data["name"]
		orbit_anchor.position = station_data["offset"]
		parent_planet.add_child(orbit_anchor)

		var station := Area3D.new()
		station.name = station_data["name"]
		station.collision_layer = 0
		station.collision_mask = 1
		station.set_meta("station_name", station_data["name"])
		station.set_meta("planet_name", station_data["planet"])
		station.set_meta("dock_offset", Vector3(0, 0, 18))
		station.body_entered.connect(_on_station_body_entered.bind(station))
		station.body_exited.connect(_on_station_body_exited.bind(station))
		orbit_anchor.add_child(station)

		var collision := CollisionShape3D.new()
		var shape := SphereShape3D.new()
		shape.radius = 12.0
		collision.shape = shape
		station.add_child(collision)

		var wireframe := MeshInstance3D.new()
		wireframe.mesh = build_station_mesh(14.0)
		wireframe.material_override = make_line_material(Color(1.0, 0.72, 0.34))
		station.add_child(wireframe)

		var dock_marker := MeshInstance3D.new()
		dock_marker.position = Vector3(0, 0, 18)
		dock_marker.mesh = build_dock_marker_mesh(3.2)
		dock_marker.material_override = make_line_material(Color(0.55, 1.0, 0.85))
		station.add_child(dock_marker)

		var station_label := Label3D.new()
		station_label.position = Vector3(0, 16.0, 0)
		station_label.text = station_data["name"]
		station_label.font_size = 36
		station_label.no_depth_test = true
		station.add_child(station_label)

		station_order.append(station)
		station_nodes_by_name[station_data["name"]] = station


func create_objective_visuals() -> void:
	objective_line = MeshInstance3D.new()
	objective_line.name = "ObjectiveLine"
	objective_line.material_override = make_line_material(Color(0.5, 0.95, 0.7))
	add_child(objective_line)

	objective_marker = MeshInstance3D.new()
	objective_marker.name = "ObjectiveMarker"
	objective_marker.material_override = make_line_material(Color(0.45, 1.0, 0.85))
	add_child(objective_marker)


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


func dock_at_station(station: Area3D) -> void:
	player.global_position = station.global_position + station.get_meta("dock_offset")
	player.velocity = Vector3.ZERO
	dock_count += 1
	objective_flash_time = 0.35

	var station_name := str(station.get_meta("station_name"))
	title_label.text = "Docked"
	dock_label.text = "Docked: %s (%d)" % [station_name, dock_count]
	handle_cargo_dock(station_name)


func update_status(message: String) -> void:
	message_label.text = message


func update_camera(delta: float) -> void:
	var desired := player.global_position + CAMERA_OFFSET
	camera.global_position = camera.global_position.lerp(desired, min(delta * 1.45, 1.0))
	camera.look_at(player.global_position + Vector3(0, 8, -18), Vector3.UP)


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
	objective_line.material_override = make_line_material(line_color)
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
		update_status("WASD move, R/F rise and descend.\nPlanets and stations are on star orbits now.")


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


func build_star_mesh() -> ArrayMesh:
	var vertices := PackedVector3Array()
	var rng := RandomNumberGenerator.new()
	rng.seed = 4606

	for i in range(380):
		var center := Vector3(
			rng.randf_range(-WORLD_LIMIT.x, WORLD_LIMIT.x),
			rng.randf_range(-WORLD_LIMIT.y, WORLD_LIMIT.y),
			rng.randf_range(-WORLD_LIMIT.z, WORLD_LIMIT.z)
		)
		var size := rng.randf_range(0.45, 2.0)
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
	var zf := size * 0.7
	var zb := -size * 0.7
	var inner := size * 0.4
	var vertices := PackedVector3Array([
		Vector3(-s, -s, zf), Vector3(s, -s, zf),
		Vector3(s, -s, zf), Vector3(s, s, zf),
		Vector3(s, s, zf), Vector3(-s, s, zf),
		Vector3(-s, s, zf), Vector3(-s, -s, zf),
		Vector3(-s, -s, zb), Vector3(s, -s, zb),
		Vector3(s, -s, zb), Vector3(s, s, zb),
		Vector3(s, s, zb), Vector3(-s, s, zb),
		Vector3(-s, s, zb), Vector3(-s, -s, zb),
		Vector3(-s, -s, zf), Vector3(-s, -s, zb),
		Vector3(s, -s, zf), Vector3(s, -s, zb),
		Vector3(s, s, zf), Vector3(s, s, zb),
		Vector3(-s, s, zf), Vector3(-s, s, zb),
		Vector3(-inner, -inner, 0), Vector3(inner, -inner, 0),
		Vector3(inner, -inner, 0), Vector3(inner, inner, 0),
		Vector3(inner, inner, 0), Vector3(-inner, inner, 0),
		Vector3(-inner, inner, 0), Vector3(-inner, -inner, 0)
	])
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
