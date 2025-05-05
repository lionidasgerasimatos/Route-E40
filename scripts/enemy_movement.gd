extends CharacterBody2D

@export var speed = 400

var player_pos
var target_pos 
@onready var player = get_parent().get_parent().get_node("CAR")

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	player_pos = player.position
	target_pos = (player_pos - position).normalized()
	
	if position.distance_to(player_pos) > 3 :
		position+=target_pos * speed * delta
