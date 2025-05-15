# EnemyCar.gd  —  chase + obstacle avoid + backing-up recovery
extends CharacterBody2D
## -------------------  tunables  -------------------------------------------
@export var target_path      : NodePath = "../../CAR"
@export var desired_distance : float    = 60
@export var steering_angle   = 40
@export var engine_power     = 700
@export var friction         = -55
@export var drag             = -0.06
@export var braking          = -450
@export var max_speed_reverse = 250
@export var slip_speed        = 600
@export var traction_fast     = 4.5
@export var traction_slow     = 10
@export var wheel_base        = 100

# Avoidance
@export var avoid_strength   : float = 1.2   # 1 = full steering lock
# “Stuck / reverse” behaviour
@export var stuck_speed      : float = 30    # px/s → slower than this counts as stopped
@export var stuck_delay      : float = 1.0   # sec the car must be stuck before reversing
@export var reverse_time     : float = 2   # sec spent backing up

## -------------------  cached nodes  ---------------------------------------
@onready var player  : CharacterBody2D = get_node(target_path)
@onready var car_an  : AnimationPlayer = $AnimationPlayer
@onready var ray_l   : RayCast2D = $RayFrontLeft
@onready var ray_m   : RayCast2D = $RayFrontMid
@onready var ray_r   : RayCast2D = $RayFrontRight
## --------------------------------------------------------------------------
var acceleration    : Vector2 = Vector2.ZERO
var steer_direction : float   = 0.0

# timers / state for “stuck” logic
var stuck_timer     : float = 0.0
var reverse_timer   : float = 0.0
var reversing       : bool  = false


func _physics_process(delta: float) -> void:
	_get_ai_input(delta)
	calculate_steering(delta)
	velocity += acceleration * delta
	apply_friction(delta)
	move_and_slide()


# ---------------------------------------------------------------------------
# AI – chase, avoid obstacles, and back up if stuck
# ---------------------------------------------------------------------------
func _get_ai_input(delta: float) -> void:
	# ---------- raycasts ----------
	ray_l.force_raycast_update()
	ray_m.force_raycast_update()
	ray_r.force_raycast_update()

	# ---------- reversing state ----------
	if reversing:
		_reverse_drive(delta)
		return   # skip normal chase while backing up

	# ---------- chase steering ----------
	var to_player   = player.global_position - global_position
	var target_dir  = to_player.normalized()
	var angle_diff  = wrapf(target_dir.angle() - rotation, -PI, PI)
	var turn_input  = clamp(angle_diff / deg_to_rad(steering_angle), -1.0, 1.0)

	# ---------- obstacle avoidance ----------
	var avoid_input = 0.0

	if ray_m.is_colliding():                                # wall dead ahead
		avoid_input = -1.0 if not ray_l.is_colliding() else 1.0
	else:
		if ray_l.is_colliding():                            # wall left
			avoid_input += 1.0
		if ray_r.is_colliding():                            # wall right
			avoid_input -= 1.0

	steer_direction = deg_to_rad(steering_angle) * \
		clamp(turn_input + avoid_input * avoid_strength, -1.0, 1.0)

	# ---------- throttle / brake ----------
	var distance = to_player.length()
	acceleration = Vector2.ZERO
	if distance > desired_distance:
		acceleration = transform.x * engine_power
	elif velocity.length() > 50:
		acceleration = transform.x * braking

	# ---------- stuck detector ----------
	var blocked_ahead = ray_m.is_colliding() or (ray_l.is_colliding() and ray_r.is_colliding())
	var slow_enough   = velocity.length() < stuck_speed

	if blocked_ahead and slow_enough:
		stuck_timer += delta
		if stuck_timer >= stuck_delay:
			_start_reverse()
	else:
		stuck_timer = 0.0

	# ---------- animations ----------
	_play_steer_anim()


# ---------------------------------------------------------------------------
# Reverse-drive helper
# ---------------------------------------------------------------------------
func _reverse_drive(delta: float) -> void:
	reverse_timer -= delta
	if reverse_timer <= 0.0:
		reversing = false
		return

	# Back up with half engine power
	acceleration    = -transform.x * engine_power * 0.6

	# Steer opposite whichever side is more blocked
	var avoid_input = 0.0
	if ray_l.is_colliding():  avoid_input += 1.0
	if ray_r.is_colliding():  avoid_input -= 1.0

	steer_direction = deg_to_rad(steering_angle) * avoid_input
	_play_steer_anim()


func _start_reverse() -> void:
	reversing     = true
	reverse_timer = reverse_time
	stuck_timer   = 0.0


# ---------------------------------------------------------------------------
# shared helpers
# ---------------------------------------------------------------------------
func _play_steer_anim() -> void:
	if steer_direction > 0.1:
		car_an.play("right")
	elif steer_direction < -0.1:
		car_an.play("left")
	else:
		car_an.play("Idle")


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
	var traction    = traction_fast if velocity.length() > slip_speed else traction_slow

	var d = new_heading.dot(velocity.normalized())
	if d > 0:
		velocity = lerp(velocity, new_heading * velocity.length(), traction * delta)
	elif d < 0:
		velocity = -new_heading * min(velocity.length(), max_speed_reverse)

	rotation = new_heading.angle()

