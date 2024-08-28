extends Control

# this script should handle the starting menus (intro animation, main
# menu, onlie or offline setup, mode selection, character selection, 
# area selection)
# after an area is selected, the player would be directed to that 
# area's hub with the selected character
# in the hub the player selects which stage to play

@export_category("MENUS")
@export var intro_animation: VideoStreamPlayer
@export var main_menu: Control
@export var options_menu: Control
@export var online_or_offline_menu: Control
@export var online_menu: Control
@export var mode_selection_menu: Control
@export var conditions_menu: Control
@export var character_selection_menu: Control
@export var area_selection_menu: Control
@export var pause_menu: Control

@export_category("CONDITIONS MENU")
@export var bots_amount_node: TextEdit
@export var wins_amount_node: TextEdit

var focused = false

var list_of_menus: Array


func _ready():
	GlobalVariables.main_menu = self
	
	# reset any current ambients to prevent error when
	# going to a previous ambient using pause menu button
	GlobalVariables.current_stage = null
	GlobalVariables.current_hub = null
	GlobalVariables.current_area = null
	
	list_of_menus = [intro_animation, main_menu, options_menu, online_or_offline_menu, online_menu, mode_selection_menu, conditions_menu, character_selection_menu, area_selection_menu]
	
	# hide menus and show intro animation
	start_menu()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# intro animation
	if intro_animation.is_visible_in_tree() and Input.is_anything_pressed():
		intro_animation.hide()
		main_menu.show()
	
	# grab focus on the next visible button
	if focused == false:
		for i in range(get_children().size()):
			if get_child(i).name != "AudioStreamPlayer" and get_child(i).is_visible_in_tree():
				for j in range(get_child(i).get_children().size()):
					if get_child(i).get_child(j) is Button:
						get_child(i).get_child(j).grab_focus()
						focused = true
						return


func start_menu():
	show_next_menu(intro_animation)


## use the server to call the next menu
func show_next_menu(next_menu):
	var next_menu_reference = list_of_menus.find(next_menu)
	
	if multiplayer.has_multiplayer_peer(): #Network.peer != null:
		Network.server_call_method(self, "show_next", next_menu_reference)
	else:
		hide_menus()
		next_menu.show()
	


@rpc("any_peer", "call_local")
func show_next(next_menu_reference):
	hide_menus()
	
	# trying to call the equivalent of the next menu node to show from server
	# to client but the server passes an "EncodedObjectAsID" instead and the
	# documentation suggests instance_from_id() method but it asks for an int
	# so a list was created instead and a refernce to the screen that needs
	# to be shown is passed
	var menu_to_show = list_of_menus[next_menu_reference]
	menu_to_show.show()


## hide all menu screens so they won't overlap each other
func hide_menus():
	focused = false
	intro_animation.hide()
	main_menu.hide()
	options_menu.hide()
	online_or_offline_menu.hide()
	online_menu.hide()
	mode_selection_menu.hide()
	conditions_menu.hide()
	character_selection_menu.hide()
	area_selection_menu.hide()
	pause_menu.hide()


## proceed with the normal screens sequence after online setup
## called from network_menu script
func after_online_setup():
	# if no online connection was made, go offline
	if Network.peer == null:
		GlobalVariables.play_online = false
		GlobalVariables.character_id = 1
	
	show_next_menu(mode_selection_menu)


## called after the area has been selected
func go_to_area_scene():
	# go to the area scene or hub of the selected area
	# the area is a placeholder for now
	# testing a game loop
	# the same hub will be selected every time for now
	#Instantiables.go_to_area(GlobalVariables.area_selected)
	Instantiables.go_to_hub(GlobalVariables.hub_selected)
	hide_menus()


# sequence of menu buttons
# there might be a better way to do this

# main menu
func _on_start_button_pressed():
	show_next_menu(character_selection_menu) #online_or_offline_menu)


func _on_options_button_pressed():
	hide_menus()
	options_menu.show()


func _on_quit_button_pressed():
	# this quit won't work on iOS, need home button press instead
	get_tree().quit()


func _on_options_back_button_pressed():
	hide_menus()
	# return to pause menu if the game is was paused
	if GlobalVariables.current_character != null:
		pause_menu.show()
		pause_menu.resume_button.grab_focus()
	else:
		main_menu.show()


func _on_online_button_pressed():
	GlobalVariables.play_online = true
	hide_menus()
	online_menu.show()


func _on_offline_button_pressed():
	GlobalVariables.play_online = false
	hide_menus()
	GlobalVariables.character_id = 1
	mode_selection_menu.show()


func _on_story_mode_button_pressed():
	Network.server_call_method(self, "mode_select", "story")


func _on_battle_mode_button_pressed():
	Network.server_call_method(self, "mode_select", "battle")


func _on_challenge_mode_button_pressed():
	Network.server_call_method(self, "mode_select", "challenge")


@rpc("any_peer", "call_local")
func mode_select(mode_selected: String):
	match mode_selected:
		"story":
			GlobalVariables.play_mode = GlobalVariables.modes.story
		"battle":
			GlobalVariables.play_mode = GlobalVariables.modes.battle
		"challenge":
			GlobalVariables.play_mode = GlobalVariables.modes.challenge
	
	show_next_menu(conditions_menu)


# players will select character by themselves, no rpc
# but this should be a list
func _on_sonic_character_button_pressed():
	GlobalVariables.character_selected = GlobalVariables.playable_characters.sonic
	hide_menus()
	online_or_offline_menu.show()
	#area_selection_menu.show()

func _on_shadow_character_button_pressed():
	GlobalVariables.character_selected = GlobalVariables.playable_characters.shadow
	hide_menus()
	online_or_offline_menu.show()
	#area_selection_menu.show()

func _on_area_1_button_pressed():
	Network.server_call_method(self, "go_to_area_1")


@rpc("any_peer", "call_local")
func go_to_area_1():
	GlobalVariables.hub_selected = Instantiables.match_place(Instantiables.worlds_and_hubs.city_hub)
	hide_menus()
	$AudioStreamPlayer.stop()
	go_to_area_scene()


# most of the back buttons from the menus trigger this method
# except for the options menu, which can be changed to call this as well
func _on_back_button_pressed():
	Network.server_call_method(self, "back_to_previous_menu")


@rpc("any_peer", "call_local")
func back_to_previous_menu():
	if character_selection_menu.is_visible_in_tree():
		hide_menus()
		main_menu.show()
		#show_next_menu(conditions_menu)
	if online_or_offline_menu.is_visible_in_tree():
		hide_menus()
		character_selection_menu.show()
		#main_menu.show()
	if online_menu.is_visible_in_tree():
		# reset connection when going back
		show_next_menu(online_or_offline_menu)
		Network.reset_connection()
	if mode_selection_menu.is_visible_in_tree():
		# reset connection when going back
		show_next_menu(online_or_offline_menu)
		Network.reset_connection()
	if conditions_menu.is_visible_in_tree():
		show_next_menu(mode_selection_menu)
	if area_selection_menu.is_visible_in_tree():
		show_next_menu(conditions_menu) #character_selection_menu)


func _on_difficulty_selection_list_item_selected(index):
	GlobalVariables.current_difficulty = GlobalVariables.difficulty_levels[index]


func _on_conditions_next_button_pressed():
	Network.server_call_method(self, "set_conditions")


@rpc("any_peer", "call_local")
func set_conditions():
	# "sanitize" the input
	# cast to int. non numbers will be 0
	# store values
	var bots_amount = int(bots_amount_node.text)
	var wins_amount = int(wins_amount_node.text)
	
	if typeof(bots_amount) == TYPE_INT and typeof(wins_amount) == TYPE_INT:	
		# limit the amount
		if bots_amount < 0:
			bots_amount = 0
		if bots_amount > GlobalVariables.MAX_BOTS_TOTAL:
			bots_amount = GlobalVariables.MAX_BOTS_TOTAL
		if wins_amount < 1:
			wins_amount = 1
		if wins_amount > GlobalVariables.MAX_WIN_POINTS:
			wins_amount = GlobalVariables.MAX_WIN_POINTS
			
		# set conditions values
		GlobalVariables.number_of_bots = bots_amount
		GlobalVariables.points_to_win = wins_amount
		
		show_next_menu(area_selection_menu) #character_selection_menu)
