extends Node

@export var tilemap : TileMap

#Tile Ids will use the following fields:
#1 : Floor
#Wall Designs:
#2 Placeholder Wall tile
#3 No walls adjacent
#4 Wall right
#5 Wall left and right
#6 Wall left
#7 Wall bot
#8 Wall top and bot
#9 Wall top
#10 Wall bot and right
#11 Wall bot and left
#12 Wall top and right
#13 Wall top and left
#14 Wall everywhere
#15 Wall bot, left, right
#16 Wall top, left, bot
#17 Wall top, right, bot
#18 Wall top, left, right

@export var tile_ids : Dictionary
@export var start_obj : Vector2i
@export var end_obj : Vector2i

func _ready():
	pass
	
func reset_map():
	tilemap.clear()

func get_start_position() -> Vector2:
	var coords = tilemap.get_used_cells_by_id(1, 0, start_obj)
	return coords[0]

func get_end_position() -> Vector2:
	var coords = tilemap.get_used_cells_by_id(1, 0, end_obj)
	return coords[0]

func generate_world(width, height):
	#Reset the world
	reset_map()
	
	#Create map as an appropriately sized 2d array with null values
	var map = []
	
	for x in range(width):
		var col = []
		col.resize(height)
		map.append(col)
	
	#Set borders:
	for x in range(width):
		map[x][0] = 2
		map[x][height-1] = 2
	for y in range(height):
		map[0][y] = 2
		map[width-1][y] = 2
		
	#Set every even/even numbered field to wall, this ensures a perfect maze without loops
	for x in range(width):
		for y in range(height):
			if x%2 == 0 and y%2 == 0:
				map[x][y] = 2
	
	#Set up the list with a random start position (use an odd/odd numbered field because it is not set):
	var start_x = randi_range(0, (width/2)-1)*2 +1
	var start_y = randi_range(0, (height/2)-1)*2 +1
	
	var coords_to_check = [Vector2i(start_x, start_y)]
	
	while true:
		#Break out of the loop if there are no more coordinates to check
		if coords_to_check == []:
			break
		
		#Use the last coordinate that has been added to check next
		var next_coord = coords_to_check[-1]
		
		#Remove the next checked coordinate from the list
		coords_to_check.erase((next_coord))
		
		#helper variables
		var x = next_coord.x
		var y = next_coord.y
		
		#Check the 4 cardinal directions
		var to_add = []
		#up
		if y-1 > 0 and map[x][y-1] == null:
			to_add.append(Vector2i(x, y-1))
		#down
		if y+1 < height and map[x][y+1] == null:
			to_add.append(Vector2i(x, y+1))
		#left
		if x-1 > 0 and map[x-1][y] == null:
			to_add.append(Vector2i(x-1, y))
		#right
		if x+1 < width and map[x+1][y] == null:
			to_add.append(Vector2i(x+1, y))
		
		#Check if one of the spots to add is already in the list to check.
		#If so, replace current tile with wall
		#If not, add to_add to the coordinates to check
		var explored = false
		for to_add_coords in to_add:
			if coords_to_check.find(to_add_coords) != -1:
				explored = true
		
		if to_add == []:
			explored = true
		
		#If we set a wall, we continue, else we append the new tochecks
		if explored:
			map[x][y] = 2
			continue
		else:
			map[x][y] = 1
			
		#Shuffle the coordinates to pick a random direction
		to_add.shuffle()
		#Append the shuffeled array
		coords_to_check += to_add
		
	#go over the entire map and replace all remaining fields with walls
	for x in range(width):
		for y in range(height):
			if map[x][y] == null:
				map[x][y] = 2
	
	#Go over the entire map. replace generic walls with proper wall ids, as per designs above:
	var floor_spaces = []
	for x in range(width):
		for y in range(height):
			#Dont replace floors. Add Floors to a list of floor tiles to spawn start and end
			if map[x][y] == 1:
				floor_spaces.append(Vector2i(x, y))
				continue
			
			#Check for walls (>= 2 means wall ids)
			var top = false
			var bot = false
			var left = false
			var right = false
			#up
			if y-1 >= 0 and map[x][y-1] >= 2:
				top = true
			#down
			if y+1 < height and map[x][y+1] >= 2:
				bot = true
			#left
			if x-1 >= 0 and map[x-1][y] >= 2:
				left = true
			#right
			if x+1 < width and map[x+1][y] >= 2:
				right = true
			
#			#3 No walls adjacent
#			#4 Wall right
#			#5 Wall left and right
#			#6 Wall left
#			#7 Wall bot
#			#8 Wall top and bot
#			#9 Wall top
#			#10 Wall bot and right
#			#11 Wall bot and left
#			#12 Wall top and right
#			#13 Wall top and left
#			#14 Wall everywhere
#			#15 Wall bot, left, right
#			#16 Wall top, left, bot
#			#17 Wall top, right, bot
#			#18 Wall top, left, right
#			if top == false and bot == false and left == false and right == false:
#				map[x][y] = 3
#			elif top == false and bot == false and left == false and right == true:
#				map[x][y] = 4
#			elif top == false and bot == false and left == true and right == true:
#				map[x][y] = 5
#			elif top == false and bot == false and left == true and right == false:
#				map[x][y] = 6
#			elif top == false and bot == true and left == false and right == false:
#				map[x][y] = 7
#			elif top == true and bot == true and left == false and right == false:
#				map[x][y] = 8
#			elif top == true and bot == false and left == false and right == false:
#				map[x][y] = 9
#			elif top == false and bot == true and left == false and right == true:
#				map[x][y] = 10
#			elif top == false and bot == true and left == true and right == false:
#				map[x][y] = 11
#			elif top == true and bot == false and left == false and right == true:
#				map[x][y] = 12
#			elif top == true and bot == false and left == true and right == false:
#				map[x][y] = 13
#			elif top == true and bot == true and left == true and right == true:
#				map[x][y] = 14
#			elif top == false and bot == true and left == true and right == true:
#				map[x][y] = 15
#			elif top == true and bot == true and left == true and right == false:
#				map[x][y] = 16
#			elif top == true and bot == true and left == false and right == true:
#				map[x][y] = 17
#			elif top == true and bot == false and left == true and right == true:
#				map[x][y] = 18
			
	
	#Iterate over the map, set cells where appropriate tile is found
	for x in range(width):
		for y in range(height):
			if map[x][y] in tile_ids:
				tilemap.set_cell(0, Vector2i(x, y), 0, tile_ids[map[x][y]])
	
	#Shuffle floor spaces. Use first floor space to spawn start
	floor_spaces.shuffle()
	#Spawn placeholder tiles on layer 1
	tilemap.set_cell(1, floor_spaces[0], 0, start_obj)
	
	#find the floor space with biggest absolute spacing in the first 5 options:
	var space = 0
	var curr_coords = floor_spaces[0]
	for coords in floor_spaces.slice(1, 5):
		var curr_space = abs(coords.x - floor_spaces[0].x) + abs(coords.y - floor_spaces[0].y)
		if curr_space > space:
			space = curr_space
			curr_coords = coords
	
	tilemap.set_cell(1, curr_coords, 0, end_obj)

func get_map_center(maze_current_size: int):
	var curr_size = floor(maze_current_size / 2)
	return tilemap.map_to_local(Vector2i(curr_size, curr_size))
