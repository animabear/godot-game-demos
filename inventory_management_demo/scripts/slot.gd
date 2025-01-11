class_name Slot extends TextureRect

signal slot_entered(slot)
signal slot_exited(slot)

enum State {
	DEFAULT,
	TAKEN,
	FREE
}

var state = State.DEFAULT
var grid_pos: Vector2i
var is_hovering = false
var item_stored = null

@onready var status_filter: ColorRect = $StatusFilter

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	if get_global_rect().has_point(get_global_mouse_position()):
		if not is_hovering:
			is_hovering = true
			slot_entered.emit(self)
	else:
		if is_hovering:
			is_hovering = false
			slot_exited.emit(self)

func set_default() -> void:
	state = State.DEFAULT

func show_default() -> void:
	status_filter.color = Color(Color.WHITE, 0.0)

func set_free() -> void:
	state = State.FREE

func show_free() -> void:
	status_filter.color = Color(Color.GREEN, 0.2)

func set_taken() -> void:
	state = State.TAKEN
	
func show_taken() -> void:
	status_filter.color = Color(Color.RED, 0.2)

func is_free() -> bool:
	return state == State.DEFAULT or state == State.FREE
