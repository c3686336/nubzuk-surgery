extends Label

func _process(delta: float) -> void:
	text = "Time Left: %d" % $/root/Game/GameOverTimer.time_left
