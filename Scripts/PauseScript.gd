extends Control

@export var pause_menu: Control
@export var resume_button: Button
@export var restart_button: Button
@export var main_menu_button: Button


func _process(_delta):
	# don't show the restart button on online play
	# because anyone could restart everyone else's match
	if GlobalVariables.play_online:
		restart_button.hide()
	else:
		restart_button.show()
	
	# if the game is not paused, hide pause menu
	if get_tree().is_paused() == false:
		hide()
	# if the pause menu is visible pause the game
	if is_visible_in_tree():
		get_tree().paused = true
	
	# allow to pause on a stage or hub while the game has not being won yet
	if GlobalVariables.game_ended == false and GlobalVariables.current_character != null and (GlobalVariables.current_area != null or GlobalVariables.current_hub != null or GlobalVariables.current_stage != null):
		# pause / resume the game when pressing "pause" button
		# prevent it when options menu is visible
		if Input.is_action_just_pressed("pause") and GlobalVariables.main_menu.options_menu.is_visible_in_tree() == false:
			toggle_pause()
		
		if get_tree().is_paused():
			# show the mouse the confine it within the screen while paused
			#pause_menu.show()
			#show()
			Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		else:
			# hide the mouse and hold it in place while not paused
			#pause_menu.hide()
			hide()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		# game ended, score screen appeared
		get_tree().paused = GlobalVariables.game_ended
		# else it's on main menu
		
		#pause_menu.hide()
		hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)


func toggle_pause():
	# if game is paused, resume
	if get_tree().is_paused():
		get_tree().paused = false
		hide()
	else:
	# if game is not paused, pause
		get_tree().paused = true
		show()
		# grab focus on resume button
		resume_button.grab_focus()


func restart():
	# prevent anyone from restarting everyone else's match
	if GlobalVariables.play_online == false:
		get_tree().paused = false
		
		# if it's restarting a hub
		if GlobalVariables.current_hub != null and GlobalVariables.hub_selected != null:
			Instantiables.go_to_hub(GlobalVariables.hub_selected)
		# if restarting a stage
		elif GlobalVariables.current_stage != null and GlobalVariables.stage_selected != null:
			Instantiables.go_to_stage(GlobalVariables.stage_selected)
		# if restarting an area
		# for now go to main menu
		else:
			#get_tree().reload_current_scene()
			Instantiables.reload_current_scene()

# exit
func go_back():
	get_tree().paused = false
	
	Instantiables.exit_current_ambient()


func _on_resume_button_pressed():
	toggle_pause()


func _on_restart_button_pressed():
	restart()


# exit button
func _on_go_to_previous_ambient_pressed():
	go_back()


func _on_options_button_pressed():
	GlobalVariables.main_menu.hide_menus()
	GlobalVariables.main_menu.options_menu.show()
	# grab focus on the back button
	GlobalVariables.main_menu.options_menu.get_child(2).grab_focus()
