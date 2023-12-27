extends Node

var possible_items = [preload("res://Entities/Items/grass.tscn")]

func init():
	spawn_items()

func spawn_items():
	for i in range(min(DungeonManager.dungeon_floor+99, 99)):
		var item = possible_items[randi()%possible_items.size()].instantiate()
		get_node("/root/BasicDungeon").add_child(item)
		print("item spawned")
