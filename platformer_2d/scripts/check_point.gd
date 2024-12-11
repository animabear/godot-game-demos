extends Area2D

@export var level = 1

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		Main.switch_level(level + 1)
