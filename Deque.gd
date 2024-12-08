class_name Deque

var array: Array
var size: int = 0

var bottom_index: int = 0
var top_index: int:
	get: return posmod((bottom_index+size-1), array.size())

func _translated_index(i: int) -> int:
	return posmod((bottom_index+i), array.size())


func _init() -> void:
	array = []
	array.resize(4)

func _grow():
	var new_array: Array = []
	new_array.resize(array.size() * 2)
	for i: int in size:
		new_array[i] = array[_translated_index(i)]
	array = new_array
	bottom_index = 0


func clear():
	for i: int in size:
		array[_translated_index(i)] = 0 # so it might free
	size = 0
	bottom_index = 0


func push_top(value) -> void:
	if size+1 > array.size(): _grow()
	size += 1
	array[top_index] = value

func push_bottom(value) -> void:
	if size+1 > array.size(): _grow()
	size += 1
	bottom_index = posmod((bottom_index - 1), array.size())
	array[bottom_index] = value


func pop_bottom():
	if size == 0: return null
	var result = array[bottom_index]
	array[bottom_index] = 0 # so that it might free what is there
	size -= 1
	bottom_index = posmod((bottom_index + 1), array.size())
	return result

func pop_top():
	if size == 0: return null
	var result = array[top_index]
	array[top_index] = 0 # so that it might free what is there
	size -= 1
	return result


func bottom():
	if size == 0: return null
	return array[bottom_index]

func top():
	if size == 0: return null
	return array[top_index]


func is_empty() -> bool:
	return size == 0
