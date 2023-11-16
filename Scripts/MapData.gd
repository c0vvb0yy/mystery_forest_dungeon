extends Node

signal turn

## Denotes if the cell is part of a room or a corridor
enum CellType{
	room, ## Cell is part of a room
	corridor## Cell is part of a corridor
}

##Denotes what is "on" the cell
enum CellContent{
	free, ## Nothing is on the cell
	player, ## The Player is standing on the cell
	enemy, ## An Enemy is standing on the cell
	item ## There's an item on the cell
}

## Dictionary<Vector2i, Cell> 
## 
## The keys of the dictionary are the coordinates of the tile in the tilemap,
## while the values represent the cells, using the Cell.gd class
var map : Dictionary

## size in pixels of the tiles in the tilemap 
const CELLSIZE := 64


## Creates a dictionary with the keys being the coordinates and the values denoting whether it is
## a room or a corridor
func init_map(level:Dictionary):
	for coord in level.keys():
		var map_coord = Vector2i(coord)
		map[map_coord] = level[coord]

func get_player_cell() -> Vector2i:
	for cell in map:
		if(map[cell].has_player):
			return cell
	return Vector2i(-99,-99)

func print_cell_content(coord):
	var print_str = str("Cell: ", str(coord))
	match map.get(coord):
		CellContent.free:
			print_str += " is: free"
		CellContent.player:
			print_str += " is: player"
		CellContent.enemy:
			print_str += " is: enemy"
		_:
			print_str += "cannot be determined"
	print(print_str)
