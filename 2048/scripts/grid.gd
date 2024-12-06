extends Node2D

@export var rows = 4
@export var cols = 4
@export var cell_dim = 32

const INVALID_GRID_POS = Vector2(-1, -1)

var grid_cell_prefab = preload("res://scenes/grid_cell.tscn")
var tile_prefab = preload("res://scenes/tile.tscn")

var grid = {} # map[grid_pos]tile
var origin = Vector2.ZERO

var is_sliding = false

var score = 0

@onready var swipe_sound = get_parent().get_node("SFX").get_node("SwipeSound")
@onready var spawn_sound = get_parent().get_node("SFX").get_node("SpawnSound")
@onready var merge_sound = get_parent().get_node("SFX").get_node("MergeSound")


func spawn_prefab(prefab, pos):
	var instance = prefab.instantiate()
	instance.position = get_pos(pos)
	add_child(instance)
	return instance

# Get world position from grid position
func get_pos(grid_pos: Vector2) -> Vector2:
	return origin + cell_dim * grid_pos + 0.5 * Vector2(cell_dim, cell_dim)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var grid_dim = cell_dim * Vector2(cols, rows)
	origin = 0.5 * get_viewport_rect().size - 0.5 * grid_dim
  
	# Spawn grid cells
	for i in range(cols):
		for j in range(rows):
			spawn_prefab(grid_cell_prefab, Vector2(i,j))
	
	# Spawn test tile
	add_tile()
	add_tile()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_input_swipe(direction: Vector2) -> void:
	if is_sliding:
		return
		
	# swipe_sound.play()

	# print("Swiped: ", direction)
	clear_merged_flags()
	slide_tiles(direction)
	add_tile()

	is_sliding = true
	await get_tree().create_timer(0.5).timeout
	is_sliding = false

func slide_tiles(direction: Vector2):
	# from left to right
	if direction == Vector2.LEFT:
		for i in range(cols):
			for j in range(rows):
				var tile_pos = Vector2(i,j)
				if get_tile(tile_pos):
					slide_tile(tile_pos, direction)
	# from right to left
	elif direction == Vector2.RIGHT:
		for i in range(cols-1, -1, -1):
			for j in range(rows):
				var tile_pos = Vector2(i,j)
				if get_tile(tile_pos):
					slide_tile(tile_pos, direction)
	# from top to bottom
	elif direction == Vector2.UP:
		for j in range(rows):
			for i in range(cols):
				var tile_pos = Vector2(i,j)
				if get_tile(tile_pos):
					slide_tile(tile_pos, direction)
	# from bottom to top
	elif direction == Vector2.DOWN:
		for j in range(rows-1, -1, -1):
			for i in range(cols):
				var tile_pos = Vector2(i,j)
				if get_tile(tile_pos):
					slide_tile(tile_pos, direction)

func slide_tile(grid_pos:Vector2, direction: Vector2):
	var last_empty = find_last_empty_cell(grid_pos, direction)
	
	# print("Last empty cell: ", last_empty)
	
	var tile = get_tile(grid_pos)
	var should_merge = false
	
	var grid_pos_merged = last_empty + direction
	if is_should_merge(tile, grid_pos_merged):
		should_merge = true
	
	# Update tile world position
	if should_merge:
		var tile_merged = get_tile(grid_pos_merged)
		tile_merged.has_merged = true
		tile.has_merged = true
		
		score += tile.value * 2
		# print("Score: ", score)
		
		# Remove tile on grid
		grid.erase(grid_pos)
		
		tile.animate_position(get_pos(grid_pos_merged), true)
		tile_merged.merge()
		
		merge_sound.play()
	else:
		# Move tile on grid
		move_tile(grid_pos, last_empty)
		tile.animate_position(get_pos(last_empty), false)
		
func is_should_merge(tile: Tile, grid_pos_merged: Vector2) -> bool:
	if (not out_of_bounds(grid_pos_merged) 
		and grid.has(grid_pos_merged)
		and grid[grid_pos_merged].value == tile.value
		and tile.has_merged == false
		and grid[grid_pos_merged].has_merged == false):
			return true

	return false

func random_grid_pos() -> Vector2:
	var empty_grid_pos_arr = []
	
	for i in range(cols):
		for j in range(rows):
			var empty_grid_pos = Vector2(i,j)
			if not grid.has(empty_grid_pos):
				empty_grid_pos_arr.push_back(empty_grid_pos)
	
	var size = empty_grid_pos_arr.size()
	if size > 0:
		var randomIndex = randi_range(0, size - 1)
		return empty_grid_pos_arr[randomIndex]

	return INVALID_GRID_POS

func add_tile():
	var grid_pos = random_grid_pos()	
	if grid_pos == INVALID_GRID_POS:
		print("Game Over: Score=", score) # TODO: show game over UI
		return
	
	var tile: Tile = spawn_prefab(tile_prefab, grid_pos)
	grid[grid_pos] = tile

	tile.animate_spawn()
	spawn_sound.play()
	

func get_tile(grid_pos: Vector2) -> Tile:
	if grid.has(grid_pos):
		return grid[grid_pos]
	return null

# Assumes from and to exist in the dictionary
func move_tile(from: Vector2, to: Vector2):
	var temp = grid[from]
	grid.erase(from)
	grid[to] = temp
	
func out_of_bounds(grid_pos: Vector2) -> bool:
	if grid_pos.x < 0 or grid_pos.x >= cols:
		return true
	if grid_pos.y < 0 or grid_pos.y >= rows:
		return true
	return false
	
func find_last_empty_cell(grid_pos: Vector2, direction: Vector2) -> Vector2:
	var pos = grid_pos + direction
	var tile = get_tile(pos)
	
	while not tile and not out_of_bounds(pos):
		pos += direction
		tile = get_tile(pos)
	
	return pos - direction
	
func clear_merged_flags():
	for grid_pos in grid:
		grid[grid_pos].has_merged = false
