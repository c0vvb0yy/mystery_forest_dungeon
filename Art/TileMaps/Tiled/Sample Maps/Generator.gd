class_name Generator

static func generate(level_size:Vector2, rooms_size: Vector2, rooms_max: int) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	
	var data := {}
	var rooms := []
	for r in range(rooms_max):
		var room := _get_random_room(level_size, rooms_size, rng)
		if _intersects(rooms, room):
			continue

		_add_room(data, rooms, room)
		if rooms.size() > 1:
			var room_previous: Room = rooms[-2]
			_add_connection(rng, data, room_previous, room)
	return data.keys()

static func _get_random_room(level_size: Vector2, rooms_size: Vector2, rng: RandomNumberGenerator) -> Room:
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
		data[point] = null


static func _add_connection(rng: RandomNumberGenerator, data: Dictionary, room1: Room, room2: Room) -> void:
	var room_center1 := (room1.position + room1.end) / 2
	var room_center2 := (room2.position + room2.end) / 2
	if rng.randi_range(0, 1) == 0:
		_add_corridor(data, room_center1.x, room_center2.x, room_center1.y, Vector2.AXIS_X)
		_add_corridor(data, room_center1.y, room_center2.y, room_center2.x, Vector2.AXIS_Y)
	else:
		_add_corridor(data, room_center1.y, room_center2.y, room_center1.x, Vector2.AXIS_Y)
		_add_corridor(data, room_center1.x, room_center2.x, room_center2.y, Vector2.AXIS_X)


static func _add_corridor(data: Dictionary, start: int, end: int, constant: int, axis: int) -> void:
	for t in range(min(start, end), max(start, end) + 1):
		var point := Vector2.ZERO
		match axis:
			Vector2.AXIS_X: point = Vector2(t, constant)
			Vector2.AXIS_Y: point = Vector2(constant, t)
		data[point] = null
