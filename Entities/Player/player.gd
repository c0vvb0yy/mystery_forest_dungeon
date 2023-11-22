extends Node2D

var player_turn

var current_coords : Vector2i
var is_moving := false
var walking_diagonally := false

var animation_walk_speed := 6.0
var animation_run_speed := 20.0
var current_speed = animation_walk_speed
var direction := Vector2i.ZERO

var stopped := false

func _ready():
	MapData.level_start.connect(spawn)
	player_turn = MapData.turn

func spawn():
	var spawn_location = MapData.get_random_coord_of_type(MapData.CellType.room)
	position = MapData.tile_map.map_to_local(spawn_location)
	current_coords = spawn_location
	MapData.map[spawn_location].gain_player(true)
	MapData.player_coords = spawn_location
	

func _unhandled_input(event):
	if is_moving:
		return
	if event.is_action_pressed("Run"):
		current_speed = animation_run_speed
	if event.is_action_released("Run"):
		current_speed = animation_walk_speed
	var _direction:=Vector2i.ZERO
	
	if event.is_action_pressed("Diagonal"):
		walking_diagonally = !walking_diagonally
	if event.is_action_released("Diagonal"):
		walking_diagonally = !walking_diagonally
	
	if(stopped):
		if any_movement_captured(event):
			stopped = false
	else:
		handle_movement(event)

func handle_movement(event:InputEvent):
	if walking_diagonally:
		if event.is_action("Down"):
			if direction.y == 0:
				direction += Vector2i.DOWN
		if event.is_action("Up"):
			if direction.y == 0:
				direction += Vector2i.UP
		if event.is_action("Right"):
			if direction.x == 0:
				direction += Vector2i.RIGHT
		if event.is_action("Left"):
			if direction.x == 0:
				direction += Vector2i.LEFT
		if direction.x == 0 or direction.y == 0:
			return
		else:
			move()
	else:
		if event.is_action("Down"):
			direction = Vector2i.DOWN
		if event.is_action("Up"):
			direction = Vector2i.UP
		if event.is_action("Right"):
			direction = Vector2i.RIGHT
		if event.is_action("Left"):
			direction = Vector2i.LEFT
		if(direction != Vector2i.ZERO):
			move()
	

func move():
	var target_coords = current_coords + direction
	if target_cell_is_free(target_coords):
		update_cells(target_coords)
		is_moving = true
		var tween = create_tween()
		tween.finished.connect(_on_moving_tween_finished)
		tween.tween_property(self, "position",position + Vector2(direction) * MapData.CELLSIZE, 1.0/current_speed).set_trans(Tween.TRANS_SINE)
		player_turn.emit()
	direction = Vector2i.ZERO

func _on_moving_tween_finished():
	is_moving = false
	if current_speed == animation_run_speed:
		check_for_poi()

func target_cell_is_free(target_coords:Vector2i) -> bool:
	if(MapData.map.get(target_coords)):
		if(MapData.map.get(target_coords).get_content() != MapData.CellContent.enemy):
			return true
	return false

func update_cells(target_coords:Vector2i):
	MapData.map[current_coords].gain_player(false)
	MapData.map[target_coords].gain_player(true)
	MapData.player_coords = target_coords
	current_coords = target_coords

##when we're running we want to stop the player at certain points
##
## these points include: intersections, near items, near stairways, near enemies
func check_for_poi():
	var player_coords = MapData.get_player_coords()
	#we look at the cell we're on
	var curr_cell = MapData.map[player_coords]
	#get its neigbors in the tilemap
	var neighbors = MapData.tile_map.get_surrounding_cells(player_coords)
	if curr_cell.get_type() == MapData.CellType.corridor:
		var corridor_count = 0
		for vector in neighbors:
			var cell = MapData.map.get(vector)
			if cell == null: continue
			match cell.get_type():
				MapData.CellType.corridor:
					corridor_count += 1
					if corridor_count <= 2:
						return
				MapData.CellType.room:
					stopped = true
					return
				_:
					print("Unaccounted for cell type")
					stopped = true
					return
	else:
		for vector in neighbors:
		#the moment a corridor entrance/item/stairway so,, a POI LOL is in our nieghbors we stop
			var cell = MapData.map.get(vector)
			if cell == null: continue
			if cell.get_type() == MapData.CellType.corridor || cell.get_content() != MapData.CellContent.free:
				stopped = true
				return
	

func any_movement_captured(event:InputEvent) -> bool:
	return event.is_action_pressed("Down") || event.is_action_pressed("Left") || event.is_action_pressed("Right") || event.is_action_pressed("Up")

func _process(_delta):
	pass
