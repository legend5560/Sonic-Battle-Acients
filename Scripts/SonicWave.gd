extends CharacterBody3D

# The shockwave projectile Sonic sends from his "shot" attacks.
# Original code by The8BitLeaf.

# Movement speed
const SPEED = 5.0

# damage caused
var damage = 10

var constant_vel : Vector3

# The active player that spawned this projectile. Hitboxes will not interact with the user.
var user

func _ready():
	constant_vel = velocity

func _physics_process(delta):
	# Add the gravity.
	if !is_on_floor():
		# The speed at which the wave falls
		velocity.y -= GlobalVariables.gravity * delta
	velocity.x = constant_vel.x
	velocity.z = constant_vel.z
	# Chooses direction based on where the player sent it.
	if velocity.x >= 0:
		$Sprite3D.flip_h = false
	else:
		$Sprite3D.flip_h = true
	
	# If the wave hits a wall, it disappears.
	if $RayCast3D.is_colliding():
		rpc("delete")
		queue_free.call_deferred()
	
	move_and_slide()

func _on_animation_player_animation_finished(_anim_name):
	# Disappears when the animation ends.
	
	rpc("delete")
	queue_free.call_deferred()

func _on_hitbox_body_entered(body):
	# If the hitbox hits something that can be hurt and isn't the user, they will take a hit and
	# be launched in the direction the wave is moving.
	if body.is_in_group("CanHurt") && body != user:
		if body.immunity != "shot":
			# If the collision body is immune to "shot" moves, they will not be affected.
			# body.get_hurt.rpc_id(body.get_multiplayer_authority(), Vector3(velocity.x, 3, velocity.z))
			Audio.play(Audio.hitStrong, self)
			body.get_hurt(Vector3(velocity.x, 3, velocity.z), user, damage)

@rpc("any_peer", "call_local")
func delete():
	queue_free()
