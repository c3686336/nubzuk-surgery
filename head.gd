extends Area3D

signal success

func on_slice(clickpos: Vector3):
	success.emit(clickpos)
