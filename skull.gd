extends Area3D

signal fail

func on_slice(clickpos: Vector3):
	fail.emit(clickpos)
