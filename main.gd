extends Control

func _ready() -> void:
	get_window().files_dropped.connect(on_files_dropped)

func on_files_dropped(files: PackedStringArray) -> void:
	$HBoxContainer/player_holder/player.place_image_files(files)
