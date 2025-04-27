extends RigidBody3D

@onready var globals = $"/root/Globals"

func _process(delta: float) -> void:
	if position.dot(position) > globals.max_pos_sq:
		queue_free()
