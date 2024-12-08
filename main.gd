extends Control

@onready var player: Player = $HBoxContainer/player_holder/player
@onready var player_holder: PlayerHolder = $HBoxContainer/player_holder


func _ready() -> void:
	get_window().files_dropped.connect(on_files_dropped)


func on_files_dropped(files: PackedStringArray) -> void:
	player.place_image_files(files)


func undo():
	player_holder.undo()


func redo():
	player_holder.redo()
