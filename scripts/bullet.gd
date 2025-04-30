extends Area2D

@export var BULLET_SPEED = 2
var direction: Vector2

func _physics_process(delta: float) -> void:
	rotation =direction.angle()
	global_position += direction * BULLET_SPEED
