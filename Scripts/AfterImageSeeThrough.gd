extends Node3D

# effect to allow the player to see the character through objects
# get current animation and seek point in the animation timeline
# play that animation at that point
@export var see_through_material: StandardMaterial3D
@export var super_form_material: StandardMaterial3D
@export_category("Normal Sonic")
@export var mesh_node: MeshInstance3D
# node that animates the mesh
@export var animation_node: AnimationPlayer
@export_category("Super Sonic")
@export var super_form_node: MeshInstance3D
@export var super_animation_node: AnimationPlayer

var current_animator_node
var current_animation_name = ""
var current_animation_time = 0.0

# character will pass this value when calling the update
var character_is_in_super_mode: bool = false

func _ready():
	# set a duplicated material so that it won't chance all instances together
	mesh_node.set_surface_override_material(0, see_through_material)
	#mesh_node.set_surface_override_material(1, see_through_material)
	
	super_form_node.set_surface_override_material(0, super_form_material)


	# update the pose
func update_pose():
	if character_is_in_super_mode:
		current_animator_node = super_animation_node
		mesh_node.hide()
		super_form_node.show()
	else:
		current_animator_node = animation_node
		mesh_node.show()
		super_form_node.hide()
	
	if current_animator_node.has_animation(current_animation_name):
		# play that animation, set speed to zero
		current_animator_node.play(current_animation_name)#, -1, 0.0) #2)
		# seek the animation timeline to the correct one
		current_animator_node.seek(current_animation_time, true)
	else:
		if current_animation_name != "":
			push_warning("see through after image doesn't have animation named ", current_animation_name)
