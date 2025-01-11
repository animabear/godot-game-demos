class_name Inventory extends Control

const ROWS = 10
const COLS = 8

var slot_scene = preload("res://scenes/slot.tscn")
var item_scene = preload("res://scenes/item.tscn")

var grids = {} # map[grid_pos]slot

var item_held: Item = null
var current_slot: Slot = null
var can_place = false
var icon_anchor: Vector2i

@onready var grid_container: GridContainer = $ColorRect/MarginContainer/VBoxContainer/ScrollContainer/GridContainer
@onready var scroll_container: ScrollContainer = $ColorRect/MarginContainer/VBoxContainer/ScrollContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# add slot row by row in GridContainer
	for i in range(ROWS):
		for j in range(COLS):
			create_slot(Vector2i(j, i))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:	
	if item_held:
		if Input.is_action_just_pressed("mouse_right_click"):
			rotate_item()
		if Input.is_action_just_pressed("mouse_left_click"):
			place_item()
	else:
		if Input.is_action_just_pressed("mouse_left_click"):
			if scroll_container.get_global_rect().has_point(get_global_mouse_position()):
				pick_item()

func create_slot(grid_pos: Vector2i):
	var slot: Slot = slot_scene.instantiate()
	slot.grid_pos = grid_pos
	grid_container.add_child(slot)
	grids[grid_pos] = slot
	
	slot.slot_entered.connect(_on_slot_mouse_entered)
	slot.slot_exited.connect(_on_slot_mouse_exited)

func _on_slot_mouse_entered(slot: Slot):
	icon_anchor = Vector2i(10000, 10000)
	current_slot = slot
	if item_held:
		check_slot_available(current_slot)
		set_grids.call_deferred(current_slot)
	
func _on_slot_mouse_exited(slot: Slot):
	clear_grids()
	
	if not grid_container.get_global_rect().has_point(get_global_mouse_position()):
		current_slot = null

func _on_spawn_button_pressed() -> void:
	var item: Item = item_scene.instantiate()
	add_child(item)
	item.load_item(randi_range(1,4))
	item.selected = true
	item_held = item

func check_slot_available(slot: Slot) -> void:
	for grid_pos in item_held.item_grids:
		var slot_pos: Vector2i = slot.grid_pos + grid_pos

		if slot_pos.x < 0 or slot_pos.x >= COLS:
			can_place = false
			return
		if slot_pos.y < 0 or slot_pos.y >= ROWS:
			can_place = false
			return

		var target_slot: Slot = grids[slot_pos]
		if not target_slot.is_free():
			can_place = false
			return
	
	can_place = true

func set_grids(slot: Slot):
	for grid_pos in item_held.item_grids:
		var slot_pos: Vector2i = slot.grid_pos + grid_pos
		
		# cannot draw outside the inventory
		if slot_pos.x < 0 or slot_pos.x >= COLS:
			can_place = false
			continue
		if slot_pos.y < 0 or slot_pos.y >= ROWS:
			can_place = false
			continue

		var target_slot: Slot = grids[slot_pos]
		if can_place:
			target_slot.show_free()
			if slot_pos.x < icon_anchor.x:
				icon_anchor.x = slot_pos.x
			if slot_pos.y < icon_anchor.y:
				icon_anchor.y = slot_pos.y
		else:
			target_slot.show_taken()

func clear_grids():
	for grid_pos in grids:
		var slot: Slot = grids[grid_pos]
		slot.show_default()

func rotate_item():
	item_held.rotate_item()
	clear_grids()
	if current_slot:
		_on_slot_mouse_entered(current_slot)
		
func place_item():
	if not can_place or not current_slot:
		return
	
	# move item_held into grid_container
	item_held.get_parent().remove_child(item_held)
	grid_container.add_child(item_held)
	item_held.global_position = get_global_mouse_position()

	var placed_slot = grids[icon_anchor]
	item_held.snap_to(placed_slot.global_position)
	item_held.grid_anchor = current_slot
	
	# update slot state
	for grid_pos in item_held.item_grids:
		var slot_pos: Vector2i = current_slot.grid_pos + grid_pos
		var target_slot: Slot = grids[slot_pos]
		target_slot.set_taken()
		target_slot.item_stored = item_held
	
	item_held = null
	clear_grids()

func pick_item():
	if not current_slot or not current_slot.item_stored:
		return

	item_held = current_slot.item_stored
	item_held.selected = true

	# move item_held out of grid_container
	item_held.get_parent().remove_child(item_held)
	add_child(item_held)
	item_held.global_position = get_global_mouse_position()
	
	# update slot state
	for grid_pos in item_held.item_grids:
		var slot_pos: Vector2i = item_held.grid_anchor.grid_pos + grid_pos
		var target_slot: Slot = grids[slot_pos]
		target_slot.set_free()
		target_slot.item_stored = null

	check_slot_available(current_slot)
	set_grids.call_deferred(current_slot)
