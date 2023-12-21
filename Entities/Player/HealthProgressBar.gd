extends ProgressBar

func _ready():
	MapData.level_start.connect(init)
	PlayerManager.health_update.connect(update_health)

func init():
	max_value = PlayerManager.max_health
	update_health()

func update_health():
	value = PlayerManager.curr_health
