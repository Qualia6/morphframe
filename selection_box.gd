extends Control


func _on_resized() -> void:
	update_size()


var animate_color: float = 0

func _process(delta: float) -> void:
	if visible:
		animate_color += delta /3
		if animate_color > 1:
			animate_color -= 1
			
		var color: Color = Color.from_hsv(animate_color,0.5,1,0.5)
		$bottom_right_handle.color = color
		$bottom_left_handle.color = color
		$top_right_handle.color = color
		$top_left_handle.color = color
		$rotation_handle.color = color
		$skew_handle.color = color
		$top_bar.color = color
		$bottom_bar.color = color
		$right_bar.color = color
		$left_bar.color = color

# wow that was really fucking annoying to program
# it doesnt even work completely perfectly 
# and no, anchors would not have been able to do what i wanted
func update_size() -> void:
	var zoomage: Vector2 = (scale / get_global_transform().get_scale())
	var handle_size: Vector2 = zoomage * 12
	var handle_offset: Vector2 = handle_size / 2
	
	var top_left: Vector2 = Vector2(0,0)
	var bottom_left: Vector2 = Vector2(0, size.y)
	var top_right: Vector2 = Vector2(size.x, 0)
	var bottom_right: Vector2 = size
	var top_center: Vector2 = Vector2(size.x/2, 0)
	var bottom_center: Vector2 = Vector2(size.x/2, size.y)
	
	$bottom_right_handle.size = handle_size
	$bottom_right_handle.position = bottom_right - handle_offset
	$bottom_left_handle.size = handle_size
	$bottom_left_handle.position = bottom_left - handle_offset
	$top_right_handle.size = handle_size
	$top_right_handle.position = top_right - handle_offset
	$top_left_handle.size = handle_size
	$top_left_handle.position = top_left - handle_offset
	$rotation_handle.size = handle_size
	$rotation_handle.position = top_center - handle_offset - Vector2(0, handle_size.y)
	$skew_handle.size = handle_size
	$skew_handle.position = bottom_center - handle_offset + Vector2(0, handle_size.y)
	
	var bar_width: Vector2 = zoomage * 6
	var bar_offset: Vector2 = bar_width / 2
	var bar_span: Vector2 = size - handle_size
	
	var horrizontal_bar_size: Vector2 = Vector2(bar_span.x, bar_width.y)
	var verticle_bar_size: Vector2 = Vector2(bar_width.x, bar_span.y)
	var horrizontal_bar_offset: Vector2 = Vector2(handle_offset.x, -bar_offset.y)
	var verticle_bar_offset: Vector2 = Vector2(-bar_offset.x, handle_offset.y)
	
	$top_bar.size = horrizontal_bar_size
	$top_bar.position = horrizontal_bar_offset
	$bottom_bar.size = horrizontal_bar_size
	$bottom_bar.position = horrizontal_bar_offset + bottom_left
	$right_bar.size = verticle_bar_size
	$right_bar.position = verticle_bar_offset
	$left_bar.size = verticle_bar_size
	$left_bar.position = verticle_bar_offset + top_right
