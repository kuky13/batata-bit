extends Control

@onready var title_label = $CenterContainer/VBoxContainer/Title
@onready var play_label = $CenterContainer/VBoxContainer/PlayButton/Label
@onready var quit_label = $CenterContainer/VBoxContainer/QuitButton/Label

func _ready() -> void:
	# Update texts
	title_label.text = Language.get_text("MAIN_TITLE")
	play_label.text = Language.get_text("MAIN_PLAY")
	quit_label.text = Language.get_text("MAIN_QUIT")
	
	# Connect buttons
	$CenterContainer/VBoxContainer/PlayButton.pressed.connect(_on_play_pressed)
	$CenterContainer/VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/create_world_menu.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
