extends RigidBody3D

func _process(delta: float) -> void:
	if position.y < -20:
		queue_free()
