extends Node2D

##player turn is filled with the MapData.turn signal. when player
signal player_turn

var current_coords : Vector2i
var is_moving := false
var is_attacking := false
#var coyote_timer : float
#const COYOTE_TIME :float = 0.666
#var count_coyote_time := false
var walking_diagonally := false

var animation_walk_speed := 6.0
var animation_run_speed := 20.0
#var direction := Vector2i.ZERO
var facing_direction := Vector2i.ZERO
var prev_direction := Vector2i.ZERO
var stopped := false

var target_cell

var is_dead := false
@onready
var standard_attack := $StandardAttack

func _ready():
	MapData.level_start.connect(spawn)
	walking_diagonally = false
	PlayerManager.speed = animation_walk_speed
	PlayerManager.life_update.connect(die)
	stopped = false
	#direction = Vector2i.ZERO
	prev_direction = Vector2i.ZERO

func spawn():
	var spawn_location = MapData.get_random_coord_of_type(MapData.CellType.room, true)
	position = MapData.tile_map.map_to_local(spawn_location)
	current_coords = spawn_location
	MapData.map[spawn_location].gain_player(true, self)
	MapData.player_coords = spawn_location
	

func _unhandled_input(event):
	if is_moving || is_attacking || PlayerManager.in_menu || is_dead :
		return
	if event.is_action_pressed("Run"):
		PlayerManager.speed = animation_run_speed
	if event.is_action_released("Run"):
		PlayerManager.speed = animation_walk_speed
	var _direction:=Vector2i.ZERO
	
	if(stopped):
		if any_movement_captured(event):
			stopped = false
	#movement only in 4 directions with WASD
	
	
	if event.is_action_pressed("Attack") && !is_attacking:
		execute_standard_attack()
	
	if event.is_action_pressed("UseItem"):
		use_item()
	
	if Options.current_profile_id == 0:	
		if event.is_action_pressed("Diagonal"):
			walking_diagonally = !walking_diagonally
		#if event.is_action_released("Diagonal"):
			#walking_diagonally = !walking_diagonally
		handle_4_movement(event)
	#8directional movement with QWEADYXC
	else:
		handle_8_movement(event)

func handle_4_movement(event:InputEvent):
	var direction : Vector2i
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
			move(direction)
	else:
		if event.is_action("Down"):
			return move(Vector2i.DOWN)
		if event.is_action("Up"):
			return move(Vector2i.UP)
		if event.is_action("Right"):
			return move(Vector2i.RIGHT)
		if event.is_action("Left"):
			return move(Vector2i.LEFT)
		if(direction != Vector2i.ZERO):
			return move(direction)
	

func handle_8_movement(event:InputEvent):
	if event.is_action("Down"):
		return move(Vector2i.DOWN)
	if event.is_action("Up"):
		return move(Vector2i.UP)
	if event.is_action("Left"):
		return move(Vector2i.LEFT)
	if event.is_action("Right"):
		return move(Vector2i.RIGHT)
	if event.is_action("RightUp"):
		return move(Vector2i(1, -1))
	if event.is_action("LeftUp"):
		return move(Vector2i(-1, -1))
	if event.is_action("RightDown"):
		return move(Vector2i(1, 1))
	if event.is_action("LeftDown"):
		return move(Vector2i(-1, 1))

func move(direction:Vector2i):
	var target_coords :Vector2i = current_coords + direction
	turn_in_direction(direction)
	player_turn.emit(target_coords)
	if target_cell_is_free(target_coords):
		is_moving = true
		var tween := create_tween()
		tween.finished.connect(_on_moving_tween_finished.bind(target_coords))
		tween.tween_property(self, "position",position + Vector2(direction) * MapData.CELLSIZE, 1.0/PlayerManager.speed)#.set_trans(Tween.TRANS_SINE)

func turn_in_direction(direction):
	facing_direction = direction
	#this will be filled more with like sprite handling

func _on_moving_tween_finished(target_coords:Vector2i):
	update_cells(target_coords)
	is_moving = false
	#count_coyote_time = false
	if PlayerManager.speed == animation_run_speed:
		check_for_poi()
	check_ground()

func target_cell_is_free(target_coords:Vector2i) -> bool:
	if(MapData.map.get(target_coords)):
		if(MapData.map.get(target_coords).get_content() != MapData.CellContent.enemy):
			return true
	return false

func update_cells(target_coords:Vector2i):
	MapData.map[current_coords].gain_player(false, self)#.set_content(null, MapData.CellContent.free)
	MapData.map[target_coords].gain_player(true, self)#.set_content(self, MapData.CellContent.player)
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
	

func check_ground():
	var cell : Cell
	cell = MapData.map[current_coords]
	if cell.get_content() == MapData.CellContent.stair:
		DungeonManager.create_next_level()
	else:
		if cell.get_content() == MapData.CellContent.item:
			cell.cell_content[0].pick_up()
		MapData.turn.emit()

func any_movement_captured(event:InputEvent) -> bool:
	return event.is_action_pressed("Down") || event.is_action_pressed("Left") || event.is_action_pressed("Right") || event.is_action_pressed("Up")|| event.is_action_pressed("RightUp") || event.is_action_pressed("LeftUp")|| event.is_action_pressed("RightDown") || event.is_action_pressed("LeftDown")
	
	

func execute_standard_attack():
	is_attacking = true
	var tween := create_tween()
	tween.finished.connect(attack_finished)
	tween.tween_property(self, "position",position + Vector2(facing_direction) * MapData.CELLSIZE, 1.0/PlayerManager.speed*0.5).set_ease(Tween.EASE_OUT)#.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position",(position + Vector2(facing_direction) * MapData.CELLSIZE) - Vector2(facing_direction) * MapData.CELLSIZE, 1.0/PlayerManager.speed*0.5).set_ease(Tween.EASE_IN).set_delay(1.0/PlayerManager.speed*0.5)
	standard_attack.attack(current_coords + facing_direction)

func use_item():
	print("using item")
	if PlayerManager.held_item == null:
		print("no item held")
		return
	PlayerManager.held_item.use()

func attack_finished():
	is_attacking = false
	MapData.turn.emit()

func take_damage(damage:int):
	PlayerManager.take_damage(damage)
	$HealthComponent.take_damage(damage)

func die():
	var tween = create_tween()
	tween.finished.connect(delete)
	tween.tween_property(self, "modulate:a", 0, 0.1)
	tween.tween_property(self, "modulate:a", 1, 0.1).set_delay(0.1)
	tween.tween_property(self, "modulate:a", 0, 0.1).set_delay(0.2)
	tween.tween_property(self, "modulate:a", 1, 0.1).set_delay(0.3)
	tween.tween_property(self, "modulate:a", 0, 0.1).set_delay(0.4)
	tween.tween_property(self, "modulate:a", 1, 0.1).set_delay(0.5)

func delete():
	get_tree().quit()
	#DungeonManager.create_next_level()

#func _physics_process(_delta):
#	if is_moving:
#		self.position = lerp(self.position, target_cell, _delta*PlayerManager.speed)
#		if position.is_equal_approx(target_cell):
#			position = target_cell
#			_on_moving_tween_finished(current_coords + direction)
#		pass
