extends ProgressBar


# Called when the node enters the scene tree for the first time.
@export var HealthCheck : HealthComponent

func _ready() -> void:
	HealthCheck.health_changed.connect(update)
	update()

func update():
	value = HealthCheck.health
