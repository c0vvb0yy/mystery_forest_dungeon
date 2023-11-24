extends TileMap

@export var view_range := 2
var cells : Array[Vector2i]

var in_room := true

var stair_room_id : int

func _ready():
	MapData.turn.connect(update_map)
	MapData.level_start.connect(initialize_map)
	
	pass # Replace with function body.

func initialize_map():
	var starting_cell = MapData.map[MapData.player_coords]
	var cell_group_id = starting_cell.get_id()
	var cell_type = starting_cell.get_type()
	draw_room(cell_group_id, cell_type)
	stair_room_id = MapData.map[MapData.stair_coords].get_id()
	pass

func update_map():
	var player_pos = MapData.player_coords
	var cell = MapData.map[player_pos]
	if cell.get_type() == MapData.CellType.room:
		if !in_room:
			draw_room(cell.get_id(), cell.get_type())
			print("Fol")
			in_room = true
	else:
		draw_corridor(player_pos)
		in_room = false
	set_cells_terrain_connect(0, cells, 0, 0)
	pass

func draw_room(cell_group_id: int , cell_type: MapData.CellType):
	cells = MapData.get_all_coordinates_of_group(cell_group_id, cell_type)
	#cells.append_array(MapData.get_all_coordinates_of_group(cell_group_id, cell_type))
	for vector in cells:
		set_cell(0, vector, 0, Vector2i.ZERO, 1)
	check_for_room_exits()
	set_cells_terrain_connect(0, cells, 0, 0)
	if cell_group_id == stair_room_id:
		set_cell(0, MapData.stair_coords, 0, Vector2i(0, 3))

func draw_corridor(player_pos):
	for x in range(player_pos.x - view_range, player_pos.x + view_range):
		for y in range(player_pos.y - view_range, player_pos.y + view_range):
			if MapData.map.get(Vector2i(x,y)):
				cells.append(Vector2i(x,y))
				set_cell(0, Vector2i(x,y), 0, Vector2i.ZERO, 1)

func check_for_room_exits():
	var border = get_room_border()
	for cell in border:
		print(cell)
	

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
