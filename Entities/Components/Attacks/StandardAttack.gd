extends Node

@export
var attack_damage : int

func attack(target_cell:Vector2i):
	if MapData.map.get(target_cell):
		var cell = MapData.map.get(target_cell)
		if cell.get_content() == MapData.CellContent.enemy:
			cell.cell_content.take_damage(attack_damage)
	pass
