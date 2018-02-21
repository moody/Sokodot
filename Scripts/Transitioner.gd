extends CanvasLayer

# Constants
const LEVEL_PATH_FORMAT = "res://Scenes/Levels/Level_%d.tscn"
const MAIN_MENU_PATH = "res://Scenes/MainMenu.tscn"

# Level info
var levelNum = 0
var levelPath

# Transition info
var transitioning = false

# File
var directory

# Called once.
func _ready():
	directory = Directory.new()
	$Panel.hide()
	
	# For development only, allows us to start on any level
	var sceneFileName = get_tree().current_scene.filename
	if sceneFileName != MAIN_MENU_PATH:
		var regex = RegEx.new()
		regex.compile("Level_(\\d+).tscn")
		var result = regex.search(sceneFileName)
		if result:
			levelNum = int(result.get_string(1))
			levelPath = LEVEL_PATH_FORMAT % levelNum

# Transitions to the main menu.
func go_to_main_menu(labelText = ""):
	levelNum = 0
	levelPath = MAIN_MENU_PATH
	start("Transition", labelText)

# Transitions to the next level.
func go_to_next_level():
	levelNum += 1
	levelPath = LEVEL_PATH_FORMAT % levelNum
	
	if directory.file_exists(levelPath):
		start("Transition", "Level %d" % levelNum)
	else:
		go_to_main_menu("The End!")

# Reloads the current level (scene).
func reload_level(): start("Reload")

# Starts an animation.
func start(anim_name, labelText = ""):
	transitioning = true
	$Panel.get_node("Label").text = labelText
	$Panel.show()
	$AnimationPlayer.play(anim_name)

# Called during "Transition" animation.
func change_scene(): get_tree().change_scene(levelPath)
# Called during "Reload" animation.
func reload_scene(): get_tree().reload_current_scene()

# Called when an animation finishes.
func _on_AnimationPlayer_animation_finished(anim_name):
	transitioning = false
	$Panel.hide()