extends CanvasLayer

@export var timer: Timer

@export var tilemap: TileMap

@export var ap : AnimationPlayer
@export var text_ap : AnimationPlayer

const damage_number_2d = preload("res://UI/damage_label_2d.tscn")

var story_label : Node

var alarm_playing : bool
var minimap_camera : Camera2D

#For the press any key to start functionality
var is_paused = true

func _input(event):
	if event is InputEventKey:
		if event.pressed:
			if is_paused:
				Engine.time_scale = 1
				is_paused = false
				text_ap.play("text_fade_quick")

func display_text(new_text: String):
	story_label.change_text(new_text)
	text_ap.play("text_fade")
	text_ap.seek(0, true)

func _ready():
	#Connect the UI Countdown label to the timer
	get_node("Control/MarginContainer/CountdownLabel").timer = timer
	story_label = get_node("Control/MarginContainer/Story_Label")
	Engine.time_scale = 0
	
func _process(delta: float):
	if not alarm_playing and timer.time_left < 10:
		alarm_playing = true
		ap.play("alarm")
	elif alarm_playing and timer.time_left > 10:
		alarm_playing = false
		ap.stop()
		

func on_collision(col_position: Vector2, from_position: Vector2, damage: float):
	#Instantiate a damage number
	var instance = damage_number_2d.instantiate()
	tilemap.add_child(instance)
	instance.display(col_position, from_position, damage)
