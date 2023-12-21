extends Node

var curr_health
var max_health = 25
var hunger

var held_item

var speed

func _ready():
	init_health()

func init_health():
	curr_health = max_health

func heal(healing: int):
	curr_health += healing
	
	if curr_health >= max_health:
		curr_health = max_health

func take_damage(damage:int):
	curr_health -= damage
	#damage_label.show_damage(str(damage))
	if curr_health <= 0:
		die()

func die():
	var parent = get_parent()
	MapData.map[parent.current_coords].set_content(null, MapData.CellContent.free)
	parent.die()
	#parent.queue_free()
