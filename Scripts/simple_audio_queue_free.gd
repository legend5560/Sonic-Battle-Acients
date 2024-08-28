extends AudioStreamPlayer3D

@onready var audio_instance = $".."


func _on_finished():
	audio_instance.queue_free()
