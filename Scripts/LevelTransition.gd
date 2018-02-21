extends CanvasLayer

# Current scene path
var currentPath
var transitioning = false

func _ready():
	$Panel.hide()

# Called to start transition to next level
func transition(scenePath, levelNum):
	currentPath = scenePath
	transitioning = true
	$Panel.get_node("Label").text = "Level " + levelNum
	$Panel.show()
	$AnimationPlayer.play("Transition")
	
# Called to reload the current level
func reload():
	transitioning = true
	$Panel.get_node("Label").text = ""
	$Panel.show()
	$AnimationPlayer.play("Reload")

# Called during "Transition"
func change_scene():
	get_tree().change_scene(currentPath)

# Called during "Reload"
func reload_scene():
	get_tree().reload_current_scene()

# Called when the transition finishes
func _on_AnimationPlayer_animation_finished( anim_name ):
	transitioning = false
	$Panel.hide()