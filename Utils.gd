class_name Utils

static func is_in_bounds(value: Vector2, min: Vector2, max: Vector2) -> bool:
	return value.x >= min.x and value.y >= min.y and value.x <= max.x and value.y <= max.y

const scroll_amount: float = 35
const fine_control_multiplier: float = 0.14
const zoom_amount: float = 0.1
const fine_zoom_control_multiplier: float = fine_control_multiplier
const fine_drag_multiplier: float = fine_control_multiplier
const discrete_transform_multiplier: float = 0.5
const fine_discrete_transform_multiplier: float = 0.1666666667
const discrete_rotate_angle: float = PI/4
const fine_discrete_rotate_angle: float = PI/24

const required_drag_distance_to_start_drag: float = 10

const mouse_border_warpping: bool = true
