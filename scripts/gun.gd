extends CharacterBody2D

var bullet_scene = preload("res://Scene/bullet.tscn")
@onready var  barrel_pos = $barrel
@onready var shooting_time:= $shooting_time


func _process(delta: float) -> void:
	look_at(get_global_mouse_position())
	
	if Input.is_action_pressed("leftMshoot") and shooting_time.is_stopped():
		var bullet = bullet_scene.instantiate()
		bullet.global_position = barrel_pos.global_position
		get_tree().get_current_scene().add_child(bullet)
		bullet.direction = (get_global_mouse_position()-global_position).normalized()
		$shooting_time.start()
		
	
	
