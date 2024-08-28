extends Node3D

# life total of the enemy
var life_total: int = 3

# the last character that caused damage to this enemy
# to call that character's method to gain points
var last_character_this_took_damage_from: CharacterBody3D

# in case the enemy have immunity
var immunity

# main sprite of the enemy
@export var main_sprite: Sprite3D

# the sprite shown when the enemy takes damage
@export var damaged_sprite: Sprite3D

# the animation player that plays that animate the sprites nodes
@export var anim: AnimationPlayer

## make this enemy suffer damage
#@rpc("any_peer","reliable","call_local")
func get_hurt(_direction, amount = 1):
	# direction is not used in this placeholder enemy
	# instead spin it and change the sprite to help feedback when this takes damage
	damaged_sprite.show()
	main_sprite.hide()
	anim.play("spin", -1, 2)
	
	# subtract amount of damage from this enemy life points
	life_total -= amount
	# if this enemy got defeated, count toward the character points
	if life_total <= 0:
		last_character_this_took_damage_from.increase_points()
		queue_free()


func _on_area_3d_area_entered(area):
	# check if it was damaged by a collider within the player group
	if area.get_parent() != null and (area.get_parent().is_in_group("Player") or area.get_parent().is_in_group("PlayerAttack")):
		# store which character hurt this enemy
		if area.get_parent().is_in_group("Player"):
			last_character_this_took_damage_from = area.get_parent()
			# cause normal damage to this enemy
			get_hurt(Vector3.ZERO)
		else:
			if area.get_parent() != null and area.get_parent().user != null:
				last_character_this_took_damage_from = area.get_parent().user
				# cause more damage to this enemy if the source is within the PlayerAttack group, shockwave for example
				get_hurt(Vector3.ZERO, 3)
		


func _on_animation_player_animation_finished(anim_name):
	# reset to idle animation after damaged animation played
	if anim_name == "spin":
		main_sprite.show()
		damaged_sprite.hide()
		anim.play("idle")
