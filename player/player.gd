extends ColorRect
class_name Player

var PlayerImageScene: PackedScene = preload("res://image/PlayerImage.tscn")

var selection: Array[PlayerImage] = []

func place_image_files(files: PackedStringArray) -> void:
	const drop_offset_distance = 40
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
	instance.clicked.connect(get_parent()._on_object_clicked.bind(instance))
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


func select_single(object: PlayerImage) -> bool:
	if not object.selected and get_selection_mode() == SelectionMode.NORMAL:
		# remove others
		deselect_everything_but_specific(object)
	var should_drag: bool = selection_changing_logic(object, get_selection_mode())
	
	if should_drag: $selection.first_point = get_local_mouse_position()
	return should_drag


func selection_changing_logic(object: PlayerImage, selection_mode: SelectionMode) -> bool:
	if object.selected:
		if selection_mode == SelectionMode.ADD or selection_mode == SelectionMode.NORMAL:
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
			return true
	printerr("hmm this code shouldnt be reachable")
	return false


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


func start_selecting() -> void:
	$selection.visible = true
	$selection.first_point = get_local_mouse_position()


func stop_selecting() -> void:
	$selection.visible = false
	$selection.second_point = get_local_mouse_position()
	
	if get_selection_mode() == SelectionMode.NORMAL:
		deselect_everything()
	
	var selection_mode: SelectionMode = get_selection_mode()
	
	print("a")
	for object: PlayerImage in $children.get_children():
		print("b")
		if Utils.is_in_bounds(object.position + object.size / 2, $selection.min, $selection.max):
			print("c")
			selection_changing_logic(object, selection_mode)


func move_selection(amount: Vector2) -> void:
	for object in selection:
		object.move_by(amount)
