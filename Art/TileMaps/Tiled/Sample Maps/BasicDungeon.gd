extends Node2D


@export var level_size := Vector2(100, 80)
@export var rooms_size := Vector2(10, 14)
@export var rooms_max := 15

@onready var level: TileMap = $Level
@onready var camera: Camera2D = $Camera2D

const FACTOR := 1.0 / 0.8

func _ready() -> void:
	_setup_camera()
	_generate()


func _setup_camera() -> void:
	camera.position = to_global(level.map_to_local(level_size / 2))
	var z = max(level_size.x, level_size.y) / 300
	camera.zoom = Vector2(z, z)


func _generate() -> void:
	level.clear()
	var map = Generator.generate(level_size, rooms_size, rooms_max)
	for vector in map:
		level.set_cell(0, vector, 0, Vector2i(1, 4))
	level.set_cells_terrain_connect(0, map, 0, 0)







