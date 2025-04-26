extends Area3D

signal success

func on_slice():
	success.emit()
