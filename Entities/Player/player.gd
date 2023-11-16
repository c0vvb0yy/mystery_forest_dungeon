extends Node2D

var player_turn

var tile_size := MapData.CELLSIZE

var current_coords : Vector2i
var is_moving := false
var walking_diagonally := false

var animation_walk_speed := 6.0
var animation_run_speed := 36.0
var current_speed = animation_walk_speed
var direction := Vector2i.ZERO

var debug_run_counter = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	player_turn = MapData.turn
	pass # Replace with function body.

func spawn(level:TileMap):
	var point_on_map = MapData.map.keys()[randi() % MapData.map.keys().size()]
	if(MapData.map[point_on_map].get_type() == MapData.CellType.room):
		position = level.map_to_local(point_on_map)
		current_coords = point_on_map
		MapData.map[point_on_map].get_player(true)
		return
	else:
		spawn(level)

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
			direction = Vector2i.ZERO
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
			direction = Vector2i.ZERO
	

func move():
	var target_coords = current_coords + direction
	if target_cell_is_free(target_coords):
		update_cells(target_coords)
		is_moving = true
		var tween = create_tween()
		tween.finished.connect(_on_moving_tween_finished)
		tween.tween_property(self, "position",position + Vector2(direction) * tile_size, 1.0/current_speed).set_trans(Tween.TRANS_SINE)
		#player_turn = MapData.turn
		player_turn.emit()

func _on_moving_tween_finished():
	is_moving = false
	if current_speed == animation_run_speed:
		check_for_poi()

func target_cell_is_free(target_coords:Vector2i) -> bool:
	if(MapData.map.get(target_coords) != null):
		if(MapData.map.get(target_coords).get_content() == MapData.CellContent.free):
			return true
		else:
			return false
	return false

func update_cells(target_coords:Vector2i):
	MapData.map[current_coords].get_player(false)
	#set_content(MapData.CellContent.free)
	MapData.map[target_coords].get_player(true)
	#.set_content(MapData.CellContent.player)
	current_coords = target_coords

##when we're running we want to stop the player at certain points
##
## these points include: intersections, near items, near stairways, near enemies
func check_for_poi():
	debug_run_counter += 1
	print(debug_run_counter)
	if(debug_run_counter >= 6):
		current_speed = animation_walk_speed
		debug_run_counter = 0
	#we look at the cell we're on
	#get its neigbors in the tilemap
	#if currently in a corridor
		#if it has more than 2 neighbors then it's a crossing or a room(beginning) and we stop the player
	#if we're in a room
		#the moment a corridor entrance/item/stairway so,, a POI LOL is in our nieghbors we stop
	
	pass

func _process(_delta):
	pass
