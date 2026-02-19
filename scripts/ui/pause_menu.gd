extends Control

@onready var title_label = $CenterContainer/VBoxContainer/Label
@onready var resume_label = $CenterContainer/VBoxContainer/ResumeButton/Label
@onready var save_label = $CenterContainer/VBoxContainer/SaveButton/Label
@onready var quit_label = $CenterContainer/VBoxContainer/QuitButton/Label

func _ready() -> void:
	# Update texts
	title_label.text = Language.get_text("PAUSE_TITLE")
	resume_label.text = Language.get_text("PAUSE_RESUME")
	save_label.text = Language.get_text("PAUSE_SAVE")
	quit_label.text = Language.get_text("PAUSE_QUIT")

	$CenterContainer/VBoxContainer/ResumeButton.pressed.connect(_on_resume_pressed)
	$CenterContainer/VBoxContainer/SaveButton.pressed.connect(_on_save_pressed)
	$CenterContainer/VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)
	
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_resume_pressed() -> void:
	get_tree().paused = false
	queue_free()

func _on_save_pressed() -> void:
	if get_tree().current_scene.has_method("save_world"):
		get_tree().current_scene.save_world()
		# Feedback visual poderia ser adicionado aqui
		save_label.text = Language.get_text("PAUSE_SAVED")
		await get_tree().create_timer(1.0).timeout
		if is_instance_valid(self):
			save_label.text = Language.get_text("PAUSE_SAVE")

func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")
