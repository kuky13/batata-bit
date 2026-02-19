extends Node

const SAVE_PATH = "user://savegame.json"

func save_game(data: Dictionary) -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(data)
		file.store_string(json_string)
		file.close()
		print("Game saved to ", SAVE_PATH)

func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		var parse_result = JSON.parse_string(json_string)
		if parse_result is Dictionary:
			return parse_result
	
	return {}

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)
