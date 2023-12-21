extends Node

@export var possible_enemies := [preload("res://Entities/Enemy/Bug.tscn"),
								preload("res://Entities/Enemy/hands.tscn")]
#: Array[PackedScene]

var enemy_queue := []
var index

func init():
	if !MapData.turn.is_connected(ordered_enemy_turn):
		MapData.turn.connect(ordered_enemy_turn)
	spawn_enemies()
	index = 0


func spawn_enemies():
	for i in range(min(DungeonManager.dungeon_floor, 3)):
		var enem = possible_enemies[randi()%possible_enemies.size()].instantiate()
		get_node("/root/BasicDungeon").add_child(enem)
		print("enemy spawned")

func register(enemy):
	enemy_queue.append(enemy)

func clear():
	enemy_queue.clear()

func ordered_enemy_turn():
	#for enemy in enemy_queue:
		#enemy.start_turn()
	enemy_queue[0].start_turn()

func next_enemy_turn():
	if index >= enemy_queue.size():
		index = 0
		return
	enemy_queue[index].start_turn()

