extends CanvasLayer

@export var move_left_action := &"move_left"
@export var move_right_action := &"move_right"
@export var move_forward_action := &"move_forward"
@export var move_backward_action := &"move_backward"
@export var jump_action := &"ui_accept"

@onready var root := $Root
@onready var left_joystick := $Root/LeftJoystick
@onready var right_buttons := $Root/RightButtons

var world: Node
var _btn_touch_indices := {}
var _original_textures := {}

func _ready() -> void:
	layer = 100
	visible = true
	
	if DisplayServer.is_touchscreen_available():
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	_setup_buttons()
	
	if left_joystick:
		left_joystick.changed.connect(_on_joystick_changed)

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
					if btn is TextureButton and btn.texture_pressed:
						btn.texture_normal = btn.texture_pressed
			elif not event.pressed:
				if _btn_touch_indices.get(bid, -1) == event.index:
					_btn_touch_indices.erase(bid)
					btn.button_up.emit()
					btn.pressed.emit()
					if btn is TextureButton:
						var orig = _original_textures.get(bid)
						if orig: btn.texture_normal = orig
	)

func _setup_buttons() -> void:
	if not right_buttons: return
	
	var jump = right_buttons.get_node("Jump")
	var place = right_buttons.get_node("Place")
	var remove = right_buttons.get_node("Remove")
	
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

func _on_joystick_changed(v: Vector2) -> void:
	_set_ax(move_left_action, move_right_action, v.x)
	_set_ax(move_forward_action, move_backward_action, v.y)

func _set_ax(neg, pos, val) -> void:
	if val < -0.1: Input.action_press(neg, -val); Input.action_release(pos)
	elif val > 0.1: Input.action_press(pos, val); Input.action_release(neg)
	else: Input.action_release(neg); Input.action_release(pos)

func _vibrate() -> void:
	if DisplayServer.is_touchscreen_available():
		Input.vibrate_handheld(50)
