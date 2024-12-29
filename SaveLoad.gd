class_name SaveLoad


const data_file_name: StringName = "data"
const images_folder_in_zip: String = "images/"



static func create_config_data(children_holder: Node) -> PackedByteArray:
	var config := ConfigFile.new()
	
	config.set_value("util", "image_ref_counts", AssetManager.image_ref_counts)
	
	var node_count: int = 0
	for node: PlayerImage in children_holder.get_children():
		var node_data = node.get_data()
		config.set_value("children", str(node_count), node_data)
		node_count += 1
	
	config.set_value("util", "number_of_children", node_count)
	
	return config.encode_to_text().to_utf8_buffer()

# returns "" on success and an error message on failure
static func write_buffer_as_file_into_zip(writer: ZIPPacker, file_name: String, buffer: PackedByteArray) -> String:
	var err: Error = writer.start_file(file_name)
	if err != OK:
		return "error " + str(err) + " creating " + file_name + " in zip"
	err = writer.write_file(buffer)
	if err != OK:
		return "error " + str(err) + " write " + file_name + " in zip"
	err = writer.close_file()
	if err != OK:
		return "error " + str(err) + " closing " + file_name + " in zip"
	return ""


static func save_file_selected(path: String, children_holder: Node) -> String:
	var writer := ZIPPacker.new()
	var err: Error
	err = writer.open(path)
	if err != OK:
		return "error " + str(err) + " opening zip"
	
	var err_str: String = write_buffer_as_file_into_zip(writer, data_file_name, create_config_data(children_holder))
	if err_str != "": return err_str
	
	for image_name: StringName in AssetManager.image_ref_counts:
		var reading_file := FileAccess.open(AssetManager.temp_image_files + image_name, FileAccess.READ)
		err = reading_file.get_error()
		if err != OK:
			return "error " + str(err) + " opening " + str(AssetManager.temp_image_files + image_name) 
		var length = reading_file.get_length()
		var data = reading_file.get_buffer(length)
		var result_path: String = images_folder_in_zip + image_name
		
		err_str = write_buffer_as_file_into_zip(writer, result_path, data)
		if err_str != "": return err_str
	
	err = writer.close()
	if err != OK:
		return "error " + str(err) + " closing zip"
	
	return ""

# returns "" on success and an error message on failure
static func transfer_from_zip_to_temp(reader: ZIPReader, source_path: String, result_path: String) -> String:
	if !reader.file_exists(source_path):
		return "error " + source_path + " not found in zip"
	var data: PackedByteArray = reader.read_file(source_path)
	var file: FileAccess = FileAccess.open(result_path, FileAccess.WRITE)
	file.store_buffer(data)
	return ""



# returns "" on success and an error message on failure
static func load_images_from_config(config: ConfigFile, reader: ZIPReader) -> String:
	var err_str: String
	
	AssetManager.image_ref_counts = config.get_value("util", "image_ref_counts")
	AssetManager.image_textures = {}
	AssetManager.image_hashes = {}
	AssetManager.delete_all_temp_images()
	for image_name: StringName in AssetManager.image_ref_counts:
		# transfer file over
		var source_image_path: String = images_folder_in_zip + image_name
		var result_image_path: String = AssetManager.temp_image_files + image_name
		err_str = transfer_from_zip_to_temp(reader, source_image_path, result_image_path)
		if err_str != "": return err_str
		
		AssetManager.load_image_from_temp_folder(image_name)
	
	return ""


# returns "" on success and an error message on failure
static func load_config(config: ConfigFile, reader: ZIPReader, player: Player) -> String:
	var err_str: String
	
	err_str = load_images_from_config(config, reader)
	if err_str != "": return err_str
	
	var number_of_children: int = config.get_value("util", "number_of_children")
	for node_count: int in number_of_children:
		var node_data: Dictionary = config.get_value("children", str(node_count))
		load_image_from_data(node_data, player)
	
	return ""


static func load_file_selected(path: String, player: Player) -> String:
	var reader := ZIPReader.new()
	var err: Error
	var data: PackedByteArray
	
	err = reader.open(path)
	if err != OK:
		return "error " + str(err) + " reading zip"
	
	if !reader.file_exists(data_file_name):
		return "error " + data_file_name + " not found in zip"
	data = reader.read_file(data_file_name)
	
	var config := ConfigFile.new()
	err = config.parse(data.get_string_from_utf8())
	if err != OK:
		return "error " + str(err) + " parsing " + data_file_name + " found in zip"
	
	var err_str: String = load_config(config, reader, player)
	if err_str != "": return err_str
	
	err = reader.close()
	if err != OK:
		return "error " + str(err) + " closing zip"
	
	return ""


static var PlayerImageScene: PackedScene = preload("res://image/PlayerImage.tscn")

static func load_image_from_data(image_data: Dictionary, player: Player) -> void:
	var instance: PlayerImage = PlayerImageScene.instantiate()
	instance.load_from_data(image_data)
	player.attach_image(instance, image_data.image_name)
