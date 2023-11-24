class_name Generator

static func generate(level_size:Vector2i, rooms_size: Vector2i, rooms_max: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	
	var data := {}
	var rooms := []
	var corridors := []
	for r in range(rooms_max):
		var room := _get_random_room(level_size, rooms_size, rng)
		if _intersects(rooms, room):
			continue

		_add_room(data, rooms, room)
		if rooms.size() > 1:
			var room_previous: Room = rooms[-2]
			_add_connection(rng, data, room_previous, room, corridors)
	
	return data

static func _get_random_room(level_size: Vector2i, rooms_size: Vector2i, rng: RandomNumberGenerator) -> Room:
	var width := rng.randi_range(rooms_size.x, rooms_size.y)
	var height := rng.randi_range(rooms_size.x, rooms_size.y)
	var x := rng.randi_range(0, level_size.x - width - 1)
	var y := rng.randi_range(0, level_size.y - height - 1)
	var rect := Rect2(x, y, width, height)
	return Room.new(rect) if rng.randi_range(0, 1) == 0 else RoomOrganic.new(rect)

static func _intersects(rooms: Array, room: Room) -> bool:
	var out := false
	for room_other in rooms:
		if room.intersects(room_other):
			out = true
			break
	return out

static func _add_room(data: Dictionary, rooms: Array, room: Room) -> void:
	rooms.push_back(room)
	for point in room:
		point = Vector2i(point)
		data[Vector2i(point)] = Cell.new(point,  MapData.CellType.room, MapData.CellContent.free, rooms.size()-1)
		


@warning_ignore("narrowing_conversion")
static func _add_connection(rng: RandomNumberGenerator, data: Dictionary, room1: Room, room2: Room, corridors: Array) -> void:
	var room_center1 := room1.get_center()
	var room_center2 := room2.get_center()
	if rng.randi_range(0, 1) == 0:
		_add_corridor(data, room_center1.x, room_center2.x, room_center1.y, Vector2i.AXIS_X, corridors)
		_add_corridor(data, room_center1.y, room_center2.y, room_center2.x, Vector2i.AXIS_Y, corridors)
	else:
		_add_corridor(data, room_center1.y, room_center2.y, room_center1.x, Vector2i.AXIS_Y, corridors)
		_add_corridor(data, room_center1.x, room_center2.x, room_center2.y, Vector2i.AXIS_X, corridors)


static func _add_corridor(data: Dictionary, start: int, end: int, constant: int, axis: int, corridors: Array) -> void:
	var corridor :=[]
	for t in range(min(start, end), max(start, end) + 1):
		var point := Vector2i.ZERO
		match axis:
			Vector2i.AXIS_X: corridor.append(Vector2i(t, constant))
			Vector2i.AXIS_Y: corridor.append(Vector2i(constant, t))
	corridors.append(corridor)
	for point in corridors[-1]:
		if(data.get(point)):
			if(data[point].get_type() != MapData.CellType.room):
				data[point] = Cell.new(point,  MapData.CellType.corridor, MapData.CellContent.free, corridors.size()-1)
		else:
			data[point] = Cell.new(point,  MapData.CellType.corridor, MapData.CellContent.free, corridors.size()-1)
#static func _add_corridor(data: Dictionary, start: int, end: int, constant: int, axis: int) -> void:
#	for t in range(min(start, end), max(start, end) + 1):
#		var point := Vector2i.ZERO
#		match axis:
#			Vector2i.AXIS_X: point = Vector2i(t, constant)
#			Vector2i.AXIS_Y: point = Vector2i(constant, t)
#
#		if(data.get(point)):
#			if(data[point].get_type() != MapData.CellType.room):
#				data[point] = Cell.new(point,  MapData.CellType.corridor, MapData.CellContent.free)
#		else:
#			data[point] = Cell.new(point,  MapData.CellType.corridor, MapData.CellContent.free)
