extends Control

@onready var seed_input: LineEdit = $CenterContainer/VBoxContainer/SeedInput
@onready var title_label = $CenterContainer/VBoxContainer/Label
@onready var seed_label = $CenterContainer/VBoxContainer/SeedLabel
@onready var generate_label = $CenterContainer/VBoxContainer/GenerateButton/Label
@onready var back_label = $CenterContainer/VBoxContainer/BackButton/Label

func _ready() -> void:
	# Update texts
	title_label.text = Language.get_text("CREATE_TITLE")
	seed_label.text = Language.get_text("CREATE_SEED_LABEL")
	seed_input.placeholder_text = Language.get_text("CREATE_SEED_PLACEHOLDER")
	generate_label.text = Language.get_text("CREATE_GENERATE")
	back_label.text = Language.get_text("CREATE_BACK")

	$CenterContainer/VBoxContainer/GenerateButton.pressed.connect(_on_generate_pressed)
	$CenterContainer/VBoxContainer/BackButton.pressed.connect(_on_back_pressed)

func _on_generate_pressed() -> void:
	var seed_text = seed_input.text.strip_edges()
	var final_seed: int = 0
	
	if seed_text.is_empty():
		randomize()
		final_seed = randi()
	elif seed_text.is_valid_int():
		final_seed = seed_text.to_int()
	else:
		final_seed = seed_text.hash()
		
	Global.current_world_seed = final_seed
	
	# Load Loading Screen
	var loading_screen = load("res://ui/loading_screen.tscn").instantiate()
	loading_screen.target_scene_path = "res://worlds/world.tscn"
	get_tree().root.add_child(loading_screen)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = loading_screen

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")
