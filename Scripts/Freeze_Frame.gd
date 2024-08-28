extends Node3D

var new_timescale
var freeze_duration

func _ready():
	if new_timescale and freeze_duration:
		Engine.time_scale = new_timescale
		await get_tree().create_timer(freeze_duration * new_timescale).timeout
		Engine.time_scale = 1.0
		queue_free()
