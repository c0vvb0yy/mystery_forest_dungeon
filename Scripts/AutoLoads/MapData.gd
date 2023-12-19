extends Node

signal turn
signal level_start

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
	friendly, ## A friendly entitiy is standing on the cell
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

## Thought it's handy to have instant access to the player coordinates
var player_coords : Vector2i

var stair_coords : Vector2i

## A_Star algorithm used for pathfinding
var a_star : AStar2D
var a_star_dict := {} ##easier access to coords ids

## Creates a dictionary with the keys being the coordinates and the values denoting whether it is
## a room or a corridor
func init_map(level:Dictionary, tiles:TileMap):
	tile_map = tiles
	for coord in level.keys():
		var map_coord = Vector2i(coord)
		map[map_coord] = level[coord]
	prepare_a_star()

func clear_map():
	map.clear()
	tile_map.clear()
	a_star.clear()

func prepare_a_star():
	a_star = AStar2D.new()
	var cells = tile_map.get_used_cells(0)
##first we load all the used cells of tilemap as points into the AStar alg
	for i in range(0, cells.size()):
		a_star.add_point(i, Vector2(cells[i]))
		a_star_dict[i] = cells[i]
##then we iterate over all point_ids to connect them to the ids of neighboring cells
	for i in range(a_star.get_point_count()):
		var main_cell = Vector2i(a_star.get_point_position(i))
		
		for x in range(main_cell.x - 1, main_cell.x + 2):
			for y in range(main_cell.y - 1, main_cell.y +2):
				if !map.get(Vector2i(x,y)) || x == main_cell.x && y == main_cell.y:
					continue
				a_star.connect_points(i, a_star_dict.find_key(Vector2i(x,y)))
				
		
		var neighbor_cells = tile_map.get_surrounding_cells(main_cell)
		for cell in neighbor_cells:
			for point_id in range(a_star.get_point_count()):
				if (cell == Vector2i(a_star.get_point_position(i))):
					a_star.connect_points(i, point_id)
					break

func find_path(current_coords, destination_coords) -> PackedVector2Array:
	var curr_id = a_star_dict.find_key(current_coords)
	var target_id = a_star_dict.find_key(destination_coords)
	var path = a_star.get_point_path(curr_id, target_id)
	return path

func get_player_coords() -> Vector2i:
	return player_coords

##returns a random coordinate of the entire map
func get_random_coord() -> Vector2i:
	return map.keys()[randi() % map.keys().size()]
	
##returns a random coordinate of a certain cell type
##Maybe see into throwing an exception if 'type' is not in the CellType enum
func get_random_coord_of_type(type:CellType) -> Vector2i:
	var room = get_all_coordinates_of_type(type)
	return room[randi() % room.size()]

##returns a random coordinate that is not on the border of a room
func get_coord_inside_room() -> Vector2i:
	var room = get_all_coordinates_of_type(CellType.room)
	var coord = room[randi() % room.size()]
	return coord

##returns all coordinates that are marked as room
##Maybe see into throwing an exception if 'type' is not in the CellType enum
func get_all_coordinates_of_type(type : CellType) -> Array[Vector2i]:
	@warning_ignore("unassigned_variable")
	var coords : Array[Vector2i]
	for coord in map.keys():
		if map[coord].get_type() == type:
			coords.append(coord)
	return coords

func get_all_coordinates_of_group(id: int, type: CellType) -> Array[Vector2i]:
	@warning_ignore("unassigned_variable")
	var coords : Array[Vector2i]
	for coord in map.keys():
		if(map[coord].get_id() == id && map[coord].get_type() == type):
			coords.append(coord)
	return coords

func get_player_cell() -> Cell:
	return map[player_coords]
