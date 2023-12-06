extends TileMap

##helps me keep track of where tiles are in relation to each other
enum Alignment {
	left,
	right,
	above,
	below,
	left_up,
	right_up,
	left_down,
	right_down
}
@export var view_range := 2
var cells : Array[Vector2i]
var drawn_cells : Array[Vector2i]
var visited_rooms : Array[int]
var in_room := true
var found_stair := false
var stair_room_id : int

func _ready():
	MapData.turn.connect(update_map)
	MapData.level_start.connect(initialize_map)
	
	pass # Replace with function body.

func clear_data():
	cells.clear()
	visited_rooms.clear()
	found_stair = false

func initialize_map():
	clear_data()
	var starting_cell = MapData.map[MapData.player_coords]
	var cell_group_id = starting_cell.get_id()
	var cell_type = starting_cell.get_type()
	stair_room_id = MapData.map[MapData.stair_coords].get_id()
	draw_room(cell_group_id, cell_type)
	set_cells_terrain_connect(0, cells, 0, 0)
	if found_stair:
		set_cell(0, MapData.stair_coords, 0, Vector2i(0, 3))
	pass

func update_map():
	var player_pos := MapData.player_coords
	var cell := MapData.get_player_cell()
	if cell.get_type() == MapData.CellType.room:
		if !in_room || !visited_rooms.has(cell.get_id()):
			visited_rooms.append(cell.get_id())
			draw_room(cell.get_id(), cell.get_type())
			in_room = true
			set_cells_terrain_connect(0, cells, 0, 0)
	else:
		#draw_corridor(player_pos)
		draw_open_corridor(player_pos)
		in_room = false
	if found_stair:
		set_cell(0, MapData.stair_coords, 0, Vector2i(0, 3))
	pass

func draw_room(cell_group_id: int , cell_type: MapData.CellType):
	cells = MapData.get_all_coordinates_of_group(cell_group_id, cell_type)
	drawn_cells.append_array(cells)
	for vector in cells:
		set_cell(0, vector, 0, Vector2i.ZERO, 1)
	check_for_room_exits()
	#set_cells_terrain_connect(0, cells, 0, 0)
	if cell_group_id == stair_room_id:
		found_stair = true
		set_cell(0, MapData.stair_coords, 0, Vector2i(0, 3))

func draw_corridor(player_pos: Vector2i):
	cells = []
	for x in range(player_pos.x - view_range, player_pos.x + view_range+1):
		for y in range(player_pos.y - view_range, player_pos.y + view_range+1):
			if MapData.map.get(Vector2i(x,y)):
				cells.append(Vector2i(x,y))
				set_cell(0, Vector2i(x,y), 0, Vector2i.ZERO, 1)
	#set_cells_terrain_connect(0, cells, 0, 0)

func draw_open_corridor(player_pos: Vector2i):
	cells = []
	for x in range(player_pos.x - view_range, player_pos.x + view_range+1):
		for y in range(player_pos.y - view_range, player_pos.y + view_range+1):
			if MapData.map.get(Vector2i(x,y)) && !drawn_cells.has(Vector2i(x,y)):
				if MapData.map.get(Vector2i(x,y)).get_type() == MapData.CellType.room:
					continue
				draw_open_cell(x,y)

func determine_cell(neighbors: Array[int]) -> Vector2i :
	var needed_cell_coords : Vector2i
	
	if neighbors.size() == 2:
		#only open corridors and corners
		if neighbors.has(Alignment.above):
			if neighbors.has(Alignment.below):
				return Vector2i(0,1)
			else: if neighbors.has(Alignment.left):
				return Vector2i(3,2)
			else: 
				return Vector2i(1,2)
		else: if neighbors.has(Alignment.below):
			if neighbors.has(Alignment.left):
				return Vector2i(3,0)
			else: 
				return Vector2i(1,0)
		else:
			return Vector2i(2,3)
	else:
		if neighbors.size() == 4: # only crossroads
			if neighbors.has(Alignment.above):
				if neighbors.has(Alignment.below) && neighbors.has(Alignment.left):
					return Vector2i(2,1)
		else:
			if neighbors.has(Alignment.left) && neighbors.has(Alignment.right):
				if neighbors.has(Alignment.above):
					return Vector2i(2,2)
				else:
					return Vector2i(2,0)
			else: if neighbors.has(Alignment.left):
				return Vector2i(3,1)
			else:
				return Vector2i(1,1)
	return Vector2i(0,3)

func draw_open_cell(x:int,y:int):
	var neighbors = check_for_neighbors(Vector2i(x,y))
	var needed_cell_coords : Vector2i = determine_cell(neighbors)
	set_cell(0, Vector2i(x,y), 0, needed_cell_coords)
	cells.append(Vector2i(x,y))
	drawn_cells.append(Vector2i(x,y))

func check_for_neighbors(cell:Vector2i) -> Array[int]:
	var neighbors : Array[int]
	if MapData.map.get(Vector2i(cell.x, cell.y-1)):
		neighbors.append(Alignment.above)
	if MapData.map.get(Vector2i(cell.x, cell.y+1)):
		neighbors.append(Alignment.below)
	if MapData.map.get(Vector2i(cell.x-1, cell.y)):
		neighbors.append(Alignment.left)
	if MapData.map.get(Vector2i(cell.x+1, cell.y)):
		neighbors.append(Alignment.right)
#	if MapData.map.get(Vector2i(cell.x+1, cell.y+1)):
#		neighbors.append(Alignment.right_down)
#	if MapData.map.get(Vector2i(cell.x+1, cell.y-1)):
#		neighbors.append(Alignment.right_up)
#	if MapData.map.get(Vector2i(cell.x-1, cell.y+1)):
#		neighbors.append(Alignment.left_down)
#	if MapData.map.get(Vector2i(cell.x-1, cell.y-1)):
#		neighbors.append(Alignment.left_up)
	return neighbors

func check_for_room_exits():
	var border = get_room_border()
	for cell in border:
		for x in range(cell.x - 1, cell.x + 2):
			for y in range(cell.y - 1, cell.y +2):
				if x == cell.x && y == cell.y:
					continue
				if MapData.map.get(Vector2i(x,y)):
					draw_open_cell(x,y)
					#cells.append(Vector2i(x,y))
					#set_cell(0, Vector2i(x,y), 0, Vector2i.ZERO, 1)
	
##Retruns array with the cell coordinates that mark the rooms border
func get_room_border() -> Array[Vector2i]:
	var border : Array[Vector2i]
	border.append(cells[0])
	var cols := [] # our array of arrays of cell collumns
	var col : Array[Vector2i]
	var start_coords = cells[0]
	if cells.find(Vector2i(start_coords.x, start_coords.y+1)) == -1 || cells[1].y > start_coords.y:
		border = get_organic_border(border, cols, col)
	else:
		border = get_rectangle_border(border, cols, col)
	return border
	# border getting for organic rooms

func get_rectangle_border(border, cols, col):
	for i in range(1, cells.size()):
		if cells[i].y == cells[i-1].y or col.size() == 0:
			col.append(cells[i])
		else:
			cols.append(col)
			if border.size() == 1:
				border.append_array(col)
			else:
				border.append(col[0])
				border.append(col[-1])
			col.clear()
			col.append(cells[i])
	border.append_array(cols[-1])
	return border

func get_organic_border(border, cols, col) -> Array[Vector2i]:
	for i in range(1, cells.size()):
		# we go down a coloumn and save the coords
		if cells[i].x == cells[i-1].x or col.size() == 0:
			col.append(cells[i])
		else:
			cols.append(col)
			if border.size() == 1:
				border.append_array(col)
			else:
				if col.size() <= cols[-2].size():
					border.append(col[0])
					border.append(col[-1])
				else:
					if col[0].y == cols[-2][0].y: 
						var difference = col.size() - cols[-2].size()
						for j in range(-(difference), 1):
							border.append(col[j])
					else:
						var prev_y = cols[-2][0].y
						if prev_y > col[0].y:
							border.append(col[0])
						else:
							var upper_diff = col[0].y - prev_y
							for j in range(upper_diff):
								border.append(col[j])
			col.clear()
			col.append(cells[i])
	border.append_array(cols[-1])
	return border

#func determine_cell(neighbors: Array[int]) -> Vector2i :
#	var needed_cell_coords : Vector2i
#	if neighbors.size() == 8:
#		return Vector2i(9,2)
#	if neighbors.size() == 7:
#		if !neighbors.has(Alignment.right_down):
#			return Vector2i(6,2)
#		if !neighbors.has(Alignment.right_up):
#			return Vector2i(6,1)
#		if !neighbors.has(Alignment.left_down):
#			return Vector2i(5,2)
#		if !neighbors.has(Alignment.left_up):
#			return Vector2i(5,1)
#
#	if neighbors.size() == 6:
#		if !neighbors.has(Alignment.right_down):
#			if !neighbors.has(Alignment.left_down):
#				return Vector2i(10, 3)
#			if !neighbors.has(Alignment.left_up):
#				return Vector2i(9, 1)
#			if !neighbors.has(Alignment.right_up):
#				return Vector2i(11, 1)
#		if !neighbors.has(Alignment.left_down):
#			if !neighbors.has(Alignment.left_up):
#				return Vector2i(8, 2)
#			if !neighbors.has(Alignment.right_up):
#				return Vector2i(10, 2)
#		if !neighbors.has(Alignment.right_up) && !neighbors.has(Alignment.left_up):
#			return Vector2i(9, 0)
#
#	if neighbors.size() == 5:
#		if !neighbors.has(Alignment.right_down):
#			if !neighbors.has(Alignment.left_down):
#				if !neighbors.has(Alignment.below):
#					return Vector2i(9, 3)
#				if !neighbors.has(Alignment.left_up):
#					return Vector2i(7, 0)
#				if !neighbors.has(Alignment.right_up):
#					return Vector2i(4, 0)
#			else:if !neighbors.has(Alignment.left_up): 
#				return Vector2i(4, 3)
#			else:
#				return Vector2i(11,2)
#		else: 
#			if !neighbors.has(Alignment.left_down):
#				if !neighbors.has(Alignment.right_up):
#					return Vector2i(7,3)
#				else: return Vector2i(8,1)
#			else: return Vector2i(10,0)
#
#	if neighbors.size() == 4:
#		if !neighbors.has(Alignment.right_up):
#			if !neighbors.has(Alignment.right_down):
#				if !neighbors.has(Alignment.left_down):
#					if !neighbors.has(Alignment.below):
#						return Vector2i(6, 3)
#					if !neighbors.has(Alignment.left_up):
#						return Vector2i(2, 1)
#					if !neighbors.has(Alignment.right):
#						return Vector2i(7, 2)
#				else: if !neighbors.has(Alignment.above):
#					return Vector2i(6, 0)
#				else: return Vector2i(7, 1)
#			else: if !neighbors.has(Alignment.above):
#				return Vector2i(5, 0)
#			else: return Vector2i(4,1)
#		else: if !neighbors.has(Alignment.below):
#			return Vector2i(5, 3)
#		else: return Vector2i(4, 2)
#
#	if neighbors.size() == 3:
#		if neighbors.has(Alignment.right_down):
#			return Vector2i(8, 0)
#		if neighbors.has(Alignment.left_up):
#			return Vector2i(11, 3)
#		if neighbors.has(Alignment.right_up):
#			return Vector2i(8, 3)
#		if neighbors.has(Alignment.left_down):
#			return Vector2i(11, 0)
#		if !neighbors.has(Alignment.left):
#			return Vector2i(1, 1)
#		if !neighbors.has(Alignment.below):
#			return Vector2i(2, 2)
#		if !neighbors.has(Alignment.right):
#			return Vector2i(3, 1)
#		else: return Vector2i(2,0)
#
#
#	if neighbors.size() == 2:
#		#only open corridors and corners
#		if neighbors.has(Alignment.above):
#			if neighbors.has(Alignment.below):
#				return Vector2i(0,1)
#			else: if neighbors.has(Alignment.left):
#				return Vector2i(3,2)
#			else: 
#				return Vector2i(1,2)
#		else: if neighbors.has(Alignment.below):
#			if neighbors.has(Alignment.left):
#				return Vector2i(3,0)
#			else: 
#				return Vector2i(1,0)
#		else:
#			return Vector2i(2,3)
#
#	if neighbors.size() == 1:
#		if neighbors.has(Alignment.above):
#			return Vector2i(0, 2)
#		if neighbors.has(Alignment.below):
#			return Vector2i(0, 0)
#		if neighbors.has(Alignment.left):
#			return Vector2i(3, 3)
#		if neighbors.has(Alignment.right):
#			return Vector2i(1, 3)
#
#	return Vector2i(0,3)
