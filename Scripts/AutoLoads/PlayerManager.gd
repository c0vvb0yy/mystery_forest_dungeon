extends Node

signal health_update
signal life_update #this is for when u die
var curr_health
var max_health = 25
var hunger
var max_inventory_space = 20
var inventory : Array
var held_item
var in_menu := false

var speed

func _ready():
	init_health()

func init_health():
	curr_health = max_health

func take_damage(damage:int):
	curr_health -= damage
	health_update.emit()
	if curr_health <= 0:
		die()

func heal(amount:int):
	curr_health = min(max_health, curr_health+amount)
	health_update.emit()

func die():
	life_update.emit()
	#var parent = get_parent()
	#MapData.map[parent.current_coords].set_content(null, MapData.CellContent.free)
	#parent.die()
	#parent.queue_free()

func add_to_inventory(item) -> bool:
	if inventory.size() == max_inventory_space + 1:
		return false
	inventory.append(item.duplicate())
	return true

func use_from_inventory(index):
	inventory[index].use()
	inventory.remove_at(index)
