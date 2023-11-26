extends RichTextLabel

@export var timer : Timer

func _process(delta):
	text = "%7.2f" % snapped(timer.time_left, 0.01)
