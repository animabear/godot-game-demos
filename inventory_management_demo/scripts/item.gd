class_name Item extends Node2D

var item_grids: Array[Vector2i] = []
var selected = false
var grid_anchor = null

@onready var icon: TextureRect = $Icon

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if selected:
		global_position = lerp(global_position, get_global_mouse_position(), 25 * delta)
	
func load_item(item_id: int) -> void:
	var item_name = DataHandler.item_data[str(item_id)]["Name"]
	var icon_path = "res://assets/%s.png" % item_name
	
	icon.texture = load(icon_path)
	
	for grid_pos: Vector2i in DataHandler.item_grid_data[str(item_id)]:
		item_grids.append(grid_pos)
	
func rotate_item():
	for i in item_grids.size():
		var grid_pos = item_grids[i]
		item_grids[i] = Vector2i(-grid_pos.y, grid_pos.x) # rotate 90 deg
	
	rotation_degrees += 90
	if rotation_degrees >= 360:
		rotation_degrees = 0

func snap_to(destination: Vector2):
	if int(rotation_degrees) % 180 == 0:
		destination += icon.size / 2
	else: # 90deg or 270deg
		var temp_size = Vector2(icon.size.y, icon.size.x)
		destination += temp_size / 2
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", destination, 0.15).set_trans(Tween.TRANS_SINE)
	selected = false
