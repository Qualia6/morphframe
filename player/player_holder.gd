extends Control
class_name PlayerHolder

var last_mouse_position: Vector2
var middle_click_dragging: bool = false

func get_scroll_amount() -> float:
	var scroll_multiplier: float = Utils.fine_control_multiplier if Input.is_action_pressed("fine control") else 1
	return Utils.scroll_amount * scroll_multiplier

func get_zoom_amount() -> float:
	var zoom_multiplier: float = Utils.fine_zoom_control_multiplier if Input.is_action_pressed("fine control") else 1
	return Utils.zoom_amount * zoom_multiplier

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action("scroll up"):
		if Input.is_action_pressed("zoom scroll modifier"):
			zoom(get_zoom_amount())
		elif Input.is_action_pressed("left right scroll modifier"):
			$player.position.x += get_scroll_amount()
		else:
			$player.position.y += get_scroll_amount()
	elif event.is_action("scroll down"):
		if Input.is_action_pressed("zoom scroll modifier"):
			zoom(-get_zoom_amount())
		elif Input.is_action_pressed("left right scroll modifier"):
			$player.position.x -= get_scroll_amount()
		else:
			$player.position.y -= get_scroll_amount()
	elif event.is_action("editor drag"):
		if event.is_pressed():
			last_mouse_position = get_local_mouse_position()
			middle_click_dragging = true

func _input(event: InputEvent) -> void:
	if event.is_action_released("editor drag") and middle_click_dragging:
		drag()
		middle_click_dragging = false

func _physics_process(delta: float) -> void:
	if middle_click_dragging:
		drag()


func drag() -> void:
	var multiplier: float = Utils.fine_editor_drag_amount if Input.is_action_pressed("fine control") else 1
	var moved_amount: Vector2 = (get_local_mouse_position() - last_mouse_position) * multiplier
	$player.position += moved_amount
	
	# teleport mouse
	# NOTE: if player_holder is scaled or insided of something that scales it - this will break!!!!!!
	var warp_mouse: Vector2 = Vector2(0,0)
	if get_local_mouse_position().x < 0: 
		warp_mouse.x = size.x
	if get_local_mouse_position().x >= size.x:
		warp_mouse.x = -size.x
	if get_local_mouse_position().y < 0:
		warp_mouse.y = size.y
	if get_local_mouse_position().y >= size.y:
		warp_mouse.y = -size.y
	
	if warp_mouse != Vector2(0,0):
		Input.warp_mouse(get_viewport().get_mouse_position() + warp_mouse)
	
	last_mouse_position = get_local_mouse_position()

func zoom(amount: float) -> void:
	var mouse_position: Vector2 = get_local_mouse_position()
	var multiplier: float = exp(amount)
	$player.position = mouse_position - multiplier * (mouse_position - $player.position)
	$player.scale *= multiplier
