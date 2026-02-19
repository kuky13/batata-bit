extends Control

@onready var progress_bar = $CenterContainer/VBoxContainer/ProgressBar
@onready var label = $CenterContainer/VBoxContainer/Label

var target_scene_path: String
var _load_status := 0
var _progress := []

func _ready() -> void:
	if target_scene_path:
		ResourceLoader.load_threaded_request(target_scene_path)

func _process(_delta: float) -> void:
	if not target_scene_path: return
	
	_load_status = ResourceLoader.load_threaded_get_status(target_scene_path, _progress)
	
	if _load_status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		progress_bar.value = _progress[0] * 100
	elif _load_status == ResourceLoader.THREAD_LOAD_LOADED:
		progress_bar.value = 100
		set_process(false)
		var scene = ResourceLoader.load_threaded_get(target_scene_path)
		get_tree().change_scene_to_packed(scene)
