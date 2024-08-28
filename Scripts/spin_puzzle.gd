extends Node3D

@export var object_with_method: Node3D
@export var name_of_the_method: String


func _on_area_3d_area_entered(area):
	if area.get_parent() != null:
		var character = area.get_parent()
		if object_with_method != null and object_with_method.has_method(name_of_the_method) and character.attacking: #character.is_in_group("Player"):
			object_with_method.call(name_of_the_method)
