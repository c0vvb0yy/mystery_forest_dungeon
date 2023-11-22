extends Camera2D

@export var target : Node
# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	self.position = lerp(self.position, target.position, 0.999)
	#self.position.clamp(target.position - Vector2(50,50), target.position + Vector2(50,50))
	pass
