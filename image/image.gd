extends Node2D
class_name PlayerImage

var selection_indicator_animation:float = 0

var selected: bool = false:
	set(value):
		selected = value
		if selected:
			selection_indicator_animation = 0
		else:
			$Image.modulate = Color(1.,1.,1.)

func _process(delta: float) -> void:
	if selected:
		selection_indicator_animation += delta
		if selection_indicator_animation > 1:
			selection_indicator_animation -= 1
		
		var a: float
		if selection_indicator_animation > 0.8:
			a = 1
		elif selection_indicator_animation > 0.4:
			a = selection_indicator_animation/2+0.6
		else:
			a = 1.-selection_indicator_animation/2
		$Image.modulate = Color(a,a,a)


signal clicked


func set_texture(texture: ImageTexture):
	$Image.texture = texture
	$Image.size = texture.get_size()


var previous_transform: Transform2D = transform
var previous_position: Vector2 = position

func set_previous() -> void:
	previous_position = position
	previous_transform = transform

func move_by(movement: Vector2):
	position = movement + previous_position

func resize(orgin: Vector2, change: Vector2):
	transform = previous_transform.scaled(change)
	position = (previous_position - orgin) * change + orgin

func do_rotation(orgin: Vector2, angle: float):
	transform = previous_transform.translated(-orgin).rotated(angle).translated(orgin)
	
func do_shear(orgin: Vector2, amount: float):
	#omg this took a couple hours till i subled on the correct result
	# why the hell is one 1 0 -a 1 and the other 1 -a 0 1? the hell i know
	# but it finnnnnaaallllllyyy works omg
	transform = (previous_transform * Transform2D(Vector2(1,0),Vector2(-amount,1),Vector2(0,0)))
	position = (previous_position-orgin)* Transform2D(Vector2(1,-amount),Vector2(0,1),Vector2(0,0)) + orgin

func _on_image_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("primary click") and event.is_pressed():
		clicked.emit()
		get_viewport().set_input_as_handled() #items with lower z-index will then ignore


func get_corners() -> Array: # Array<Vector2, Vector2, Vector2, Vector2>
	return [
		transform * (Vector2(0,0) * $Image.size),
		transform * (Vector2(1,0) * $Image.size),
		transform * (Vector2(0,1) * $Image.size),
		transform * (Vector2(1,1) * $Image.size)
	]


func get_bounding_rect() -> Rect2:
	var corners = get_corners()
	@warning_ignore("shadowed_global_identifier")
	var min: Vector2 = corners[0].min(corners[1]).min(corners[2]).min(corners[3])
	@warning_ignore("shadowed_global_identifier")
	var max: Vector2 = corners[0].max(corners[1]).max(corners[2]).max(corners[3])
	return Rect2(min, max-min)


func get_center() -> Vector2:
	var combined_scale: Vector2 = scale * $Image.size
	var skew_delta: Vector2 = Vector2(-sin(skew),cos(skew))
	var bottom_left_offset: Vector2 = Vector2(combined_scale.x, 0) + skew_delta * combined_scale.y
	return position + bottom_left_offset / 2
