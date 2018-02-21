extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _process(delta):
	if Input.is_action_just_released("ui_cancel"):
		get_tree().quit()

func _on_PlayButton_pressed():
	LevelTransition.transition("res://Scenes/Levels/Level1.tscn", "1")

func _on_ExitButton_pressed():
	get_tree().quit()
