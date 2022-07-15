class_name FileHandler
extends Node

static func copy_dict_key(from: Dictionary, to: Dictionary, key: String) -> Dictionary:
	if from.has(key):
		to[key] = from[key]
	else:
		to = {}
	return to


static func directory_check(path: String, create: bool = false) -> int:
	var dir:= Directory.new()
	var err: int = OK
	if !dir.dir_exists(path.get_base_dir()):
		if !create:
			print("FileHandler:", "Create folder not enabled!")
			return ERR_FILE_BAD_PATH
		err = dir.make_dir_recursive(path.get_base_dir())
		if err:
			print("FileHandler:", "Creating directory ", path.get_base_dir(),
					" failed - ", err)
	return err


static func get_file_hash(path : String) -> String:
	var file:= File.new()
	var f_hash:String = file.get_sha256(path)
	return f_hash


static func read_json(path: String) -> Dictionary:
	var dic: Dictionary = {}
	var file:= File.new()
	if file.file_exists(path):
		var err : int = file.open(path, File.READ)
		if err == OK:
			dic = parse_json(file.get_as_text())
			file.close()
		else:
			print("FileHandler read_json fopen error:", err)
	else:
		print("FileHandler read_json not existing path:", path)
	return dic


static func save_json(path: String, data: Dictionary, create_folder: bool = false) -> int:
	var err: int = directory_check(path, create_folder)
	if err != OK:
		return err
	var file:= File.new()
	err = file.open(path, File.WRITE)
	if err:
		print("FileHandler:", "Open file ", path, " write failed - ", err)
		return err
	file.store_string(to_json(data))
	return OK


static func write_string(path: String, data: String, create: bool = false) -> int:
	var err: int = directory_check(path, create)
	if err != OK:
		return err

	var file = File.new()
	err = file.open(path, File.WRITE)
	if err:
		print("FileHandler:", "Open file ", path, " write failed - ", err)
		return err
	file.store_string(data)
	return OK
