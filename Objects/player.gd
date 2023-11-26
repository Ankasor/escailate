extends CharacterBody2D

@export var movement_controller: Node2D
@export var tileMap: TileMap
@export var sprite : Sprite2D

@export var idle_amplitude : float
@export var idle_frequency : float
var time = 0

@export var movement_delay : float
var moving = false
var moving_start_time = 0

@export var ap : AnimationPlayer

@export var remote_camera : Node2D

var bool_once = false

func _ready():
	get_node("tile_based_movement_controller").tileMap = tileMap;
	movement_controller.movement_success.connect(on_movement)
	movement_controller.movement_collision.connect(on_collision)

	
	
func _process(delta):
	if(!bool_once):
		bool_once = true
		var node_path = remote_camera.get_path()
		print(node_path)
		var rt = get_node("Sprite2D/RemoteTransform2D")
		rt.set_remote_node(node_path)
		rt.force_update_cache()
		rt.force_update_transform()
		
	time += delta 
	
	var sprite_movement = Vector2(0, 0)
	
	if not moving:
		if Input.is_action_just_pressed("up"):
			movement_controller.movement_direction(Vector2i(0, -1))
			ap.play("move_up")
		elif Input.is_action_just_pressed("down"):
			movement_controller.movement_direction(Vector2i(0, 1))
			ap.play("move_down")
		elif Input.is_action_just_pressed("left"):
			movement_controller.movement_direction(Vector2i(-1, 0))
			ap.play("move_left")
		elif Input.is_action_just_pressed("right"):
			movement_controller.movement_direction(Vector2i(1, 0))
			ap.play("move_right")
		
	else:
		if time > moving_start_time + movement_delay:
			moving = false
			
	var idle_movement_y = sin(time * idle_frequency) * idle_amplitude
	sprite.global_position += Vector2(0, idle_movement_y) * delta

func on_movement(target_position):
	set_moving()
	

func on_collision(target_position):
	set_moving()
	
func set_moving():
	moving = true
	moving_start_time = time
