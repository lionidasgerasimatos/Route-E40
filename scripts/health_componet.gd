extends Node2D
class_name  HealthComponent

@export var Max_Health:= 100

var health : float
signal health_changed

func _ready() -> void:
	health= Max_Health
	
func damage(attack: Attack):
	health -= attack.attack_damage
	health_changed.emit()
