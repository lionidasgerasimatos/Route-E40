extends Node2D

@export var player : CharacterBody2D
@export var tilemap	: TileMap        
@export var spawn_scene : PackedScene    
@export var item_scene : PackedScene    
@export var enemy_sec : float   = 7.0  
@export var item_sec : float   = 17.0   
@export var max_tile_radius : int = 3
@export var min_tile_radius : int = 1

@onready var timer : Timer = $EnemyTimer         
@onready var timer2 : Timer = $ItemTimer         



func _ready() -> void:
	randomize()

func _on_enemy_timer_timeout() -> void:
	
	var center = CoordinatesClass.node_to_tile(tilemap, player)
	var ring := pick_tile(center,max_tile_radius,min_tile_radius)
	var random_tile :Vector2i = ring.pick_random()
	var enemy := spawn_scene.instantiate()
	add_child(enemy) 
	var center_local  = tilemap.map_to_local(random_tile) + tilemap.tile_set.tile_size * 0.5
	var center_global = tilemap.to_global(center_local)

	enemy.global_position = Vector2(center_global)


	#print("ring size", ring, " center: ", center,"tilePicked", random_tile)
	
	
	
func pick_tile(center: Vector2i , maxR :int, minR:int ) -> Array[Vector2i]:
	
	assert(maxR >= minR and minR >=0)

	var possible_tiles :Array[Vector2i]= []

	for i in range(-maxR, maxR + 1):
		for j in range(-maxR, maxR + 1):
			var distance =max(abs(i), abs(j))
			if distance > minR:
				possible_tiles.append((center + Vector2i(i, j)))
		possible_tiles = possible_tiles.filter(func(element):
			return element.x >= 0 and element.y >= 0 and element.x <40 and element.y < 40)
	
	return possible_tiles
	
	
	
	
	
	
	



"""
func SpawnerOne() -> void:

	var possible_tiles :Array[Vector2i]= []
	for x in range(center.x -max_tile_radius, center.x + max_tile_radius+1):
		for y in range(center.y -max_tile_radius, center.y + max_tile_radius+1):
			var tile_pos = (Vector2i(x, y )- center).length_squared()
"""
