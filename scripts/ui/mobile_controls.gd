extends CanvasLayer

@export var move_left_action := &"move_left"
@export var move_right_action := &"move_right"
@export var move_forward_action := &"move_forward"
@export var move_backward_action := &"move_backward"
@export var jump_action := &"ui_accept"
@export var look_speed := Vector2(2.8, 2.2)

@onready var root := $Root
@onready var left_area := $Root/LeftArea
@onready var right_area := $Root/RightArea

var world: Node
var _look := Vector2.ZERO
var _dpad_up := false
var _dpad_down := false
var _dpad_left := false
var _dpad_right := false
var _dpad_active := false
var _btn_touch_indices := {}
var _original_textures := {}

func _ready() -> void:
	layer = 100
	visible = true
	
	if DisplayServer.is_touchscreen_available():
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	# Ajuste de layout robusto para mobile
	_adjust_layout()
	get_viewport().size_changed.connect(_adjust_layout)
	
	# Garante que os botões fiquem sobre o joystick (para receber input)
	var joystick_area = $Root/RightArea/JoystickArea
	var action_buttons = $Root/RightArea/ActionButtons
	if joystick_area and action_buttons:
		$Root/RightArea.move_child(joystick_area, 0)
	
	_setup_buttons()

func _setup_touch_button(btn: BaseButton) -> void:
	btn.focus_mode = Control.FOCUS_NONE
	if btn is TextureButton:
		_original_textures[btn.get_instance_id()] = btn.texture_normal
		
	btn.gui_input.connect(func(event):
		if event is InputEventScreenTouch:
			var bid = btn.get_instance_id()
			if event.pressed:
				if not _btn_touch_indices.has(bid):
					_btn_touch_indices[bid] = event.index
					btn.button_down.emit()
					if btn is Button:
						btn.add_theme_stylebox_override("normal", btn.get_theme_stylebox("pressed"))
					elif btn is TextureButton and btn.texture_pressed:
						btn.texture_normal = btn.texture_pressed
			elif not event.pressed:
				if _btn_touch_indices.get(bid, -1) == event.index:
					_btn_touch_indices.erase(bid)
					btn.button_up.emit()
					btn.pressed.emit()
					if btn is Button:
						btn.remove_theme_stylebox_override("normal")
					elif btn is TextureButton:
						var orig = _original_textures.get(bid)
						if orig: btn.texture_normal = orig
	)

func _setup_buttons() -> void:
	# D-Pad
	var up = $Root/LeftArea/DPad/Up
	var down = $Root/LeftArea/DPad/Down
	var left = $Root/LeftArea/DPad/Left
	var right = $Root/LeftArea/DPad/Right
	
	_setup_touch_button(up)
	_setup_touch_button(down)
	_setup_touch_button(left)
	_setup_touch_button(right)
	
	up.button_down.connect(func(): _dpad_up = true)
	up.button_up.connect(func(): _dpad_up = false)
	down.button_down.connect(func(): _dpad_down = true)
	down.button_up.connect(func(): _dpad_down = false)
	left.button_down.connect(func(): _dpad_left = true)
	left.button_up.connect(func(): _dpad_left = false)
	right.button_down.connect(func(): _dpad_right = true)
	right.button_up.connect(func(): _dpad_right = false)
	
	# Joystick
	var joy = $Root/RightArea/JoystickArea/RightJoystick
	joy.changed.connect(func(v): _look = v)
	
	# Actions
	var jump = $Root/RightArea/ActionButtons/Jump
	var place = $Root/RightArea/ActionButtons/Place
	var remove = $Root/RightArea/ActionButtons/Remove
	
	_setup_touch_button(jump)
	_setup_touch_button(place)
	_setup_touch_button(remove)
	
	jump.button_down.connect(func(): 
		Input.action_press(jump_action)
		_vibrate()
	)
	jump.button_up.connect(func(): Input.action_release(jump_action))
	
	place.button_down.connect(func(): 
		if world and world.has_method("request_place"): world.request_place()
		_vibrate()
	)
	
	remove.button_down.connect(func(): 
		if world and world.has_method("request_remove"): world.request_remove()
		_vibrate()
	)

func _vibrate() -> void:
	if DisplayServer.is_touchscreen_available():
		Input.vibrate_handheld(50)

func _adjust_layout() -> void:
	var screen_size = get_viewport().get_visible_rect().size
	var safe = DisplayServer.get_display_safe_area()
	if safe.size.x == 0: safe = Rect2(Vector2.ZERO, screen_size)
	
	# Root ocupa a tela inteira via anchors
	root.offset_left = 0.0
	root.offset_top = 0.0
	root.offset_right = 0.0
	root.offset_bottom = 0.0
	
	var base_height = 720.0
	var scale_factor = clampf(screen_size.y / base_height, 0.9, 1.5)
	
	# Aplica escala
	left_area.scale = Vector2.ONE * scale_factor
	right_area.scale = Vector2.ONE * scale_factor
	
	# Margens ajustadas para ficar nos cantos (conforme pedido)
	var margin_x = 10.0
	var margin_y = 10.0
	
	# Ajuste para Notch/Cutout (Safe Area) do lado esquerdo
	if safe.position.x > 0:
		margin_x += safe.position.x
	
	# Posicionamento LeftArea (D-Pad)
	# left_h deve ser a altura real do container ou aproximado
	var left_h = 320.0 * scale_factor
	left_area.position = Vector2(margin_x, screen_size.y - left_h - margin_y)
	
	# Posicionamento RightArea (Ações)
	var right_w = 540.0 * scale_factor
	var right_h = 420.0 * scale_factor
	
	# Margem direita (Notch reverso ou borda)
	var margin_right = 10.0 # Usar margem pequena fixa base
	var safe_right = screen_size.x - safe.end.x
	if safe_right > 0:
		margin_right += safe_right
		
	right_area.position = Vector2(screen_size.x - right_w - margin_right, screen_size.y - right_h - margin_y)

func _process(delta: float) -> void:
	var v = Vector2(float(_dpad_right) - float(_dpad_left), float(_dpad_down) - float(_dpad_up))
	if v != Vector2.ZERO:
		_dpad_active = true
		_apply_move(v.normalized())
	elif _dpad_active:
		_dpad_active = false
		_apply_move(Vector2.ZERO)
		
	if world and world.has_method("apply_look_joystick"):
		world.apply_look_joystick(_look * look_speed, delta)

func _apply_move(v: Vector2) -> void:
	_set_ax(move_left_action, move_right_action, v.x)
	_set_ax(move_forward_action, move_backward_action, v.y)

func _set_ax(neg, pos, val) -> void:
	if val < -0.1: Input.action_press(neg, -val); Input.action_release(pos)
	elif val > 0.1: Input.action_press(pos, val); Input.action_release(neg)
	else: Input.action_release(neg); Input.action_release(pos)
