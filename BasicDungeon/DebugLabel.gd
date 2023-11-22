extends RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready():
	MapData.connect("turn", update)
	pass # Replace with function body.

func update():
	var player_coords = MapData.get_player_coords()
	var string = str(player_coords, "\n")
	string += str(MapData.map[player_coords].get_type(true), "\n")
	string += str(MapData.map[player_coords].get_content(true))
	text = string
