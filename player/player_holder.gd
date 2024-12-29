extends Control
class_name PlayerHolder

# Responsibilities:
#	User Input
#	Movement of the editor
#	Undo


var previous_player_position: Vector2

var middle_click_dragging: bool = false

var previous_mouse_position: Vector2
var accumulated_drag: Vector2 = Vector2(0,0)
var starting_mouse_position: Vector2

var previous_mouse_editor_position: Vector2
var accumulated_editor_drag: Vector2 = Vector2(0,0)

enum MouseAction {NONE, DRAGGING, SELECTING, POTENTIAL_DRAG, RESIZE}
var mouse_action = MouseAction.NONE

enum ResizeMode {UP, LEFT, RIGHT, DOWN, UP_LEFT, UP_RIGHT, DOWN_LEFT, DOWN_RIGHT, ROTATE, SHEAR}
var resize_mode = ResizeMode.DOWN_RIGHT

var handle_transform_orgin: Vector2

func _on_object_clicked(object: PlayerImage) -> void:
	if mouse_action == MouseAction.NONE:
		var previous_selection: Array[PlayerImage] = $player.selection.duplicate()
		var should_drag: bool = $player.select_single(object)
		var action: Actions.SelectionAction = Actions.SelectionAction.new($player, $player.selection)
		action.previous_selection = previous_selection
		apply_action(action, true)
		if should_drag: 
			mouse_action = MouseAction.POTENTIAL_DRAG
			reset_mouse_movement()


func reset_mouse_movement():
	previous_mouse_editor_position = get_local_mouse_position()
	accumulated_editor_drag = Vector2(0,0)
	starting_mouse_position = $player.get_local_mouse_position()
	previous_mouse_position = $player.get_local_mouse_position()
	accumulated_drag = Vector2(0,0)


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
			reset_mouse_movement()
			previous_player_position = $player.position
			middle_click_dragging = true
			
	elif event.is_action("primary click"): 
		if event.is_pressed() and mouse_action == MouseAction.NONE:
			mouse_action = MouseAction.SELECTING
			reset_mouse_movement()
			$player.start_selecting()
			get_viewport().set_input_as_handled()
		elif event.is_released() and mouse_action == MouseAction.SELECTING:
			mouse_action = MouseAction.NONE
			var previous_selection: Array[PlayerImage] = $player.selection.duplicate()
			$player.stop_selecting()
			var action: Actions.SelectionAction = Actions.SelectionAction.new($player, $player.selection)
			action.previous_selection = previous_selection
			apply_action(action, true)
			get_viewport().set_input_as_handled()


func _input(event: InputEvent) -> void: # happens before objects
	if event.is_action_released("editor drag") and middle_click_dragging:
		editor_drag()
		middle_click_dragging = false
	
	if event.is_action_released("primary click"):
		if mouse_action == MouseAction.DRAGGING:
			accumulate_drag()
			physics_drag(true)
			mouse_action = MouseAction.NONE
		if mouse_action == MouseAction.POTENTIAL_DRAG:
			mouse_action = MouseAction.NONE
		if mouse_action == MouseAction.RESIZE:
			accumulate_drag()
			physics_resize(true)
			mouse_action = MouseAction.NONE


func _physics_process(delta: float) -> void:
	if middle_click_dragging:
		editor_drag()

	match mouse_action:
		MouseAction.DRAGGING:
			physics_drag(false)
		MouseAction.SELECTING:
			physics_select()
		MouseAction.POTENTIAL_DRAG:
			physics_potential_drag()
		MouseAction.RESIZE:
			physics_resize(false)
	
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
		reset_mouse_movement()
		mouse_action = MouseAction.DRAGGING

func physics_select() -> void:
	$player/selector.second_point = $player/selector.first_point - accumulated_drag

func physics_drag(final: bool) -> void:
	var action: Actions.MoveAction = Actions.MoveAction.new($player, -accumulated_drag, $player.selection)
	apply_action(action, final)
	$player.update_selection_box()


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
		reset_mouse_movement()
		mouse_action = MouseAction.RESIZE
		resize_mode = mode
		set_handle_transform_orgin()
		get_viewport().set_input_as_handled()


func set_handle_transform_orgin():
	handle_transform_orgin = $player/selection_box.position
	match resize_mode:
		PlayerHolder.ResizeMode.UP_LEFT:
			handle_transform_orgin += $player/selection_box.size
		PlayerHolder.ResizeMode.UP_RIGHT:
			handle_transform_orgin.y += $player/selection_box.size.y
		PlayerHolder.ResizeMode.DOWN_LEFT:
			handle_transform_orgin.x += $player/selection_box.size.x
		PlayerHolder.ResizeMode.DOWN_RIGHT:
			pass
		PlayerHolder.ResizeMode.UP:
			handle_transform_orgin += $player/selection_box.size
		PlayerHolder.ResizeMode.LEFT:
			pass
		PlayerHolder.ResizeMode.DOWN:
			pass
		PlayerHolder.ResizeMode.RIGHT:
			handle_transform_orgin += $player/selection_box.size
		_:
			handle_transform_orgin += $player/selection_box.size / 2


func physics_resize(final: bool):
	var action = Actions._TransformAction
	
	if resize_mode == PlayerHolder.ResizeMode.ROTATE:
		var angle: float = (starting_mouse_position - accumulated_drag - handle_transform_orgin).angle() + PI/2
		
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
		
		action = Actions.RotateAction.new($player, angle, handle_transform_orgin, $player.selection)

	elif resize_mode == PlayerHolder.ResizeMode.SHEAR:
		var amount: float = accumulated_drag.x / (starting_mouse_position.y - handle_transform_orgin.y)
		action = Actions.SkewAction.new($player, amount, handle_transform_orgin, $player.selection)
		
	else:
		var change: Vector2 = Vector2(1,1) + accumulated_drag / (handle_transform_orgin - starting_mouse_position)
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
		
		action = Actions.ScaleAction.new($player, change, handle_transform_orgin, $player.selection)
	
	apply_action(action, final)
	$player.update_selection_box()

func reset() -> void:
	undo_deque.clear()
	redo_stack.clear()
	update_undoredo_button_state()

var undo_deque: Deque = Deque.new()
var redo_stack: Array = []
var action_finished: bool = true

signal update_undo_state(enabled: bool, tooltip: String)
signal update_redo_state(enabled: bool, tooltip: String)

func update_undoredo_button_state():
	if undo_deque.is_empty():
		update_undo_state.emit(false, "")
	else:
		var top_state: Actions.CachedState = undo_deque.top()
		update_undo_state.emit(true, top_state.get_name())
		
	if redo_stack.is_empty():
		update_redo_state.emit(false, "")
	else:
		var top_state: Actions.CachedState = redo_stack.back()
		update_redo_state.emit(true, top_state.get_name())


func apply_action(action: Actions._Action, finished = true) -> void:
	if !Utils.selecting_undo and action is Actions.SelectionAction: return
	if !action.is_substantive(): return
	
	if !action_finished:
		var previous_state: Actions.CachedState = undo_deque.pop_top()
		if previous_state != null:
			previous_state.apply(0)
	action_finished = finished
	
	var state: Actions.CachedState = Actions.CachedState.new($player)
	state.add(action)
	
	if !state.is_substantive(): 
		return
		
	state.apply(1)
	undo_deque.push_top(state)
	
	redo_stack.clear()
	
	while undo_deque.size > Utils.max_undo:
		undo_deque.pop_bottom()
	update_undoredo_button_state()


func undo() -> void:
	var state: Actions.CachedState = undo_deque.pop_top()
	if state == null: return
	state.apply(0)
	redo_stack.push_back(state)
	update_undoredo_button_state()

func redo() -> void:
	var state: Actions.CachedState = redo_stack.pop_back()
	if state == null: return
	state.apply(1)
	undo_deque.push_top(state)
	update_undoredo_button_state()
