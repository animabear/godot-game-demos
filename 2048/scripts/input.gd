extends Node2D

signal swipe(Vector2)

var has_swiped = false
var swipe_threshold = 100
var touch_start = Vector2.ZERO

func _input(event):
	if event is InputEventScreenTouch:
		var touch = event as InputEventScreenTouch
		if touch.is_pressed():
			touch_start = touch.position
		if touch.is_released():
			has_swiped = false
	elif event is InputEventScreenDrag and not has_swiped:
		var touch = event as InputEventScreenDrag
		var touch_end = touch.position
		var delta = touch_end - touch_start
		
		handle_swipe(delta)

func handle_swipe(delta: Vector2):
	# Horizontal swipe
	if abs(delta.x) > abs(delta.y):
		if delta.x > swipe_threshold:
			has_swiped = true
			swipe.emit(Vector2.RIGHT)
		elif delta.x < -swipe_threshold:
			has_swiped = true
			swipe.emit(Vector2.LEFT)
		return

	# Vertical swipe
	if delta.y > swipe_threshold:
		has_swiped = true
		swipe.emit(Vector2.DOWN)
	elif delta.y < -swipe_threshold:
		has_swiped = true
		swipe.emit(Vector2.UP)
	
	return
