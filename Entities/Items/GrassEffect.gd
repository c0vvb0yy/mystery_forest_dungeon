extends Node

@export
var healing : int = 2

func use():
	if PlayerManager.curr_health >= PlayerManager.max_health:
		print("no healing needed")
		return
	PlayerManager.heal(healing)
	PlayerManager.held_item = null
