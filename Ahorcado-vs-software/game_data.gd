
extends Node

const SAVE_PATH = "user://settings.json"
const VOLUME_BUSES = {"volume_master": "Master", "volume_music": "Music", "volume_effects": "SFX"}

var settings = {"volume_master": 1.0, "volume_music": 0.5, "volume_effects": 0.5}

func _ready():
	load_data()
	apply_all_volumes()

func save_data():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	
	if file == null:
		push_error("Can't open file to save.")
		return
	
	var json = JSON.stringify(settings)
	file.store_string(json)
	file.close()

func load_data():
	if not FileAccess.file_exists(SAVE_PATH):
		save_data()
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	
	if file == null:
		push_error("Can't open file to read.")
		return
	
	var contents = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var result = json.parse(contents)
	
	if result == OK and json.data is Dictionary:
		settings = json.data
	else:
		push_error("Settings file not valid.")

func change_volume(type: String, value: float):
	if settings.has(type):
		settings[type] = clampf(value, 0.0, 1.0)
		apply_volume(type)
		save_data()

func apply_volume(type: String) -> void:
	if not VOLUME_BUSES.has(type):
		return
	
	var bus_name = VOLUME_BUSES[type]
	var bus_index = AudioServer.get_bus_index(bus_name)
	
	if bus_index == -1:
		push_error("Audio bus not found: " + bus_name)
		return
	
	var volume = settings[type]
	
	AudioServer.set_bus_volume_linear(bus_index, linear_to_db(volume))

func preview_volume(type: String, value: float) -> void:
	if settings.has(type):
		settings[type] = clampf(value, 0.0, 1.0)
		apply_volume(type)

func apply_all_volumes() -> void:
	for type in VOLUME_BUSES.keys():
		apply_volume(type)

func get_volume(type: String) -> float:
	return settings.get(type, 1.0)
