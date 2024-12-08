extends ToolBarButton


func _init():
	disabled = true


func _on_player_holder_update_undo_state(enabled: bool, tooltip: String) -> void:
	disabled = !enabled
	tooltip_text = "Undo " + tooltip
