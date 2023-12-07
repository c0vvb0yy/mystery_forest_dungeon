extends RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready():
	MapData.connect("turn", update)
	MapData.connect("level_start", update)
	pass # Replace with function body.

func update():
	var player_coords = MapData.get_player_coords()
	var string = str(player_coords, "\n")
	if MapData.map.has(player_coords):
		var cell = MapData.map[player_coords]
		string += str(cell.get_type(true), "\n")
		string += str(cell.get_content(true), "\n")
		string += str(cell.get_id())
	text = string
