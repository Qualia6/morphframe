extends ToolBarButton


func _init():
	disabled = true


func _on_player_holder_update_redo_state(enabled: bool) -> void:
	disabled = !enabled
