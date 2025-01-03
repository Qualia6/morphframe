class_name Actions

# Responsibilities:
#	Applying a specific action (_Action and dependants)
# 	Reverting / sequencing actions (_CachedState and dependants)


# warning: two way coupling between this and _Action
# as developping on this, be careful of this
# to remove this coupling: split this into two classes:
#	one for caching state
#	one for sequenced actions
# that is not implemented right now because would add unnessasary complexity that i dont think will be needed
class CachedState:
	var previous_transforms: Dictionary = {} # [PlayerImage, Transform2D]
	var previous_selection: Array[PlayerImage]
	var previous_selection_set: bool = false
	var update_selection_box: bool = false
	
	var player: Player
	var action_series: Array[_Action] = []
	
	func _init(player: Player):
		self.player = player
	
	func add(action: _Action):
		if !action.is_substantive(): 
			return
		action.update_cached_items(self)
		action_series.push_back(action)
	
	func _reset(): # same as calling apply(0)
		if previous_selection_set:
			player.set_selection(previous_selection)
		
		for child: PlayerImage in previous_transforms:
			child.transform = previous_transforms[child]
		
		if update_selection_box:
			player.update_selection_box()
	
	func apply(t: float = 1):
		_reset()
		if t == 0: return
		
		for action: _Action in action_series:
			action.apply(t)
		
		if update_selection_box:
			player.update_selection_box()
	
	func get_name() -> String:
		var s: String = ""
		for action: _Action in action_series:
			s += action.get_name() + " "
		return s.left(-1)
	
	func is_substantive() -> bool:
		if previous_selection_set: return true
		if !previous_transforms.is_empty(): return true
		if !action_series.is_empty(): return true
		return false


# if extending this, implement:
#	_init				- call super
#	_set_previous		- override
#	get_name				- override
#	update_cached_items	- override
#	apply				- override
# 	is_substantive		- override
class _Action:
	var player: Player
	
	func _init(player: Player):
		self.player = player
	
	func get_name() -> StringName:
		return "Action"
	
	func update_cached_items(_cached_state: CachedState) -> void:
		pass
	
	func apply(_t: float = 1.0) -> void:
		pass
	
	func is_substantive() -> bool:
		return true


# if extending this, implement:
#	_init				- call super
#	get_name				- override
#	_action				- override
#	is_substantive		- call super like
#			if !super(): return false
class _TransformAction extends _Action:
	var selection: Array[PlayerImage]
	
	func _init(player: Player, selection: Array[PlayerImage] = player.selection):
		self.player = player
		self.selection = selection.duplicate()
	
	func get_name() -> StringName:
		return "Transform"
	
	func update_cached_items(cached_state: CachedState) -> void:
		for child: PlayerImage in selection:
			cached_state.previous_transforms[child] = child.transform
		cached_state.update_selection_box = true
	
	func apply(t: float = 1) -> void:
		if t == 0: return
		for child: PlayerImage in selection:
			_action(child, t)
	
	func _action(_child: PlayerImage, _t: float) -> void:
		pass
	
	func is_substantive() -> bool:
		return !selection.is_empty()


class MoveAction extends _TransformAction:
	var offset: Vector2;
	
	func _init(player: Player, offset: Vector2, selection: Array[PlayerImage] = player.selection):
		super(player, selection)
		self.offset = offset
	
	func get_name() -> StringName:
		return "Move"
	
	func _action(child: PlayerImage, t: float) -> void:
		child.transform = child.transform.translated(offset * t)
	
	func is_substantive() -> bool:
		if !super(): return false
		return !offset.is_zero_approx()


class RotateAction extends _TransformAction:
	var angle: float;
	var center: Vector2;
	
	func _init(player: Player, angle: float, center: Vector2, selection: Array[PlayerImage] = player.selection):
		super(player, selection)
		self.angle = angle
		self.center = center
	
	func get_name() -> StringName:
		return "Rotate"
	
	func _action(child: PlayerImage, t: float) -> void:
		child.transform = child.transform.translated(-center).rotated(angle * t).translated(center)
	
	func is_substantive() -> bool:
		if !super(): return false
		return !is_zero_approx(fmod(angle, TAU))


class SkewAction extends _TransformAction:
	var amount: float;
	var center: Vector2;
	
	func _init(player: Player, amount: float, center: Vector2, selection: Array[PlayerImage] = player.selection):
		super(player, selection)
		self.amount = amount
		self.center = center
	
	func get_name() -> StringName:
		return "Skew"
	
	# This is wrong :(
	func _action(child: PlayerImage, t: float) -> void:
		var factor: float = amount * t
		var previous_pos: Vector2 = child.position
		child.transform = (child.transform * Transform2D(Vector2(1,0),Vector2(-factor,1),Vector2(0,0)))
		child.position = (previous_pos-center)* Transform2D(Vector2(1,-factor),Vector2(0,1),Vector2(0,0)) + center
	
	func is_substantive() -> bool:
		if !super(): return false
		return !is_zero_approx(amount)


class ScaleAction extends _TransformAction:
	var scale: Vector2;
	var center: Vector2;
	
	func _init(player: Player, scale: Vector2, center: Vector2, selection: Array[PlayerImage] = player.selection):
		super(player, selection)
		self.scale = scale
		self.center = center
	
	func get_name() -> StringName:
		return "Scale"
	
	func _action(child: PlayerImage, t: float) -> void:
		var factor: Vector2 = lerp(Vector2(1,1), scale, t)
		var previous_pos: Vector2 = child.position
		child.transform = child.transform.scaled(factor)
		child.position = (previous_pos - center) * factor + center
	
	func is_substantive() -> bool:
		if !super(): return false
		return !scale.is_equal_approx(Vector2(1.0,1.0))


class SelectionAction extends _Action:
	var new_selection: Array[PlayerImage]
	var previous_selection: Array[PlayerImage]
	
	func _init(player: Player, new_selection: Array[PlayerImage] = player.selection.duplicate(), previous_selection: Array[PlayerImage] = player.selection.duplicate()):
		super(player)
		self.new_selection = new_selection
		self.previous_selection = previous_selection
	
	func get_name() -> StringName:
		return "Change Selection"
	
	func update_cached_items(cached_state: CachedState) -> void:
		if cached_state.previous_selection_set == false:
			cached_state.previous_selection_set = true
			cached_state.previous_selection = previous_selection
			cached_state.update_selection_box = true
	
	func apply(t: float = 1.0) -> void:
		if t >= 0.5:
			player.set_selection(new_selection)
	
	func is_substantive() -> bool:
		if new_selection.size() != previous_selection.size(): return true
		for i: int in new_selection.size():
			if !new_selection.has(previous_selection[i]):
				return true
		return false
