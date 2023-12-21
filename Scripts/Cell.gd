class_name Cell
##Cell class that holds all important information about the cells making up a dungeon
##
## Cells know their own positions(coords) in the tilemap, 
## what type(room or corridor) they are,
## and what is on them (content)

##Position in the tile map, aswell as the key in the dictionary they're assigned to 
var coords : Vector2i
##Denotes if the cell is part of a room or a corridor
##
## 0 = Cell is part of a room
## 1 = Cell is part of a corridor
var _type : int
var _content : int

##holds reference to actual thing on it
## could be player, item, enemy
var cell_content
#DEPRECATED
var has_player := false

##All cells of the same room or corridor will be given the same group id
var group_id : int

func _init(coord: Vector2i, type: MapData.CellType, content:MapData.CellContent, id : int):
	coords = coord
	_type = type
	_content = content
	group_id = id

func get_type(pretty_string:=false):
	if !pretty_string:
		return _type
	match _type:
		MapData.CellType.corridor:
			return "Corridor"
		MapData.CellType.room:
			return "Room"

func get_content(pretty_string:=false):
	if !pretty_string:
		return _content
	match _content:
		MapData.CellContent.enemy:
			return "enemy"
		MapData.CellContent.free:
			return "free"
		MapData.CellContent.item:
			return "item"
		MapData.CellContent.stair:
			return "staircase"
		MapData.CellContent.friendly:
			return "friend"
		MapData.CellContent.player:
			return "despite everything. it's u"
		_:
			return "u fucked up"

func get_id():
	return group_id

func gain_player(player_is_on):
	has_player = player_is_on

## sets the type of cell
func set_type(type: MapData.CellType):
	_type = type

##Updates the content of the cell
##There will probably need to be way more logic once it comes to items
func set_content(content, content_id:MapData.CellContent):
	cell_content = content
	_content = content_id

func _print():
	print(str(coords))
