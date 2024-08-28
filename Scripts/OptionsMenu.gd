extends Control

# script for the options menu
# inputmap

var is_listening = false

# the action that is being changed
# "left", &"right", &"up", &"down"
# &"guard", &"punch", &"pause", &"jump"
# &"special", &"change_cam_position", &"upper"
var current_action = ""

# to change the text in the buttons after remapping
@export var up_button: Button
@export var left_button: Button
@export var down_button: Button
@export var right_button: Button
@export var punch_button: Button
@export var special_button: Button
@export var jump_button: Button
@export var guard_button: Button
@export var upper_button: Button
@export var flip_camera_button: Button

var current_button = null

var buttons: Array

var actions_list = ["up", "left", "down", "right", "punch", "special", "jump", "guard", "upper_button", "flip_camera_button"]
var default_inputs = {"up": null, "left": null, "down": null, "right": null, "punch": null, "special": null, "jump": null, "guard": null, "upper_button": null, "flip_camera_button": null}
var current_inputs = {}


func _ready():
	# add the button nodes to the list
	buttons = [up_button, left_button, down_button, right_button, punch_button, special_button, jump_button, guard_button, upper_button, flip_camera_button]
	# store the default inputs from global variables
	current_inputs = GlobalVariables.DEFAULT_INPUTS.duplicate()
	# load the default inputs
	load_input_values()


func _on_restore_default_button_pressed():
	InputMap.load_from_project_settings()
	set_default_values()


func _on_up_button_pressed():
	if current_action == "":
		current_action = "up"
		current_button = up_button
		# grey out the button
		current_button.disabled = true


func _on_left_button_pressed():
	if current_action == "":
		current_action = "left"
		current_button = left_button
		# grey out the button
		current_button.disabled = true


func _on_down_button_pressed():
	if current_action == "":
		current_action = "down"
		current_button = down_button
		# grey out the button
		current_button.disabled = true


func _on_right_button_pressed():
	if current_action == "":
		current_action = "right"
		current_button = right_button
		# grey out the button
		current_button.disabled = true


func _on_punch_button_pressed():
	if current_action == "":
		current_action = "punch"
		current_button = punch_button
		# grey out the button
		current_button.disabled = true


func _on_special_button_pressed():
	if current_action == "":
		current_action = "special"
		current_button = special_button
		# grey out the button
		current_button.disabled = true


func _on_jump_button_pressed():
	if current_action == "":
		current_action = "jump"
		current_button = jump_button
		# grey out the button
		current_button.disabled = true


func _on_guard_button_pressed():
	if current_action == "":
		current_action = "guard"
		current_button = guard_button
		# grey out the button
		current_button.disabled = true


# load the values in the project settings and store
func load_input_values():
	for i in range(buttons.size()):
		# get first input from the inputs for that move
		var input = actions_list[i] #InputMap.action_get_events(actions_list[i])[0]
		# get a human readable string form
		var key = current_inputs[input] #OS.get_keycode_string(input.physical_keycode)
		#print(key)
		# set the key to the respective action
		default_inputs[actions_list[i]] = key
		# write the text in the respective button
		buttons[i].text = key
		
		# need to load the inputs from a save file
		
		# make the buttons actually work accordingly to the give inputs
		#InputMap.action_erase_events(input)
		#var new_event_key = event.new()
		#new_event_key = OS.set_keycode_string()
		#InputMap.action_add_event(input, key)
	#print(default_inputs)
		
	current_action = ""
	current_button = null


# write the text on the buttons accordingly to the inputs
func set_default_values():
	#var default_inputs = {"up": null, "left": null, "down": null, "right": null, "punch": null, "special": null, "jump": null, "guard": null}
	
	for i in range(buttons.size()):
		var input = InputMap.action_get_events(actions_list[i])[0]
		
		InputMap.action_erase_events(actions_list[i])
		InputMap.action_add_event(actions_list[i], input)
		
		buttons[i].text = current_inputs[actions_list[i]]
		
	current_action = ""
	current_button = null


func _input(event):
	if current_action != "" and not event is InputEventMouseMotion:
		var new_event = event
		
		# change the input text in the button
		if event is InputEventKey:
			print(OS.get_keycode_string(event.keycode))
			current_button.text = OS.get_keycode_string(event.keycode)
		elif event is InputEventMouseButton:
			print(event.button_index)
			if event.button_index == 1:
				current_button.text = "LMB"
			if event.button_index == 2:
				current_button.text = "RMB"
			if event.button_index == 3:
				current_button.text = "MMB"
			if event.button_index == 4:
				current_button.text = "MMB UP"
			if event.button_index == 5:
				current_button.text = "MMB DOWN"
		elif event is InputEventJoypadButton:
			print(event.button_index)
			current_button.text = "Joystick " + str(event.button_index)
		elif event is InputEventJoypadMotion:
			print(event.axis)
			print(event.axis_value)
			# L Horizontal
			if event.axis == 0:
				#new_event.axis = 0
				# Right
				if event.axis_value > 0:
					current_button.text = "L H R"
					#new_event.axis_value = 1.0
				# Left
				if event.axis_value < 0:
					current_button.text = "L H L"
					#new_event.axis_value = -1.0
			# L Vertical
			if event.axis == 1:
				#new_event.axis = 1
				# Down
				if event.axis_value > 0:
					current_button.text = "L V D"
					#new_event.axis_value = 1.0
				# Up
				if event.axis_value < 0:
					current_button.text = "L V U"
					#new_event.axis_value = -1.0
			# R Horizontal
			if event.axis == 2:
				#new_event.axis = 2
				# Right
				if event.axis_value > 0:
					current_button.text = "R H R"
				# Left
				if event.axis_value < 0:
					current_button.text = "R H L"
			# R Vertical
			if event.axis == 3:
				#new_event.axis = 3
				# Down
				if event.axis_value > 0:
					current_button.text = "R V D"
				# Up
				if event.axis_value < 0:
					current_button.text = "R V U"
		
		# check joystick
		print(event)
		
		# erase previous input registered for that move
		InputMap.action_erase_events(current_action)
		# make the button pressed the new input for that move
		InputMap.action_add_event(current_action, new_event)
		# reset the current action
		current_action = ""
		
		# enable it
		current_button.disabled = false
		# reset current button
		current_button = null


func _on_shake_camera_check_box_pressed():
	if GlobalVariables.can_shake_camera:
		GlobalVariables.can_shake_camera = false
	else:
		GlobalVariables.can_shake_camera = true


func _on_upper_button_pressed():
	if current_action == "":
		current_action = "upper"
		current_button = upper_button
		# grey out the button
		current_button.disabled = true


func _on_flip_camera_button_pressed():
	if current_action == "":
		current_action = "change_cam_position"
		current_button = flip_camera_button
		# grey out the button
		current_button.disabled = true
