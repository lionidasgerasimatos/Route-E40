extends Node2D

@onready var red_light := $RedLight
@onready var blue_light := $BlueLight

@export_range(0.0, 4.0) var max_energy : float = 1.8        # how bright the flash becomes
@export var on_time      : float = 0.15                     # seconds fully on
@export var fade_time    : float = 0.12                     # seconds for each fade
@export var pause_time   : float = 0.05                     # dark gap between flashes

func _ready() -> void:
    _start_police_cycle()

func _start_police_cycle() -> void:
    var tween := get_tree().create_tween().set_loops()      # loops forever

    # --- RED flash ----------------------------------------------------------
    tween.tween_property(red_light, "energy",
        max_energy, fade_time).from(0.0)                    # fade in
    tween.tween_interval(on_time)                           # stay on
    tween.tween_property(red_light, "energy",
        0.0, fade_time)                                     # fade out
    tween.tween_interval(pause_time)                        # short dark gap

    # --- Blue flash --------------------------------------------------------
    tween.tween_property(blue_light, "energy",
        max_energy, fade_time).from(0.0)
    tween.tween_interval(on_time)
    tween.tween_property(blue_light, "energy",
        0.0, fade_time)
    tween.tween_interval(pause_time)