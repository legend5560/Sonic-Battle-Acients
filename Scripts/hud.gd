extends Control

# each part of the hud
@export_category("Battle HUD")
@export var battle_hud_node: Control
@export var life_ui: RichTextLabel
@export var special_ui: RichTextLabel
@export var points_ui: RichTextLabel
@export var avatar_ui: TextureRect

@export_category("Area HUD")
@export var area_hud_node: Control
@export var rings_ui: RichTextLabel
@export var extra_lives_ui: RichTextLabel

const MAX_LIFE_TOTAL = 100


func _ready():
	enable_hud()


func _process(_delta):
	# if game is paused, resume
	if get_tree().is_paused():
		battle_hud_node.hide()
		area_hud_node.hide()
	else:
	# if game is not paused, pause
		enable_hud()


func enable_hud():
	if GlobalVariables.current_stage != null:
		battle_hud_node.show()
		area_hud_node.hide()
	else:
		battle_hud_node.hide()
		area_hud_node.show()


# update the all hud fields
func update_hud(life_amount, special_amount, points_amount):
	change_life(life_amount)
	change_special(special_amount)
	change_points(points_amount)
	update_rings(GlobalVariables.total_rings)
	update_extra_lives(GlobalVariables.extra_lives)


## change the amount shown in the life points on hud in-game
func change_life(new_life_total):
	var new_life_bar = fill_bar_with(new_life_total)
	var percent = str(new_life_total) + "%" #str(int((new_life_total / MAX_LIFE_TOTAL) * 100)) + "%"
	life_ui.text = percent + " " + new_life_bar


## change the amount shown in the special bar on hud in-game
func change_special(new_special_amount):
	var new_special_bar = fill_bar_with(new_special_amount)
	var percent = str(new_special_amount) + "%" #str(int((new_special_amount / 100) * 100)) + "%"
	special_ui.text = percent + " " + new_special_bar


## change the amount of points gained shown on hud in-game
func change_points(points_amount):
	points_ui.text = str(points_amount) + "Pt"


## change the avatar image next to the points shown on hud in-game
func change_avatar(new_avatar):
	avatar_ui.texture = new_avatar


func update_rings(rings_amount):
	rings_ui.text = str(rings_amount)


func update_extra_lives(extra_lives_amount):
	extra_lives_ui.text = str(extra_lives_amount)


func fill_bar_with(resource) -> String:
	var new_bar = "" #"/"
	# add a char for each 4 points
	# could be another number as long as it doesn't bloat the screen
	var char_amount = resource / 4
	for i in range(char_amount):
		new_bar += "/"
	
	# fill blank spaces
	var empty = (MAX_LIFE_TOTAL - resource) / 4
	for j in range(empty):
		new_bar += "_"
	#new_bar += "/"
	return new_bar
