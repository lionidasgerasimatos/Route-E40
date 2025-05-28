extends Area2D
class_name HitboxComponent

@export var health_component : HealthComponent

func damage(attack: Attack) -> void:
	health_component.damage(attack)
	
	if health_component.health <= 0:
		if get_parent().is_in_group("player"):
			get_tree().paused =true
		get_parent().queue_free()