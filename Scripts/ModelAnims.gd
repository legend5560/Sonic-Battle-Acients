extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_animation_player_animation_finished(anim_name):
	if get_parent().model_node == self:
		get_parent().anim_end(anim_name)
