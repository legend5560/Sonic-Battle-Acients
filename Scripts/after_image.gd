extends Node3D

# after image effect
# get current animation and seek point in the animation timeline
# play that animation at that point
# stop the animation

@export var after_image_material: StandardMaterial3D
@export var mesh_node: MeshInstance3D
var new_material

# node that animates the mesh
@export var animation_node: AnimationPlayer
var current_animation_name = ""
var current_animation_time = 0.0

@export var after_image_life_time: float = 0.1


func _ready():
	# set a duplicated material so that it won't chance all instances together
	new_material = after_image_material.duplicate()
	mesh_node.set_surface_override_material(0, new_material)
	#mesh_node.set_surface_override_material(1, new_material)
	
	# set the afterimage pose
	if animation_node.has_animation(current_animation_name):
		# play that animation, set speed to zero
		animation_node.play(current_animation_name, -1, 0.0) #2)
		# seek the animation timeline to the correct one
		animation_node.seek(current_animation_time, true)


func _process(delta):
	# fade out the material
	var new_color = new_material.albedo_color
	new_color[3] = new_color[3] - 0.02
	new_material.albedo_color = new_color
	
	# check to delete
	after_image_life_time -= delta
	if after_image_life_time <= 0:
		queue_free()
