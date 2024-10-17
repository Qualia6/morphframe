class_name Utils

static func is_in_bounds(value: Vector2, min: Vector2, max: Vector2) -> bool:
	return value.x >= min.x and value.y >= min.y and value.x <= max.x and value.y <= max.y
	
const scroll_amount: float = 35
const fine_control_multiplier: float = 0.14
const zoom_amount: float = 0.1
const fine_zoom_control_multiplier: float = fine_control_multiplier
const fine_editor_drag_amount: float = fine_control_multiplier


#enum SelectionMode {NORMAL, ADD, REMOVE, XOR}
#static func get_selection_mode() -> SelectionMode:
	#if Input.is_action_pressed("add to selection"):
		#if Input.is_action_pressed("remove from selection"):
			#return SelectionMode.XOR
		#else:
			#return SelectionMode.ADD
	#else:
		#if Input.is_action_pressed("remove from selection"):
			#return SelectionMode.REMOVE
		#else:
			#return SelectionMode.NORMAL
