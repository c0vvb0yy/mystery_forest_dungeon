extends Node2D

@export
var item_name : String

var location : Vector2i

func _ready():
	MapData.level_start.connect(spawn)

func spawn():
	location = MapData.get_random_coord_of_type(MapData.CellType.room, true)
	position = MapData.tile_map.map_to_local(location)
	MapData.map.get(location).set_content(self, MapData.CellContent.item)
	print("Item at: ", location)

func pick_up():
	if PlayerManager.held_item == null:
		PlayerManager.held_item = self
		remove_item_from_world()
	else: if PlayerManager.add_to_inventory(self):
		remove_item_from_world()

func remove_item_from_world():
	MapData.free_up_cell(location)
	$Sprite2D.visible = false

func use():
	$Effect.use()
	
