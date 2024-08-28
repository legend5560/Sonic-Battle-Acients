extends Control

# the parts of the menu
# menu title
@export var menu_title: RichTextLabel
# the abilities symbols
@export var shot_symbol: TextureRect
@export var pow_symbol: TextureRect
@export var set_symbol: TextureRect
# the cursor to select abilities
@export var selector: TextureRect
# the character's avatar
@export var avatar: TextureRect
# the text node for the time left
@export var time_left_text: RichTextLabel
# the text displaying which ability were select to which slot
# "POW" selected to "Ground", for example
@export var shot_slot: RichTextLabel
@export var pow_slot: RichTextLabel
@export var set_slot: RichTextLabel

# the titles of the menu
enum titles {GROUND, AERIAL, DEFEND}
# the possible abilities that the selector use as position
enum abilities {SHOT, POW, SET}

# amount of time to start the timer with
const STARTING_TIME: float = 20.0

# which abilities are available
var abilities_symbol: Array[TextureRect] # = [shot_symbol, pow_symbol, set_symbol]

# the name of the slots titles
var slot_titles: Array[RichTextLabel]

# the abilities that the player will select
var selected_abilites: Array = []

# possible postions for the selector to be
var possible_positions: Array

# the current position of the selector of the abilities
var current_position: int = 0 #: abilities = abilities.SHOT

# there is probably a better way to snap into the correct position
var selector_position_correction: Vector2 = Vector2(-112, -20)

# set to true when the time runs out to start the battle
var done: bool = false

# helps readability of the find method
var not_found: int = -1

var empty_string = ""


func _ready():
	initialise_fields()


func _process(_delta):
	if GlobalVariables.game_ended:
		queue_free()
	
	if not is_multiplayer_authority(): return
	move_selector()
	
	select_ability()
	
	undo_previous_selection()
	
	check_timeout()


## set the hud to it's default values
func initialise_fields():
	menu_title.text = str(titles.find_key(0)) + " Attack"
	GlobalVariables.select_ability_timer = get_tree().create_timer(STARTING_TIME, false, true)
	abilities_symbol = [shot_symbol, pow_symbol, set_symbol]
	slot_titles = [shot_slot, pow_slot, set_slot]
	shot_slot.text = empty_string
	pow_slot.text = empty_string
	set_slot.text = empty_string
	
	# add an int to correspond each possible index the selector can reach
	for i in range(abilities.size()):
		possible_positions.append(i)


## move selector to the left or right
func move_selector():
	if Input.is_action_just_pressed("right"):
		if current_position < (possible_positions.size() - 1):
			# these line beloow causes a warning because you are using
			# the int value instead of the name you gave to the enum.
			# cast it like ability.SHOT or use a dictionary
			current_position += 1
			set_selector()
	
	# move selector to the left
	if Input.is_action_just_pressed("left"):
		if current_position > 0:
			current_position -= 1
			set_selector()


## set the selector position
func set_selector():
	selector.position = abilities_symbol[possible_positions[current_position]].position + selector_position_correction


## select current ability and set it into the current slot
func select_ability():
	if Input.is_action_just_pressed("punch") or done:
		# if there is still an ability slot to be select
		if selected_abilites.size() < abilities_symbol.size():
			# store the amount of slots already selected
			var current_slot = selected_abilites.size()
			# change the text bellow the skill image to the current ability name
			slot_titles[possible_positions[current_position]].text = titles.find_key(current_slot)
			# add the current skill to the selected abilities
			selected_abilites.append(str(abilities.find_key(possible_positions[current_position])))
			
			# example
			# [shot]	[pow]	[set]
			# 0			1		2
			# ""		""		""
			# possible positions [0, 1, 2]
			# current position is 0
			# selector is at "shot" ability's position
			# shot is selected
			# [shot]	[pow]	[set]
			# x			1		2
			# ground	""		""
			# possible positions [1, 2]
			# current position is 0
			# selector is at "pow" ability's position
			# selected cursor goes to the item in the abilities_symbol with
			# index equal to the value found at index 0 in possible_positions
			
			# only erase a possible position if there are more than one position
			if possible_positions.size() > 1:
				possible_positions.erase(possible_positions[current_position])
				current_position = 0
				set_selector()
			
			change_menu_title_text()
		else:
		# abilities selection done, confirm to start the battle
			# add the selected abilities to the global variables
			# so that the abilities are accessible to the character
			GlobalVariables.selected_abilities = selected_abilites.duplicate()
			# create character or pointer to select where to spawn the charater
			if GlobalVariables.defeated or GlobalVariables.current_hub == null:
				var spawner = Instantiables.create(Instantiables.objects.POINTERSPAWNER)
				get_parent().add_child(spawner)
			else:
				Instantiables.add_player(get_parent())
			queue_free()


## undo previous selection if any
func undo_previous_selection():
	if Input.is_action_just_pressed("pause"):
		if selected_abilites.size() > 0:
			# erase the text bellow the respective skill image and
			# add that ability back to the possible positions to be selected
			if selected_abilites[selected_abilites.size() - 1] == "SHOT":
				slot_titles[0].text = empty_string
				possible_positions.append(0)
			if selected_abilites[selected_abilites.size() - 1] == "POW":
				slot_titles[1].text = empty_string
				possible_positions.append(1)
			if selected_abilites[selected_abilites.size() - 1] == "SET":
				slot_titles[2].text = empty_string
				possible_positions.append(2)
			
			#slot_titles[slot_titles.find(selected_abilites[selected_abilites.size() - 1])].text = ""
		
			# reorder the positions
			possible_positions.sort()
			
			current_position = 0
			set_selector()
			
			# remove the last selected ability
			selected_abilites.remove_at(selected_abilites.size() - 1)
			
			change_menu_title_text()


## update the time left to select an ability
func check_timeout():
	time_left_text.text = str(int(GlobalVariables.select_ability_timer.time_left))
	
	# if the timer runs out,
	# select a default value to the unselected slots and start the battle
	if not done and (GlobalVariables.select_ability_timer == null or GlobalVariables.select_ability_timer.time_left <= 0):
		for i in range(abilities.size()): #abs(abilities.size() - selected_abilites.size())):
			if selected_abilites.find(abilities.find_key(i)) == not_found:
				selected_abilites.append(abilities.find_key(i))
				# could set it using the select ability method instead
				# current_position = 0
				# select_ability()
		
		# set "done" to start the battle
		done = true


## change the title of the ability menu accordingly
func change_menu_title_text():
	if selected_abilites.size() < titles.size() - 1:
		menu_title.text = str(titles.find_key(selected_abilites.size())) + " ATTACK"
	elif selected_abilites.size() < titles.size():
		menu_title.text = str(titles.find_key(selected_abilites.size()))
	else:
		menu_title.text = "LET'S BATTLE!"
