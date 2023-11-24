extends Node2D


@export var level_size := Vector2(100, 80)
@export var rooms_size := Vector2(10, 14)
@export var rooms_max := 15

@onready var level = $Level
@onready var cam = $Camera2D

var index := 0
var level_dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	level.clear()
	level_dictionary = Generator.generate(level_size, rooms_size, randi_range(5, rooms_max))

	#for vector in level_dictionary.keys():
		#level.set_cell(0, vector, 0, Vector2i.ZERO, 1)
		#await get_tree().create_timer(0.75).timeout
	#setup_map_cam()
	
func setup_map_cam() -> void:
	cam.position = to_global(level.map_to_local(level_size / 2))
	var z = max(level_size.x, level_size.y) / 600
	cam.zoom = Vector2(z, z)

func _unhandled_input(event):
	if event.is_action("Down"):
		draw_cell()

func draw_cell():
	level.set_cell(0, level_dictionary.keys()[index], 0, Vector2i.ZERO, 1)
	setup_map_cam()
	index += 1
