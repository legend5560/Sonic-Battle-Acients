extends Node3D

## This script is entirely for having NPC characters appear on the hub before they're added,
## so that we can tease future playable characters in demos if we have the models/animations but not
## full implementation yet.
## (i.e. Shadow appearing in the city hub just in case we don't have him fully ready for SAGE.)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$AnimationPlayer.play("IMPATIENT")
