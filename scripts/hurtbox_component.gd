extends Area2D

@export var attack_damage:= 20

func _on_area_entered(area:Area2D) -> void:
	if area.has_method("damage") :
		var attack = Attack.new()
		attack.attack_damage = attack_damage
		area.damage(attack)
		print("tcouh")




