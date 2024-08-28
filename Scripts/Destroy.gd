extends Node3D

@export var time: float = 1.0

func _process(delta):
	if time > 0:
		time -= delta
	else:
		queue_free()
