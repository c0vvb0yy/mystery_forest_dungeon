class_name Room

var position := Vector2.ZERO : set = _no_op, get = get_position
var end:= Vector2.ZERO : set = _no_op, get = get_end
var center := Vector2.ZERO : set = _no_op, get = get_center
var _rect: Rect2

var _rect_area: float
var _iter_index: int

func _init(rect: Rect2) -> void:
	update(rect)

func _iter_init(_arg) -> bool:
	_iter_index = 0
	return _iter_is_running()

func _iter_next(_arg) -> bool:
	_iter_index += 1
	return _iter_is_running()

func _iter_get(_arg) -> Vector2:
	@warning_ignore("narrowing_conversion")
	var offset := Util.index_to_xy(_rect.size.x, _iter_index)
	return _rect.position + offset

func update(rect: Rect2) -> void:
	_rect = rect.abs()
	_rect_area = rect.get_area()

func intersects(room: Room) -> bool:
	return _rect.intersects(room._rect)

func get_position() -> Vector2:
	return _rect.position

func get_end() -> Vector2:
	return _rect.end

func get_center() -> Vector2:
	return 0.5 * (_rect.position + _rect.end)

func _iter_is_running() -> bool:
	return _iter_index < _rect_area

func _no_op(_val) -> void:
	pass
