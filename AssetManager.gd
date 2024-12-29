class_name AssetManager

# uses a randomized subfolder so that multipile instances dont interfer with each other
const temp_image_files_root: String = "user://temp/images/"
static var temp_image_files: String = "":
	get():
		if temp_image_files == "":
			temp_image_files = temp_image_files_root + str(randi()) + "/"
			DirAccess.make_dir_recursive_absolute(temp_image_files)
		return temp_image_files

static var image_ref_counts: Dictionary = {} # StringName (image name), int (reference count)
static var image_textures: Dictionary = {} # StringName (image name), ImageTexture
static var image_hashes: Dictionary = {} # StringName (image name), PackedByteArray (hash)


static func use_image(image_name: StringName) -> ImageTexture:
	image_ref_counts[image_name] += 1
	return image_textures[image_name]

static func release_image(image_name: StringName):
	image_ref_counts[image_name] -= 1
	if image_ref_counts[image_name] == 0: # delete it if unused
		DirAccess.open(temp_image_files).remove(image_name)
		image_ref_counts.erase(image_name)
		image_textures.erase(image_name)
		image_hashes.erase(image_name)


# if image hash already exists (in image_hashes) then return its name (key) if it doesnt then return ""
@warning_ignore("shadowed_global_identifier")
static func check_if_image_hash_already_exists(hash: PackedByteArray) -> StringName:
	for key: StringName in image_hashes:
		if image_hashes[key] == hash:
			return key
	return &""



static func hash_image(image: Image) -> PackedByteArray:
	var copy_of_image: Image = image.duplicate()
	copy_of_image.shrink_x2()
	copy_of_image.convert(Image.FORMAT_RGBA4444)
	var hashing: HashingContext = HashingContext.new()
	hashing.start(HashingContext.HASH_MD5)
	hashing.update(copy_of_image.get_data())
	return hashing.finish()


static func generate_unused_image_name(goal_name: StringName) -> StringName:
	if not image_ref_counts.has(goal_name):
		return goal_name
	var base: String = goal_name.get_basename()
	var extension: String = goal_name.get_extension()
	var addon: int = 1
	while image_ref_counts.has(base + str(addon) + "." + extension):
		addon += 1
	return base + str(addon) + "." + extension


# takes a file path
# returns a StringName for the image
static func import_or_reuse_image(source_file_path: String) -> StringName:
	
	var source: DirAccess = DirAccess.open(source_file_path.get_base_dir())
	var image: Image = Image.new()
	image.load(source_file_path)
	@warning_ignore("shadowed_global_identifier")
	var hash: PackedByteArray = hash_image(image)
	
	var image_name: StringName = check_if_image_hash_already_exists(hash)
	if image_name == "": # does not already exist - if it doesnt just reuse the previous image
		image_name = generate_unused_image_name(source_file_path.get_file())
		#print("creating " + image_name)
		var result_path: String = temp_image_files + image_name
		source.copy(source_file_path, result_path)
		var image_texture: ImageTexture = ImageTexture.new()
		image_texture.set_image(image)
		image_ref_counts[image_name] = 0
		image_hashes[image_name] = hash
		image_textures[image_name] = image_texture
	
	return image_name


# notice does NOT affect Gloval.image_ref_counts but does affect AssetManager.image_textures and Gloval.image_hashes
static func load_image_from_temp_folder(image_name: StringName) -> void:
		# load texture
		var image: Image = Image.new()
		image.load(temp_image_files + image_name)
		var image_texture: ImageTexture = ImageTexture.new()
		image_texture.set_image(image)
		image_textures[image_name] = image_texture
		
		# generate hash
		@warning_ignore("shadowed_global_identifier")
		var hash: PackedByteArray = hash_image(image)
		image_hashes[image_name] = hash


static func delete_all_temp_images() -> void:
	var dir = DirAccess.open(temp_image_files)
	for file in dir.get_files():
		dir.remove(file)

static func delete_temp_image_folder() -> void:
	delete_all_temp_images()
	DirAccess.remove_absolute(temp_image_files)
	temp_image_files = "" # so that when accessing temp_image_files next time anouther directory will be created
