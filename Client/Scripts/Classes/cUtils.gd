class_name Utils
extends Node


static func thread_array_finished(thr_arr:Array, thr_inst_id:int, mutex:Mutex) -> void:
	mutex.lock()
	for thr in thr_arr:
#		print("thr.get_instance_id():", thr.get_instance_id())
		if thr.get_instance_id() == thr_inst_id:
			thread_finished(thr)
	mutex.unlock()
	thread_array_clean(thr_arr, mutex)


static func thread_finished(thr:Thread) -> void:
	if thr == null: return
	var ms:int = OS.get_ticks_msec()
	while thr.is_alive():
		if OS.get_ticks_msec() - ms > 1000:
			ms = OS.get_ticks_msec()
			print("Thread still alive thr:", thr)
	if thr.is_active():
		thr.wait_to_finish()


static func thread_array_clean(thr_arr:Array, thr_arr_mutex:Mutex) -> void:
	thr_arr_mutex.lock()
	for idx in range(thr_arr.size() - 1, -1, -1):
		if thr_arr[idx] != null:
			if !thr_arr[idx].is_alive():
				thread_finished(thr_arr[idx])
				thr_arr.remove(idx)
		else:
			thr_arr.remove(idx)
	thr_arr_mutex.unlock()

