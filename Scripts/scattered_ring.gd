extends CharacterBody3D

# Original code by The8BitLeaf. changed later

const DEFAULT_BOUNCE_VALUE: float = 4.0
const MIN_TIME: float = 3.5
var bounce_amount: float = DEFAULT_BOUNCE_VALUE
var blinking_period: float = 0.0

var current_time = GlobalVariables.SCATTERED_RINGS_TIME

@export var ring: Node3D
@export var collision_area: Area3D


func _ready():
	#collision_area.monitorable = false
	collision_area.set_deferred("monitorable", false)


func _physics_process(delta):
	current_time -= delta
	
	# Add the gravity.
	if !is_on_floor():
		# The speed at which the ring falls
		velocity.y -= GlobalVariables.gravity * delta
	else:
		bounce_amount = move_toward(bounce_amount, 0, 0.4)
		# If the ring hits the ground, it bounces.
		velocity.y = bounce_amount
	
	# The ring slows down after moving for a while, becoming stationary.
	velocity.x = lerp(velocity.x, 0.0, 0.02)
	velocity.z = lerp(velocity.z, 0.0, 0.02)
	
	move_and_slide()
	
	# enable the detection after it scattered
	if can_collect():
		collision_area.monitorable = true
	
	if current_time <= 3.0:
		# blink faster as the time out approaches
		if blinking_period <= 0:
			blinking_period = current_time / 5.0
		blinking_period -= delta * 5
		if blinking_period <= 0.0:
			if ring.is_visible_in_tree():
				ring.hide()
			else:
				ring.show()
		
		# delete when scaterred rings timer runs out
		if current_time <= 0:
			delete()


func can_collect():
	return current_time <= MIN_TIME


## add a method unique to the ring
## to prevent deleting another object
func delete_ring():
	if can_collect():
		var ring_collected_effect = Instantiables.RING_COLLECTED_EFFECT.instantiate()
		ring_collected_effect.position = position + Vector3(0, 0.1, 0)
		get_parent().add_child(ring_collected_effect)
		ring_collected_effect.get_child(0).emitting = true
		delete()


@rpc("any_peer", "call_local")
func delete():
	queue_free()
