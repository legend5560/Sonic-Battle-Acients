extends Camera3D

# This code handles the main camera that follows the player.
# In online multiplayer, this will eventually only focus on the active client player.
# Original code by The8BitLeaf.

# code modified later on


var player	# The player target.
var spin = 1

const NORMAL_SPEED = 0.025
const FAST_SPEED = 0.08
var current_speed = NORMAL_SPEED

var shake_camera_time: float = 0.0
const DEFAULT_SHAKE_INTENSITY: float = 1.0
var shake_intensity: float = DEFAULT_SHAKE_INTENSITY

var player_is_behind_object: bool = false

@export var light_node: DirectionalLight3D
@export var raycast_to_player: RayCast3D

var original_light_color

func _ready():
	# The camera locks on to the player.
	# When we have multiple characters and respawning, this will likely change to some capacity.
	player = get_parent()
	# store in global variables
	GlobalVariables.camera = self
	# if it's in perspective mode, set the position to where it should be
	if projection == 0:
		position = Vector3(0, 10, 10)
	
	original_light_color = light_node.light_color


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# speed up the pace when changing camera direction
	var target_z_value = player.position.z + (15 * spin) - player.velocity.z
	var difference = abs(abs(target_z_value) - abs(global_position.z))
	if difference > 1:
		current_speed = FAST_SPEED
		# make the place marker's label change orientation
		GlobalVariables.camera_orientation_changed.emit()
	else:
		current_speed = NORMAL_SPEED
	
	# The camera will always slowly accelerate to the player's location and look at them.
	global_position = lerp(global_position, Vector3(player.position.x - player.velocity.x, player.position.y + 5 + difference - player.velocity.y, player.position.z + (15 * spin) - player.velocity.z), current_speed)
	look_at(player.position)

	# nighttime on the city hub 
	if GlobalVariables.current_hub != null:
		#light_node.light_energy = 0.1
		light_node.light_color = Color(0, 0, 0, 1)
	else:
		light_node.light_energy = 3
		light_node.light_color = original_light_color

	# make the camera farther away on the areas
	if GlobalVariables.current_stage == null:
		size = 5
		fov = 20
	else:
		size = 3
		fov = 10
	
	# shake camera if needed
	if shake_camera_time > 0 and GlobalVariables.can_shake_camera:
		shake_camera_time -= delta
		var new_position = Vector3(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity), 0)
		position = lerp(position, new_position, 0.01)
		if shake_camera_time <= 0:
			shake_intensity = DEFAULT_SHAKE_INTENSITY
	
	# check if player is behind a wall
	# if so, the player will use the see through after image
	# so the player can see the character
	if player:
		# check if there is a collider
		var new_raycast_collision = raycast_to_player.get_collider()
		# if so
		if new_raycast_collision != null:
			# get the position of the collision
			var new_point = raycast_to_player.get_collision_point()
			# store the distances
			var camera_distance_to_point = (position - new_point).length()
			var camera_distance_to_player = (position - player.position).length()
			# if the point is closer to the camera than the player
			if camera_distance_to_point < camera_distance_to_player \
			and new_raycast_collision.name != player.name:
				player_is_behind_object = true
			else:
				player_is_behind_object = false
		else:
			player_is_behind_object = false


func rotate_camera():
	# spin control which side the camera will lerp to along the Z axis
	spin = -spin
	# store character position
	var character_position = get_parent().position
	# store distance between character and camera
	#var character_distance = (character_position - position).length()
	# store direction from camera to character
	var direction = (character_position - position).normalized()
	# invert the Y axis of the direction so it won't cross the ground
	direction.y = -direction.y
	# set the new camera position to behind the character
	#global_position = direction * character_distance


# for the shake camera effect
func shake(amount = 0.1, intensity = DEFAULT_SHAKE_INTENSITY):
	# set an amount of time to shake the camera
	shake_camera_time = amount
	# set an intensity
	if intensity != DEFAULT_SHAKE_INTENSITY:
		shake_intensity = intensity
