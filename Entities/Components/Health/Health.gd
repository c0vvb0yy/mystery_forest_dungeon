extends Node2D

signal died

@export
var max_health : int
var curr_health : int

@onready
var damage_label = $DamageIndicator

func _ready():
	init_health()

func init_health():
	curr_health = max_health

func heal(healing: int):
	curr_health += healing
	
	if curr_health >= max_health:
		curr_health = max_health

func take_damage(damage:int):
	curr_health -= damage
	damage_label.show_damage(str(damage))
	if curr_health <= 0:
		die()

func die():
	emit_signal("died")
	var parent = get_parent()
	MapData.map[parent.current_coords].set_content(null, MapData.CellContent.free)
	parent.die()
	#parent.queue_free()
