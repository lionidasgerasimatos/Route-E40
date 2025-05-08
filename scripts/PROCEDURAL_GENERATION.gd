extends Node2D

# we assign the coordinates of a wall with binary value
const N = 1
const E = 2
const S = 4
const W = 8

#This is a mapping of the four values and what physical direction they represent up down left right(north,south etc.) 
var cell_walls := {Vector2i(0,-1):N, Vector2i(1,0):E, Vector2i(0,1):S,Vector2i(-1,0):W }

#How many tiles big we want it
@export var width = 30
@export var height = 25
#How many pixels is the tilemap see from settings
@export var tile_size = 64 
var source_id : int 
#Preloads
@onready var Map = $TileMap


#---------------------------------------------------------------------------------------------
"""The Next four interconnected functions are there because of a spesific Reason
I use a bigger tile set that the godot default

So i cant just set cell and call the coordinates because they have been shifted since a single tile is 64x64
and if i where to call the second tile it wouldnt find a thing.

If thats not the case then you can do it the normal way and just set_cells withing the RBA loop

To get by that we us a BitMask """

func bitmask_to_atlas_coords(mask:int) -> Vector2i:
	#Convert 0‑15 wall mask → (x, y) cell inside the 4 × 4 atlas
	return Vector2i(mask & 3, mask >> 2)   # x = mask % 4, y = mask // 4

func atlas_coords_to_bitmask(coords:Vector2i) -> int:
	#Inverse of the above we use it when we read a tile
	return coords.y * 4 + coords.x

func get_walls(cell:Vector2i) -> int:
	#Return the current wall mask at cell
	return atlas_coords_to_bitmask(Map.get_cell_atlas_coords(0, cell))

func set_walls(cell:Vector2i, mask:int) -> void:
	#Write *mask* to *cell* on layer 0 using our atlas source
	Map.set_cell(0, cell, source_id, bitmask_to_atlas_coords(mask))


#----------------------------------------------------------------------------------------------------


# Begining of Action
func _ready() -> void:
	randomize()
	# Pick the *first* source in the TileSet (usually id 0)
	source_id = Map.tile_set.get_source_id(0)

	# DEBUG: draw one tile so you can verify slicing visually
	# Comment this line once you see the tile appear at (0,0).
	set_walls(Vector2i.ZERO, 15)

	# Generate the full maze
	make_maze()

# THIS IS A HELPER Function we want it just to check the arround the cell and see whats there in a list
#func check_neighbors(cell:Vector2i, unvisited:Array[Vector2i]) -> Array[Vector2i] :
	#Returns an array of cell's UNVISITED neighbors
	#var list : Array[Vector2i] = []      
	#for n in cell_walls.keys():              #n is a direction offset 
		#var neighbor :Vector2i = cell + n    #compute the neighbor;s cell coordinates
		#if neighbor in unvisited :          
			#list.append(neighbor)       #we add the neighbor to the list as an element
			
	#return list


func make_maze() ->void :
	var unvisited: Array[Vector2i] = [] #array of unvisited tiles
	# GDscript doesnt have a stack data type we will represent that with an array to do the LIFO effect
	var stack: Array[Vector2i] = []
	
	# Fill the map with solid tiles
	Map.clear()
	for x in range(width):
		for y in range(height):
			var cell := Vector2i(x,y)
			unvisited.append(cell)
			
			set_walls(cell,15)  # Every cell starts with mask 15 all four walls
	
	# We pick the 0,0 coordinates and remove it from the unvisited list  
	var current : Vector2i = Vector2i.ZERO
	unvisited.erase(current)
	
	# The Recursive Backtraking Algorithm Loop
	while unvisited:   # while not empty
		
		# Find the unvisited Neighbors
		var neighbors :Array[Vector2i] = [] 
		for direction in cell_walls.keys():    # One of the four direction vectors 
			var NEXT = current + direction
			if NEXT in unvisited :           #Add it to list
				neighbors.append(NEXT)    
		
		# Making the Road
		if neighbors.size() > 0 :
			var next = neighbors[randi() % neighbors.size()] # select random neighbor
			stack.append(current) # Add cell to stack
			
			#REMOVE WALLS FROM BOTH CELLS
			var direction_moved = next - current
			# We find the Wall that touches between the Two Cells Because we want to make it a CONNECTION
			var current_mask = get_walls(current) - cell_walls[direction_moved] # Basically we subract the binary number of the 
			#cell minus the direction to get the wall remember the N S E W at the top
			var next_mask = get_walls(next) - cell_walls[-direction_moved] # The opposite here
			
			"""
			This is what we would do without using the masks calling it straight from here:
			
			the 0 here mean the source id or the tile set layer by default its 0
			
			var current_wall = Map.get_cell_source_id(0,current) - cell_walls[direction_moved]
			var next_wall = Map.get_cell_source_id(0,next) - cell_walls[-direction_moved]
			
			Map.set_cell(0,current,current_walls) 
			Map.set_cell(0,next,next_walls) 
			"""
			
			# Set the connecting cells
			set_walls(current,current_mask)
			set_walls(next,next_mask)
			
			# Move forward
			current = next
			unvisited.erase(current)
			# This will continue unless we have no neighbours witch means it a dead end or end
			
		elif stack :
			# BACKTRACK AT DEAD END 
			# WE USE LIFO HERE TO FIND THE LAST INTERSECTION 
			current = stack.pop_back()
		await get_tree().process_frame
		
		
		
