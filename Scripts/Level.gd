extends Node

# Map Size
const MAP_WIDTH = 16
const MAP_HEIGHT = 9

const TILE_SIZE = 64
const TILE_OFFSET = TILE_SIZE * 0.5

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

# Coins
var coin_texture = preload("res://Textures/Coin.png")
var coins = [] # coin tile positions (Vector2)

func _ready():
	# Only 1 player tile
	assert($Map.get_used_cells_by_id(PLAYER_ID).size() == 1)
	# At least 1 box, and equal to number of coins
	var numBoxes = $Map.get_used_cells_by_id(BOX_ID).size()
	var numCoins = $Map.get_used_cells_by_id(COIN_ID).size()
	assert(numBoxes > 0)
	assert(numCoins > 0)
	assert(numBoxes == numCoins)
	
	# Replace coin tiles with sprites, store positions
	for pos in $Map.get_used_cells_by_id(COIN_ID):
		set_tile(pos, EMPTY_ID) # remove tile
		coins.append(pos) # add coin position to array
		# Add coin sprite
		var coin = Sprite.new()
		coin.set_texture(coin_texture)
		coin.position = pos * TILE_SIZE
		coin.position.x += TILE_OFFSET
		coin.position.y += TILE_OFFSET
		add_child(coin)

func _process(delta):
	# Do nothing if level is changing
	if Transitioner.transitioning: return
	
	if Input.is_action_just_released("reload_level"):
		Transitioner.reload_level()
	elif Input.is_action_just_released("ui_cancel"):
		Transitioner.go_to_main_menu()
	
	if Input.is_action_just_pressed("ui_left"):
		move_player(DIR_LEFT)
	elif Input.is_action_just_pressed("ui_right"):
		move_player(DIR_RIGHT)
	elif Input.is_action_just_pressed("ui_up"):
		move_player(DIR_UP)
	elif Input.is_action_just_pressed("ui_down"):
		move_player(DIR_DOWN)
		
	if has_won(): Transitioner.go_to_next_level()

# Returns true if the player has won the level.
func has_won(): return $Map.get_used_cells_by_id(BOX_ID).size() == 0

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
	var isBox = id == BOX_ID or id == LOCK_BOX_ID
	if id != EMPTY_ID and !isBox: return
	# check for box and if we can move it
	if isBox:
		if can_move_box(newBoxPos):
			# If moving to coin tile, set tile image to lock box, otherwise regular box
			var isCoin = coins.has(newBoxPos)
			set_tile(newPos, LOCK_BOX_ID if isCoin else BOX_ID)
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