extends Area2D
class_name HitboxComponent

@export var health_component : HealthComponent

func damage(attack: Attack) -> void:
	health_component.damage(attack)
	
	if health_component.health <= 0:
		get_parent().get_parent().queue_free()
		get_parent().queue_free()