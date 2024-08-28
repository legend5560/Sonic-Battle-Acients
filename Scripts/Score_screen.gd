extends Control

# winner ID
var winner
var done: bool = false
var button_pressed: bool = false

@export var win_text_node: RichTextLabel
@export var play_again_button: Button


func _process(_delta):
	if winner != null and done == false:
		done = true
		win_text_node.text = "Player " + str(winner) + " Won!"
		play_again_button.grab_focus()
	
	if button_pressed:
		queue_free()


## play again with the same settings
func _on_play_again_button_pressed():
	# delete this screen
	button_pressed = true
	
	# restart current match
	Instantiables.go_to_stage(GlobalVariables.stage_selected) #restart_current_stage()	


func _on_back_to_hub_button_pressed():	
	# delete this screen
	button_pressed = true
	
	# reset win conditions
	GlobalVariables.reset_win_conditions()
	
	if is_instance_valid(GlobalVariables.current_character) and is_instance_valid(GlobalVariables.current_character.hud):
		GlobalVariables.current_character.hud.update_hud(GlobalVariables.current_character.life_total, GlobalVariables.current_character.special_amount, GlobalVariables.current_character.points)
	
	Instantiables.go_to_hub(GlobalVariables.hub_selected)
	get_tree().paused = false
