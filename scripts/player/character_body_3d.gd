extends CharacterBody3D

@export var speed = 6.0
@export var acceleration := 30.0
@export var deceleration := 30.0
@export var stop_threshold := 0.1
@export var camera_relative_movement := true
@export var jump_velocity := 7.0
@export var jump_gravity_scale := 1.5
@export var fall_gravity_scale := 2.5
@export var max_fall_speed := 50.0

# Variáveis para controle de pulo e fluidez
var _coyote_time := 0.15
var _coyote_timer := 0.0
var _jump_buffer_time := 0.1
var _jump_buffer_timer := 0.0
var _is_jumping := false

# Referência ao nó de animação
@onready var animation = $AnimatedSprite3D 

var _camera: Camera3D
var last_dir = Vector2.DOWN # Direção padrão inicial

func _ready() -> void:
	_camera = get_viewport().get_camera_3d()

func _physics_process(delta: float) -> void:
	# Atualiza timers
	if is_on_floor():
		_coyote_timer = _coyote_time
		_is_jumping = false
	else:
		_coyote_timer -= delta

	if Input.is_action_just_pressed("ui_accept"):
		_jump_buffer_timer = _jump_buffer_time
	else:
		_jump_buffer_timer -= delta

	# Aplica gravidade variável para pulo melhor (estilo Mario/Celeste)
	if not is_on_floor():
		var gravity_mult := fall_gravity_scale
		if velocity.y > 0 and Input.is_action_pressed("ui_accept"):
			gravity_mult = jump_gravity_scale
		
		velocity += get_gravity() * gravity_mult * delta
		
		# Limita a velocidade de queda para evitar atravessar o chão
		if velocity.y < -max_fall_speed:
			velocity.y = -max_fall_speed

	# Pulo com Coyote Time e Buffer
	if _jump_buffer_timer > 0 and _coyote_timer > 0:
		velocity.y = jump_velocity
		_jump_buffer_timer = 0
		_coyote_timer = 0
		_is_jumping = true
	
	# Corte de pulo (se soltar o botão, cai mais rápido)
	if Input.is_action_just_released("ui_accept") and velocity.y > 0:
		velocity.y *= 0.5

	handle_movement(delta)
	move_and_slide()

func handle_movement(delta: float) -> void:
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	if input_dir == Vector2.ZERO:
		input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if input_dir == Vector2.ZERO:
		var planar := Vector3(velocity.x, 0.0, velocity.z)
		planar = planar.move_toward(Vector3.ZERO, deceleration * delta)
		if planar.length() < stop_threshold:
			planar = Vector3.ZERO
		velocity.x = planar.x
		velocity.z = planar.z
		
		# Mantém a última animação de idle baseada na última direção de movimento
		play_idle_animation(last_dir)
	else:
		if input_dir.length() > 1.0:
			input_dir = input_dir.normalized()
			
		var desired_dir := Vector3(input_dir.x, 0.0, input_dir.y)
		
		# Ajusta direção baseada na câmera
		if camera_relative_movement:
			var cam := _camera
			if not cam: cam = get_viewport().get_camera_3d() # Fallback
			if cam:
				var right := cam.global_transform.basis.x
				var forward := -cam.global_transform.basis.z
				right.y = 0.0
				forward.y = 0.0
				right = right.normalized()
				forward = forward.normalized()
				# O input_dir.y positivo é "para baixo" (move_backward), que deve ser Forward negativo (-Z)
				# O input_dir.y negativo é "para cima" (move_forward), que deve ser Forward positivo (+Z)
				# Portanto, usamos -input_dir.y para alinhar com o vetor forward da câmera
				desired_dir = (right * input_dir.x) + (forward * -input_dir.y)
		
		if desired_dir.length() > 0.001:
			desired_dir = desired_dir.normalized()
			
		var desired := desired_dir * float(speed)
		var planar := Vector3(velocity.x, 0.0, velocity.z)
		planar = planar.move_toward(desired, acceleration * delta)
		velocity.x = planar.x
		velocity.z = planar.z
		
		# Calcula direção para a animação
		var anim_dir: Vector2 = input_dir # Por padrão usa o input (resposta instantânea)
		
		update_sprite_direction(anim_dir)

func update_sprite_direction(dir_2d):
	if dir_2d.length() == 0:
		return
	
	last_dir = dir_2d.normalized()
	play_run_animation(last_dir)

func play_idle_animation(dir):
	if not animation: return
	var anim_name = "idle"
	if animation.sprite_frames.has_animation("idle_down"):
		anim_name = "idle"
	elif animation.sprite_frames.has_animation("igle_down"):
		anim_name = "igle"
		
	# Prioriza animações laterais se houver movimento horizontal significativo
	if abs(dir.x) > 0.5:
		animation.play(anim_name + ("_right" if dir.x > 0 else "_left"))
	else:
		animation.play(anim_name + ("_down" if dir.y > 0 else "_up"))

func play_run_animation(dir):
	if not animation: return
	if abs(dir.x) > abs(dir.y):
		animation.play("run_right" if dir.x > 0 else "run_left")
	else:
		animation.play("run_down" if dir.y > 0 else "run_up")
