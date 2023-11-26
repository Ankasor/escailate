extends Node


#References to the controllers for maze generation
@export var maze_generation_controller : Node
@export var tile_replacement_controller_objects : Node

@export var maze_start_size : int
@export var maze_growth_size : int
var maze_current_size

#The timer controlling the game countdown
@export var timer : Timer
@export var timer_start_time : float

#The Player and a reference to the movement script for the collision event
@export var player : Node2D
var tile_based_movement_controller : Node

#A reference to the map finish and start objects
var finish
var start

#Settings for the time deduction for the collision
@export var collision_time_min : float
@export var collision_time_max : float
@export var collision_time_step : float

#Settings for the added time per level
@export var time_multiple : float

var collision_number_steps : int

#Reference to the UI layer
@export var UI: Node

@export var camera: Camera2D
@export var camera_limit: float

#Story time phrases and counter
var level = -1 #starts at -1, so first line shows at first level up
var resets = 0

@export var story_lines: Dictionary

func _ready():
	#Connect to the timer and the tile_based_movement controller
	timer.timeout.connect(on_timer_timeout)
	tile_based_movement_controller = player.get_node("tile_based_movement_controller")
	tile_based_movement_controller.movement_collision.connect(on_collision)
	
	#helper calculation to make randoming the time deduction easier later
	collision_number_steps = (collision_time_max - collision_time_min) / collision_time_step
	
	#Set current maze size to start size
	maze_current_size = maze_start_size
	
	reset_map()
	timer.start(timer_start_time)
	UI.display_text("Press any key to start")
	
func reset_map():	
	#Delete the finish object if there is one
	if finish != null:
		finish.queue_free()
	if start != null:
		start.queue_free()
	
	#generate maze
	maze_generation_controller.generate_world(maze_current_size, maze_current_size)
	#set player position
	var startpos = maze_generation_controller.get_start_position()
	tile_based_movement_controller.teleport_target_position(startpos)
	
	
	
	#replace placeholder tiles
	tile_replacement_controller_objects.replace_tiles()
	#Get list of replaced tiles to find the finish game object
	var replaced = tile_replacement_controller_objects.get_replaced_tiles()
	for curr in replaced:
		if curr is object_finish:
			finish = curr
			finish.player_entered.connect(finish_entered)
		elif curr is object_start:
			start = curr
			
	#Set new camera limits
	var camera_map_size = get_map_center().x * 2
	var curr_camera_distance = maxf(camera_limit, (DisplayServer.window_get_size().y/2)-camera_map_size)
	var new_camera_limit = camera_map_size + curr_camera_distance
	camera.limit_left = -curr_camera_distance
	camera.limit_top = -curr_camera_distance
	camera.limit_right = new_camera_limit
	camera.limit_bottom = new_camera_limit

func finish_entered():
	maze_current_size += maze_growth_size
	level += 1
	if story_lines.has(resets):
		if range(story_lines[resets].size()).has(level):
			UI.display_text(story_lines[resets][level])
	change_timer(maze_current_size * time_multiple)
	
	reset_map()

func on_timer_timeout():
	maze_current_size = maze_start_size
	resets += 1
	level = -1
	timer.start(timer_start_time)
	reset_map()

func on_collision(target_position):

	#Collision time based on the settings. steps as int as to have smooth values.
	var collision_time = -(collision_time_min + (randi_range(0, collision_number_steps) * collision_time_step))
	change_timer(collision_time)
	
	UI.on_collision(target_position, player.global_position, collision_time)
	

func get_map_center():
	return maze_generation_controller.get_map_center(maze_current_size)

func change_timer(to_change: float):
	if to_change < 0 and to_change < -timer.time_left:
		timer.start(0.001)
	else: 
		timer.start(timer.time_left + to_change)
