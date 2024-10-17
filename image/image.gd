extends TextureRect
class_name PlayerImage

var selected: bool = false:
	set(value):
		selected = value
		if selected:
			modulate = Color(0.5,0.5,0.5)
		else:
			modulate = Color(1.,1.,1.)



signal clicked

#func set_texture(texture: ImageTexture):
	#$image.texture = texture
	#$collision_shape.scale = texture.get_size()

func move_by(movement: Vector2):
	position += movement


func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("primary click") and event.is_pressed():
		clicked.emit()
		get_viewport().set_input_as_handled() #items with lower z-index will then ignore
