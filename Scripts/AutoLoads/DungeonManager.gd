extends Node

var dungeon_level = preload("res://BasicDungeon/BasicDungeon.tscn")
var floor := 1
func create_next_level():
	MapData.clear_map()
	floor += 1
	get_tree().change_scene_to_packed(dungeon_level)
	print(floor)
