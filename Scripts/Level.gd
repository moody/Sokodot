extends Node

# Map Size
const MAP_WIDTH = 16
const MAP_HEIGHT = 9

const TILE_SIZE = 64

# Tile IDs
const EMPTY_ID = -1
const PLAYER_ID = 0
const WALL_ID = 1
const BOX_ID = 2
const COIN_ID = 3
const LOCK_BOX_ID = 4

# Directions
const DIR_LEFT = 0
const DIR_RIGHT = 1
const DIR_UP = 2
const DIR_DOWN = 3

# Levels
const MAX_LEVELS = 2 # update when adding new levels
var nextLevel

func _ready():
	# Map should not have coins
	assert($Map.get_used_cells_by_id(COIN_ID).size() == 0)
	# Only 1 player tile
	assert($Map.get_used_cells_by_id(PLAYER_ID).size() == 1)
	# At least 1 box, and equal to number of coins
	var numBoxes = $Map.get_used_cells_by_id(BOX_ID).size()
	var numCoins = $Coins.get_used_cells_by_id(COIN_ID).size()
	assert(numBoxes > 0)
	assert(numCoins > 0)
	assert(numBoxes == numCoins)
	
	# Get next level number
	var regex = RegEx.new()
	regex.compile("Level(\\d+).tscn")
	var result = regex.search(get_tree().current_scene.filename)
	if result:
		nextLevel = int(result.get_string(1)) + 1
		nextLevel = null if (nextLevel > MAX_LEVELS) else str(nextLevel)

func _process(delta):
	if Input.is_action_just_released("reload_level"):
		get_tree().reload_current_scene()
	elif Input.is_action_just_released("ui_cancel"):
		get_tree().change_scene("res://Scenes/MainMenu.tscn")
		
	if Input.is_action_just_pressed("ui_left"):
		move_player(DIR_LEFT)
	elif Input.is_action_just_pressed("ui_right"):
		move_player(DIR_RIGHT)
	elif Input.is_action_just_pressed("ui_up"):
		move_player(DIR_UP)
	elif Input.is_action_just_pressed("ui_down"):
		move_player(DIR_DOWN)
		
	if has_won():
		if nextLevel:
			get_tree().change_scene("res://Scenes/Levels/Level" + nextLevel + ".tscn")
		else:
			get_tree().change_scene("res://Scenes/MainMenu.tscn")

# Returns true if the player has won the level.
func has_won():
	var noBoxes = $Map.get_used_cells_by_id(BOX_ID).size() == 0
	var noCoins = $Map.get_used_cells_by_id(COIN_ID).size() == 0
	return noBoxes and noCoins

# Moves the player in the specified direction if possible.
func move_player(dir):
	var pos = $Map.get_used_cells_by_id(PLAYER_ID)[0]
	var newPos
	var newBoxPos
	
	match dir:
		DIR_LEFT:
			if (pos.x == 0): return
			newPos = Vector2(pos.x - 1, pos.y)
			newBoxPos = Vector2(pos.x - 2, pos.y)
		DIR_RIGHT:
			if (pos.x == MAP_WIDTH - 1): return
			newPos = Vector2(pos.x + 1, pos.y)
			newBoxPos = Vector2(pos.x + 2, pos.y)
		DIR_UP:
			if (pos.y == 0): return
			newPos = Vector2(pos.x, pos.y - 1)
			newBoxPos = Vector2(pos.x, pos.y - 2)
		DIR_DOWN:
			if (pos.y == MAP_HEIGHT - 1): return
			newPos = Vector2(pos.x, pos.y + 1)
			newBoxPos = Vector2(pos.x, pos.y + 2)
	
	# don't move unless tile is empty or is a box
	var id = $Map.get_cell(newPos.x, newPos.y)
	if id != EMPTY_ID and id != BOX_ID: return
	# check for box and if we can move it
	if id == BOX_ID:
		if can_move_box(newBoxPos):
			var isCoin = $Coins.get_cell(newBoxPos.x, newBoxPos.y) == COIN_ID
			if isCoin: set_tile(newPos, LOCK_BOX_ID) # change box to lockbox
			move_tile(newPos, newBoxPos) # move box
			move_tile(pos, newPos) # move player
	else:
		move_tile(pos, newPos)

# Sets a tile to a new tile id.
func set_tile(pos, id):
	$Map.set_cell(pos.x, pos.y, id)

# Moves a tile to a new position.
func move_tile(pos, newPos):
	var id = $Map.get_cell(pos.x, pos.y)
	set_tile(pos, EMPTY_ID)
	set_tile(newPos, id)

# Returns true if the box tile can be moved by the player.
func can_move_box(newPos):
	var validTile = $Map.get_cell(newPos.x, newPos.y) == EMPTY_ID
	var canMoveHorizontal = (newPos.x >= 0) and (newPos.x < MAP_WIDTH)
	var canMoveVertical = (newPos.y >= 0) and (newPos.y < MAP_HEIGHT)
	return validTile and canMoveHorizontal and canMoveVertical