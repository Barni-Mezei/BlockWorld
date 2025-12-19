extends Node

signal thread_available

const max_threads : int = 1 # 4 is optimal

var used_thread_count : int = 0
var threads : Array[Dictionary]

var last_freed_index : int = 0

var mutex : Mutex

func _ready() -> void:
	threads.resize(max_threads)

	for i in range(max_threads):
		threads[i] = {
			"used": false,
			"thread": Thread.new()
		}

	mutex = Mutex.new()

func find_first_free_index() -> int:
	mutex.lock()
	for i in range(max_threads):
		if threads[i]["used"] == false:
			return i
	mutex.unlock()

	return -1

func get_thread() -> Dictionary:
	var free_index = find_first_free_index()
	if free_index == -1:
		return {
			"index": -1,
			"thread": null
		}

	mutex.lock()
	threads[free_index]["used"] = true
	used_thread_count += 1
	mutex.unlock()

	return {
		"index": free_index,
		"thread": threads[free_index]["thread"]
	}

func free_thread(thread_index : int) -> void:
	mutex.lock()
	threads[thread_index]["used"] = false
	used_thread_count -= 1
	mutex.unlock()

	if threads[thread_index]["thread"].is_started():
		await threads[thread_index]["thread"].wait_to_finish()

	#prints("Unlocked", thread_index)

	last_freed_index = thread_index
	thread_available.emit()
