extends Node

const ITEM_DATA_PATH = "res://data/item_data.json"

var item_data = {}
var item_grid_data = {}

func _ready() -> void:
	load_data(ITEM_DATA_PATH)
	set_grid_data()

func load_data(path) -> void:
	if not FileAccess.file_exists(path):
		print("Item data file not found")
	
	var item_data_file = FileAccess.open(path, FileAccess.READ)
	item_data = JSON.parse_string(item_data_file.get_as_text())
	item_data_file.close()
	print(item_data)

func set_grid_data():
	for item_id in item_data.keys():
		var grid_pos_list = []
		for point in item_data[item_id]["Grid"].split("/"):
			var pos = point.split(",")
			grid_pos_list.append(Vector2i(int(pos[0]), int(pos[1])))
		item_grid_data[item_id] = grid_pos_list
	print(item_grid_data)
