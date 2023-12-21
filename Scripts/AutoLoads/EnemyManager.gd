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

func de_register(enemy):
	enemy_queue.erase(enemy)

func clear():
	enemy_queue.clear()

func ordered_enemy_turn():
	#for enemy in enemy_queue:
		#enemy.start_turn()
	if enemy_queue.size() >0:
		if enemy_queue[0]==null:
			enemy_queue.erase(enemy_queue[0])
	if enemy_queue.size() > 0:
		enemy_queue[0].start_turn()
	#var null_enemies :=[]
	#for enemy in enemy_queue:
		#if enemy != null:
			#enemy.start_turn()
			#return
		#else:
			#null_enemies.append(enemy)
	#for null_enem in null_enemies:
		#enemy_queue.erase(null_enem)
	##enemy_queue[0].start_turn()

func next_enemy_turn():
	if index >= enemy_queue.size():
		index = 0
		return
	if enemy_queue[index] != null:
		enemy_queue[index].start_turn()
	else:
		var null_enemy = enemy_queue[index]
		enemy_queue.erase(null_enemy)
		next_enemy_turn()

