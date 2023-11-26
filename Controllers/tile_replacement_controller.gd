extends Node

@export var tilemap : TileMap
@export var tiles : Dictionary
@export var replacement_layer : int

enum replacement_mode_enum {none, remove, deactivate}
@export var replacement_mode : replacement_mode_enum

var preloads : Dictionary

var replaced = []


func _ready():
	#Load the appropriate ressources for all replacement tiles
	for key in tiles:
		preloads[key] = load(tiles[key])

func get_replaced_tiles() -> Array:
	return replaced

func replace_tiles():
	replaced = []
	for key in tiles:
		#Get the list of all cells using the replacement tile
		var to_replace = tilemap.get_used_cells_by_id(replacement_layer, 0, key)
		
		#Spawn replacement tiles on all positions
		for coords in to_replace:
			var new_instance = preloads[key].instantiate()
			add_child(new_instance)
			var new_coords = tilemap.map_to_local(coords)
			new_instance.global_position = new_coords
			replaced.append(new_instance)
			# Remove the placeholder tiles, if remove replacement mode
			if replacement_mode == replacement_mode_enum.remove:
				tilemap.set_cell(replacement_layer, coords)
	
	#deactivate the entire layer if deactivate replacement mode
	if replacement_mode == replacement_mode_enum.deactivate:
		tilemap.set_layer_enabled(replacement_layer, false)
