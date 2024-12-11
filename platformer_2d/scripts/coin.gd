class_name Coin extends Area2D

signal collected

func _on_body_entered(body: Node2D) -> void:
	#print("+1 coin!")
	collected.emit()
	queue_free()
