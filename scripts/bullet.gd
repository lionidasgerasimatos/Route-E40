extends Area2D

@onready var  _animator := $AnimationPlayer

@export var attack_damage:= 50
@export var BULLET_SPEED = 2
var direction: Vector2





func _physics_process(delta: float) -> void:
	rotation =direction.angle()
	global_position += direction * BULLET_SPEED






func _on_area_entered(area:Area2D):
	if area.has_method("damage") :
		var attack = Attack.new()
		attack.attack_damage = 50
		area.damage(attack)
		
	
	_animator.play("Hit")
	queue_free()
	 
