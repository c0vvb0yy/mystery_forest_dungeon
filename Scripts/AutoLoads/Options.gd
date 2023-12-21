extends Node

var current_profile_id = 0
var control_schemes ={
	0 : 'four_directions',
	1 : 'eight_directions'
}

var four_directions = {
	'Up': KEY_W,
	'Down': KEY_S,
	'Left': KEY_A,
	'Right': KEY_D
}

var eight_directions = {
	'LeftUp': KEY_Q,
	'Up': KEY_W,
	'RightUp': KEY_E,
	'Left': KEY_A,
	'Right': KEY_D,
	'LeftDown': KEY_Y,
	'Down': KEY_X,
	'RightDown': KEY_C
}

func _unhandled_input(event):
	if event.is_action_pressed("SwitchControls"):
		change_controls()
	pass

func change_controls():
	current_profile_id = 1 if current_profile_id == 0 else 0
	var profile = get(control_schemes[current_profile_id])
	
	for action_name in profile.keys():
		change_action_key(action_name, profile[action_name])
	

func change_action_key(action_name, key_scancode):
	erase_action_events(action_name)
	
	var new_event := InputEventKey.new()
	new_event.set_keycode(key_scancode)
	InputMap.action_add_event(action_name, new_event)
	
	

func erase_action_events(action_name):
	var input_events = InputMap.action_get_events(action_name)
	for event in input_events:
		InputMap.action_erase_event(action_name, event)
