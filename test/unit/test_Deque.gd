extends GutTest

var deque: Deque

func before_each():
	deque = Deque.new()

func after_each():
	deque = null

func add_values():
	deque.push_top(1)
	deque.push_bottom(2)
	deque.push_top(3)
	deque.push_bottom(4)
	deque.push_top(5)
	deque.push_bottom(6)

func test_empty():
	assert_eq(deque.top(), null)
	assert_eq(deque.bottom(), null)
	assert_eq(deque.pop_top(), null)
	assert_eq(deque.pop_bottom(), null)
	assert_true(deque.is_empty())

func test_push():
	deque.push_top(14)
	assert_eq(deque.size, 1)
	assert_eq(deque.bottom_index, 0)
	deque.push_bottom(18)
	assert_eq(deque.size, 2)
	assert_gt(deque.bottom_index, 0)
	assert_false(deque.is_empty())

func test_grow():
	add_values()
	assert_gte(deque.array.size(), 6)
	deque.push_top(7)
	deque.push_bottom(8)
	assert_eq(deque.array.size(), 8)

func test_pop_top():
	add_values()
	assert_eq(deque.pop_top(), 5)
	assert_eq(deque.pop_top(), 3)
	assert_eq(deque.pop_top(), 1)
	assert_eq(deque.pop_top(), 2)
	assert_eq(deque.pop_top(), 4)
	assert_eq(deque.pop_top(), 6)
	assert_eq(deque.pop_top(), null)

func test_pop_bottom():
	add_values()
	assert_eq(deque.pop_bottom(), 6)
	assert_eq(deque.pop_bottom(), 4)
	assert_eq(deque.pop_bottom(), 2)
	assert_eq(deque.pop_bottom(), 1)
	assert_eq(deque.pop_bottom(), 3)
	assert_eq(deque.pop_bottom(), 5)
	assert_eq(deque.pop_bottom(), null)

func test_pop_push():
	add_values()
	assert_eq(deque.pop_bottom(), 6)
	assert_eq(deque.pop_bottom(), 4)
	assert_eq(deque.pop_bottom(), 2)
	add_values()
	assert_eq(deque.pop_top(), 5)
	assert_eq(deque.pop_top(), 3)
	assert_eq(deque.pop_top(), 1)
	add_values()
	assert_eq(deque.pop_bottom(), 6)
	assert_eq(deque.pop_top(), 5)
	assert_eq(deque.pop_bottom(), 4)
	assert_eq(deque.pop_top(), 3)
	assert_eq(deque.pop_bottom(), 2)
	assert_eq(deque.pop_top(), 1)
	assert_eq(deque.pop_bottom(), 6)
	assert_eq(deque.pop_top(), 5)
	assert_eq(deque.pop_bottom(), 4)
	assert_eq(deque.pop_top(), 3)
	assert_eq(deque.pop_bottom(), 2)
	assert_eq(deque.pop_top(), 1)
	assert_eq(deque.pop_bottom(), null)
	assert_eq(deque.pop_top(), null)

func test_clear():
	add_values()
	deque.push_top(Deque.new())
	deque.top().push_top("Billy")
	var weak_ref: WeakRef = weakref(deque.top())
	assert_is(deque.top(), Deque)
	assert_eq(deque.top().top(), "Billy")
	add_values()
	add_values()
	deque.clear()
	assert_eq(deque.size, 0)
	assert_eq(weak_ref.get_ref(), null)
