extends Node2D

@onready
var label = $DamageNumber

func show_damage(damage:String):
	label.text = "-"+damage
	var tween = create_tween()
	tween.tween_property(self,"position", position + Vector2.UP*25, 1.5)
	tween.tween_property(self, "modulate:a", 0, 0.5).set_delay(0.75)
	tween.finished.connect(on_tween_finished)

func on_tween_finished():
	position = Vector2.ZERO
