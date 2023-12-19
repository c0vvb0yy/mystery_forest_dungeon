extends RichTextLabel

@onready 
var player = $"/root/BasicDungeon/Player"

# Called when the node enters the scene tree for the first time.
func _ready():
	#MapData.connect("turn", update)
	MapData.connect("level_start", update)
	player.connect("player_turn", update_target)
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

func update_target(target_coords):
	var player_coords = MapData.get_player_coords()
	var string = str(player_coords, "\n")
	if MapData.map.has(target_coords):
		var cell = MapData.map[player_coords]
		string += str(cell.get_type(true), "\n")
		string += str(cell.get_content(true), "\n")
		string += str(cell.get_id(), "\n")
		string += str("target content: ",  MapData.map[target_coords].get_content(true))
	text = string
