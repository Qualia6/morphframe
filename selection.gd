extends ColorRect

var first_point: Vector2 = Vector2(0,0):
		set(value):
			first_point = value
			update()
var second_point: Vector2 = Vector2(0,0):
		set(value):
			second_point = value
			update()

var min: Vector2 = Vector2(0,0)
var max: Vector2 = Vector2(0,0)

func update() -> void:
	min = first_point.min(second_point)
	max = first_point.max(second_point)
	position = min
	size = max - min

func _ready() -> void:
	visible = false
