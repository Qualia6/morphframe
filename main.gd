extends Control

@onready var player: Player = $HBoxContainer/player_holder/player
@onready var player_holder: PlayerHolder = $HBoxContainer/player_holder
@onready var children_holder: Node = $HBoxContainer/player_holder/player/children

@onready var save_dialog: FileDialog = $Popups/Save
@onready var load_dialog: FileDialog = $Popups/Load
@onready var alert_dialog: AcceptDialog = $Popups/Alert

func _ready() -> void:
	get_window().files_dropped.connect(on_files_dropped)
	get_tree().set_auto_accept_quit(false)

func on_files_dropped(files: PackedStringArray) -> void:
	player.place_image_files(files)

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		AssetManager.delete_temp_image_folder()
		get_tree().quit()

func undo_button():
	player_holder.undo()

func redo_button():
	player_holder.redo()


func save_button():
	save_dialog.show()

func save_file_selected(path: String) -> void:
	var err_str: String = SaveLoad.save_file_selected(path, children_holder)
	if err_str != "":
		alert(err_str, "Saving Error!")


func load_button():
	load_dialog.show()

func load_file_selected(path: String) -> void:
	player.reset()
	var err_str: String = SaveLoad.load_file_selected(path, player)
	if err_str != "":
		alert(err_str, "Saving Error!")


func alert(message: String, title: String = "Alert!") -> void:
	alert_dialog.dialog_text = message
	alert_dialog.title = title
	alert_dialog.show()
