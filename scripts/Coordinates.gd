extends Node
class_name CoordinatesClass

static func get_tile_coordinates(tilemap: TileMap, position: Vector2) -> Vector2:
	# Get the tile coordinates from the tilemap based on the position
	var local := tilemap.to_local(position)
	return tilemap.local_to_map(local)


static func node_to_tile(tilemap: TileMap, node: Node2D) -> Vector2i:
	return get_tile_coordinates(tilemap, node.global_position)
