extends Area2D

@export var speed := 220.0
var screen_height := 540.0


func _ready() -> void:
	add_to_group("enemies")
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)


func _process(delta: float) -> void:
	position.y += speed * delta
	rotation += delta * 1.5
	if position.y > screen_height + 40.0:
		queue_free()


func _on_body_entered(body: Node) -> void:
	if body.has_method("hit"):
		body.hit()

	var current_scene := get_tree().current_scene
	if current_scene and current_scene.has_method("game_over"):
		current_scene.game_over()

	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("bullets"):
		area.queue_free()
		queue_free()
