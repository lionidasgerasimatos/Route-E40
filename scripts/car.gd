extends CharacterBody2D


@onready var audio := $AudioStreamPlayer2D
@onready var car_an :=$CarAnimation

@export var steering_angle = 40  # Maximum angle for steering the car's wheels
@export var engine_power = 700  # How much force the engine can apply for acceleration
@export var friction = -55  # The friction coefficient that slows down the car
@export var drag = -0.06  # Air drag coefficient that also slows down the car
@export var braking = -450  # Braking power when the brake input is applied
@export var max_speed_reverse = 250  # Maximum speed limit in reverse
@export var slip_speed = 600  # Speed above which the car's traction decreases (for drifting)
@export var traction_fast = 4.5  # Traction factor when the car is moving fast (affects control)
@export var traction_slow = 10  # Traction factor when the car is moving slow (affects control)
@export var tilemap :TileMap

var wheel_base = 100  # Distance between the front and back axle of the car
var acceleration = Vector2.ZERO  # Current acceleration vector
var steer_direction  # Current direction of steering

func _physics_process(delta: float) -> void:
	
	acceleration = Vector2.ZERO
	get_input()  # Take input from player
	calculate_steering(delta)  # Apply turning logic based on steering

	var speed = velocity.length()
	var moving = speed > 1.0   
	var t = clamp(speed / engine_power, 0.0, 1.0)  # Adjust volume based on speed
	audio.pitch_scale = lerp(0.8,1.1,t)
	
	if moving:
		if not audio.is_playing():
			audio.play()  # Play engine sound if the car is moving
	else:
		if audio.is_playing():
			audio.stop()  # Stop engine sound if the car is not moving

	velocity += acceleration * delta 
	if not velocity.is_zero_approx():
		pass

	apply_friction(delta)  # Apply friction forces to the car
	move_and_slide()  # Move the car and handle collisions
	
	var tile_coords: Vector2i = CoordinatesClass.node_to_tile(tilemap,self)
	print("Tile Coords: ", tile_coords)  # Debugging output to see the tile coordinates



func get_input():
	# Get steering input and translate it to an angle
	var turn = Input.get_axis("left", "right")
	steer_direction = turn * deg_to_rad(steering_angle)
	# If accelerate is pressed, apply engine power to the car's forward direction
	if Input.is_action_pressed("up"):
		acceleration = transform.x * engine_power
	# If brake is pressed, apply braking force
	if Input.is_action_pressed("down") or  Input.is_action_pressed("handbreak"):
		acceleration = transform.x * braking
	
	# Handle Animations
	if turn > 0.1:
		car_an.play("right")
	elif turn < -0.1:
		car_an.play("left")
	else:
		car_an.play("Idle")


func apply_friction(delta):
	# If there is no input and speed is very low, just stop to prevent endless sliding
	if acceleration == Vector2.ZERO and velocity.length() < 50:
		velocity = Vector2.ZERO
	# Calculate friction force and air drag based on current velocity, and apply it
	var friction_force = velocity * friction * delta
	var drag_force = velocity * velocity.length() * drag * delta
	# Add the forces to the acceleration
	acceleration += drag_force + friction_force

func calculate_steering(delta):
	# Calculate the positions of the rear and front wheel
	var rear_wheel = position - transform.x * wheel_base / 2.0
	var front_wheel = position + transform.x * wheel_base / 2.0
	# Advance the wheels' positions based on the current velocity, applying rotation to the front wheel
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta
	# Calculate the new heading based on the wheels' positions
	var new_heading = rear_wheel.direction_to(front_wheel)
	# Choose the traction model based on the current speed
	var traction = traction_slow
	if velocity.length() > slip_speed:
		traction = traction_fast
	# Dot product represents how aligned the new heading is with the current velocity direction
	var d = new_heading.dot(velocity.normalized())
	# If not braking (d > 0), adjust the car velocity smoothly towards the new heading
	if d > 0:
		velocity = lerp(velocity, new_heading * velocity.length(), traction * delta)
	# If braking (d < 0), reverse the direction and limit the speed
	if d < 0:
		velocity = -new_heading * min(velocity.length(), max_speed_reverse)
	# Update the car's rotation to face in the direction of the new heading
	rotation = new_heading.angle()
