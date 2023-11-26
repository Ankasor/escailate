extends Node2D

@export var ap : AnimationPlayer
@export var label : RichTextLabel

func _ready():
	pass

func display(pos_from: Vector2, pos_to: Vector2, amount : float):
	label.text = str(amount)
	
	#Tween the position in the direction of the collision with a bias to the top
	var tween = create_tween()
	position = pos_from
	var final_pos = pos_from + (pos_from-pos_to) + Vector2(randf_range(-12, 12), randf_range(-12, 12))
	tween.tween_property(self, "position", final_pos, 1)
	
	ap.play("dmg_anim")

func remove():
	queue_free()
