extends Sprite2D

@onready var tile_map = $"../ScreenMap"

# Called when the node enters the scene tree for the first time.
func _ready():
	MapData.level_start.connect(update_pos_on_map)
	MapData.turn.connect(update_pos_on_map)
	pass # Replace with function body.

func update_pos_on_map():
	var coords = MapData.get_player_coords()
	position = tile_map.map_to_local(coords)
	pass
