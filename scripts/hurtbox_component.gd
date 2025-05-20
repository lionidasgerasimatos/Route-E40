extends Area2D

@export var attack_damage:= 102

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


		
	
	

func _on_area_entered(area:Area2D) -> void:
	if area.has_method("damage") :
		var attack = Attack.new()
		attack.attack_damage = attack_damage
		area.damage(attack)
		print("tcouh")



func _on_body_entered(body:Node2D) -> void:
	pass
