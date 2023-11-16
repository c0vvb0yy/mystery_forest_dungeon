extends Node2D
##Script to immanentize the proceduraly the dungeon layout into the game

@export var level_size := Vector2(100, 80)
@export var rooms_size := Vector2(10, 14)
@export var rooms_max := 15

@onready var level: TileMap = $Level
@onready var camera: Camera2D = $Player/Camera2D
@onready var player: Node2D = $Player

var map: Array[Vector2i]

const FACTOR := 1.0 / 0.8

func _ready() -> void:
	#_setup_camera()
	_generate()
	player.spawn(level)


func _setup_camera() -> void:
	camera.position = to_global(level.map_to_local(level_size / 2))
	var z = max(level_size.x, level_size.y) / 300
	camera.zoom = Vector2(z, z)


func _generate() -> void:
	level.clear()
	var level_dictionary = Generator.generate(level_size, rooms_size, rooms_max)
	for vector in level_dictionary.keys():
		map.append(Vector2i(vector))
	for vector in map:
		level.set_cell(0, vector, 0, Vector2i.ZERO, 1)
	level_dictionary = check_room_corridors(level_dictionary)
	level.set_cells_terrain_connect(0, map, 0, 0)
	MapData.init_map(level_dictionary)

## If there were corridors built that border on rooms, we should change their tpyes to room in the data
## since that is what they appear as
func check_room_corridors(data: Dictionary):
	for cell in map:
		if data[cell].get_type() == MapData.CellType.corridor:
			var room_neigbors := 0
			var corr_neighbors := 0
			var neighbors = level.get_surrounding_cells(cell)
			for neighbor in neighbors:
				match data[cell].get_type():
					MapData.CellType.corridor:
						corr_neighbors += 1
					MapData.CellType.room:
						room_neigbors += 1
			if room_neigbors >= corr_neighbors:
				data[cell].set_type(MapData.CellType.room)
	return data




