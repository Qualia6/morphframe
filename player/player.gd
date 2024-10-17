extends ColorRect
class_name Player

var PlayerImageScene: PackedScene = preload("res://image/PlayerImage.tscn")

enum MouseAction {NONE, DRAGGING, SELECTING, POTENTIAL_DRAG}

var mouse_action = MouseAction.NONE
var previous_mouse_position: Vector2
var selection: Array[PlayerImage] = []

func place_image_files(files: PackedStringArray) -> void:
	const drop_offset_distance = 20
	for i: int in range(0, len(files)):
		var image: Image = Image.new()
		image.load(files[i])
		var image_texture: ImageTexture = ImageTexture.new()
		image_texture.set_image(image)
		var place_location = get_local_mouse_position() + Vector2(i,i) * drop_offset_distance
		add_image(place_location, image_texture)

func add_image(location: Vector2, image: ImageTexture) -> void:
	var instance: PlayerImage = PlayerImageScene.instantiate()
	instance.position = location
	instance.set_texture(image)
	var scale_factor: float = min(300 / image.get_size().y, min(300 / image.get_size().x, 1))
	instance.size = Vector2(scale_factor,scale_factor) * image.get_size()
	instance.clicked.connect(_on_object_clicked.bind(instance))
	$children.add_child(instance)
	print("added image :3")


enum SelectionMode {NORMAL, ADD, REMOVE, XOR}

func get_selection_mode() -> SelectionMode:
	if Input.is_action_pressed("add to selection"):
		if Input.is_action_pressed("remove from selection"):
			return SelectionMode.XOR
		else:
			return SelectionMode.ADD
	else:
		if Input.is_action_pressed("remove from selection"):
			return SelectionMode.REMOVE
		else:
			return SelectionMode.NORMAL




func _on_object_clicked(object: PlayerImage) -> void:
	if mouse_action != MouseAction.NONE: return
	
	if not object.selected and get_selection_mode() == SelectionMode.NORMAL:
		# remove others
		deselect_everything_but_specific(object)
		

	var should_drag: bool = selection_changing_logic(object, get_selection_mode())
	if should_drag: mouse_action = MouseAction.POTENTIAL_DRAG


func selection_changing_logic(object: PlayerImage, selection_mode: SelectionMode) -> bool:
	if object.selected:
		if selection_mode == SelectionMode.ADD or selection_mode == SelectionMode.NORMAL:
			previous_mouse_position = get_local_mouse_position()
			return true
		if selection_mode == SelectionMode.XOR or selection_mode == SelectionMode.REMOVE:
			# remove self
			var index = selection.find(object)
			object.selected = false
			selection.pop_at(index)
			return false
	else:
		if selection_mode == SelectionMode.REMOVE: return false
		if selection_mode == SelectionMode.ADD or selection_mode == SelectionMode.XOR or selection_mode == SelectionMode.NORMAL:
			# add self
			selection.push_back(object)
			object.selected = true
			previous_mouse_position = get_local_mouse_position()
			return true
	printerr("hmm this code shouldnt be reachable")
	return false


func start_selecting() -> void:
	$selection.visible = true
	mouse_action = MouseAction.SELECTING
	previous_mouse_position = get_local_mouse_position()

func stop_selecting() -> void:
	$selection.visible = false
	mouse_action = MouseAction.NONE
	var current_mouse_position = get_local_mouse_position()
	
	if get_selection_mode() == SelectionMode.NORMAL:
		deselect_everything()
	var min_select_area = current_mouse_position.min(previous_mouse_position)
	var max_select_area = current_mouse_position.max(previous_mouse_position)
	var selection_mode: SelectionMode = get_selection_mode()
	for object: PlayerImage in $children.get_children():
		if Utils.is_in_bounds(object.position + object.size / 2, min_select_area, max_select_area):
			selection_changing_logic(object, selection_mode)




func deselect_everything_but_specific(object: PlayerImage) -> void:
	var before_selection: bool = false
	for i in range(len(selection),0,-1):	
		var current_index: int
		if before_selection: current_index = len(selection) - 2
		else: current_index = len(selection) - 1	
		if selection[current_index] == object:
			before_selection = true
		else:
			# remove here
			selection[current_index].selected = false
			selection.pop_at(current_index)

func deselect_everything() -> void:
	for i in range(len(selection)):
		selection[i].selected = false
	selection = []


func _on_gui_input(event: InputEvent):
	if not event.is_action("primary click"): return
	# happens after objects
	if event.is_pressed() and mouse_action == MouseAction.NONE:
		start_selecting()
		get_viewport().set_input_as_handled()
		#viewport.set_input_as_handled()
	elif event.is_released() and mouse_action == MouseAction.SELECTING:
		stop_selecting()
		get_viewport().set_input_as_handled()
		#viewport.set_input_as_handled()


#func _on_input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:


func _input(event: InputEvent) -> void:
	if not event.is_action("primary click"): return
	# happens before objects
	if event.is_released():
		if mouse_action == MouseAction.DRAGGING:
			var current_mouse_position: Vector2 = get_local_mouse_position()
			physics_drag(current_mouse_position)
			mouse_action = MouseAction.NONE
		if mouse_action == MouseAction.POTENTIAL_DRAG:
			mouse_action = MouseAction.NONE

func _physics_process(delta: float) -> void:
	var current_mouse_position: Vector2 = get_local_mouse_position()
	match mouse_action:
		MouseAction.DRAGGING:
			physics_drag(current_mouse_position)
		MouseAction.SELECTING:
			physics_select(current_mouse_position)
		MouseAction.POTENTIAL_DRAG:
			physics_potential_drag(current_mouse_position)

const required_drag_distance_to_start_drag_squared: float = 10**2

func physics_potential_drag(current_mouse_position: Vector2):
	if current_mouse_position.distance_squared_to(previous_mouse_position) > required_drag_distance_to_start_drag_squared:
		mouse_action = MouseAction.DRAGGING

func physics_select(current_mouse_position: Vector2) -> void:
	$selection.size = (current_mouse_position - previous_mouse_position).abs()
	$selection.position = current_mouse_position.min(previous_mouse_position)

func physics_drag(current_mouse_position: Vector2) -> void:
	var movement = current_mouse_position - previous_mouse_position
	for object in selection:
		object.move_by(movement)
	previous_mouse_position = get_local_mouse_position()
	

func _ready() -> void:
	$selection.visible = false
	#get_viewport().set_physics_object_picking_sort(true)
