extends Node

signal died

@export
var max_health : int
var curr_health : int

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
	
	if curr_health <= 0:
		die()

func die():
	emit_signal("died")
	var parent = get_parent()
	MapData.map[parent.current_coords].set_content(null, MapData.CellContent.free)
	parent.queue_free()
