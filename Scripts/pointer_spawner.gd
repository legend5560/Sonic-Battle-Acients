extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var ground_height: float = 0.2
var done: bool = false

@export var raycaster: RayCast3D
@export var target_spot: Node3D
@export var timer_text: RichTextLabel


func _physics_process(_delta):
	if not is_multiplayer_authority(): return
	if not done:
		# Get the input direction and handle the movement/deceleration.
		var input_dir = Input.get_vector("left", "right", "up", "down")
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
		
		# check ground height using raycast and place the target shadow there
		ground_height = raycaster.get_collision_point().y
		target_spot.global_position.y = ground_height
		
		# press attack to place the character
		if Input.is_action_just_pressed("punch"):
			place_character()
		
		# show time left
		timer_text.text = str(int(GlobalVariables.select_ability_timer.time_left))
		# if timer started in ability_select runs out, place the character
		if GlobalVariables.select_ability_timer.time_left <= 0:
			place_character()
		
		move_and_slide()


## spawn character on target location
func place_character():
	done = true
	var new_position = position
	new_position.y = ground_height
	Instantiables.add_player(get_parent(), new_position)
	queue_free()
