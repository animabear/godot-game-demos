class_name UI extends CanvasLayer


@onready var points_label: Label = $MarginContainer/PointsLabel
@onready var game_over_box: BoxContainer = $MarginContainer/GameOverBox

func _ready():
	points_label.text = "%d" % 0
	
func update_points(points: int):
	points_label.text = "%d" % points

func on_game_over():
	game_over_box.show()

func _on_button_pressed() -> void:
	get_tree().reload_current_scene()
