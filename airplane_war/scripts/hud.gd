extends Control

func _ready() -> void:
	update_score(0)

func update_score(score):
	$Score.text = "Score: %s" % score
