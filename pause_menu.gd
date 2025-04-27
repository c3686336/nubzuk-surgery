extends VBoxContainer

signal unpause
signal pause

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused:
			unpause.emit()
		else:
			pause.emit()
