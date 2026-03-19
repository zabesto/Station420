extends Area2D

@export var speed := 520.0


func _ready() -> void:
	add_to_group("bullets")


func _process(delta: float) -> void:
	position.y -= speed * delta
	if position.y < -24.0:
		queue_free()
