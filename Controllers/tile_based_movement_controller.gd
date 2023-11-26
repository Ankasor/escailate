extends Node2D

@export var tileMap: TileMap

@export var body : Node2D

signal movement_success(position)
signal movement_collision(position)
signal teleport_success

#Moves this node to a given grid position on the tile map
func movement_target_position(target_position: Vector2i):
	var target_tileData = tileMap.get_cell_tile_data(0, target_position)
	
	#Checks for collision. If the tile is not walkable, emit movement_collision signal and end the function here
	if not target_tileData.get_custom_data("walkable"):
		movement_collision.emit(tileMap.map_to_local(target_position))
		return
	
	#Moves the tile into position, emits movement_success signal
	move_to_global_position(tileMap.map_to_local(target_position))
	movement_success.emit(tileMap.map_to_local(target_position))

#Telepors this node to a given grid position on the tile map without collision checks
func teleport_target_position(target_position: Vector2i):
	move_to_global_position(tileMap.map_to_local(target_position))
	teleport_success.emit()

#Moves this node in a Vector2i direction on the tile map
func movement_direction(direction: Vector2i):
	var current_position = tileMap.local_to_map(global_position)
	var target_position = current_position + direction
	movement_target_position(target_position)

func move_to_global_position(new_position: Vector2):
	body.position = new_position
	
