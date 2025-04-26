extends Sprite2D

func _ready() -> void:
	# hide()
	pass

func _process(delta: float) -> void:
	self.position = get_viewport().get_mouse_position()
