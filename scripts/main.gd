extends Node3D

const WORLD_LIMIT := Vector3(4800, 1200, 4800)
const CAMERA_OFFSET := Vector3(0, 76, 136)
const CAMERA_VELOCITY_LEAD := 0.18
const STAR_MASS := 620000.0
const STAR_RADIUS := 90.0
const SHIP_GRAVITY_SCALE := 0.32
const GRAVITY_CONSTANT := 2.4
const GRAVITY_SOFTENING := 1200.0
const PLAYER_FIRE_COOLDOWN := 0.18
const PLAYER_PROJECTILE_SPEED := 860.0
const ENEMY_PROJECTILE_SPEED := 420.0
const ENEMY_RESPAWN_TIME := 6.0
const ENEMY_ENGAGE_RADIUS := 860.0
const ENEMY_FIRE_RADIUS := 560.0
const PLAYER_MAX_HULL := 100.0
const PLAYER_MAX_SHIELDS := 100.0
const SHIELD_RECHARGE_RATE := 10.0
const SHIELD_RECHARGE_DELAY := 2.6
const STAR_DAMAGE_RADIUS := 210.0
const STAR_DAMAGE_PER_SECOND := 34.0
const DEBRIS_HAZARD_THICKNESS := 26.0
const DEBRIS_DAMAGE_PER_SECOND := 11.0
const ENEMY_MAX_HULL := 40.0
const PLAYER_PROJECTILE_DAMAGE := 20.0
const ENEMY_PROJECTILE_DAMAGE := 16.0
const ENEMY_CONTACT_DAMAGE := 24.0
const PLAYER_FIRE_RANGE := 1200.0
const ENEMY_SPAWN_COUNT := 4
const PLAYER_COLLISION_RADIUS := 6.0
const PLANET_COLLISION_MARGIN := 8.0
const STAR_COLLISION_MARGIN := 18.0
const STATION_COLLISION_RADIUS := 10.0

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
@onready var combat_label: Label = $CanvasLayer/HUD/CombatLabel
@onready var alert_label: Label = $CanvasLayer/HUD/AlertLabel
@onready var pause_label: Label = $CanvasLayer/HUD/PauseLabel

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
var enemy_nodes := []
var player_projectiles := []
var enemy_projectiles := []
var transient_effects := []
var player_hull := PLAYER_MAX_HULL
var player_shields := PLAYER_MAX_SHIELDS
var kills := 0
var score := 0
var fire_cooldown := 0.0
var shield_recharge_delay := 0.0
var enemy_respawn_timer := 0.0
var alert_timer := 0.0
var paused := false
var game_over_state := false


func _ready() -> void:
	player.call("set_world_limit", WORLD_LIMIT)
	alert_label.text = ""
	pause_label.visible = false
	create_starfield()
	create_star()
	create_planets()
	create_stations()
	create_shipping_lanes()
	create_navigation_beacons()
	create_objective_visuals()
	setup_cargo_route()
	call_deferred("spawn_initial_enemies")

	if station_order.size() > 0:
		player.global_position = station_order[0].global_position + Vector3(0, 0, 30)

	title_label.text = "Wireframe System"
	update_combat_label()
	update_status("WASD move, R/F rise and descend.\nHold Shift to boost through the shipping lanes.")


func _process(delta: float) -> void:
	if paused:
		update_alert(delta)
		return

	update_camera(delta)
	update_objective_visuals(delta)
	update_scanner()
	update_alert(delta)
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
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		toggle_pause()
		return

	if paused:
		return

	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ENTER and game_over_state:
		restart_game()
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
	far_stars.material_override = make_line_material(Color(0.82, 0.9, 1.0))
	add_child(far_stars)

	var mid_stars := MeshInstance3D.new()
	mid_stars.name = "MidStars"
	mid_stars.mesh = build_star_mesh(180, WORLD_LIMIT * 0.72, 1.2, 3.4)
	mid_stars.material_override = make_line_material(Color(0.46, 0.88, 1.0))
	add_child(mid_stars)

	var dust_ribbons := MeshInstance3D.new()
	dust_ribbons.name = "DustRibbons"
	dust_ribbons.mesh = build_dust_ribbon_mesh()
	dust_ribbons.material_override = make_line_material(Color(0.26, 0.6, 0.74))
	world_root.add_child(dust_ribbons)


func create_star() -> void:
	star_node = Node3D.new()
	star_node.name = "HeliosPrime"
	star_node.set_meta("collision_radius", STAR_RADIUS + STAR_COLLISION_MARGIN)
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
		root.set_meta("collision_radius", float(planet_data["radius"]) + PLANET_COLLISION_MARGIN)

		var planet_mesh := MeshInstance3D.new()
		planet_mesh.mesh = build_planet_mesh(planet_data["radius"])
		planet_mesh.material_override = make_line_material(planet_data["color"])
		root.add_child(planet_mesh)

		var orbit_ring := MeshInstance3D.new()
		orbit_ring.mesh = build_ring_mesh(orbit_radius, 96)
		orbit_ring.material_override = make_line_material(planet_data["orbit_tint"])
		orbit_ring.rotation = Vector3(tilt, 0, 0)
		add_child(orbit_ring)

		var debris_ring := MeshInstance3D.new()
		debris_ring.mesh = build_debris_belt_mesh(float(planet_data["radius"]) + 54.0, 62.0, 56)
		debris_ring.material_override = make_line_material(planet_data["orbit_tint"].lerp(Color.WHITE, 0.18))
		debris_ring.rotation = Vector3(tilt * 3.4, phase * 0.25, 0)
		root.add_child(debris_ring)

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
		station.set_meta("collision_radius", STATION_COLLISION_RADIUS)
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
		lane.material_override = make_line_material(Color(0.34, 0.88, 0.76))
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
		mesh.material_override = make_line_material(beacon_data["color"])
		root.add_child(mesh)

		var label := Label3D.new()
		label.text = beacon_data["label"]
		label.position = Vector3(0, 24, 0)
		label.font_size = 32
		label.no_depth_test = true
		root.add_child(label)


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


func toggle_pause() -> void:
	if game_over_state:
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
	combat_label.text = "Hull %d\nShields %d\nContacts %d\nScore %d\nKills %d" % [
		int(round(player_hull)),
		int(round(player_shields)),
		enemy_nodes.size(),
		score,
		kills
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
	mesh.material_override = make_line_material(Color(1.0, 0.46, 0.34))
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
			cooldown = 1.5
		enemy.set_meta("fire_cooldown", cooldown)

		if distance > ENEMY_ENGAGE_RADIUS * 2.6:
			enemy.global_position = player.global_position - direction * ENEMY_ENGAGE_RADIUS

		if distance < 18.0:
			damage_player(ENEMY_CONTACT_DAMAGE, "Drone collision")
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
	mesh.material_override = make_line_material(Color(0.55, 0.95, 1.0) if from_player else Color(1.0, 0.54, 0.42))
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
				enemy.queue_free()
				enemy_nodes.remove_at(i)
				set_alert("Drone down", 0.45)
			return true
	return false


func handle_enemy_projectile_hit(projectile: Node3D) -> bool:
	if projectile.global_position.distance_to(player.global_position) <= PLAYER_COLLISION_RADIUS + 4.0:
		damage_player(ENEMY_PROJECTILE_DAMAGE, "Incoming fire")
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


func damage_player(amount: float, reason: String) -> void:
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
	set_alert(reason, 0.45)
	if player_hull <= 0.0:
		trigger_game_over(reason)


func trigger_game_over(reason: String) -> void:
	game_over_state = true
	paused = true
	title_label.text = "Ship Lost"
	pause_label.visible = true
	pause_label.text = "Ship Lost\n%s\nPress Enter to restart" % reason
	update_status("Run ended.\nPress Enter to restart the patrol.")


func create_burst(position: Vector3, color: Color) -> void:
	var burst := MeshInstance3D.new()
	burst.mesh = build_burst_mesh(8.0)
	burst.material_override = make_line_material(color)
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
