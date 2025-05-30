extends Node2D
class_name  HealthComponent

@export var Max_Health: float = 100.0

var health 
signal health_changed

func _ready() -> void:
	health= Max_Health
	
func damage(attack: Attack):
	health -= attack.attack_damage
	if health > Max_Health:
		health = Max_Health

	health_changed.emit()
	print("Health: ", health)
