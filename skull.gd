extends Area3D

signal fail

func on_slice():
	fail.emit()
