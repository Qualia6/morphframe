extends Control


@onready var save_dialog: FileDialog = $SaveDialoge
@onready var open_dialog: FileDialog = $OpenDialoge
@onready var children_holder: Node = $children


const data_file_name: StringName = "data"
const temp_image_files: String = "user://temp/images/"
const images_folder_in_zip: String = "images/"



func save_pressed() -> void:
	save_dialog.visible = true

func _save_file_selected(path: String) -> void:
	var err_str: String = SaveLoad.save_file_selected(path, children_holder)
	if err_str == "":
		$label.text = "Success!"
	else:
		$label.text = err_str


func load_pressed() -> void:
	open_dialog.visible = true

func _load_file_selected(path: String) -> void:
	reset()
	var err_str: String = SaveLoad.load_file_selected(path, self)
	if err_str == "":
		$label.text = "Success!"
	else:
		$label.text = err_str


func reset() -> void:
	for child: PlayerImage in children_holder.get_children():
		remove_player_child(child)


func _ready() -> void:
	get_window().files_dropped.connect(on_files_dropped)

func on_files_dropped(files: PackedStringArray) -> void:
	DirAccess.make_dir_recursive_absolute(temp_image_files)
	
	for source_file_path: String in files:
		var image_name: StringName = AssetManager.import_or_reuse_image(source_file_path)
		add_image(image_name)


var PlayerImageScene: PackedScene = preload("res://image/PlayerImage.tscn")

func add_image(image_name: StringName) -> void:
	var image: ImageTexture = AssetManager.use_image(image_name)
	var instance: PlayerImage = PlayerImageScene.instantiate()
	instance.position = Vector2(randf(),randf()) * ($children.size - Vector2(100,100))
	instance.set_texture(image_name)
	var scale_factor: float = min(100 / image.get_size().y, min(100 / image.get_size().x, 1))
	instance.scale = Vector2(scale_factor,scale_factor)
	attach_image(instance, image_name)

func attach_image(image: PlayerImage, image_name: StringName) -> void:
	image.clicked.connect(_on_object_clicked.bind(image))
	$children.add_child(image)


func _on_object_clicked(instance: PlayerImage):
	remove_player_child(instance)

func remove_player_child(instance: PlayerImage):
	AssetManager.release_image(instance.image_name)
	instance.queue_free()
