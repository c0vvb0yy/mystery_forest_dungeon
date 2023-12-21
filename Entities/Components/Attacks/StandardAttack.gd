extends Node

@export
var attack_damage : int

func attack(target_cell:Vector2i):
	if MapData.map.get(target_cell):
		var cell = MapData.map.get(target_cell)
		if cell.get_content() == MapData.CellContent.enemy:
			cell.cell_content[0].take_damage(attack_damage)
		if cell.has_player:
			cell.cell_content[1].take_damage(attack_damage)
	pass
