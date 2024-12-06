extends Control
class_name PlayerHolder

var previous_player_position: Vector2

var middle_click_dragging: bool = false

var previous_mouse_position: Vector2
var accumulated_drag: Vector2 = Vector2(0,0)
var starting_mouse_position: Vector2

var previous_mouse_editor_position: Vector2
var accumulated_editor_drag: Vector2 = Vector2(0,0)
var starting_mouse_editor_position: Vector2

enum MouseAction {NONE, DRAGGING, SELECTING, POTENTIAL_DRAG, RESIZE}
var mouse_action = MouseAction.NONE

enum ResizeMode {UP, LEFT, RIGHT, DOWN, UP_LEFT, UP_RIGHT, DOWN_LEFT, DOWN_RIGHT, ROTATE, SHEAR}
var resize_mode = ResizeMode.DOWN_RIGHT

var resizing_orgin: Vector2


func _on_object_clicked(object: PlayerImage) -> void:
	if mouse_action == MouseAction.NONE:
		var should_drag: bool = $player.select_single(object)
		if should_drag: 
			mouse_action = MouseAction.POTENTIAL_DRAG
			start_transform_selection()
			


func start_editor_drag():
	starting_mouse_editor_position = get_local_mouse_position()
	previous_mouse_editor_position = get_local_mouse_position()
	accumulated_editor_drag = Vector2(0,0)
	starting_mouse_position = $player.get_local_mouse_position()
	previous_mouse_position = $player.get_local_mouse_position()
	accumulated_drag = Vector2(0,0)
	previous_player_position = $player.position
	
func start_selecting():
	starting_mouse_editor_position = get_local_mouse_position()
	previous_mouse_editor_position = get_local_mouse_position()
	accumulated_editor_drag = Vector2(0,0)
	starting_mouse_position = $player.get_local_mouse_position()
	previous_mouse_position = $player.get_local_mouse_position()
	accumulated_drag = Vector2(0,0)

func start_transform_selection():
	starting_mouse_editor_position = get_local_mouse_position()
	previous_mouse_editor_position = get_local_mouse_position()
	accumulated_editor_drag = Vector2(0,0)
	starting_mouse_position = $player.get_local_mouse_position()
	previous_mouse_position = $player.get_local_mouse_position()
	accumulated_drag = Vector2(0,0)
	$player.start_transform_selection()


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
			start_editor_drag()
			middle_click_dragging = true
			
	elif event.is_action("primary click"): 
		if event.is_pressed() and mouse_action == MouseAction.NONE:
			mouse_action = MouseAction.SELECTING
			start_selecting()
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
	
	if event.is_action_released("primary click"):
		if mouse_action == MouseAction.DRAGGING:
			accumulate_drag()
			physics_drag()
			mouse_action = MouseAction.NONE
		if mouse_action == MouseAction.POTENTIAL_DRAG:
			mouse_action = MouseAction.NONE
		if mouse_action == MouseAction.RESIZE:
			accumulate_drag()
			physics_resize()
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
		MouseAction.RESIZE:
			physics_resize()
	
	if ((mouse_action != MouseAction.NONE) or middle_click_dragging) and Utils.mouse_border_warpping:
		potential_mouse_warp()
	
	accumulate_drag()


func accumulate_drag():
	var multiplier = Utils.fine_drag_multiplier if Input.is_action_pressed("fine control") else 1
	accumulated_editor_drag += (previous_mouse_editor_position - get_local_mouse_position()) * multiplier
	previous_mouse_editor_position = get_local_mouse_position()
	accumulated_drag += (previous_mouse_position - $player.get_local_mouse_position()) * multiplier
	previous_mouse_position = $player.get_local_mouse_position()


func physics_potential_drag():
	if accumulated_drag.length() > Utils.required_drag_distance_to_start_drag :
		start_transform_selection()
		mouse_action = MouseAction.DRAGGING

func physics_select() -> void:
	$player/selector.second_point = $player/selector.first_point - accumulated_drag

func physics_drag() -> void:
	$player.move_selection(-accumulated_drag)


func potential_mouse_warp() -> void:	
	# teleport mouse
	# NOTE: if player_holder is scaled or insided of something that scales it - this will break!!!!!!
	var warp_mouse: Vector2 = Vector2(0,0)
	if get_local_mouse_position().x < 1: 
		warp_mouse.x = size.x - 2
	if get_local_mouse_position().x >= size.x - 1:
		warp_mouse.x = -size.x + 2
	if get_local_mouse_position().y < 1:
		warp_mouse.y = size.y - 2
	if get_local_mouse_position().y >= size.y - 1:
		warp_mouse.y = -size.y + 2
	
	if warp_mouse != Vector2(0,0):
		Input.warp_mouse(get_viewport().get_mouse_position() + warp_mouse)
		previous_mouse_editor_position = get_local_mouse_position()
		previous_mouse_position = $player.get_local_mouse_position()


func editor_drag() -> void:
	$player.position = previous_player_position - accumulated_editor_drag 


func zoom(amount: float) -> void:
	var mouse_position: Vector2 = get_local_mouse_position()
	var multiplier: float = exp(amount)
	if (middle_click_dragging):
		accumulated_editor_drag = previous_player_position - multiplier * (mouse_position - previous_player_position + accumulated_editor_drag) - mouse_position
	$player.position = mouse_position - multiplier * (mouse_position - $player.position)
	$player.scale *= multiplier
	$player/selection_box.update_size()


func _on_resize_gui_input(event: InputEvent, mode: ResizeMode) -> void:
	if event.is_action_pressed("primary click") and event.is_pressed() and mouse_action == MouseAction.NONE:
		start_transform_selection()
		mouse_action = MouseAction.RESIZE
		resize_mode = mode
		set_resizing_orgin()
		get_viewport().set_input_as_handled()


func set_resizing_orgin():
	resizing_orgin = $player/selection_box.position
	match resize_mode:
		PlayerHolder.ResizeMode.UP_LEFT:
			resizing_orgin += $player/selection_box.size
		PlayerHolder.ResizeMode.UP_RIGHT:
			resizing_orgin.y += $player/selection_box.size.y
		PlayerHolder.ResizeMode.DOWN_LEFT:
			resizing_orgin.x += $player/selection_box.size.x
		PlayerHolder.ResizeMode.DOWN_RIGHT:
			pass
		PlayerHolder.ResizeMode.UP:
			resizing_orgin += $player/selection_box.size
		PlayerHolder.ResizeMode.LEFT:
			pass
		PlayerHolder.ResizeMode.DOWN:
			pass
		PlayerHolder.ResizeMode.RIGHT:
			resizing_orgin += $player/selection_box.size
		_:
			resizing_orgin += $player/selection_box.size / 2


func physics_resize():
	if resize_mode == PlayerHolder.ResizeMode.ROTATE:
		var angle: float = (starting_mouse_position - accumulated_drag - resizing_orgin).angle() + PI/2
		
		if Input.is_action_pressed("discrete transform"):
			if Input.is_action_pressed("fine control"):
				angle /= Utils.fine_discrete_rotate_angle
			else:
				angle /= Utils.discrete_rotate_angle
			angle = roundf(angle)
			if Input.is_action_pressed("fine control"):
				angle *= Utils.fine_discrete_rotate_angle
			else:
				angle *= Utils.discrete_rotate_angle
		
		$player.rotate_selection(resizing_orgin, angle)
	elif resize_mode == PlayerHolder.ResizeMode.SHEAR:
		$player.shear_selection(resizing_orgin, accumulated_drag.x / (starting_mouse_position.y - resizing_orgin.y))
	else:
		var change: Vector2 = Vector2(1,1) + accumulated_drag / (resizing_orgin - starting_mouse_position)
		var lock_scale: bool = Input.is_action_pressed("lock scale");
		
		if resize_mode == PlayerHolder.ResizeMode.UP or resize_mode == PlayerHolder.ResizeMode.DOWN:
			change.x = 1
			lock_scale = false
		elif resize_mode == PlayerHolder.ResizeMode.LEFT or resize_mode == PlayerHolder.ResizeMode.RIGHT:
			change.y = 1
			lock_scale = false
			
		if lock_scale:
			change = change.project(Vector2(1,1))
		
		if Input.is_action_pressed("discrete transform"):
			if Input.is_action_pressed("fine control"):
				change /= Utils.fine_discrete_transform_multiplier
			else:
				change /= Utils.discrete_transform_multiplier
			change.x = int(change.x)
			change.y = int(change.y)
			if Input.is_action_pressed("fine control"):
				change *= Utils.fine_discrete_transform_multiplier
			else:
				change *= Utils.discrete_transform_multiplier
		
		$player.resize_selection(resizing_orgin, change)
