extends Node2D

# tetrominoes
var i_0 = [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)]
var i_90 = [Vector2i(2, 0), Vector2i(2, 1), Vector2i(2, 2), Vector2i(2, 3)]
var i_180 = [Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2)]
var i_270 = [Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(1, 3)]
var i = [i_0, i_90, i_180, i_270]

var t_0 = [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]
var t_90 = [Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)]
var t_180 = [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)]
var t_270 = [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)]
var t = [t_0, t_90, t_180, t_270]

var o_0 = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
var o_90 = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
var o_180 = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
var o_270 = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
var o = [o_0, o_90, o_180, o_270]

var z_0 = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1)]
var z_90 = [Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)]
var z_180 = [Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)]
var z_270 = [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2)]
var z = [z_0, z_90, z_180, z_270]

var s_0 = [Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1)]
var s_90 = [Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)]
var s_180 = [Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2), Vector2i(1, 2)]
var s_270 = [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)]
var s = [s_0, s_90, s_180, s_270]

var l_0 = [Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]
var l_90 = [Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)]
var l_180 = [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2)]
var l_270 = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2)]
var l = [l_0, l_90, l_180, l_270]

var j_0 = [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]
var j_90 = [Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(1, 2)]
var j_180 = [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)]
var j_270 = [Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 2), Vector2i(1, 2)]
var j = [j_0, j_90, j_180, j_270]

var shapes = [i, t, o, z, s, l, j]
var shapes_full = shapes.duplicate()

const COLS = 10
const ROWS = 20

# movement
const START_POS = Vector2i(5, 0)
var cur_pos: Vector2i

const DIRECTION = {"left": Vector2i.LEFT, "right": Vector2i.RIGHT, "down": Vector2i.DOWN}
const STEPS_REQ = 50 # steps required to move
var steps = {"left": 0, "right": 0, "down": 0}

const ACCEL = 0.25
var speed: float

# game piece
var piece_type
var next_piece_type
var rotation_index = 0
var active_piece: Array

# tilemap
const TILE_ID = 0
var piece_atlas
var next_piece_atlas

# game score
const REWARD = 100
var score = 0

@onready var boardTileMap = $Board
@onready var activeTileMap = $Active

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	new_game()
	
	$HUD/StartButton.pressed.connect(new_game)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:	
	if Input.is_action_pressed("move_down"):
		steps["down"] += 10
	elif Input.is_action_pressed("move_left"):
		steps["left"] += 10
	elif Input.is_action_pressed("move_right"):
		steps["right"] += 10
	elif Input.is_action_just_pressed("rotate"):
		rotate_piece()
	
	# apply downward movement every frame
	steps["down"] += speed
	
	for dir in steps:
		if steps[dir] > STEPS_REQ:
			move_piece(DIRECTION[dir])
			steps[dir] = 0

func new_game():
	get_tree().paused = false

	clear_board()
	clear_piece(active_piece, cur_pos)
	clear_panel()
	$HUD/GameOverLabel.hide()
	speed = 1.0
	steps = {"left": 0, "right": 0, "down": 0}
	update_score(0)
	
	piece_type = pick_piece()
	piece_atlas = Vector2i(shapes_full.find(piece_type), 0) # different pieces have different colors
	
	next_piece_type = pick_piece()
	next_piece_atlas = Vector2i(shapes_full.find(next_piece_type), 0)
	
	create_piece()

func pick_piece():
	var piece
	if shapes.is_empty():
		shapes = shapes_full.duplicate()
	
	shapes.shuffle()
	piece = shapes.pop_front()
	return piece

func create_piece():
	rotation_index = 0
	cur_pos = START_POS
	active_piece = piece_type[rotation_index]
	
	# check for game over again
	if is_no_space_on_top(active_piece, cur_pos):
		game_over()
		return
	
	draw_piece(active_piece, cur_pos, piece_atlas)
	
	# update next piece review
	clear_panel()
	draw_piece(next_piece_type[rotation_index], Vector2i(15,6), next_piece_atlas)

func move_piece(direction):
	if can_move(active_piece, cur_pos + direction):
		clear_piece(active_piece, cur_pos)
		cur_pos += direction
		draw_piece(active_piece, cur_pos, piece_atlas)
		return

	if direction == Vector2i.DOWN:
		if check_game_over():
			game_over()
			return

		land_piece(active_piece, cur_pos, piece_atlas)
		check_rows()
		
		piece_type = next_piece_type
		piece_atlas = next_piece_atlas
		
		next_piece_type = pick_piece()
		next_piece_atlas = Vector2i(shapes_full.find(next_piece_type), 0)
		
		create_piece()

func rotate_piece():
	var next_rotation_index = (rotation_index + 1) % 4
	var next_active_piece = piece_type[next_rotation_index]
	
	var can_rotate_ret = can_rotate(active_piece, next_active_piece, cur_pos)
	var is_can_rotate = can_rotate_ret[0]
	var rotate_pos = can_rotate_ret[1]
	
	if is_can_rotate:
		clear_piece(active_piece, cur_pos)
		rotation_index = next_rotation_index
		active_piece = next_active_piece
		cur_pos = rotate_pos
		draw_piece(active_piece, cur_pos, piece_atlas)

func draw_piece(piece, pos, atlas):
	for i in piece:
		activeTileMap.set_cell(pos + i, TILE_ID, atlas)

func clear_piece(piece, pos):
	for i in piece:
		activeTileMap.erase_cell(pos + i)

# move piece from active layer to borad layer
func land_piece(piece, pos, atlas):
	for i in piece:	
		activeTileMap.erase_cell(pos + i)
		boardTileMap.set_cell(pos+i, TILE_ID, atlas)

func check_rows():
	var row = ROWS
	while row > 0:
		var count = 0
		for col in range(1, COLS + 1): # [1, cols]
			if not is_free(Vector2i(col, row)):
				count += 1

		if count == COLS:
			shift_rows(row)
			update_score(score + REWARD)
			speed += ACCEL
		else:
			row -= 1

func shift_rows(row):
	for r in range(row, 1, -1):
		for c in range(1, COLS + 1): # [1, cols]
			var atlas = boardTileMap.get_cell_atlas_coords(Vector2i(c, r-1))
			if atlas == Vector2i(-1, -1):
				boardTileMap.erase_cell(Vector2i(c, r))
			else:
				boardTileMap.set_cell(Vector2i(c, r), TILE_ID, atlas)

func update_score(value):
	score = value
	$HUD/ScoreLabel.text = "SCORE: %s" % value
	
func can_move(piece, next_pos):
	var is_can_move = true

	for i in piece:
		if not is_free(next_pos + i):
			is_can_move = false
			break

	return is_can_move

func can_rotate(active_piece, rotate_piece, cur_pos):
	var is_can_rotate = true
	var rotate_pos = cur_pos
	
	if can_move(rotate_piece, cur_pos):
		return [is_can_rotate, rotate_pos]

	if is_on_left_edge(active_piece, cur_pos):
		var next_rotate_pos = cur_pos + Vector2i(1, 0)
		while is_on_left_edge(rotate_piece, next_rotate_pos):
			if can_move(rotate_piece, next_rotate_pos):
				return [is_can_rotate, next_rotate_pos]
			next_rotate_pos += Vector2i(1, 0)
	
	if is_on_right_edge(active_piece, cur_pos):	
		var next_rotate_pos = cur_pos + Vector2i(-1, 0)
		while is_on_right_edge(rotate_piece, next_rotate_pos):
			if can_move(rotate_piece, next_rotate_pos):
				return [is_can_rotate, next_rotate_pos]
			next_rotate_pos += Vector2i(-1, 0)

	if is_on_top_edge(active_piece, cur_pos):
		var next_rotate_pos = cur_pos + Vector2i(0, 1)
		while is_on_top_edge(rotate_piece, next_rotate_pos):
			if can_move(rotate_piece, next_rotate_pos):
				return [is_can_rotate, next_rotate_pos]
			next_rotate_pos += Vector2i(0, 1)

	is_can_rotate = false
	return [is_can_rotate, rotate_pos]
	
func is_on_left_edge(piece, pos):
	var on_left_edge = false

	for i in piece:
		var draw_pos = pos + i
		if draw_pos.x <= 1:
			on_left_edge = true
			break
		
	return on_left_edge
	
func is_on_right_edge(piece, pos):
	var on_right_edge = false

	for i in piece:
		var draw_pos = pos + i
		if draw_pos.x >= COLS:
			on_right_edge = true
			break
		
	return on_right_edge
	
func is_on_top_edge(piece, pos):
	var on_top_edge = false

	for i in piece:
		var draw_pos = pos + i
		if draw_pos.y <= 1:
			on_top_edge = true
			break
		
	return on_top_edge

func is_free(pos):
	return boardTileMap.get_cell_source_id(pos) == -1
	
func is_no_space_on_top(piece, pos):
	var no_space_on_top = false

	for i in piece:
		var draw_pos = pos + i
		if not is_free(draw_pos) and draw_pos.y == 1:
			no_space_on_top = true

	return no_space_on_top

func clear_board():
	for row in range(1, ROWS+1):
		for col in range(1, COLS+1):
			boardTileMap.erase_cell(Vector2i(col, row))

func clear_panel():
	for col in range(14, 19):
		for row in range(5, 9):
			activeTileMap.erase_cell(Vector2i(col, row))

func check_game_over():
	var is_game_over = false
	
	for i in active_piece:
		var draw_pos = cur_pos + i
		if draw_pos.y <= 0:
			is_game_over = true
			break
	
	return is_game_over

func game_over():
	get_tree().paused = true
	$HUD/GameOverLabel.show()
