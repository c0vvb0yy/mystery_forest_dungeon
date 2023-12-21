extends Node2D

@export
var sight_range : int = 2

var current_coords : Vector2i

var path
var path_index : int = 0
var is_moving := false
var is_tracking := false

# Called when the node enters the scene tree for the first time.
func _ready():
	MapData.level_start.connect(spawn)
	#MapData.turn.connect(start_turn)
	pass # Replace with function body.

func spawn():
	var spawn_location = MapData.get_random_coord_of_type(MapData.CellType.room)
	position = MapData.tile_map.map_to_local(spawn_location)
	current_coords = spawn_location
	get_new_destination()
	EnemyManager.register(self)


func start_turn():
	#check if player is in same room or vicinity
	look_for_player()
	#check if i have a path to go on
	if path_index >= path.size():
		get_new_destination()
	print("next cell:", Vector2i(path[path_index]), "current cell: ", current_coords)
	start_move(Vector2i(path[path_index]))
	
	pass

func look_for_player():
	var curr_id = MapData.map.get(current_coords).get_id()
	var player_id = MapData.get_player_cell().get_id()
	if curr_id == player_id && !is_tracking:
		is_tracking = true
		get_new_destination()
		#get_player_destination()
	else:
		for cell in MapData.get_surrounding_cells_in_range(current_coords, sight_range):
			if cell.has_player:
				print("found player in: ", cell.coords)
				is_tracking = true
				return
		is_tracking = false
		
		
	#if curr_id == player_id && !is_tracking:
		#is_tracking = true
		#get_new_destination()
	#else: if is_tracking:
		#pass
	#else:
		#is_tracking = false

func get_player_destination():
	path = MapData.find_path(current_coords, MapData.get_player_coords())

func get_new_destination():
	var destination
	if is_tracking:
		destination = MapData.get_player_coords()
	else:
		destination = MapData.get_random_coord_of_type(MapData.CellType.room)
	path = MapData.find_path(current_coords, destination)
	path_index = 1 #we start counting from 1 bc at index 0 is the current pos and we dont wanna move there. we're already there

func start_move(target_coord:Vector2i):
	move(target_coord)

func move(target_coords:Vector2i):
	if target_cell_is_free(target_coords):
		update_cells(target_coords)
		EnemyManager.index += 1
		EnemyManager.next_enemy_turn()
		is_moving = true
		var tween := create_tween()
		tween.finished.connect(_on_moving_tween_finished.bind(target_coords))
		tween.tween_property(self, "position", MapData.tile_map.map_to_local(target_coords), 1.0/PlayerManager.speed)#.set_trans(Tween.TRANS_SINE)

func _on_moving_tween_finished(target_coords:Vector2i):
	is_moving = false
	path_index += 1
	#direction = Vector2i.ZERO
	#if current_speed == animation_run_speed:
	#	check_for_poi()
	#check_ground()

func target_cell_is_free(target_coords:Vector2i) -> bool:
	if(MapData.map.get(target_coords)):
		var cell = MapData.map.get(target_coords)
		if(cell.get_content() == MapData.CellContent.enemy || cell.has_player):
			return false
	return true

func update_cells(target_coords:Vector2i):
	MapData.map[current_coords].set_content(null, MapData.CellContent.free)
	MapData.map[target_coords].set_content(self.get_parent(), 2)
	current_coords = target_coords
