extends MeshInstance3D

@export var rotation_speed = 0.005
@export var move_speed = 0.005
@export var start_pos = Vector3(0,0,0)
@export var end_pos = Vector3(0,0,0)
@export var move_wait = 0 # time to wait before moving again in frames

var get_pos = end_pos
var move_timer = move_wait

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if rotation_speed != 0:
		rotation.y += rotation_speed

	if move_speed != 0:
			
		if get_pos == Vector3(0,0,0):
			get_pos = end_pos
		
		if position == end_pos:
			if move_timer != 0:
				move_timer -= 1
			else:
				get_pos = start_pos
				move_timer = move_wait
				
		elif position == start_pos:
			if move_timer != 0:
				move_timer -= 1
			else:
				get_pos = end_pos
				move_timer = move_wait
		position = position.move_toward(get_pos,move_speed)

	



