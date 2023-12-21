extends Node

var dungeon_level = preload("res://Entities/Dungeon/BasicDungeon/BasicDungeon.tscn")
var dungeon_floor := 1
func create_next_level():
	MapData.clear_map()
	EnemyManager.clear()
	dungeon_floor += 1
	get_tree().change_scene_to_packed(dungeon_level)
	print(dungeon_floor)
