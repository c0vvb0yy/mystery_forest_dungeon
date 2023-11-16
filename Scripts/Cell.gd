class_name Cell

var coords : Vector2i
##Denotes if the cell is part of a room or a corridor
##
## 0 = Cell is part of a room
## 1 = Cell is part of a corridor
var _type : int
var _content : int

func _init(coord: Vector2i, type: MapData.CellType, content:MapData.CellContent):
	coords = coord
	_type = type
	_content = content

func get_type():
	return _type

func get_content():
	return _content

## sets the type of cell (room or corridor)
##
## Are you really sure you want to be using this?
func set_type(type: MapData.CellType):
	_type = type

##Updates the content of the cell
##There will probably need to be way more logic once it comes to items
func set_content(content: MapData.CellContent):
	_content = content
