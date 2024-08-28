extends Label3D

# the character that have this node as input
var cpu_character
# the current target the bot is following
var target
# the player which is the main target to follow
var player_target

# store the bot states
# for future use
enum states {idle, pursue, attack, hit}
var current_state: states = states.idle

# the direction towards target
var target_direction: Vector3
# the distance to the target
var distance_to_target: float
# the minimum distance to stop chasing the player and start attacking
const min_attack_distance: float = 0.5

var distance_to_keep_from_target = min_attack_distance

# safe distance for the bot to stay away from the character
const safe_distance: float = 1.0

var life_offset = 35

var total_healed: int = 0

var last_life_total: int = 0

var players_around: Array
# store if there are rings around the stage
var rings_around: Array
# store possible targets like a player or a ring
var possible_targets: Array

# timer between jumps
var jump_timer: SceneTreeTimer

# set a delay on the bots response as difficulty level
var delay: float = 0.0

## The container of the raycasts
## it will point towards the direction the bot is going
@export var raycasts_container: Marker3D
## the raycast used to detect if there is a wall in front of the bot to jump
## raycasts forward
@export var wall_detector: RayCast3D
## the raycast used to detect if there is a platform for the bot to land after jumping
## raycasts downwards
@export var platform_detector: RayCast3D


func _physics_process(delta):
	# if this node has a parent
	if cpu_character:
		update_life_ui()
		select_target()
		
		if delay > 0:
			# count down the delay
			delay -= delta
		
		# if there is a target and a player target
		if target:
			if target.is_in_group("Player"):
				# if player have more life
				if is_instance_valid(target) and \
				(target.life_total + life_offset) > cpu_character.life_total:
					# go with defensive behaviour
					aggressive_behaviour()
					#cautious_behaviour()
				
				# else if bot have more life
				elif is_instance_valid(target) and \
				(cpu_character.life_total + life_offset) > target.life_total:
					# go with aggressive behaviour
					aggressive_behaviour()
					#cautious_behaviour()
				
				# else the bot and player have less than the life_offset between their life totals
				else:
					# go with tactics
					aggressive_behaviour()
					#cautious_behaviour()
			else:
				# go towards rings
				aggressive_behaviour()
		else:
			# no targets
			reset_properties()
			
	else:
		# set the cpu_character as the bot that have this controller
		if cpu_character == null and get_parent() != null:
			cpu_character = get_parent()


func select_target():
	if target == null:
		target = GlobalVariables.current_character
		player_target = GlobalVariables.current_character
	rings_around = get_tree().get_nodes_in_group("Ring").duplicate()
	#players_around = get_tree().get_nodes_in_group("Player").duplicate()
	players_around.append(GlobalVariables.current_character)
	
	# on challenge mode the bots will search for players
	# on battle mode bots can fight bots
	if GlobalVariables.play_mode == GlobalVariables.modes.battle:
		players_around = get_tree().get_nodes_in_group("Bot").duplicate()
		
	#if GlobalVariables.play_mode == GlobalVariables.modes.challenge:
		#for j in players_around:
		#	if j.is_in_group("Bot"):
		#		players_around.erase(j)
	
	# store variables for possible targets
	possible_targets.clear()
	possible_targets = rings_around.duplicate()
	possible_targets += players_around.duplicate()
	
	# if a ring is closer than the player, set the ring as target
	if possible_targets.size() > 0 and cpu_character != null:
		var new_target_distance
		for new_target in possible_targets:
			if is_instance_valid(new_target):
				new_target_distance = (new_target.position - cpu_character.position).length()
				# if the new target is closer and is not this bot
				if new_target_distance < distance_to_target and new_target != get_parent():
					target = new_target


func update_life_ui():
	# make the lifetotal label face the camera
	if get_viewport().get_camera_3d() != null:
		look_at(-get_viewport().get_camera_3d().position)
	# update lifetotal label text
	text = str(cpu_character.life_total) + "%\n" + cpu_character.name + " - " + str(cpu_character.points) + "Pt"


## common responses to the ambient
## like dodging attacks
func common_behaviours():
	# prevent loops by reseting the properties
	reset_properties()
	
	# store the distance and direction
	target_direction = (target.position - cpu_character.position).normalized()
	distance_to_target = (target.position - cpu_character.position).length()
	
	# set a closer distance to collect the rings
	if target.is_in_group("Player"):
		distance_to_keep_from_target = min_attack_distance
	else:
		distance_to_keep_from_target = 0.2
		
		# if the target is a ring and this ring is too close to trigger, collect
		if distance_to_target < 0.2 and target.is_in_group("Ring") and target.has_method("can_collect") and target.can_collect():
			cpu_character.collect_ring(target)
	
	# store planar variables
	# position with y axis at zero
	var planar_position = target.position
	planar_position.y = 0
	var planar_distance = (planar_position - cpu_character.position).length()
	
	# heal if the player is far and life is not full
	# or if healed 35 points
	if planar_distance > (distance_to_keep_from_target + 1.0) \
	and cpu_character.life_total < cpu_character.MAX_LIFE_TOTAL \
	and total_healed < life_offset:
		# if the player is trying to keep distance, keep guard on
		# to heal
		cpu_character.heal_pressed = true
		
		# keep track of how much was healed
		if cpu_character.life_total > last_life_total:
			last_life_total = cpu_character.life_total
			total_healed += cpu_character.DEFAULT_HEAL_AMOUNT
	else:
		# only go back to healing if hurt
		if cpu_character.hurt:
			total_healed = 0
			last_life_total = cpu_character.life_total
		cpu_character.heal_pressed = false


## if the target is far, move
## if the target is close, attack
## if the target is hidding right above, heal
func aggressive_behaviour():
	common_behaviours()
	
	# go closer to target
	if distance_to_target > distance_to_keep_from_target:
		# move towards target when not trying to go up around a platform
		move_towards_target()
	
	# if close enough to attack, attack target
	else:
		if target.is_in_group("Player"):
			attack_target()
	
	# if can chase or against the wall after a launch, use the chase mechanic
	if cpu_character.can_chase or cpu_character.model_node.get_node("AnimationPlayer").current_animation == "WALL":
		cpu_character.jump_pressed = true
	
	if cpu_character.special_amount == 100 and GlobalVariables.current_difficulty != GlobalVariables.difficulty_levels[0]:
		cpu_character.super_pressed = true


## keep distance from player
## circulate the player
## attack the player from behind
func cautious_behaviour():
	common_behaviours()
	
	# check is target is a character
	if target.is_in_group("Player"):
	# keep distance so the character can't hit
		if distance_to_target < safe_distance:
			# move away
			move_towards_target(-1)
		else:
			# move near by
			#move_towards_target()
		
			# check the target's input direction with direction to target
			# and circulate until the bot is behind the character
			if target_direction.dot(target.direction) > 0.6:
				# circulate the character
				var proxy_position = cpu_character.position + target_direction.normalized()
				var angle = 120.0
			# check if it's faster to get there by moving clockwise or counterclockwise
				#var points_on_circle = 100
				#angle = 360.0 / points_on_circle
				proxy_position = proxy_position.rotated(Vector3.UP, deg_to_rad(angle))
				cpu_character.direction = cpu_character.position + proxy_position.normalized()
			else:
				# attack from behind
				move_towards_target()
				if distance_to_target < distance_to_keep_from_target:
					attack_target()
	

## move towards target
## or away from it if value is negative
func move_towards_target(mode_value = 1):
	# Set the input direction
	# use the navmesh of the stage and navigate with the nav agent
	if cpu_character != null and target != null:
		# check planar velocity to see if bot got stuck
		var planar_velocity = cpu_character.velocity
		planar_velocity.y = 0.0
		
		# if not stuck:
		if planar_velocity.length() > 2 and distance_to_target > 1:
			# use navmesh
			cpu_character.nav.target_position = target.position
			cpu_character.direction = (cpu_character.nav.get_next_path_position() - cpu_character.global_position).normalized()
		else:
			# walk
			cpu_character.direction = mode_value * (cpu_character.transform.basis * Vector3(target_direction.x, 0, target_direction.z)).normalized()
	
	# if there is an obstacle, jump
	jump_check()
	


## check for hazards
func hazard_ahead():
	# check with platform_detector raycast
	var new_hazard_ahead = false
	var object_collided = platform_detector.get_collider()
	if object_collided:
		# StaticBody3D is in the Hazard group
		new_hazard_ahead = object_collided.is_in_group("Hazard") || object_collided.is_in_group("PlayerAttack")
	
	# check with wall_detector raycast
	var new_hazard_ahead2 = false
	var object_collided2 = wall_detector.get_collider()
	if object_collided2:
		# StaticBody3D is in the Hazard group
		new_hazard_ahead2 = object_collided2.is_in_group("Hazard") || object_collided2.is_in_group("PlayerAttack")
	
	# return if either are true
	return (new_hazard_ahead || new_hazard_ahead2)


func jump_check():
	var direction = cpu_character.direction
	direction.y = 0
	# change the direction of the raycast container's forward to match the
	# direction the bot is going
	raycasts_container.transform.basis.z = direction
	
	# check for obstacle, hazard and mind the gap
	if wall_detector.is_colliding() or \
	hazard_ahead() or \
	platform_detector.is_colliding() == false or \
	platform_detector.get_collision_point().y + 0.5 < cpu_character.position.y:
		# wait to press double jump
		if (jump_timer == null or (jump_timer != null and jump_timer.time_left <= 0)):
			jump()


func jump():
	cpu_character.jump_pressed = true
	# double jump timer
	jump_timer = get_tree().create_timer(0.35, false, true)


# don't attack player if it's on the ground or getting up
func can_attack_player() -> bool:
	var can_attack
	
	if target.is_in_group("Player") and target.life_total > 0 and \
	not target.model_node.get_node("AnimationPlayer").current_animation == "KO" \
	and not target.model_node.get_node("AnimationPlayer").current_animation == "GET UP FULL":
		can_attack = true
	else:
		can_attack = false
	
	return can_attack


func attack_target():
	if delay <= 0.0 and can_attack_player():
		# set delay based on difficulty level
		delay = GlobalVariables.current_difficulty
		
		# use special move if the bot finished the combo and player is hurt or 
		# if player is close and there is a hazard between the player and the bot
		#if (target.is_in_group("Player") and (target.hurt or target.launched or target.spiked) and cpu_character.model_node.get_node("AnimationPlayer").current_animation == "PGC 4") or (hazard_ahead() and distance_to_target < 2):
		if cpu_character.ground_skill == "SHOT" and (target.is_in_group("Player") and distance_to_target > min_attack_distance) or (hazard_ahead() and distance_to_target < 2):
			# special attack check
			cpu_character.special_pressed = true
		else:
			if cpu_character.ground_skill != "SHOT":
				# select an attack at random
				var random_move = randi_range(0, 100)
				
				# 10 % chance of special SET or POW move
				if random_move <= 10:
					cpu_character.special_pressed = true
				
				# 10 % change of updraft
				elif random_move > 10 and random_move <= 20:
					#cpu_character.model_node.get_node("AnimationPlayer").play("UPPER")
					cpu_character.upper_pressed = true
				
				# 80 % change of punch combo
				elif random_move > 20:
					cpu_character.attack_pressed = true
			else:
				# attack check
				cpu_character.attack_pressed = true


func reset_properties():
	cpu_character.direction = Vector3.ZERO
	cpu_character.special_pressed = false
	cpu_character.attack_pressed = false
	cpu_character.dash_triggered = false
	cpu_character.jump_pressed = false
	cpu_character.upper_pressed = false
	cpu_character.super_pressed = false
	# can't heal if it keeps reseting
	#cpu_character.guard_pressed = false
	
