extends CharacterBody2D

var bullet_scene = preload("res://Scene/bullet.tscn")
@onready var  barrel_pos = $barrel
@onready var shooting_time:= $shooting_time
@onready var muzzle_flash:= $barrel_light
@onready var gun_animation:=$GunAnimation


var light_timer :=0.0
var light_duration := 0.1  # How long the light should stay visible (in seconds)




func _ready():
	print(muzzle_flash) #test


func _process(delta: float) -> void:
	look_at(get_global_mouse_position()) # Following the mouse with in-build godot function 
	
	
	#Lighting Particles Animation
	if light_timer > 0 :   #While the limer is active the muzzle flash happends
		light_timer -= delta
		muzzle_flash.visible =true 
		muzzle_flash.energy = lerp(2.0,0.0,1.0 - (light_timer/ light_duration)) # dynamic on and off 
		$CPUParticles2D.emitting =true #For the cannon smoke 
		gun_animation.play("shooting")
	else :
		muzzle_flash.visible =false
		$CPUParticles2D.emitting =false
		gun_animation.play("idle") 
	
	#Shooting
	if Input.is_action_pressed("leftMshoot") and shooting_time.is_stopped(): 
		var bullet = bullet_scene.instantiate()
		bullet.global_position = barrel_pos.global_position
		get_tree().get_current_scene().add_child(bullet) #Must add as a child otherwise it wont work at spawn 
		bullet.direction = (get_global_mouse_position()-global_position).normalized() # The .normalized is because godot coordinates are fliped -1 is 1 and reverse
		$shooting_time.start() #begin the Fire Rate 
		
		
		
		
		$barrel_light.visible =true
		light_timer = light_duration 
		muzzle_flash.energy = 2.0  # Start muzzle flash with strong light
		muzzle_flash.visible = true #Turn on the flash 
