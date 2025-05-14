# EnemyCar.gd
extends CharacterBody2D


@export var target_path     : NodePath = "../../CAR"   # path to the player car
@export var desired_distance: float    = 100            # stop pushing when this close

@export var steering_angle  = 20      # °  max wheel angle (same as player)
@export var engine_power    = 700     #     forward thrust
@export var friction        = -55
@export var drag            = -0.06
@export var braking         = -450
@export var max_speed_reverse = 250
@export var slip_speed        = 600
@export var traction_fast     = 4.5
@export var traction_slow     = 10
var  wheel_base        = 100           # px between axles


 

@onready var player   : CharacterBody2D = get_node(target_path)
@onready var car_an :=$AnimationPlayer

var acceleration   : Vector2 = Vector2.ZERO
var steer_direction: float   = 0.0



func _physics_process(delta: float) -> void:
	# Navigational Agent update

	
	
	# 1) high-level “AI input”
	get_ai_input(delta)

	# 2) car physics (identical to player script)
	calculate_steering(delta)
	velocity += acceleration * delta
	apply_friction(delta)
	move_and_slide()











# ---------------------------------------------------------------------------
# AI “input”  – decides steering & throttle so the car hunts the player
# ---------------------------------------------------------------------------
func get_ai_input(delta: float) -> void:
	var to_player   = player.global_position - global_position
	var distance    = to_player.length()
	var target_dir  = to_player.normalized()

	# STEERING 
	# angle we need to turn (-π … π)
	var angle_diff = wrapf(target_dir.angle() - rotation, -PI, PI)
	# translate to the same -1 … 1 input range the player’s turn axis uses
	var turn_input = clamp(angle_diff / deg_to_rad(steering_angle), -1.0, 1.0)
	steer_direction = turn_input * deg_to_rad(steering_angle)
	
	#print(steer_direction)
	
	# THROTTLE / BRAKE 
	acceleration = Vector2.ZERO
	# Far away → accelerate forward
	if distance > desired_distance:
		acceleration = transform.x * engine_power
	# Close & still moving fast toward player → brake
	elif velocity.length() > 50:
		acceleration = transform.x * braking

	# ANIMATION 
	if steer_direction > 0.1:
		car_an.play("right")
	elif steer_direction < -0.1:
		car_an.play("left")
	else:
		car_an.play("Idle")


# ---------------------------------------------------------------------------
#  The helper functions below are copied 1-for-1 from the player script
# ---------------------------------------------------------------------------
func apply_friction(delta: float) -> void:
	if acceleration == Vector2.ZERO and velocity.length() < 50:
		velocity = Vector2.ZERO
	var friction_force = velocity * friction * delta
	var drag_force     = velocity * velocity.length() * drag * delta
	acceleration += drag_force + friction_force


func calculate_steering(delta: float) -> void:
	var rear_wheel  = global_position - transform.x * wheel_base / 2.0
	var front_wheel = global_position + transform.x * wheel_base / 2.0
	rear_wheel  += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta

	var new_heading = rear_wheel.direction_to(front_wheel)
	var traction = traction_fast if velocity.length() > slip_speed else traction_slow


	var d = new_heading.dot(velocity.normalized())
	if d > 0:
		velocity = lerp(velocity, new_heading * velocity.length(), traction * delta)
	elif d < 0:
		velocity = -new_heading * min(velocity.length(), max_speed_reverse)

	rotation = new_heading.angle()
