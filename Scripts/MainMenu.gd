extends Node

func _process(delta):
	if Input.is_action_just_released("ui_cancel"):
		get_tree().quit()

func _on_PlayButton_pressed():
	Transitioner.go_to_next_level()

func _on_ExitButton_pressed():
	get_tree().quit()
