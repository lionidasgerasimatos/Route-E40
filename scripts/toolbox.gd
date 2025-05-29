extends Area2D

@export var healamount := 20


func _ready() -> void:
	body_entered.connect(_on_body_entered)



func _on_body_entered(body:Node2D) -> void:
	if body.is_in_group("player"):
		print("Healing player")
		var health_component = body.get_node_or_null("HealthComponent")
		if health_component:
			health_component.heal(healamount)
			print("Player healed by ", healamount)
			queue_free()  
