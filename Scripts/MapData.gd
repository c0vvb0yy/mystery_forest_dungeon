extends Node

signal turn

## Denotes if the cell is part of a room or a corridor
enum CellType{
	room, ## Cell is part of a room
	corridor, ## Cell is part of a corridor
}

##Denotes what is "on" the cell
enum CellContent{
	free, ## Nothing is on the cell
	player, ## The Player is standing on the cell
	enemy, ## An Enemy is standing on the cell
	item, ## There's an item on the cell
	stair ## The cell holds the stair leading to the next level
}

##The coordinates of the stair case sprite in the tilemap
const STAIRCASE_COORDS := Vector2i(0,4)

## Dictionary<Vector2i, Cell> 
## 
## The keys of the dictionary are the coordinates of the tile in the tilemap,
## while the values represent the cells, using the Cell.gd class
var map : Dictionary

var tile_map: TileMap

## size in pixels of the tiles in the tilemap 
const CELLSIZE := 64


## Creates a dictionary with the keys being the coordinates and the values denoting whether it is
## a room or a corridor
func init_map(level:Dictionary, tiles:TileMap):
	tile_map = tiles
	for coord in level.keys():
		var map_coord = Vector2i(coord)
		map[map_coord] = level[coord]

func get_player_coords() -> Vector2i:
	for cell in map:
		if(map[cell].has_player):
			return cell
	return Vector2i(-99,-99)

##returns a random coordinate of the entire map
func get_random_coord() -> Vector2i:
	return map.keys()[randi() % MapData.map.keys().size()]
	
##returns a random coordinate of a certain cell type
##Maybe see into throwing an exception if 'type' is not in the CellType enum
func get_random_coord_of_type(type:CellType) -> Vector2i:
	var room = get_all_coordinates_of_type(type)
	return room[randi() % room.size()]

##returns all coordinates that are marked as room
##Maybe see into throwing an exception if 'type' is not in the CellType enum
func get_all_coordinates_of_type(type : CellType) -> Array[Vector2i]:
	var coords : Array[Vector2i]
	for coord in map.keys():
		if map[coord].get_type() == type:
			coords.append(coord)
	return coords
