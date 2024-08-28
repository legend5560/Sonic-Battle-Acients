extends Node3D

@export var animator: AnimationPlayer
@export var start_with_arm_dowm: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	if start_with_arm_dowm:
		move_arm()


func move_arm():
	animator.play("arm_down")
