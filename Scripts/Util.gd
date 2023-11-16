class_name Util

static func _less_vector_x(v1: Vector2, v2: Vector2) -> bool:
	return v1.x < v2.x

static func _less_vector_y(v1: Vector2, v2: Vector2) -> bool:
	return v1.y < v2.y

static func index_to_xy(width: int, index: int) -> Vector2:
	@warning_ignore("integer_division")
	return Vector2(index % width, index / width)
