extends Control

func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()

func set_score(score):
	$Panel/Score.text = "SCORE: %s" % score

func set_high_score(score):
	$Panel/HighScore.text = "HI-SCORE: %s" % score
