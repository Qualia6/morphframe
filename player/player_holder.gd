extends Control
class_name PlayerHolder

var previous_mouse_position: Vector2
var middle_click_dragging: bool = false

enum MouseAction {NONE, DRAGGING, SELECTING, POTENTIAL_DRAG}
var mouse_action = MouseAction.NONE


func _on_object_clicked(object: PlayerImage) -> void:
	if mouse_action == MouseAction.NONE:
		var should_drag: bool = $player.select_single(object)
		if should_drag: mouse_action = MouseAction.POTENTIAL_DRAG
		previous_mouse_position = get_local_mouse_position()


func get_scroll_amount() -> float:
	var scroll_multiplier: float = Utils.fine_control_multiplier if Input.is_action_pressed("fine control") else 1
	return Utils.scroll_amount * scroll_multiplier


func get_zoom_amount() -> float:
	var zoom_multiplier: float = Utils.fine_zoom_control_multiplier if Input.is_action_pressed("fine control") else 1
	return Utils.zoom_amount * zoom_multiplier


func _on_gui_input(event: InputEvent) -> void:	# happens after objects
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
			previous_mouse_position = get_local_mouse_position()
			middle_click_dragging = true
			
	elif event.is_action("primary click"): 
		if event.is_pressed() and mouse_action == MouseAction.NONE:
			mouse_action = MouseAction.SELECTING
			$player.start_selecting()
			get_viewport().set_input_as_handled()
		elif event.is_released() and mouse_action == MouseAction.SELECTING:
			mouse_action = MouseAction.NONE
			$player.stop_selecting()
			get_viewport().set_input_as_handled()


func _input(event: InputEvent) -> void: # happens before objects
	if event.is_action_released("editor drag") and middle_click_dragging:
		editor_drag()
		middle_click_dragging = false
	
	if event.is_action("primary click"):
		if event.is_released():
			if mouse_action == MouseAction.DRAGGING:
				var current_mouse_position: Vector2 = get_local_mouse_position()
				physics_drag()
				mouse_action = MouseAction.NONE
			if mouse_action == MouseAction.POTENTIAL_DRAG:
				mouse_action = MouseAction.NONE


func _physics_process(delta: float) -> void:
	if middle_click_dragging:
		editor_drag()

	match mouse_action:
		MouseAction.DRAGGING:
			physics_drag()
		MouseAction.SELECTING:
			physics_select()
		MouseAction.POTENTIAL_DRAG:
			physics_potential_drag()


const required_drag_distance_to_start_drag_squared: float = 10**2

func physics_potential_drag():
	if get_local_mouse_position().distance_squared_to(previous_mouse_position) > required_drag_distance_to_start_drag_squared:
		mouse_action = MouseAction.DRAGGING

func physics_select() -> void:
	$player/selection.second_point = $player.get_local_mouse_position()

func physics_drag() -> void:
	var movement = get_local_mouse_position() - previous_mouse_position
	$player.move_selection(movement / $player.scale)
	previous_mouse_position = get_local_mouse_position()


func editor_drag() -> void:
	var multiplier: float = Utils.fine_editor_drag_amount if Input.is_action_pressed("fine control") else 1
	var moved_amount: Vector2 = (get_local_mouse_position() - previous_mouse_position) * multiplier
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
	
	previous_mouse_position = get_local_mouse_position()


func zoom(amount: float) -> void:
	var mouse_position: Vector2 = get_local_mouse_position()
	var multiplier: float = exp(amount)
	$player.position = mouse_position - multiplier * (mouse_position - $player.position)
	$player.scale *= multiplier
