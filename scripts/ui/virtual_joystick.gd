extends Control

signal changed(v: Vector2)

@export var base_texture: Texture2D
@export var handle_texture: Texture2D
@export var radius: float = 100.0
@export var deadzone: float = 0.1

var _touch_id: int = -1
var _value: Vector2 = Vector2.ZERO

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if _touch_id == -1:
				_touch_id = event.index
				_update_input(event.position)
		elif event.index == _touch_id:
			_reset()
			
	elif event is InputEventScreenDrag:
		if event.index == _touch_id:
			_update_input(event.position)

func _update_input(pos: Vector2) -> void:
	var center = size * 0.5
	var diff = pos - center
	var dist = diff.length()
	
	if dist > radius:
		diff = diff.normalized() * radius
		dist = radius
		
	var v = diff / radius
	if v.length() < deadzone:
		v = Vector2.ZERO
		
	if v != _value:
		_value = v
		changed.emit(_value)
	queue_redraw()

func _reset() -> void:
	_touch_id = -1
	_value = Vector2.ZERO
	changed.emit(_value)
	queue_redraw()

func _draw() -> void:
	var center = size * 0.5
	
	# Desenha a base
	if base_texture:
		var b_size = Vector2.ONE * radius * 2.2
		draw_texture_rect(base_texture, Rect2(center - b_size * 0.5, b_size), false, Color(1, 1, 1, 0.4))
	else:
		draw_circle(center, radius, Color(0.2, 0.2, 0.2, 0.4))
	
	# Desenha o handle
	var h_pos = center + (_value * radius)
	if handle_texture:
		var h_size = Vector2.ONE * radius * 0.8
		draw_texture_rect(handle_texture, Rect2(h_pos - h_size * 0.5, h_size), false, Color(1, 1, 1, 0.8))
	else:
		draw_circle(h_pos, radius * 0.4, Color(1, 1, 1, 0.6))
