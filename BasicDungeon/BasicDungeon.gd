extends Node2D
##Script to immanentize the proceduraly the dungeon layout into the game

@export var level_size := Vector2(100, 80)
@export var rooms_size := Vector2(10, 14)
@export var rooms_max := 15

@onready var level: TileMap = $Level
@onready var screen_map: TileMap = $ScreenMap
@onready var player: Node2D = $Player

var map: Array[Vector2i]

func _ready() -> void:
	_generate()
	player.spawn(level)


func _generate() -> void:
	level.clear()
	var level_dictionary = Generator.generate(level_size, rooms_size, rooms_max)
	for vector in level_dictionary.keys():
		map.append(Vector2i(vector))
		level.set_cell(0, vector, 0, Vector2i.ZERO, 1)
		screen_map.set_cell(0, vector, 0, Vector2i.ZERO, 1)
	level.set_cells_terrain_connect(0, map, 0, 0)
	screen_map.set_cells_terrain_connect(0, map, 0, 0)
	MapData.init_map(level_dictionary, level)
	correct_corridors_to_be_rooms()
	generate_staircase()

## If there were corridors built that border on rooms, we should change their tpyes to room in the data
## since that is what they appear as
func correct_corridors_to_be_rooms():
	for cell in map:
		if MapData.map[cell].get_type() == MapData.CellType.corridor:
			var room_neigbors := 0
			var corr_neighbors := 0
			var neighbors = level.get_surrounding_cells(cell)
			for neighbor in neighbors:
				match MapData.map[cell].get_type():
					MapData.CellType.corridor:
						corr_neighbors += 1
					MapData.CellType.room:
						room_neigbors += 1
			if room_neigbors >= corr_neighbors:
				MapData.map[cell].set_type(MapData.CellType.room)

func generate_staircase():
	var stair_location = MapData.get_random_coord_of_type(MapData.CellType.room)
	print(stair_location)
	level.set_cell(0, stair_location, 0, MapData.STAIRCASE_COORDS)
	var stair_cell : Cell
	stair_cell = MapData.map[stair_location]
	stair_cell.set_content(MapData.CellContent.stair)
	MapData.map[stair_location] = stair_cell
