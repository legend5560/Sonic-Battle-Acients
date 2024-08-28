extends CharacterBody3D

# The ring projectile sonic throws for his grounded "pow" move.
# All of the important code is handled from Sonic's script, but this handles physics.
# Original code by The8BitLeaf.

const TIME: float = 4.0
var timer: SceneTreeTimer
var ring_owner


func _ready():
	timer = get_tree().create_timer(TIME, false, true)


func _physics_process(delta):
	# Add the gravity.
	if !is_on_floor():
		# The speed at which the ring falls
		velocity.y -= GlobalVariables.gravity * delta
	else:
		# If the ring hits the ground, it bounces.
		velocity.y = 2
	
	# The ring slows down after moving for a while, becoming stationary.
	velocity.x = lerp(velocity.x, 0.0, 0.02)
	velocity.z = lerp(velocity.z, 0.0, 0.02)
	
	move_and_slide()
	
	if timer != null and timer.time_left <= 0:
		# reset variables on sonic
		if ring_owner != null:
			ring_owner.chasing_ring = false
			ring_owner.thrown_ring = false
			ring_owner.active_ring = null
		# destroy
		delete()


@rpc("any_peer", "call_local")
func delete():
	queue_free()
