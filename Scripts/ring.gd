extends Node3D


## add a method unique to the ring
## to prevent deleting another object
func delete_ring():
	var ring_collected_effect = Instantiables.RING_COLLECTED_EFFECT.instantiate()
	ring_collected_effect.position = position + Vector3(0, 0.1, 0)
	get_parent().add_child(ring_collected_effect)
	ring_collected_effect.get_child(0).emitting = true
	delete()


@rpc("any_peer", "call_local")
func delete():
	# effects
	# audio
	# remove from scene
	queue_free()
