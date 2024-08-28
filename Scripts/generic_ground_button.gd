extends Node3D

@export var object_with_method: Node3D
@export var method_name: String

@export var on_material: StandardMaterial3D
@export var off_material: StandardMaterial3D

@export var button_mesh_object: MeshInstance3D

@export var can_trigger_again: bool = false
var done = false


func _ready():
	button_mesh_object.set_surface_override_material(1, off_material)
	
	
func _on_area_3d_area_entered(area):
	if done == false and area.get_parent() != null and area.get_parent().is_in_group("Player"): # and object_with_method != null and object_with_method.has_method(method_name):
		if not can_trigger_again:
			done = true
		button_mesh_object.set_surface_override_material(1, on_material)
		object_with_method.call(method_name)


func _on_area_3d_area_exited(area):
	if can_trigger_again and area.get_parent() != null and area.get_parent().is_in_group("Player"): # and object_with_method != null and object_with_method.has_method(method_name):
		button_mesh_object.set_surface_override_material(1, off_material)
