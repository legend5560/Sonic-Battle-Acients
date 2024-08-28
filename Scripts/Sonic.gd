extends CharacterBody3D

# This is the script for the playable character Sonic.
# Most of the code can be copied over to other characters, but a lot of values and
# character-specific actions will need to be adjusted in order to copy this code over.
# Original code by The8BitLeaf.

# code modified later on

# Basic movement speed values for Sonic.
const SPEED = 4.0
const JUMP_VELOCITY = 5.0

# Basic movement speed values for Sonic.
const RECOVERY_JUMP_VELOCITY = 5.0
const SUPER_RECOVERY_JUMP_VELOCITY = 6.0

# Basic movement speed values for Super Sonic.
const SUPER_SPEED = 6.0
const SUPER_JUMP_VELOCITY = 6.0

# Dash speed is the speed value for the dash move executed by double tapping a direction on the ground
# Sonic's midair jump ability is an air dash, and the speed is determined by airdash speed.
const DASH_SPEED = 10.0
const DASH_HEIGHT = 3.0
const AIRDASH_SPEED = 10.0

# amount of time allowed between presses to consider it as a double tap
const DOUBLETAP_DELAY: float = 0.2

# max distance from ground to allow jump through coyote time
const MAX_COYOTE_GROUND_DISTANCE: float = 0.1

# default life total value
const MAX_LIFE_TOTAL = 100

# default max special amount
const MAX_SPECIAL_AMOUNT = 100

# max number of rings to be created when scattering rings
const MAX_SCATTERED_RINGS_ALLOWED: int = 8

# heal points per ring collected
const HEAL_POINTS_PER_RING: int = 2

const DEFAULT_HEAL_AMOUNT: int = 4

# input direction
var direction = Vector3.ZERO

# Booleans for checking when Sonic is jumping or falling, used to make sure
# that Sonic plays the correct animations.
var jumping = false
var falling = false
var jump_clicked: bool = false

# Starting determines the state where Sonic is accelerating, usually only impacts ground moves.
# When starting, Sonic can execute a dash or strong attack on the ground.
# Walking is just to differentiate his moving state.
var walking = false
var starting = false

# When letting go of a direction while moving, Sonic plays a stopping animation
var stopped = true

# Boolean for when Sonic is in the middle of a dash animation.
var dashing = false

# Boolean that makes sure Sonic can only airdash once in the air. Resets when on the ground.
var can_airdash = true

# Boolean to determine when to lock Sonic's moveset during an attack.
var attacking = false

# Like can_airdash, but instead determines if a midair attack can be executed.
var can_air_attack = true

# The current punching state for the 3-hit combo.
var current_punch = 0

# This vector determines the strength and direction the hitbox object sends opponents.
# Each move changes the launch power when necessary and the animation handles the hitbox position.
var launch_power: Vector3

# this variable determines the amount of damage that the character will cause
# each move changes the damage caused accordingly
var damage_caused: int

# States for when Sonic is hurt, locking his actions.
var hurt = false
var launched = false
var spiked = false
var rolling = false

# State for when Sonic can jump out of being launched, or other similar animations
var can_recover = false

# Checking if sonic is currently in his wall-hitting animation, also the window to tech a wall
var hitting_wall = false

# Skills! These strings determine what Sonic's grounded and midair special type are.
# Immunity determines which category of special move Sonic is immune to.
var ground_skill
var air_skill
var immunity

# Sonic's midair "pow" special move bounces off the ground, so this state makes sure he does that.
var bouncing = false

# active_ring is the object recently created by Sonic's grounded "pow" move, for checking constant positioning.
# thrown_ring indicates when a ring is on the field, to avoid calling a null active_ring
var active_ring: CharacterBody3D
var thrown_ring = false

# The state in which Sonic is moving in the direction of active_ring.
var chasing_ring = false

# The mine object currently on the field, to ensure only one mine can be used at a time.
var active_mine

# Since Sonic's "pow" move is a melee attack and uses his regular hitboxes,
# this boolean ensures that immunities still apply.
var pow_move = false

# coyote time variables
# timer for coyote time
var coyote_timer: SceneTreeTimer
# distance from ground when on air
var coyote_ground_distance: float = 0.0

# store the time left for double tap check
var doubletap_timer = DOUBLETAP_DELAY
# to allow dash only after a double tap
var dash_triggered = false

# values presented on hud
var life_total: int = MAX_LIFE_TOTAL
var special_amount: int = 0
var points: int = 0

# value that will increase when pressing healing to trigger the heal method
var healing_time: float = 0.0
# the rate the healing_time will increase
var healing_pace: float = 0.1
# the amount of heling_time to trigger a heal call
var healing_threshold: float = 3.0
# where the heal effect scene that will be instantiated will be stored
var heal_effect: Node3D
# boolean to check when Sonic is healing
var healing: bool

# boolean to check when Sonic is guarding
var guarding: bool

# the last player who caused damage to this character
var last_aggressor
# boolean to check when the player is chasing after a successful wall jump
var chasing_aggressor : bool
# boolean to check when the player can do the AIM attack
var can_spike : bool
# boolean to check when the player can chase after a strong hit
var can_chase : bool

# prevent defeated() to be called more than once
var was_defeated: bool = false

var punch_timer: SceneTreeTimer

# store the input state transmited by a input node or CPU node
# this allows to separate the inputs from the character script
# which helps creating CPU characters
#var punch_pressed: bool = false
var special_pressed: bool = false
var jump_pressed: bool = false
var attack_pressed: bool = false
var upper_pressed: bool = false
var guard_pressed: bool = false
var heal_pressed: bool = false
var super_pressed: bool = false

# rings collected in a stage
# start with an amount to test
var rings: int = MAX_SCATTERED_RINGS_ALLOWED

# to reposition if falling off a pit but still not defeated
var last_spawn_position: Vector3 = Vector3.ZERO

var after_image_time: float = 0.0

# object to allow player to see the character through objects
var see_through_after_image: Node3D

var special_is_full_effect: Node3D

var super_mode = false

# multiplier for damage. When super, this is increased.
var damage_multiplier = 1.0

# state for going super, so no inputs are used during the animation
var going_super = false

# counter to determine when each step of the special draining happens
var special_drain_counter: int = 0
# the amount accrrued each cycle to count towards the threshold
var special_drain_step: int = 1
# the threshold for each draining
var special_drain_threshold: int = 10
# amount to drain from the special bar each draining while on super form
var special_drain_amount: int = 1

# make only one $ call and store the node
@onready var sprite_animation_player = $AnimationPlayer
@onready var model_node = $sonicrigged2
@onready var model_animation_player = $sonicrigged2/AnimationPlayer
@onready var drop_shadow_range = $DropShadowRange
@onready var drop_shadow = $DropShadow
@onready var hit_box = $Hitbox

# model calls for base form and super sonic, for setting model_node and model_animation_player
@onready var base_model = $sonicrigged2
@onready var base_model_anim = $sonicrigged2/AnimationPlayer
@onready var super_model = $supersonicrigged
@onready var super_model_anim = $supersonicrigged/AnimationPlayer

# guard effect, the temporary one is a simple particle
@onready var guard_effect = $GuardEffectTemp

# Head Up Display
@export_category("HUD")
@export var hud: Control

# camera
@export_category("CAMERA")
@export var camera: Camera3D

# the checker for when the current point in the "PAC" animation changes to the strong variant,
# change this in animation player
@export var pac_strong = false

## the character model which turns accordingly to the input direction
## this is used as reference direction for the Bots
#@export var model_node: Node3D


func _enter_tree():
	#set_multiplayer_authority(str(name).to_int())
	set_multiplayer_authority(GlobalVariables.character_id)


func _ready():
	if not is_multiplayer_authority(): return
	$MainCam.current = true
	
	points = GlobalVariables.character_points
	
	if GlobalVariables.respawnSpecial > 0:
		special_amount = GlobalVariables.respawnSpecial
	
	# update the hud with the default values when starting the game
	hud.update_hud(life_total, special_amount, points)
	
	GlobalVariables.current_character = self
	
	if GlobalVariables.current_stage == null:
		ground_skill = "POW"
		air_skill = "POW"
	
	last_spawn_position = position


# Setting a drop shadow is weird in _physics_process(), so the drop shadow code is in _process().
func _process(delta):	
	# If the drop shadow ray detects ground, it sets the visual shadow at the collision point.
	if drop_shadow_range.is_colliding():
		drop_shadow.visible = true
		var ground_height = drop_shadow_range.get_collision_point().y
		drop_shadow.global_position.y = ground_height
		
		# coyote time to help responsiveness jump
		if !is_on_floor():
			coyote_ground_distance = position.y - ground_height

	else:
		drop_shadow.visible = false
	
	# coyote time between gaps
	if coyote_timer == null:
		create_coyote_timer()
	
	# call coyote light feet here so it can work with coyote edge by creating it's timer
	coyote_light_feet()
		
	# to check the time between key presses
	# could create an actual timer instead
	if doubletap_timer > 0:
		doubletap_timer -= delta
	
	# control how often an after image will appear
	if after_image_time > 0:
		after_image_time -= delta


func _physics_process(delta):
	if !is_multiplayer_authority(): return
	
	if !going_super:
		if super_mode:
			damage_multiplier = 1.5
			model_node = super_model
			model_animation_player = super_model_anim
			base_model.visible = false
			super_model.visible = true
			
			# drain special while on super form
			handle_special_draining()
			
		else:
			damage_multiplier = 1.0
			model_node = base_model
			model_animation_player = base_model_anim
			base_model.visible = true
			super_model.visible = false
	
	if !is_on_floor():
		if !hitting_wall && !going_super:
			# add the gravity.
			# The speed at which Sonic falls
			velocity.y -= GlobalVariables.gravity * delta
		# Since starting and walking only do things on the ground, they are set to inactive here.
		starting = false
		walking = false
	else:
		hitting_wall = false
		can_recover = false
		# remove current coyote timer form the variable
		coyote_timer = null
		# Being on the ground means you aren't jumping or falling
		jumping = false
		falling = false
		jump_clicked = false
		# Because Sonic's dash is a sort of jump, this is how the move resets itself.
		# For characters that slide along the ground (i.e. Shadow), this may change.
		dashing = false
		# Midair moves can only be used after a jump once, and they can be used again after touching the ground.
		can_airdash = true
		can_air_attack = true
		if !hitting_wall:
			chasing_aggressor = false
		can_spike = false
		# If Sonic is in his midair "pow" bouncing state, his velocity sends him upwards off the ground.
		if bouncing:
			velocity.y = 5
			can_airdash = false
			can_air_attack = false	# As funny as it would be to have the SA2 bounce spam, it would be too OP here.
		
		if chasing_ring:
			attacking = false
			chasing_ring = false
			starting = false
			pow_move = false
		
		if spiked:
			model_animation_player.play("KO")
			spiked = false
		
	
	if model_animation_player.current_animation == "PAC":
		if pac_strong:
			launch_power = Vector3(model_node.basis.z.normalized().x * 5, 5, model_node.basis.z.normalized().x * 5)
			damage_caused = 17
	
	if is_on_wall() && model_animation_player.current_animation == "LAUNCHED":
		model_node.rotation.y = Vector2(-get_wall_normal().z, -get_wall_normal().x).angle()
		velocity = Vector3.ZERO
		position.y += 0.1
		model_animation_player.play("HIT WALL")
		hitting_wall = true
	
	if !going_super:
		if !attacking && !hurt && !chasing_aggressor && !can_spike && !guarding:
			
			handle_super()
			
			if !healing:
				handle_jump()
				
				handle_dash()
				
				handle_movement_input()
				
				handle_sprite_orientation()
				
				handle_attack()
				
				handle_guard()
				
				handle_upper()
				
				rotate_model()
			else:
				# if Sonic is in his healing state, he slows to a halt.
				velocity.x = lerp(velocity.x, 0.0, 0.1)
				velocity.z = lerp(velocity.z, 0.0, 0.1)
			handle_healing()
		
		else:
			if can_recover:
				handle_recovery()
			
			if !chasing_ring && !bouncing && !chasing_aggressor:
				if !guarding:
					# if Sonic is in his attacking or hurt state, he slows to a halt.
					velocity.x = lerp(velocity.x, 0.0, 0.1)
					velocity.z = lerp(velocity.z, 0.0, 0.1)
				else:
					# if Sonic is in his guard state, he slows faster.
					velocity.x = lerp(velocity.x, 0.0, 0.5)
					velocity.z = lerp(velocity.z, 0.0, 0.5)
			if model_animation_player.current_animation == "HIT WALL" || can_chase:
				handle_walljump()
	
	# remove the healing effect if not pressing the button
	if (!heal_pressed or hurt) and heal_effect != null:
		healing = false
		healing_time = 0
		heal_effect.hide()
	
	# defeated if going lower than the lower limit of the map or
	# life total is less than or equal to zero
	# or the character is not in a battle and don't have rings
	if position.y < -5.0:
		#cause damage
		life_total -= 10
		if life_total < 0:
			life_total = 0
		#reposition or respawn
		if life_total <= 0:
			defeated()
		else:
			hud.change_life(life_total)
			velocity = Vector3.ZERO
			GlobalVariables.respawnLife = life_total
			GlobalVariables.respawnSpecial = special_amount
			if GlobalVariables.current_character != null:
				GlobalVariables.current_character.queue_free()
				GlobalVariables.current_character = null
			GlobalVariables.select_ability_timer = get_tree().create_timer(2.0, false, true)
			var spawner = Instantiables.create(Instantiables.objects.POINTERSPAWNER)
			spawner.position = last_spawn_position
			get_parent().add_child(spawner)


	# If Sonic is currently chasing an aggressor after successfully executing a wall jump, he accelerates to above its position.
	if chasing_aggressor && last_aggressor != null:
		velocity.x = lerp(velocity.x, (last_aggressor.transform.origin - transform.origin).normalized().x * 20, 0.25)
		velocity.z = lerp(velocity.z, (last_aggressor.transform.origin - transform.origin).normalized().z * 20, 0.25)
		
		if velocity.y <= 0:
			chasing_aggressor = false
			can_spike = true
	
	if can_spike:
		handle_spike()
	
	handle_see_through()
	
	handle_after_image()
	
	handle_special_is_full()
	
	# Automatically handle the animation and character controller physics.
	handle_animation()
	move_and_slide()


## handle the movement of the character given an input
func handle_movement_input():	
	# Code for handling basic movement
	if direction:
		# If Sonic is at a standstill before moving, he enters his starting state for dashes and strong attacks.
		if !starting && !walking && is_on_floor():
			starting = true
			sprite_animation_player.play("startWalk")
			model_animation_player.play("WALK START")
		if !super_mode:
			velocity.x = lerp(velocity.x, direction.x * SPEED, 0.1)
			velocity.z = lerp(velocity.z, direction.z * SPEED, 0.1)
		else:
			velocity.x = lerp(velocity.x, direction.x * SUPER_SPEED, 0.1)
			velocity.z = lerp(velocity.z, direction.z * SUPER_SPEED, 0.1)
	else:		
		walking = false
		velocity.x = lerp(velocity.x, 0.0, 0.1)
		velocity.z = lerp(velocity.z, 0.0, 0.1)


## Code for determining the direction the character is facing.
func handle_sprite_orientation():
	hit_box.rotation = model_node.rotation
	# Since some moves hold backwards without turning.
	#var flip_threshold = 2
	# if the character is on idle or walk animation, flip the sprite with the input
	#if walking or starting:
	#	flip_threshold = 2

func handle_super():
	if super_pressed && special_amount == 100 && !super_mode && !going_super:
		going_super = true
		model_node = super_model
		model_animation_player = super_model_anim
		healing = false
		guarding = false
		velocity = Vector3.ZERO
		sprite_animation_player.play("super")
		base_model_anim.play("SUPER")
		super_model_anim.play("SUPER")

## method to check and perform the dash movement
func handle_dash():
	# This set of "if" statements handles the dash. Pressing your current velocity direction
	# while in the starting state causes Sonic to dash in that direction, recreating the "double-tap" input
	# This is probably a very workaround solution and there's probably a way to make it work better
	# But this is the best solution I could come up with.
	# added a dash_triggered to prevent dashing when simply pressing diagonals
	# (was suposed to substitute the double tap completely but the character was making a
	# jump animation instead of dash animation so added the dash_triggered variable instead)
	if dash_triggered:
		velocity = Vector3(velocity.normalized().x * DASH_SPEED, DASH_HEIGHT, velocity.normalized().z * DASH_SPEED)
		dashing = true
		coyote_timer = null
		sprite_animation_player.play("dash")
		model_animation_player.play("DASH")
		Audio.play(Audio.dash, self)
		
		var dust_effect = Instantiables.DUST_PARTICLE.instantiate()
		dust_effect.position = position
		get_parent().add_child(dust_effect)
		dust_effect.look_at(position - velocity.normalized())
		dust_effect.get_child(0).emitting = true
		dust_effect.get_child(1).emitting = true
		
	dash_triggered = false

## For handling the ability to jump out of being launched for a while.
func handle_recovery():
	if jump_pressed:
		bouncing = false
		chasing_ring = false
		attacking = false
		can_recover = false
		hurt = false
		launched = false
		Audio.play(Audio.jump, self)
		if !super_mode:
			velocity.y = RECOVERY_JUMP_VELOCITY
		else:
			velocity.y = SUPER_RECOVERY_JUMP_VELOCITY
		jumping = true
		jump_clicked = true
		# remove current coyote timer form the variable
		coyote_timer = null

## plays a timer after being launched by a strong attack, when it ends Sonic can recovery jump
func launch_recovery():
	await get_tree().create_timer(0.6).timeout
	if model_animation_player.current_animation == "LAUNCHED":
		can_recover = true

## method to control the jump
func handle_jump():
	# If you're in the air, Sonic performs his midair action (as long as he hasn't used it yet.)
	if jump_pressed && (is_on_floor() || coyote_time()) && !dashing:
		Audio.play(Audio.jump, self)
		if !super_mode:
			velocity.y = JUMP_VELOCITY
		else:
			velocity.y = SUPER_JUMP_VELOCITY
		jumping = true
		jump_clicked = true
		# remove current coyote timer form the variable
		coyote_timer = null
	elif jump_pressed && !is_on_floor() && can_airdash:
		Audio.play(Audio.airDash, self) #spin)
		dashing = true
		can_airdash = false
		# remove current coyote timer form the variable
		coyote_timer = null
		sprite_animation_player.play("airdash")
		model_animation_player.play("DJMP 1")
		# If Sonic is inputting a direction, he airdashes in that direction.
		# If no direction is held, he moves horizontally in the direction he's facing.
		if direction:
			velocity = Vector3(direction.x * AIRDASH_SPEED, 4, direction.z * AIRDASH_SPEED)
		else:
			var new_velocity = model_node.transform.basis.z.normalized() * AIRDASH_SPEED
			new_velocity.y = 4
			velocity = new_velocity
	
	# controlled height jump test
	#if jump_clicked and Input.is_action_just_released("jump") and velocity.y > 0:
	#	velocity.y = 1

func handle_walljump():
	if guard_pressed:
		hurt = false
		can_chase = false
		attacking = false
		model_animation_player.play("WALL")

func handle_guard():
	if guard_pressed && is_on_floor() && !super_pressed:
		guarding = true
		model_animation_player.play("GUARD")
		guard_effect.restart()
		# guard_effect.emitting = true

## help responsiveness feeling by forgiving the difference between the human response and the machine accuracy
func coyote_time() -> bool:
	if coyote_edge() and coyote_light_feet():
		push_warning("coyote light feet edge case")
	return coyote_edge() or coyote_light_feet()


## help responsiveness feeling by allowing to jump right after passing an edge
func coyote_edge() -> bool:
	var can_jump = false
	if coyote_timer != null and coyote_timer.time_left > 0 and jump_clicked == false:
		can_jump = true
	return can_jump


## help responsiveness feeling by allowing to jump right before touching the ground
func coyote_light_feet() -> bool:
	var can_jump = false
	if !is_on_floor() and coyote_ground_distance <= MAX_COYOTE_GROUND_DISTANCE and jump_clicked == false:
		can_jump = true
		# creating the timer here will allow the coyote light feet to work with coyote edge
		# so that the player to jump when passing very close to the edge of a platform
		create_coyote_timer()
	return can_jump


## create a timer for the coyote time
func create_coyote_timer():
	coyote_timer = get_tree().create_timer(0.2, false, true)


## create a timer for the punch combo
func create_punch_timer():
	punch_timer = get_tree().create_timer(0.5, false, true)


## method to handle when the updraft button is pressed
func handle_upper():
	if upper_pressed:
		if is_on_floor():
			sprite_animation_player.play("upStrong")
			model_animation_player.play("UPPER")
			Audio.play(Audio.attackStrong, self)
			launch_power = Vector3(0, 7, 0)
			damage_caused = 17
			attacking = true
			velocity = -model_node.basis.z.normalized() * 2
		else:
			if can_air_attack:
				pac_strong = false
				can_air_attack = false
				sprite_animation_player.play("pac")
				model_animation_player.play("PAC")
				Audio.play(Audio.attackStrong, self)
				launch_power = Vector3(0, 1, 0)
				velocity.y = 3
				damage_caused = 2
				attacking = true

## method to execute the AIM attack
func handle_spike():
	if attack_pressed:
		can_spike = false
		sprite_animation_player.play("aim")
		model_animation_player.play("AIM")
		Audio.play(Audio.attackStrong, self)
		launch_power = Vector3(0, -5, 0)
		damage_caused = 17
		attacking = true

## method to determine what happens when punch attack is pressed, grounded or not
## ALL the basic attacks are handled in this chain of if statements.
func handle_attack():
	if attack_pressed && starting:
		# The code for Sonic's strong attacks. If he's holding the opposite direction,
		# he executes an up strong attack which slightly bumps him backwards.
		
		# If sonic holds any other direction, he executes a normal strong attack
		# that sends the opponent in the direction he specifies.
		sprite_animation_player.play("strong")
		model_animation_player.play("PGC 4")
		Audio.play(Audio.attackStrong, self)
		var new_launch = model_node.transform.basis.z.normalized() * 20
		new_launch.y = 5
		launch_power = new_launch
		damage_caused = 17
		attacking = true
	elif attack_pressed && dashing && can_airdash:
		# The code for Sonic's dash attack. His dash attack stalls him in the air for a short time.
		can_airdash = false
		attacking = true
		sprite_animation_player.play("dashAttack")
		model_animation_player.play("DASH ATK")
		Audio.play(Audio.attack2, self)
		launch_power = Vector3(velocity.x, 2, velocity.z)
		damage_caused = 7
		velocity.y = 3
	elif attack_pressed && !dashing && !is_on_floor() && can_air_attack:
		# The code for Sonic's midair attack. He can only use this once before landing, and it
		# sends the opponent downwards.
		attacking = true
		can_air_attack = false
		sprite_animation_player.play("airAttack")
		model_animation_player.play("AIR")
		Audio.play(Audio.attack2, self)
		
		var new_launch = model_node.transform.basis.z.normalized() * 5
		new_launch.y = -2
		launch_power = new_launch
		damage_caused = 7
		
		velocity.y = 4
	elif Input.is_action_just_pressed("punch") && is_on_floor() && !starting:
		create_punch_timer()
		attacking = true
		if current_punch == 0:
			# The code to initiate Sonic's 3-hit combo. The rest of the punches are in _on_animation_player_animation_finished().
			sprite_animation_player.play("punch1")
			model_animation_player.play("PGC 1")
			Audio.play(Audio.attack1, self) 
			launch_power = Vector3(0, 0, 0)
			damage_caused = 7
			current_punch = 1
		elif current_punch == 1:
			sprite_animation_player.play("punch2")
			model_animation_player.play("PGC 2")
			Audio.play(Audio.attack2, self)
			launch_power = Vector3(0, 0, 0)
			damage_caused = 7
			current_punch = 2
			
		elif current_punch == 2:
			sprite_animation_player.play("punch3")
			model_animation_player.play("PGC 3")
			Audio.play(Audio.attack2, self)
			launch_power = Vector3(0, 0, 0)
			damage_caused = 7
			current_punch = 3
		
		elif current_punch == 3:
			sprite_animation_player.play("strong")
			model_animation_player.play("PGC 4")
			Audio.play(Audio.attackStrong, self)
			var new_launch = model_node.transform.basis.z.normalized() * 20
			new_launch.y = 5
			launch_power = new_launch
			damage_caused = 7
			current_punch = 0
	
	# The code for initiating Sonic's grounded and midair specials, which go to functions that check the selected skills.
	# no abilities on the hub areas
	if ground_skill != null and air_skill != null and !super_pressed: #GlobalVariables.current_hub == null and GlobalVariables.current_area == null:
		if special_pressed && is_on_floor():
			attacking = true
			rpc("ground_special", randi(), direction)
		elif special_pressed && !is_on_floor() && can_air_attack:
			attacking = true
			can_air_attack = false
			rpc("air_special", randi(), direction)


## method to pace the healing of the character given an input
func handle_healing():	
	if heal_pressed && is_on_floor():
		healing_time += healing_pace
		if healing_time >= healing_threshold:
			healing = true
			heal()
			Audio.play(Audio.heal, self)
			healing_time = 0
	else:
		if healing:
			model_animation_player.play("IDLE")
		healing = false
		healing_time = 0
		if heal_effect != null:
			heal_effect.hide()


## method to heal the character's life total
func heal(amount = DEFAULT_HEAL_AMOUNT):
	if heal_effect == null:
		heal_effect = Instantiables.HEALING_EFFECT.instantiate()
		heal_effect.position = Vector3(0, -0.15, 0)
		add_child(heal_effect)
		heal_effect.get_child(0).emitting = true
	else:
		heal_effect.show()
		heal_effect.get_child(0).emitting = true
	
	if life_total < MAX_LIFE_TOTAL:
		life_total += amount
	if life_total > MAX_LIFE_TOTAL:
		life_total = MAX_LIFE_TOTAL
	hud.change_life(life_total)
	
	increase_special(4)


## method to fill the character's special amount
func increase_special(amount = 1):
	if special_amount < MAX_SPECIAL_AMOUNT:
		special_amount += amount
	if special_amount > MAX_SPECIAL_AMOUNT:
		special_amount = MAX_SPECIAL_AMOUNT
	hud.change_special(special_amount)


## increase the total points gained in-game by one
func increase_points():
	points += 1
	hud.change_points(points)
	GlobalVariables.character_points = points
	if points >= GlobalVariables.points_to_win:
		GlobalVariables.win(self)


func handle_special_is_full():
	if special_amount >= MAX_SPECIAL_AMOUNT:
		if special_is_full_effect == null:
			special_is_full_effect = Instantiables.SPECIAL_IS_FULL_EFFECT.instantiate()
			special_is_full_effect.position = Vector3(0, 0.02, 0)
			add_child(special_is_full_effect)
		else:
			special_is_full_effect.show()
	else:
		if special_is_full_effect != null:
			special_is_full_effect.hide()


func handle_special_draining():
	if special_amount > 0:
		special_drain_counter += special_drain_step
		if special_drain_counter >= special_drain_threshold:
			special_drain_counter = 0
			special_amount -= special_drain_amount
			hud.change_special(special_amount)
	else:
		super_mode = false


## gain one extra life
func one_up():
	GlobalVariables.extra_lives += 1
	hud.update_extra_lives(GlobalVariables.extra_lives)


func collect_ring():
	# increase the amount of rings
	# rings collected in a stage should count towards
	# the rings total only after the battle is over
	Audio.play(Audio.ring, self)
	if GlobalVariables.current_stage != null:
		rings += 1
		GlobalVariables.total_rings += 1
		heal(HEAL_POINTS_PER_RING)
	else:
		GlobalVariables.total_rings += 1
		hud.update_rings(GlobalVariables.total_rings)
	
	# increase a permanent counter of how many rings were collected
	# to count towards extra lives gained
	# this prevents extra lives gained if the character didn't
	# lost all rings and is collecting scattered ones
	# ( 100 rings, scattered 1 ring, collect it = extra live )
	GlobalVariables.ring_count_towards_extra_life += 1
	if GlobalVariables.ring_count_towards_extra_life >= 100:
		one_up()
		GlobalVariables.ring_count_towards_extra_life = 0


## scatter rings in a circular pattern
func scatter_rings(amount = 1):	
	# inside a stage scatter one ring per hit
	# and more rings if the hit was strong
	# if on a hub or area scatter all rings
	if GlobalVariables.current_stage == null:
		amount = rings
		
	var number_of_rings_to_scatter = amount
	
	# clamp the value
	number_of_rings_to_scatter = clamp(number_of_rings_to_scatter, 0, MAX_SCATTERED_RINGS_ALLOWED)
	
	if rings > 0:
		rings -= amount
		if rings < 0:
			rings = 0
	
	# update hud
	hud.update_rings(rings)
	
	# relative ring position
	var proxy_position = position + transform.basis.z
	var angle = 360.0
	if number_of_rings_to_scatter > 0:
		angle = 360.0 / number_of_rings_to_scatter
	# circular pattern
	for i in number_of_rings_to_scatter:
		proxy_position = proxy_position.rotated(Vector3.UP, deg_to_rad(angle * i))
		var new_ring_position = position + proxy_position.normalized()
		Instantiables.create_scattered_ring(new_ring_position, position)


## This function mostly handles what animations play with what booleans.
func handle_animation():
	# None of these animations play when Sonic is in his hurt or attacking state.
	if !attacking && !hurt && !healing && !chasing_aggressor && !can_spike && !hitting_wall && !guarding && !going_super:
		if is_on_floor():
			# Animations that play when Sonic is on the ground. If he's not starting movement, at least.
			if !starting && !dashing:
				if round(velocity.x) != 0 || round(velocity.z) != 0:
					# player is pressing a direction
					#if direction:
					if !super_mode:
						sprite_animation_player.play("walk")
						model_animation_player.play("WALK")
					else:
						sprite_animation_player.play("walk")
						model_animation_player.play("RUN")
					stopped = false
					# player is not pressing a direction and the character still have some velocity
					# sonic is stopping
					#else:
					#	print(model_animation_player.current_animation)
					#	if model_animation_player.current_animation == "" or \
					#	model_animation_player.current_animation != "WALK":
					#		model_animation_player.play("STOP")
				else:
					if stopped:
						sprite_animation_player.play("idle")
						model_animation_player.play("IDLE")
					else:
						sprite_animation_player.play("idle")
						model_animation_player.play("STOP")
		else:
			stopped = true
			# Midair animations. These don't play when Sonic is dashing.
			if !dashing:
				if velocity.y > 0:
					sprite_animation_player.play("jump")
					model_animation_player.play("JUMP")
					falling = false
				elif velocity.y <= 0 && !falling:
					# Because falling should only play once, this is tied to the falling state.
					sprite_animation_player.play("fall")
					model_animation_player.play("FALL")
					falling = true
	else:
		stopped = true
		if !is_on_floor() && "PGC" in model_animation_player.current_animation:
			if model_animation_player.current_animation != "PGC 5":
				attacking = false
				current_punch = 0
				if velocity.y > 0:
					sprite_animation_player.play("jump")
					model_animation_player.play("JUMP")
					falling = false
				elif velocity.y <= 0 && !falling:
					# Because falling should only play once, this is tied to the falling state.
					sprite_animation_player.play("fall")
					model_animation_player.play("FALL")
					falling = true
		elif is_on_floor() && model_animation_player.current_animation == "PAC":
				attacking = false
				sprite_animation_player.play("idle")
				model_animation_player.play("IDLE")
		elif healing:
			sprite_animation_player.play("idle")
			model_animation_player.play("HEAL")
		elif chasing_aggressor || can_spike:
			sprite_animation_player.play("idle")
			model_animation_player.play("TARGET")


## method to set the abilities and immunity of the character
## "SHOT", "POW" and SET" 
func set_abilities(new_abilities: Array):
	if new_abilities.size() == 3:
		ground_skill = new_abilities[0]
		air_skill = new_abilities[1]
		immunity = new_abilities[2]


func handle_see_through():
	if see_through_after_image == null:
			see_through_after_image = Instantiables.AFTER_IMAGE_SEE_THROUGH.instantiate()
			see_through_after_image.position = Vector3.ZERO
			add_child(see_through_after_image)
	else:
		if GlobalVariables.camera and GlobalVariables.camera.player_is_behind_object:
			see_through_after_image.show()
			see_through_after_image.rotation = model_node.rotation
			see_through_after_image.current_animation_name = model_animation_player.current_animation
			see_through_after_image.current_animation_time = model_animation_player.current_animation_position
			see_through_after_image.character_is_in_super_mode = super_mode
			see_through_after_image.update_pose()
		else:
			see_through_after_image.hide()
	


func handle_after_image():
	if model_animation_player.current_animation == "DASH" \
	or "DJMP" in model_animation_player.current_animation \
	or chasing_ring or bouncing  or chasing_aggressor:
		create_after_image()


func create_after_image():
	if after_image_time <= 0:
		after_image_time = 0.05
		var new_after_image = Instantiables.AFTER_IMAGE.instantiate()
		new_after_image.position = position
		new_after_image.get_child(0).transform.basis.z = model_node.transform.basis.z
		new_after_image.current_animation_name = model_animation_player.current_animation
		new_after_image.current_animation_time = model_animation_player.current_animation_position

		get_parent().add_child(new_after_image)


func anim_end(anim_name):
	if anim_name == "WALK START":
		# End the "starting" state when the starting animation ends.
		starting = false
		walking = true
	elif anim_name == "STOP":
		starting = false
		stopped = true
	elif anim_name == "DJMP 1":
		if !rolling:
			model_animation_player.play("DJMP 3")
			can_air_attack = false
			can_airdash = false
			coyote_timer = null
		else:
			rolling = false
			hurt = false
			starting = false
			can_air_attack = false
	elif anim_name == "DJMP 3":
		# Go back to falling state when airdash ends.
		dashing = false
		sprite_animation_player.play("fall")
		model_animation_player.play("FALL")
		falling = true
	elif anim_name == "PGC 4":
		# Sonic's normal strong attack has an extra effect where he has to recoil backwards,
		# so this code plays that recoil and adjusts his velocity accordingly.
		sprite_animation_player.play("strongRecoil")
		model_animation_player.play("PGC 5")
		velocity = -model_node.basis.z.normalized() * 3
		velocity.y = 3
		can_air_attack = false
		can_airdash = false
	elif anim_name == "PGC 5" || anim_name == "UPPER" || anim_name == "BLOCKED":
		# Resets Sonic's attacking state when the up strong, blocked, or regular strong recoil ends.
		attacking = false
		starting = false
		can_air_attack = false
		can_airdash = false
		can_chase = false
		guarding = false
	elif anim_name == "DASH ATK":
		# Resets Sonic's attacking state when his dash attack ends.
		attacking = false
		dashing = false
	elif anim_name == "AIM":
		attacking = false
		can_air_attack = false
	elif anim_name == "GUARD":
		guarding = false
		attacking = true
		model_animation_player.play("BLOCKED")
		guard_effect.emitting = false
	elif anim_name == "SUPER":
		super_mode = true
		going_super = false
		if !is_on_floor():
			falling = true
			sprite_animation_player.play("fall")
			model_animation_player.play("FALL")
	elif anim_name == "AIR" || anim_name == "PAC":
		# Resets Sonic's attacking state when his air attack ends. Also sets him to falling state.
		attacking = false
		jumping = false
		falling = true
		sprite_animation_player.play("fall")
		model_animation_player.play("FALL")
	elif anim_name == "PGC 1" || anim_name == "PGC 2" || anim_name == "PGC 3":
		# The 3-hit combo. Press the punch button again before punch_timer runs out to do the next attack
		if Input.is_action_just_pressed("punch") and punch_timer != null and punch_timer.time_left > 0:
			# create a new timer to give time for a possible combo sequence
			create_punch_timer()
			if current_punch == 1:
				sprite_animation_player.play("punch2")
				model_animation_player.play("PGC 2")
				launch_power = Vector3(0, 0, 0)
				damage_caused = 7
				current_punch = 2
			elif current_punch == 2:
				sprite_animation_player.play("punch3")
				model_animation_player.play("PGC 3")
				launch_power = Vector3(0, 0, 0)
				damage_caused = 7
				current_punch = 3
			elif current_punch == 3:
				# The final part of the combo does an immediate strong attack.
				sprite_animation_player.play("strong")
				model_animation_player.play("PGC 4")
				
				var new_launch = model_node.transform.basis.z.normalized() * 20
				new_launch.y = 5
				launch_power = new_launch
				damage_caused = 7
				current_punch = 0
		else:
			attacking = false

	elif anim_name == "HURT 1" || anim_name == "HURT 2":
		# Reset's Sonic's "hurt" state when the animation ends.
		hurt = false
		starting = false
		can_air_attack = false
	elif anim_name == "KO":
		if life_total > 0:
			if !direction:
				model_animation_player.play("GET UP FULL")
			else:
				velocity = Vector3(direction.x, 0, direction.z) * 10
				model_animation_player.play("DJMP 1")
				Audio.play(Audio.bounce, self)
				rolling = true
		else:
			defeated()
	elif anim_name == "GET UP FULL":
		hurt = false
		starting = false
		can_air_attack = false
	elif anim_name == "WALL":
		hitting_wall = false
		velocity.y = 7
		chasing_aggressor = true
		model_animation_player.play("TARGET")
	elif anim_name == "HIT WALL":
		velocity = -model_node.basis.z.normalized() * 5
		hitting_wall = false
		model_animation_player.play("SPIKED")
	elif anim_name == "LAUNCHED":
		# For as long as Sonic is in the air, the animation loops. When he hits the ground, his state resets.
		if is_on_floor():
			model_animation_player.play("KO")
		else:
			sprite_animation_player.play("hurtStrong")
			model_animation_player.play("LAUNCHED")
	elif anim_name == "SPIKED":
		if !is_on_floor():
			model_animation_player.play("SPIKED")
		else:
			model_animation_player.play("KO")
			spiked = false
	elif anim_name in ["RING", "BOMB G (LAZY)", "BOMB A"]:
		# Handles Sonic's reset states for all of his special moves.
		attacking = false
		starting = false
		bouncing = false
		pow_move = false
		if !is_on_floor():
			# Sets Sonic's falling state if he's in the air.
			jumping = false
			falling = true
			sprite_animation_player.play("fall")
			model_animation_player.play("FALL")
	elif anim_name == "DJMP 2":
		if !is_on_floor() && chasing_ring:
			model_animation_player.play("DJMP 2")
		else:
			attacking = false
			starting = false
			bouncing = false
			pow_move = false
			if !is_on_floor():
				# Sets Sonic's falling state if he's in the air.
				jumping = false
				falling = true
				sprite_animation_player.play("fall")
				model_animation_player.play("FALL")
	
	if punch_timer == null or punch_timer.time_left <= 0:
		# If the player doesn't continue the combo, Sonic's states reset as usual.
		current_punch = 0

## Very simple signal state determining when the attack hitbox actually hits something.
func _on_hitbox_body_entered(body):
	if !is_multiplayer_authority(): return
	if body.is_in_group("CanHurt") && body != self and attacking:
		if !body.guarding:
			Audio.play(Audio.hit, self)
			# If the current attack is Sonic's "pow" move, the hitbox pays attention to immunities.
			if !pow_move || body.immunity != "pow":
				body.get_hurt.rpc_id(body.get_multiplayer_authority(), launch_power, self, floor(damage_caused * damage_multiplier))
		else:
			model_animation_player.play("BLOCKED")
			velocity = -model_node.basis.z.normalized() * 5


func defeated(): #who_owns_last_attack = null):
	if was_defeated == false:
		# trigger once per instance
		was_defeated = true
		
		var ko_effect = Instantiables.KO_EFFECT.instantiate()
		ko_effect.position = position
		get_parent().add_child(ko_effect)
		ko_effect.get_child(0).emitting = true
		
		if last_aggressor != null:
			if last_aggressor.has_method("increase_points"):
				last_aggressor.increase_points()
		
		# player must get the ability selection screen again
		# then select a location to spawn
		if GlobalVariables.current_stage != null:
			GlobalVariables.respawnLife = -99 #-99 cus I cant set it to null for some reason
			GlobalVariables.respawnSpecial = special_amount
			Instantiables.respawn()
		elif GlobalVariables.current_hub != null:
			Instantiables.go_to_hub(GlobalVariables.hub_selected)
		else:
			Instantiables.go_to_area(GlobalVariables.area_selected)


## to give a bit more impact on strong attacks, freeze the screen a bit
#func freeze_frame(new_timescale, freeze_duration):
#	Engine.time_scale = new_timescale
#	await get_tree().create_timer(freeze_duration * new_timescale).timeout
#	Engine.time_scale = 1.0


## A function that handles Sonic getting hurt. Knockback is determined by the thing that initiates this
# function, which is why you don't see it here.
@rpc("any_peer","reliable","call_local")
func get_hurt(launch_speed, owner_of_the_attack, damage_taken = 1):
	# just in case an attack hits through guard for whatever reason
	guarding = false
	if model_animation_player.current_animation != "KO" and model_animation_player.current_animation != "SPIKED" and !hitting_wall and model_animation_player.current_animation != "SUPER":
		# store the last player who damaged this character
		last_aggressor = owner_of_the_attack
		
		var sparks = Instantiables.SPARKS.instantiate()
		sparks.position = position + Vector3(0, 0.1, 0)
		get_parent().add_child(sparks)
		sparks.get_child(0).emitting = true
		
		# give a invunerability time
		
		if !hurt:
			# rings shouldn't provid all life points back
			if damage_taken > MAX_SCATTERED_RINGS_ALLOWED * HEAL_POINTS_PER_RING:
				#scatter_rings(MAX_SCATTERED_RINGS_ALLOWED)
				Audio.play(Audio.ring_spread, self)
				
				# freeze frame
				Instantiables.create_freeze_frame(0.1, 0.3)
				#freeze_frame(0.1, 0.3) #(0.05, 1.0)
				
				# shake camera
				GlobalVariables.camera.shake(0.5, 1.0)
				
			else:
				#scatter_rings()
				# shake camera
				GlobalVariables.camera.shake()
			
			# mutantsonic formula
			var rings_to_scatter = int((damage_taken / 2.0) -1)
			
			if rings_to_scatter > MAX_SCATTERED_RINGS_ALLOWED:
				rings_to_scatter = MAX_SCATTERED_RINGS_ALLOWED
			if rings_to_scatter < 1:
				rings_to_scatter = 1
			
			scatter_rings(rings_to_scatter)
				
		
		life_total -= damage_taken
		if life_total < 0:
			life_total = 0
		hud.change_life(life_total)
		#push_warning("life: ", life_total, ", damage_taken: ", damage_taken, ", launch: ", launch_speed )
		
		# A bunch of states reset to make sure getting hurt cancels them out.
		hurt = true
		falling = false
		jumping = false
		bouncing = false
		healing = false
		can_chase = false
		
		velocity = launch_speed
		# If Sonic was chasing a ring, the ring is deleted.
		if chasing_ring:
			chasing_ring = false
			thrown_ring = false
			if active_ring != null:
				active_ring.queue_free()
		
		# Depending on where Sonic is and what his velocity is, the animation is different.
		if abs(velocity.x) > 8 || abs(velocity.z) > 8:
			sprite_animation_player.play("hurtStrong")
			model_animation_player.play("LAUNCHED")
			launch_recovery()
		else:
			if launch_speed.y > 5:
				sprite_animation_player.play("hurtAir")
				model_animation_player.play("HURT 2")
			elif launch_speed.y < 0 && !is_on_floor():
				sprite_animation_player.play("hurtAir")
				model_animation_player.play("SPIKED")
				spiked = true
			else:
				sprite_animation_player.play("hurt")
				model_animation_player.play("HURT 1")
		
		# More state resets. Idk why these are placed at the end.
		current_punch = 0
		dashing = false
		attacking = false
		
		if GlobalVariables.current_stage != null:
			if (life_total <= 0 and GlobalVariables.game_ended == false):
				if !is_on_floor():
					model_animation_player.play("SPIKED")
				else:
					model_animation_player.play("KO")


## The function for determining what happens with each selected grounded special move.
@rpc("any_peer", "reliable", "call_local")
func ground_special(id, _dir):
	if ground_skill == "SHOT":
		# Sonic's ground "shot" move sends a shockwave in the direction specified by the player.
		# Sonic is also launched back away from the direction of the projectile.
		can_air_attack = false
		can_airdash = false
		sprite_animation_player.play("shotGround")
		model_animation_player.play("DJMP 2")
		Audio.play(Audio.shot, self)
		#Instantiates a new shot projectile.
		var new_shot = Instantiables.create(Instantiables.objects.SHOT_PROJECTILE)
		new_shot.user = self	# This makes sure Sonic can't hit himself with a projectile.
		new_shot.set_meta("author", name)
		new_shot.name = "wave" + str(id)
		var new_forward = model_node.transform.basis.z.normalized()
		new_forward.y = 0
		new_shot.transform.basis.z = new_forward
		new_shot.velocity = Vector3(model_node.basis.z.normalized().x * 3, 0, model_node.basis.z.normalized().z * 3)
		velocity = -model_node.basis.z.normalized() * 5
		velocity.y = 5
		
		new_shot.position = position
		# Creates the projectile.
		new_shot.set_multiplayer_authority(get_multiplayer_authority())
		get_tree().current_scene.add_child(new_shot, true)
	elif ground_skill == "POW":
		# Sonic's ground "pow" move first throws a ring. If the player inputs the move again,
		# Sonic will accelerate in the direction of the ring.
		# The ring is sent in a specified direciton.
		if !thrown_ring:	# When no ring is on the field.
			sprite_animation_player.play("powGround")
			model_animation_player.play("RING")
			Audio.play(Audio.ring, self)
			#Instantiates a new ring projectile
			var new_ring = Instantiables.create(Instantiables.objects.TOSS_RING)
			new_ring.ring_owner = self
			active_ring = new_ring
			new_ring.name = "ring" + str(id)
			thrown_ring = true
			new_ring.position = position
			new_ring.velocity = Vector3(model_node.basis.z.normalized().x * 3, 5, model_node.basis.z.normalized().z * 3)
			# Creates the ring projectile.
			get_tree().current_scene.add_child(new_ring, true)
		else:	# When a ring is on the field.
			can_recover = true
			launch_power = Vector3(0, 6, 0)
			damage_caused = 10
			velocity = (active_ring.transform.origin - transform.origin).normalized() * 7
			velocity = Vector3(clamp(velocity.x, -7, 7), clamp(velocity.y, 4, 6), clamp(velocity.z, -7, 7))
			pow_move = true
			sprite_animation_player.play("powAir")
			model_animation_player.play("DJMP 2")
			Audio.play(Audio.bounce, self)
			thrown_ring = false
			chasing_ring = true
			if active_ring != null:
				active_ring.queue_free()
	elif ground_skill == "SET":
		# Sonic's grounded "set" move sets down a mine where he's standing, which explodes over time
		# or on contact.
		sprite_animation_player.play("setGround")
		model_animation_player.play("BOMB G (LAZY)")
		if active_mine == null: # Only works if there's no mine already active.
			# Instantiates a new mine object.
			var new_mine = Instantiables.create(Instantiables.objects.SET_MINE) #set_mine.instantiate()
			new_mine.position = position
			new_mine.name = "mine" + str(id)
			new_mine.set_multiplayer_authority(get_multiplayer_authority())
			new_mine.user = self	# This makes sure Sonic can't hit himself with his own mine.
			active_mine = new_mine
			# Creates the mine
			get_tree().current_scene.add_child(new_mine, true)
		else:
			active_mine.blast()


## The function for determining what happens with each selected air special move.
@rpc("authority","call_local")
func air_special(id, _dir):
	if air_skill == "SHOT":
		# This works almost exactly the same as the grounded version,
		# Sonic sends a wave projectile that falls to the ground, which moves based on a specified
		# direction. He is also sent backwards away from the projectile.
		sprite_animation_player.play("shotAir")
		model_animation_player.play("DJMP 2")
		Audio.play(Audio.shot, self)
		can_air_attack = false
		can_airdash = false
		can_air_attack = false
		can_airdash = false
		#Instantiates a new shot projectile.
		var new_shot = Instantiables.create(Instantiables.objects.SHOT_PROJECTILE) #shot_projectile.instantiate()
		new_shot.user = self	# This makes sure Sonic can't hit himself with a projectile.
		new_shot.name = "wave" + str(id)
		new_shot.set_multiplayer_authority(get_multiplayer_authority())
		new_shot.position = position

		var new_forward = model_node.transform.basis.z.normalized()
		new_forward.y = 0
		new_shot.transform.basis.z = new_forward
				
		new_shot.velocity = Vector3(model_node.basis.z.normalized().x * 3, 0, model_node.basis.z.normalized().z * 3)
		velocity = -model_node.basis.z.normalized() * 5
		velocity.y = 2
		
		# Creates the projectile
		get_tree().current_scene.add_child(new_shot, true)
	elif air_skill == "POW":
		can_recover = true
		# Sonic's midair "pow" move causes him to curl into a ball and launch himself towards the ground
		# If Sonic hits the ground, he bounces once.
		sprite_animation_player.play("powAir")
		model_animation_player.play("DJMP 2")
		Audio.play(Audio.bounce, self)
		pow_move = true
		bouncing = true	# Initiates the "bouncing" state for bouncing off the ground.
		launch_power = Vector3(0, 6, 0)
		velocity.y = -5
		damage_caused = 7
	elif air_skill == "SET":
		# Works exactly like the grounded variant, Sonic places a mine that falls to the ground.
		# The mine explodes over time or on impact.
		# In the air, Sonic also gets a slight bit of air stall.
		sprite_animation_player.play("setAir")
		model_animation_player.play("BOMB A")
		can_air_attack = false
		can_airdash = false
		if active_mine == null:	# Only works if there's no mine already active.
			velocity.y = 3
			# Instantiates a new mine object.
			var new_mine = Instantiables.create(Instantiables.objects.SET_MINE) #set_mine.instantiate()
			new_mine.name = "mine" + str(id)
			new_mine.position = position
			new_mine.user = self	# This makes sure Sonic can't hit himself with his own mine.
			active_mine = new_mine
			# Creates the mine object.
			get_tree().current_scene.add_child(new_mine, true)


## use Area3D to detect collectables like rings and hazards
func _on_ring_collider_area_entered(area):
	# store the parent of the Area3D the character collided
	if area.get_parent() != null && life_total > 0:
		var collided_object = area.get_parent()
		
		# collect ring
		if collided_object.is_in_group("Ring"):
			collect_ring()
			if collided_object.has_method("delete_ring"):
				collided_object.delete_ring()


func rotate_model():
	if direction && !attacking && !healing:
		model_node.rotation.y = Vector2(velocity.z, velocity.x).angle()
