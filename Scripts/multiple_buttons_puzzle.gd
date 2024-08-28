extends Node3D

@export_category("Buttons of the Puzzle")
## buttons that need to be triggered to solve the puzzle
@export var buttons: Array[Node3D]
@export_category("Solved Puzzle Triggered")
## should it reveal an object after solved?
@export var reveal_object: bool = false
# should it call a method after solved?
@export var call_method: bool = false
@export var object_to_reveal_or_call: Node3D
@export var method_name: String

var number_of_buttons_pressed: int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	reset_button()


func reset_button(selected_button = -1):
	# if no button is specified, reset all buttons
	if selected_button == -1:
		for button in buttons.size():
			buttons[button].done = false
	else:
	# else reset that button if it isn't null
		if selected_button < buttons.size() and buttons[selected_button] != null:
			buttons[selected_button].done = false


func button_pressed():
	number_of_buttons_pressed += 1
	if number_of_buttons_pressed >= buttons.size():
		puzzle_solved()


func puzzle_solved():
	if reveal_object:
		object_to_reveal_or_call.show()
	if call_method:
		object_to_reveal_or_call.call(method_name)
