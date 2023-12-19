extends Node2D

var current_coords : Vector2i
var is_moving := false

@export_enum("free", "Player", "Enemy", "Friendly", "Item") 
var content_type: int


func move(target_coords:Vector2i):
	if target_cell_is_free(target_coords):
		is_moving = true
		var tween := create_tween()
		tween.finished.connect(_on_moving_tween_finished.bind(target_coords))
		tween.tween_property(self, "position", MapData.tile_map.map_to_local(target_coords), 1.0/1.0)#.set_trans(Tween.TRANS_SINE)

func _on_moving_tween_finished(target_coords:Vector2i):
	update_cells(target_coords)
	is_moving = false
	
	#direction = Vector2i.ZERO
	#if current_speed == animation_run_speed:
	#	check_for_poi()
	#check_ground()

func target_cell_is_free(target_coords:Vector2i) -> bool:
	if(MapData.map.get(target_coords)):
		if(MapData.map.get(target_coords).get_content() != MapData.CellContent.enemy):
			return true
	return false

func update_cells(target_coords:Vector2i):
	MapData.map[current_coords].set_content(null, MapData.CellContent.free)
	MapData.map[target_coords].set_content(self.get_parent(), content_type)
