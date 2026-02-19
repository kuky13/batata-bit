extends Node3D

@export var player_path: NodePath = ^"MeshInstance3D/StaticBody3D/CharacterBody3D"
@export var camera_path: NodePath = ^"Camera3D"
@export var grid_map_path: NodePath = ^"GridMap"

@export var camera_target_offset := Vector3(0.0, 0.5, 0.0) # Subir um pouco o alvo
@export var camera_distance := 10.0 # Mais longe inicialmente
@export var camera_min_distance := 3.0
@export var camera_max_distance := 18.0
@export var camera_zoom_step := 1.0
@export var camera_yaw_sensitivity := 0.15 # Aumentado para melhor resposta no mobile
@export var camera_pitch_sensitivity := 0.1
@export var camera_pitch_min := deg_to_rad(15.0) # Aumentado para evitar câmera muito baixa entrando no chão
@export var camera_pitch_max := deg_to_rad(65.0)
@export var camera_follow_speed_horizontal := 10.0 # Muito mais rápido para não perder o personagem (era 6.0)
@export var camera_follow_speed_vertical := 5.0 # Acompanha pulos melhor (era 2.0)
@export var camera_rotation_speed := 8.0
@export var camera_zoom_speed := 18.0
@export var camera_fov := 45.0
@export var camera_collision_mask := 2
@export var camera_collision_margin := 0.5 # Margem maior para colisão
@export var camera_use_scene_start := true
@export var camera_rotate_button := MOUSE_BUTTON_RIGHT
@export var camera_capture_on_start := true
@export var camera_invert_x := false
@export var camera_invert_y := false

@export var build_item_id := 0
@export var build_item_ids: PackedInt32Array = PackedInt32Array([0, 1, 2])
@export var build_item_index := 0
@export var allow_build_floating := false
@export var protected_item_ids: PackedInt32Array = PackedInt32Array([]) # Sem blocos protegidos, pode quebrar tudo!
@export var build_raycast_distance := 12.0
@export var build_raycast_mask := 2
@export var use_runtime_mesh_library := true
@export var blocks_scene: PackedScene = preload("res://resources/prefabs/blocks.tscn")
@export var grid_cell_size := Vector3(0.5, 0.25, 0.5)

@export var default_tree_texture: Texture2D = preload("res://assets/Pixel Art Top Down/Texture/TX Plant.png")
@export var trees_texture_override: Texture2D
@export var trees_region_override_enabled := false
@export var trees_region_override_rect := Rect2(0, 0, 0, 0)

@export var trees_hitbox_enabled := true
@export var trees_hitbox_radius_scale := 0.2
@export var trees_hitbox_height_scale := 1.0
@export var trees_hitbox_radius_min := 0.18
@export var trees_hitbox_radius_max := 0.8
@export var trees_hitbox_height_min := 1.6
@export var trees_hitbox_y_extra := 0.0

@export var vegetation_collision_layer := 2
@export var vegetation_collision_mask := 1

@export var world_generate_on_ready := true
@export var use_random_seed := false
@export var world_seed_string := "1234567891011" # Seed estilo Minecraft (string ou número)
@export var world_seed := 0 # Valor numérico interno processado
# @export var world_size_cells := Vector2i(200, 200) # Removed in favor of infinite chunks
@export var chunk_size := 16
@export var view_distance_chunks := 6
@export var world_centered := true
@export var world_force_ideal_cell_size := true

@export var chunk_clear_extra_above := 24
@export var chunk_clear_extra_below := 2

@export var terrain_base_y := 0
@export var terrain_surface_item_id := 0 # Grama (ID 0)
@export var terrain_dirt_item_id := 1 # Terra (ID 1)
@export var terrain_stone_item_id := 2 # Pedra (ID 2)
@export var terrain_fill_item_id := 2 # Pedra/Terra (ID antigo)
@export var terrain_fill_depth := 3
@export var terrain_height_enabled := true
@export var terrain_height_max := 4 # Ajustado para meios blocos (mais altura em unidades de bloco)
@export var terrain_height_frequency := 0.005

@export var terrain_mountains_enabled := true
@export var terrain_mountain_height_max := 60
@export var terrain_mountain_frequency := 0.002
@export var terrain_mountain_threshold := 0.55
@export var terrain_mountain_power := 2.0

@export var terrain_water_level := -2
@export var terrain_water_item_id := 3 # Água

@export var biomes_enabled := true
@export var biome_frequency := 0.005
@export var biome_sand_item_id := 4 # Areia
@export var biome_grass2_item_id := 1 # Grama 2
@export var biome_rock_item_id := 2 # Pedra
@export var biome_sand_max := 0.22
@export var biome_grass2_min := 0.45
@export var biome_grass2_max := 0.65
@export var biome_rock_min := 0.82

@export var trees_generate_on_ready := true
@export var trees_chance := 0.002
@export var trees_random_scale := Vector2(2.5, 3.5)
@export var trees_y_offset := -0.15
@export var trees_sink_into_ground := 0.05
@export var trees_place_on_grass_only := true
@export var trees_snap_to_block_top := true
@export var trees_auto_lift_to_ground := true
@export var trees_spawn_item_ids: PackedInt32Array = PackedInt32Array([0])

@export var trees_template_name := "template_arvore_comum"
@export var trees_prefer_scene_template := true
@export var trees_use_exact_template := true

@export var grass_generate_on_ready := true
@export var grass_chance := 0.03
@export var grass_random_scale := Vector2(0.9, 1.2)
@export var grass_y_offset := 0.0
@export var grass_place_on_grass_only := true
@export var grass_snap_to_block_top := true
@export var grass_auto_lift_to_ground := true
@export var grass_spawn_item_ids: PackedInt32Array = PackedInt32Array([0])
@export var grass_template_names: PackedStringArray = PackedStringArray(["template_grama", "template_grama_alta"])
@export var grass_prefer_scene_templates := true
@export var grass_use_exact_template := false

@export var crosshair_enabled := true
@export var crosshair_size := 8.0
@export var crosshair_thickness := 1.0
@export var crosshair_color := Color(1.0, 1.0, 1.0, 0.15)

@export var mobile_controls_enabled := true
@export var mobile_controls_force_show := true
@export var camera_auto_follow_direction := true # Reativado e forçado para sempre seguir
@export var camera_auto_follow_speed := 2.5 # Suavizado para não causar enjoo
@export var camera_auto_follow_delay := 0.5 # Aumentado para permitir controle manual sem briga com a câmera
@export var camera_look_ahead_enabled := true
@export var camera_look_ahead_factor := 1.5 # Aumentado para olhar bem à frente na direção do movimento (era 0.5)
@export var camera_look_ahead_speed := 3.0

var _player: CharacterBody3D
var _camera: Camera3D
var _grid_map: GridMap
var _camera_pivot := Vector3.ZERO
# var _current_look_ahead := Vector3.ZERO # Variável interna para suavizar o look ahead
var _cam_yaw := 0.0
var _cam_pitch := 0.0
var _cam_dist := 0.0
var _cam_target_yaw := 0.0
var _cam_target_pitch := 0.0
var _cam_target_dist := 0.0
var _cam_rotating := false
var _cam_last_input_time := 0.0
var _mobile_ui: CanvasLayer
var _trees_root: Node3D

# Chunk system
var _loaded_chunks: Dictionary = {} # Vector2i -> bool
var _chunk_trees: Dictionary = {} # Vector2i -> Array[Node]
var _tree_templates: Array[Node] = []
var _tree_templates_exact := false
var _grass_templates: Array[Node] = []
var _grass_templates_exact := false
var _noise: FastNoiseLite
var _mountain_noise: FastNoiseLite
var _biome_noise: FastNoiseLite
var _last_player_chunk := Vector2i(999999, 999999)
var _chunks_to_load: Array[Vector2i] = []
var _load_speed := 1 # Chunks per frame

func _ready() -> void:
	_player = get_node_or_null(player_path) as CharacterBody3D
	_camera = get_node_or_null(camera_path) as Camera3D
	_grid_map = get_node_or_null(grid_map_path) as GridMap
	if not _player:
		_player = find_child("CharacterBody3D", true, false) as CharacterBody3D
	if not _camera:
		_camera = find_child("Camera3D", true, false) as Camera3D
	if not _grid_map:
		_grid_map = find_child("GridMap", true, false) as GridMap
	_sync_selected_build_item()
	if _camera:
		_camera.current = true
		_camera.fov = camera_fov
	if camera_capture_on_start:
		_set_camera_rotating(true)
	if _player and _camera:
		if camera_use_scene_start:
			_camera_pivot = _player.global_position + camera_target_offset
			var offset := _camera.global_position - _camera_pivot
			if offset.length() < 0.001:
				offset = Vector3(0.0, 2.0, 4.0)
			_cam_target_dist = clampf(offset.length(), camera_min_distance, camera_max_distance)
			_cam_dist = _cam_target_dist
			var horiz := Vector2(offset.x, offset.z).length()
			_cam_target_yaw = atan2(offset.x, offset.z)
			_cam_yaw = _cam_target_yaw
			_cam_target_pitch = clampf(atan2(offset.y, horiz), camera_pitch_min, camera_pitch_max)
			if offset.y < 0.0:
				_cam_target_pitch = clampf(deg_to_rad(20.0), camera_pitch_min, camera_pitch_max)
			_cam_pitch = _cam_target_pitch
		else:
			_cam_target_dist = clampf(camera_distance, camera_min_distance, camera_max_distance)
			_cam_dist = _cam_target_dist
			_cam_target_yaw = 0.0
			_cam_yaw = 0.0
			_cam_target_pitch = clampf(deg_to_rad(35.0), camera_pitch_min, camera_pitch_max) # Ângulo inicial melhor (35 graus)
			_cam_pitch = _cam_target_pitch
	if _grid_map:
		_grid_map.clear() # Limpa dados antigos da cena
		if use_runtime_mesh_library:
			_grid_map.mesh_library = _make_runtime_mesh_library()
		_apply_grid_cell_size()
	
	_prepare_noise()
	
	# Seed Logic
	if use_random_seed:
		randomize()
		world_seed = randi()
	else:
		# Tenta converter string para int (funciona para números grandes como 1234567891011)
		if world_seed_string.is_valid_int():
			world_seed = world_seed_string.to_int()
		else:
			# Se for texto (ex: "Minecraft"), usa o hash
			world_seed = world_seed_string.hash()
			
	print("World Seed: ", world_seed)
	
	_noise.seed = int(world_seed)
	_mountain_noise.seed = int(world_seed + 2)
	_biome_noise.seed = int(world_seed + 1)
	
	_prepare_tree_templates()
	_prepare_grass_templates()
	
	if world_generate_on_ready:
		_update_chunks_around_player(true) # Force immediate load on start
		
	if _player:
		# Place player on ground at (0,0) initially if falling
		var py := _get_terrain_height(0, 0) + 2
		_player.global_position = Vector3(0, py * grid_cell_size.y, 0)

	_setup_crosshair()
	_setup_mobile_controls()

func _process(delta: float) -> void:
	if _player:
		_update_chunks_around_player(false)
		_process_chunk_loading()
		
	if not _player or not _camera:
		return
	_update_camera(delta)

func _exit_tree() -> void:
	_cleanup_runtime_nodes()

func _cleanup_runtime_nodes() -> void:
	for chunk_pos in _chunk_trees:
		var arr = _chunk_trees[chunk_pos]
		if arr is Array:
			for n in arr:
				if is_instance_valid(n):
					(n as Node).free()
	_chunk_trees.clear()
	_loaded_chunks.clear()
	_chunks_to_load.clear()

	for t in _tree_templates:
		if is_instance_valid(t):
			(t as Node).free()
	_tree_templates.clear()

	for g in _grass_templates:
		if is_instance_valid(g):
			(g as Node).free()
	_grass_templates.clear()

func _prepare_noise() -> void:
	_noise = FastNoiseLite.new()
	_noise.seed = world_seed
	_noise.frequency = terrain_height_frequency
	_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	_noise.fractal_octaves = 3
	
	_mountain_noise = FastNoiseLite.new()
	_mountain_noise.seed = world_seed + 2
	_mountain_noise.frequency = terrain_mountain_frequency
	_mountain_noise.fractal_type = FastNoiseLite.FRACTAL_RIDGED
	_mountain_noise.fractal_octaves = 5
	_mountain_noise.fractal_lacunarity = 2.0
	_mountain_noise.fractal_gain = 0.5
	
	_biome_noise = FastNoiseLite.new()
	_biome_noise.seed = world_seed + 1
	_biome_noise.frequency = biome_frequency

func _prepare_tree_templates() -> void:
	_tree_templates_exact = false
	_tree_templates.clear()

	if trees_prefer_scene_template and not trees_template_name.is_empty():
		var named_template := find_child(trees_template_name, true, false)
		if named_template:
			var t := (named_template as Node).duplicate()
			_apply_tree_visual_overrides_recursive(t)
			_apply_collision_overrides_recursive(t)
			_tree_templates.append(t)
			_tree_templates_exact = trees_use_exact_template
			if named_template is Node3D:
				(named_template as Node3D).visible = false

	var trees_node := get_node_or_null(^"arvores") as Node3D
	if not trees_node:
		trees_node = find_child("arvores", true, false) as Node3D
	
	if trees_node:
		if _tree_templates.is_empty():
			for n in trees_node.get_children():
				if n is Node:
					var t := (n as Node).duplicate()
					_apply_tree_visual_overrides_recursive(t)
					_apply_collision_overrides_recursive(t)
					_tree_templates.append(t)
		# Clear existing placeholders
		for n in trees_node.get_children():
			n.queue_free()
	
	# Fallback if no trees found in scene
	if _tree_templates.is_empty():
		# Also try to add the sprite if texture exists, as a second option
		var base_texture: Texture2D = trees_texture_override if trees_texture_override else default_tree_texture
		if base_texture:
			var s := Sprite3D.new()
			s.texture = base_texture
			s.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			s.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
			s.pixel_size = 0.04
			s.centered = true
			s.offset = Vector2(0, float(base_texture.get_height()) * 0.5)
			s.visible = true
			_apply_tree_visual_overrides(s)
			_tree_templates.append(s)
		else:
			# Create a simple Green Box tree for debugging/fallback
			var mesh_instance := MeshInstance3D.new()
			var mesh := BoxMesh.new()
			mesh.size = Vector3(0.4, 1.5, 0.4)
			var mat := StandardMaterial3D.new()
			mat.albedo_color = Color(0.0, 0.8, 0.0) # Green
			mesh.material = mat
			mesh_instance.mesh = mesh
			mesh_instance.position.y = 0.75 # Pivot offset (half height)
			
			# Wrap in a Node3D to act as the pivot/base like the Sprite3D would
			var container := Node3D.new()
			container.add_child(mesh_instance)
			
			_tree_templates.append(container)
	
	# Create a clean container if needed, but we will spawn trees dynamically
	if not trees_node:
		trees_node = Node3D.new()
		trees_node.name = "arvores"
		add_child(trees_node)
	
	_trees_root = trees_node

func _prepare_grass_templates() -> void:
	_grass_templates_exact = false
	_grass_templates.clear()
	if not grass_generate_on_ready:
		return
	if grass_prefer_scene_templates and not grass_template_names.is_empty():
		for n in grass_template_names:
			if n.is_empty():
				continue
			var t := find_child(n, true, false)
			if t:
				var g := (t as Node).duplicate()
				_apply_tree_visual_overrides_recursive(g)
				_apply_collision_overrides_recursive(g)
				_grass_templates.append(g)
				if t is Node3D:
					(t as Node3D).visible = false
		_grass_templates_exact = grass_use_exact_template

func _apply_tree_visual_overrides(s: Sprite3D) -> void:
	if trees_texture_override:
		s.texture = trees_texture_override
	if trees_region_override_enabled:
		s.region_enabled = true
		s.region_rect = trees_region_override_rect

func _apply_tree_visual_overrides_recursive(n: Node) -> void:
	if n is Sprite3D:
		_apply_tree_visual_overrides(n as Sprite3D)
	for c in n.get_children():
		if c is Node:
			_apply_tree_visual_overrides_recursive(c as Node)

func _apply_collision_overrides_recursive(n: Node) -> void:
	if n is CollisionObject3D:
		(n as CollisionObject3D).collision_layer = vegetation_collision_layer
		(n as CollisionObject3D).collision_mask = vegetation_collision_mask
	for c in n.get_children():
		if c is Node:
			_apply_collision_overrides_recursive(c as Node)

func _node_has_collision(n: Node) -> bool:
	if n is CollisionShape3D:
		return true
	if n is CollisionObject3D:
		for c in n.get_children():
			if c is CollisionShape3D:
				return true
	for c in n.get_children():
		if c is Node and _node_has_collision(c as Node):
			return true
	return false

func _find_first_sprite3d(n: Node) -> Sprite3D:
	if n is Sprite3D:
		return n as Sprite3D
	for c in n.get_children():
		if c is Node:
			var s := _find_first_sprite3d(c as Node)
			if s:
				return s
	return null

func _get_chunk_pos(world_pos: Vector3) -> Vector2i:
	var _cx := int(floor(world_pos.x / (chunk_size * grid_cell_size.x)))
	var _cz := int(floor(world_pos.z / (chunk_size * grid_cell_size.z)))
	return Vector2i(_cx, _cz)

func _chunk_seed(chunk_pos: Vector2i) -> int:
	var s := int(world_seed)
	s = s ^ int(chunk_pos.x) * 73856093
	s = s ^ int(chunk_pos.y) * 19349663
	s = s ^ (s >> 13)
	s = s * 1274126177
	s = s ^ (s >> 16)
	return s & 0x7fffffff

func _update_chunks_around_player(immediate: bool) -> void:
	if not _player:
		return
		
	var current_chunk := _get_chunk_pos(_player.global_position)
	if current_chunk == _last_player_chunk and not immediate:
		return
		
	_last_player_chunk = current_chunk
	
	var needed_chunks: Dictionary = {}
	
	for x in range(-view_distance_chunks, view_distance_chunks + 1):
		for z in range(-view_distance_chunks, view_distance_chunks + 1):
			var dist_sq := x*x + z*z
			if dist_sq <= view_distance_chunks * view_distance_chunks:
				var chunk_pos := current_chunk + Vector2i(x, z)
				needed_chunks[chunk_pos] = true
	
	# Unload old chunks
	var to_unload: Array[Vector2i] = []
	for chunk_pos in _loaded_chunks:
		if not needed_chunks.has(chunk_pos):
			to_unload.append(chunk_pos)
	
	for chunk_pos in to_unload:
		_unload_chunk(chunk_pos)
		
	# Queue new chunks
	_chunks_to_load.clear()
	# Prioritize closest chunks
	var sorted_needed: Array[Vector2i] = []
	for chunk_pos in needed_chunks:
		if not _loaded_chunks.has(chunk_pos):
			sorted_needed.append(chunk_pos)
			
	sorted_needed.sort_custom(func(a, b):
		return a.distance_squared_to(current_chunk) < b.distance_squared_to(current_chunk)
	)
	
	_chunks_to_load.append_array(sorted_needed)
	
	if immediate:
		while not _chunks_to_load.is_empty():
			_load_next_chunk()

func _process_chunk_loading() -> void:
	if _chunks_to_load.is_empty():
		return
	
	for i in range(_load_speed):
		if _chunks_to_load.is_empty():
			break
		_load_next_chunk()

func _load_next_chunk() -> void:
	var chunk_pos = _chunks_to_load.pop_front()
	if _loaded_chunks.has(chunk_pos):
		return
	_generate_chunk(chunk_pos)
	_loaded_chunks[chunk_pos] = true

func _unload_chunk(chunk_pos: Vector2i) -> void:
	if not _loaded_chunks.has(chunk_pos):
		return
	_loaded_chunks.erase(chunk_pos)
	
	# Clear grid cells - Optimized: Recalculate height to avoid iterating air
	var start_x := chunk_pos.x * chunk_size
	var start_z := chunk_pos.y * chunk_size
	for x in range(chunk_size):
		for z in range(chunk_size):
			var cx := start_x + x
			var cz := start_z + z
			
			# Recalculate height to know exactly what to clear
			var height := _calc_height(cx, cz, _noise, _mountain_noise)
			var y := terrain_base_y + height
			
			# Clear only the relevant vertical column (Ground + Water + Potential Trees/Structures)
			# Clearing a bit above for trees (e.g. +10) and below for fill (+depth)
			var top_clear = y + 15 + chunk_clear_extra_above
			var bottom_clear = y - maxi(terrain_fill_depth, 5) - 1 - chunk_clear_extra_below
			if y <= terrain_water_level:
				top_clear = max(top_clear, terrain_water_level + 1)
				
			for cy in range(bottom_clear, top_clear):
				_grid_map.set_cell_item(Vector3i(cx, cy, cz), -1)
	
	# Clear trees
	if _chunk_trees.has(chunk_pos):
		for node in _chunk_trees[chunk_pos]:
			if is_instance_valid(node):
				node.queue_free()
		_chunk_trees.erase(chunk_pos)

func _get_terrain_height(cx: int, cz: int) -> int:
	return _calc_height(cx, cz, _noise, _mountain_noise) + terrain_base_y

func _generate_chunk(chunk_pos: Vector2i) -> void:
	_ensure_grid_map()
	
	var start_x := chunk_pos.x * chunk_size
	var start_z := chunk_pos.y * chunk_size
	
	var new_trees: Array[Node] = []
	var rng := RandomNumberGenerator.new()
	rng.seed = _chunk_seed(chunk_pos)
	
	for x in range(chunk_size):
		for z in range(chunk_size):
			var cx := start_x + x
			var cz := start_z + z
			
			var height := _calc_height(cx, cz, _noise, _mountain_noise)
			var y := terrain_base_y + height
			var surface_id := _calc_surface_id(cx, cz, _biome_noise)
			
			var is_underwater := y <= terrain_water_level and terrain_water_item_id != -1
			
			if is_underwater:
				# Underwater ground (sand)
				for dy in range(maxi(terrain_fill_depth, 0)):
					_grid_map.set_cell_item(Vector3i(cx, y - 1 - dy, cz), terrain_fill_item_id)
				_grid_map.set_cell_item(Vector3i(cx, y, cz), biome_sand_item_id)
				
				# Water above
				for wy in range(y + 1, terrain_water_level + 1):
					_grid_map.set_cell_item(Vector3i(cx, wy, cz), terrain_water_item_id)
			else:
				# --- Camadas de Solo ---
				# 1. Superfície (Grama ou Areia/Pedra dependendo do bioma)
				_grid_map.set_cell_item(Vector3i(cx, y, cz), surface_id)
				
				# 2. Terra (2 camadas abaixo da superfície)
				# IDs: 0=Grama, 1=Terra, 2=Pedra
				var dirt_id := terrain_dirt_item_id
				for dy in range(1, 3): # y-1 e y-2
					_grid_map.set_cell_item(Vector3i(cx, y - dy, cz), dirt_id)
					
				# 3. Pedra (3 camadas abaixo da terra)
				var stone_id := terrain_stone_item_id
				for dy in range(3, 6): # y-3, y-4, y-5
					_grid_map.set_cell_item(Vector3i(cx, y - dy, cz), stone_id)
					
				# Opcional: Preencher o resto com pedra até o fundo do chunk se necessário
				# for dy in range(6, terrain_fill_depth + 6):
				# 	_grid_map.set_cell_item(Vector3i(cx, y - dy, cz), stone_id)
			
			# Trees
			if not is_underwater and trees_generate_on_ready and not _tree_templates.is_empty() and _trees_root:
				# Simple chance check
				if rng.randf() < trees_chance:
					# Check if valid spot (not underwater)
					var ok_place := true
					if trees_place_on_grass_only:
						var surface_item := _grid_map.get_cell_item(Vector3i(cx, y, cz))
						if not trees_spawn_item_ids.has(surface_item):
							ok_place = false
					
					if ok_place:
						# Seed already set above
						
						# Clone the template
						var t_idx := rng.randi_range(0, _tree_templates.size() - 1)
						var t := (_tree_templates[t_idx] as Node).duplicate()
							
						_trees_root.add_child(t)
						new_trees.append(t)
						
						# Setup physics for new tree
						if t is Sprite3D:
							_apply_tree_visual_overrides(t as Sprite3D)
							if trees_hitbox_enabled:
								_setup_single_tree_physics(t as Sprite3D)
						else:
							_apply_tree_visual_overrides_recursive(t)
							if trees_hitbox_enabled and not _node_has_collision(t):
								var s3d := _find_first_sprite3d(t)
								if s3d:
									_setup_single_tree_physics(s3d)
								else:
									var body := StaticBody3D.new()
									var shape := BoxShape3D.new()
									shape.size = Vector3(0.4, 1.5, 0.4)
									var cs := CollisionShape3D.new()
									cs.shape = shape
									cs.position.y = 0.75
									body.add_child(cs)
									t.add_child(body)
						
						if t is Node3D:
							var t3d := t as Node3D
							if not _tree_templates_exact:
								t3d.rotation.y = rng.randf_range(0.0, TAU)
								var sc := rng.randf_range(trees_random_scale.x, trees_random_scale.y)
								t3d.scale = Vector3.ONE * sc
							
							var world_pos := _grid_map.to_global(_grid_map.map_to_local(Vector3i(cx, y, cz)))
							var y_off := trees_y_offset
							
							if trees_snap_to_block_top:
								y_off += float(_grid_map.cell_size.y) * 0.5
								
							if trees_auto_lift_to_ground and not _tree_templates_exact:
								var s := _find_first_sprite3d(t)
								if s:
									var aabb: AABB = s.get_aabb()
									y_off += -float(aabb.position.y) * t3d.scale.y
							
							y_off -= trees_sink_into_ground
								
							t3d.global_position = world_pos + Vector3(0.0, y_off, 0.0)
							t3d.visible = true

			# Grass
			if not is_underwater and grass_generate_on_ready and not _grass_templates.is_empty() and _trees_root:
				if rng.randf() < grass_chance:
					var ok_grass := true
					if grass_place_on_grass_only:
						var surface_item := _grid_map.get_cell_item(Vector3i(cx, y, cz))
						if not grass_spawn_item_ids.has(surface_item):
							ok_grass = false
					if ok_grass:
						var g_idx := rng.randi_range(0, _grass_templates.size() - 1)
						var g := (_grass_templates[g_idx] as Node).duplicate()
						_trees_root.add_child(g)
						new_trees.append(g)
						if g is Node3D:
							var g3d := g as Node3D
							if not _grass_templates_exact:
								g3d.rotation.y = rng.randf_range(0.0, TAU)
								var gsc := rng.randf_range(grass_random_scale.x, grass_random_scale.y)
								g3d.scale = Vector3.ONE * gsc
							var g_world_pos := _grid_map.to_global(_grid_map.map_to_local(Vector3i(cx, y, cz)))
							var gy_off := grass_y_offset
							if grass_snap_to_block_top:
								gy_off += float(_grid_map.cell_size.y) * 0.5
							if grass_auto_lift_to_ground and not _grass_templates_exact:
								var gs := _find_first_sprite3d(g)
								if gs:
									var gaabb := gs.get_aabb()
									gy_off += -float(gaabb.position.y) * g3d.scale.y
							g3d.global_position = g_world_pos + Vector3(0.0, gy_off, 0.0)
							g3d.visible = true

	if not new_trees.is_empty():
		_chunk_trees[chunk_pos] = new_trees

func _setup_single_tree_physics(s: Sprite3D) -> void:
	if s.has_node(^"CollisionBody"):
		return
	var aabb := s.get_aabb()
	var base_h := maxf(aabb.size.y, trees_hitbox_height_min)
	var h := base_h * trees_hitbox_height_scale
	var base_r := maxf(aabb.size.x, aabb.size.z) * 0.18
	var r := clampf(base_r * trees_hitbox_radius_scale, trees_hitbox_radius_min, trees_hitbox_radius_max)
	var body := StaticBody3D.new()
	body.name = "CollisionBody"
	body.collision_layer = vegetation_collision_layer
	body.collision_mask = vegetation_collision_mask
	body.transform = Transform3D.IDENTITY
	var cs := CollisionShape3D.new()
	var shape := CylinderShape3D.new()
	shape.radius = r
	shape.height = h
	cs.shape = shape
	cs.position = Vector3(0.0, float(aabb.position.y) + trees_hitbox_y_extra + (h * 0.5), 0.0)
	body.add_child(cs)
	s.add_child(body)

func _unhandled_input(event: InputEvent) -> void:
	if not _player or not _camera:
		return

	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == camera_rotate_button:
			if mb.pressed:
				_set_camera_rotating(true)
			return
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				# Se clicar na tela (não em UI), captura o mouse se não estiver
				if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED and not _mobile_ui:
					_set_camera_rotating(true)
				elif _grid_map:
					_try_place_block()
			return
		if mb.button_index == MOUSE_BUTTON_MIDDLE:
			_set_camera_rotating(mb.pressed)
			return
		if mb.button_index == MOUSE_BUTTON_WHEEL_UP and mb.pressed:
			_cam_target_dist = clampf(_cam_target_dist - camera_zoom_step, camera_min_distance, camera_max_distance)
			return
		if mb.button_index == MOUSE_BUTTON_WHEEL_DOWN and mb.pressed:
			_cam_target_dist = clampf(_cam_target_dist + camera_zoom_step, camera_min_distance, camera_max_distance)
			return

	# Mobile Touch Look (Simples)
	if event is InputEventScreenDrag:
		# Se não estiver tocando em controles de UI (assumindo que UI consome o evento se necessário)
		# Uma lógica simples de "arrastar na tela gira a câmera"
		# Idealmente verificaríamos se não está tocando no joystick virtual
		var drag = event as InputEventScreenDrag
		# Apenas se o toque não começou em uma área de UI (ex: joystick esquerdo)
		# Como simplificação: se for na metade direita da tela
		var screen_size = get_viewport().get_visible_rect().size
		if drag.position.x > screen_size.x * 0.4:
			_cam_last_input_time = Time.get_ticks_msec() / 1000.0
			var sx := -1.0 if camera_invert_x else 1.0
			var sy := -1.0 if camera_invert_y else 1.0
			# Sensibilidade específica para touch
			var touch_sens := 0.005 
			_cam_target_yaw -= drag.relative.x * touch_sens * sx
			_cam_target_yaw = wrapf(_cam_target_yaw, -PI, PI)
			_cam_target_pitch = clampf(_cam_target_pitch + drag.relative.y * touch_sens * sy, camera_pitch_min, camera_pitch_max)
			return

	if event is InputEventMouseMotion:
		if _cam_rotating:
			_cam_last_input_time = Time.get_ticks_msec() / 1000.0
			var mm := event as InputEventMouseMotion
			var sx := -1.0 if camera_invert_x else 1.0
			var sy := -1.0 if camera_invert_y else 1.0
			_cam_target_yaw += mm.relative.x * camera_yaw_sensitivity * sx
			_cam_target_yaw = wrapf(_cam_target_yaw, -PI, PI)
			_cam_target_pitch = clampf(_cam_target_pitch + mm.relative.y * camera_pitch_sensitivity * sy, camera_pitch_min, camera_pitch_max)
		return

	if event is InputEventKey and event.pressed and not event.echo:
		var k := event as InputEventKey
		if k.keycode == KEY_ESCAPE:
			_set_camera_rotating(false)
			return
		if k.keycode == KEY_E and _grid_map:
			_try_place_block()
			return
		if k.keycode == KEY_Q and _grid_map:
			_try_remove_block()
			return
		if k.keycode == KEY_TAB:
			_set_build_item_index(build_item_index + 1)
			return
		if k.keycode >= KEY_1 and k.keycode <= KEY_9:
			_set_build_item_index(int(k.keycode - KEY_1))
			return

func _try_place_block() -> void:
	var hit := _get_build_hit()
	if hit.is_empty():
		return
	var world_pos: Vector3 = hit.position
	var normal: Vector3 = hit.normal
	# Ajuste para meios blocos no eixo Y
	var cell := _world_to_cell(world_pos + normal * (grid_cell_size.y * 0.51))
	if _grid_map.get_cell_item(cell) != -1:
		return
	if not allow_build_floating and not _has_attachment(cell):
		return
	_grid_map.set_cell_item(cell, _get_selected_item_id())

func _try_remove_block() -> void:
	var hit := _get_build_hit()
	if hit.is_empty():
		return
	var world_pos: Vector3 = hit.position
	var normal: Vector3 = hit.normal
	# Ajuste fino para pegar o bloco certo ao mirar
	var cell := _world_to_cell(world_pos - normal * 0.05)
	
	var item := _grid_map.get_cell_item(cell)
	
	# Se não achou nada (as vezes o raycast pega a beirada), tenta um pouco mais fundo
	if item == -1:
		cell = _world_to_cell(world_pos - normal * 0.2)
		item = _grid_map.get_cell_item(cell)
		
	if item == -1:
		return
		
	# Verifica se está na lista de protegidos (agora vazia por padrão)
	if protected_item_ids.has(item):
		return
		
	_grid_map.set_cell_item(cell, -1)
	
	# Efeito visual ou sonoro de quebra poderia ser adicionado aqui
	print("Quebrou bloco: ", item, " em ", cell)

func _get_build_hit() -> Dictionary:
	if not _camera:
		return {}
	var from_pos := _camera.global_position
	var dir := -_camera.global_transform.basis.z
	var to_pos := from_pos + dir * build_raycast_distance
	var params := PhysicsRayQueryParameters3D.new()
	params.from = from_pos
	params.to = to_pos
	params.collision_mask = build_raycast_mask
	if _player:
		params.exclude = [_player.get_rid()]
	return get_world_3d().direct_space_state.intersect_ray(params)

func _get_selected_item_id() -> int:
	if build_item_ids.size() <= 0:
		return build_item_id
	var idx := clampi(build_item_index, 0, build_item_ids.size() - 1)
	return int(build_item_ids[idx])

func _set_build_item_index(new_index: int) -> void:
	if build_item_ids.size() <= 0:
		return
	build_item_index = wrapi(new_index, 0, build_item_ids.size())
	_sync_selected_build_item()

func _sync_selected_build_item() -> void:
	build_item_id = _get_selected_item_id()

func _world_to_cell(world_pos: Vector3) -> Vector3i:
	var local_pos := _grid_map.to_local(world_pos)
	return _grid_map.local_to_map(local_pos)

func _has_attachment(cell: Vector3i) -> bool:
	if cell.y <= 0:
		return true
	var neighbors := [
		Vector3i(1, 0, 0), Vector3i(-1, 0, 0),
		Vector3i(0, 1, 0), Vector3i(0, -1, 0),
		Vector3i(0, 0, 1), Vector3i(0, 0, -1),
	]
	for d in neighbors:
		if _grid_map.get_cell_item(cell + d) != -1:
			return true
	return false

func _apply_grid_cell_size() -> void:
	_grid_map.cell_size = grid_cell_size

func _ensure_grid_map() -> void:
	if _grid_map:
		return
	var parent := find_child("MeshInstance3D", true, false) as Node3D
	if not parent:
		parent = self
	var gm := GridMap.new()
	gm.name = "GridMap"
	gm.collision_layer = 2
	gm.collision_mask = 0
	parent.add_child(gm)
	_grid_map = gm
	_apply_grid_cell_size()
	if use_runtime_mesh_library:
		_grid_map.mesh_library = _make_runtime_mesh_library()

func _calc_height(cx: int, cz: int, base_noise: FastNoiseLite, mountain_noise: FastNoiseLite) -> int:
	var height := 0
	if terrain_height_enabled:
		var n := base_noise.get_noise_2d(float(cx), float(cz))
		height += int(round(((n + 1.0) * 0.5) * float(terrain_height_max)))
	if terrain_mountains_enabled:
		var m := (mountain_noise.get_noise_2d(float(cx), float(cz)) + 1.0) * 0.5
		var t := (m - terrain_mountain_threshold) / maxf(1.0 - terrain_mountain_threshold, 0.001)
		t = clampf(t, 0.0, 1.0)
		height += int(round(pow(t, terrain_mountain_power) * float(terrain_mountain_height_max)))
	return height

func _calc_surface_id(cx: int, cz: int, biome_noise: FastNoiseLite) -> int:
	# Priorizar Grama (0) como padrão absoluto
	var surface_id := terrain_surface_item_id
	
	if not biomes_enabled:
		return surface_id
		
	var b := (biome_noise.get_noise_2d(float(cx), float(cz)) + 1.0) * 0.5
	
	# Ajustado para que a maior parte do mundo seja Grama (entre 0.22 e 0.82)
	if b < biome_sand_max:
		return biome_sand_item_id
	if b > biome_rock_min:
		return biome_rock_item_id
		
	# Removida a variação "Grama 2" para garantir uniformidade visual por enquanto
	# if b >= biome_grass2_min and b <= biome_grass2_max:
	# 	return biome_grass2_item_id
		
	return surface_id

func _make_runtime_mesh_library() -> MeshLibrary:
	if not blocks_scene:
		push_error("Blocks Scene not assigned!")
		return MeshLibrary.new()
		
	var ml := MeshLibrary.new()
	var _scene_state = blocks_scene.get_state()
	# Precisamos instanciar para ler meshes e collision shapes corretamente
	var root = blocks_scene.instantiate()
	
	var id_counter := 0
	for child in root.get_children():
		if child is MeshInstance3D:
			ml.create_item(id_counter)
			ml.set_item_name(id_counter, child.name)
			
			# Precisamos duplicar o mesh para aplicar o material específico deste bloco,
			# já que no blocks.tscn eles compartilham o mesmo mesh mas usam material_override
			var mesh = child.mesh.duplicate()
			if child.material_override:
				mesh.material = child.material_override
			elif child.get_surface_override_material(0):
				mesh.material = child.get_surface_override_material(0)
				
			ml.set_item_mesh(id_counter, mesh)
			
			# Collisions
			var static_body = child.get_node_or_null("StaticBody3D")
			if static_body:
				var collision_shape = static_body.get_node_or_null("CollisionShape3D")
				if collision_shape and collision_shape.shape:
					ml.set_item_shapes(id_counter, [collision_shape.shape, collision_shape.transform])
			
			id_counter += 1
			
	root.queue_free()
	return ml

func _set_camera_rotating(enabled: bool) -> void:
	_cam_rotating = enabled
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if enabled else Input.MOUSE_MODE_VISIBLE

func apply_look_joystick(look_rate: Vector2, delta: float) -> void:
	if look_rate.length_squared() > 0.001:
		_cam_last_input_time = Time.get_ticks_msec() / 1000.0
	_cam_target_yaw = wrapf(_cam_target_yaw + look_rate.x * delta, -PI, PI)
	_cam_target_pitch = clampf(_cam_target_pitch + look_rate.y * delta, camera_pitch_min, camera_pitch_max)

func request_place() -> void:
	if _grid_map:
		_try_place_block()

func request_remove() -> void:
	if _grid_map:
		_try_remove_block()

func _update_camera(delta: float) -> void:
	_camera.fov = camera_fov
	
	var target_pos := _player.global_position + camera_target_offset
	
	# Smooth Horizontal
	var target_h := Vector3(target_pos.x, 0, target_pos.z)
	var current_h := Vector3(_camera_pivot.x, 0, _camera_pivot.z)
	var t_h := 1.0 - exp(-camera_follow_speed_horizontal * delta)
	var next_h := current_h.lerp(target_h, t_h)
	
	# Smooth Vertical (Damped)
	var target_y := target_pos.y
	var current_y := _camera_pivot.y
	var t_v := 1.0 - exp(-camera_follow_speed_vertical * delta)
	
	# Se estiver caindo (target menor que current), suaviza ainda mais
	if target_y < current_y:
		t_v *= 0.5
		
	var next_y := lerpf(current_y, target_y, t_v)
	
	# Aplica o movimento suave calculado
	_camera_pivot = Vector3(next_h.x, next_y, next_h.z)
	
	# Clamp Pivot to Player Range (Hard Limit) - Safer implementation
	# Se a câmera estiver muito longe (ex: > 3 blocos), puxa ela instantaneamente
	# Isso impede que o personagem saia da tela mesmo se estiver correndo muito rápido
	var dist_to_player := Vector2(_camera_pivot.x, _camera_pivot.z).distance_to(Vector2(target_pos.x, target_pos.z))
	if dist_to_player > 3.0:
		var dir_to_target := (_camera_pivot - target_pos).normalized()
		var ideal_pos := target_pos + dir_to_target * 3.0
		# Mantém Y suave, mas corrige X/Z na marra
		_camera_pivot.x = ideal_pos.x
		_camera_pivot.z = ideal_pos.z

	# Auto-follow direction (Fixed Camera Behavior)
	if camera_auto_follow_direction:
		# Verifica se o jogador está se movendo
		var vel := _player.velocity
		var speed_sq := vel.x * vel.x + vel.z * vel.z
		
		# Se estiver andando, a câmera DEVE alinhar atrás do jogador
		if speed_sq > 0.1:
			# Se o jogador estiver girando manualmente (touch/mouse), damos uma pausa no auto-follow
			# Mas se ele só estiver andando, a câmera segue firme
			var time_since_input := Time.get_ticks_msec() / 1000.0 - _cam_last_input_time
			if time_since_input > camera_auto_follow_delay:
				# Use -vel.x, -vel.z so the camera aligns behind the player looking forward
				var target_angle := atan2(-vel.x, -vel.z)
				
				# Rotação mais rápida para "fixar" a visão na direção do movimento
				var follow_factor := 1.0 - exp(-camera_auto_follow_speed * delta)
				
				# Interpolação angular suave mas firme
				_cam_target_yaw = lerp_angle(_cam_target_yaw, target_angle, follow_factor)

	var rot_t := 1.0 - exp(-camera_rotation_speed * delta)
	_cam_yaw = lerp_angle(_cam_yaw, _cam_target_yaw, rot_t)
	_cam_pitch = lerpf(_cam_pitch, _cam_target_pitch, rot_t)

	var zoom_t := 1.0 - exp(-camera_zoom_speed * delta)
	_cam_dist = lerpf(_cam_dist, _cam_target_dist, zoom_t)

	var cos_p := cos(_cam_pitch)
	var dir := Vector3(sin(_cam_yaw) * cos_p, sin(_cam_pitch), cos(_cam_yaw) * cos_p).normalized()
	
	# Calcula posição desejada ideal (sem colisão)
	var desired_target := _camera_pivot + dir * _cam_dist
	
	# Aplica colisão
	var final_pos := _apply_camera_collision(_camera_pivot, desired_target, dir, delta)
	
	# Verificação extra de altura do terreno (aplicada sobre a posição final)
	if _grid_map:
		var _map_pos := _grid_map.local_to_map(_grid_map.to_local(final_pos))
		var _cx := int(floor(final_pos.x / (chunk_size * grid_cell_size.x)))
		var _cz := int(floor(final_pos.z / (chunk_size * grid_cell_size.z)))
		
		# Pega altura do terreno na posição da câmera
		var terrain_h_y = _get_terrain_height(_map_pos.x, _map_pos.z) * grid_cell_size.y
		
		# Mantém a câmera pelo menos 1.0 bloco acima do terreno calculado
		var min_y = terrain_h_y + 1.0
		if final_pos.y < min_y:
			final_pos.y = lerpf(final_pos.y, min_y, 15.0 * delta)
			
	_camera.global_position = final_pos
	if _camera.global_position.distance_squared_to(_camera_pivot) > 0.001:
		_camera.look_at(_camera_pivot, Vector3.UP)

func _apply_camera_collision(from_pos: Vector3, to_pos: Vector3, dir: Vector3, _delta: float) -> Vector3:
	var space := get_world_3d().direct_space_state
	var params := PhysicsRayQueryParameters3D.new()
	params.from = from_pos
	params.to = to_pos
	params.collision_mask = camera_collision_mask
	if _player:
		params.exclude = [_player.get_rid()]
	
	var hit := space.intersect_ray(params)
	var target_dist := _cam_dist
	
	if not hit.is_empty():
		var hit_pos: Vector3 = hit.position
		# Se bateu, queremos encurtar a distância imediatamente
		var hit_dist := from_pos.distance_to(hit_pos) - camera_collision_margin
		target_dist = clampf(hit_dist, camera_min_distance, _cam_dist)
	
	return from_pos + dir * target_dist

func _setup_crosshair() -> void:
	if not crosshair_enabled:
		return
	if has_node(^"HUD"):
		return
	var hud := CanvasLayer.new()
	hud.name = "HUD"
	hud.layer = 20
	add_child(hud)
	var root := Control.new()
	root.name = "Root"
	root.anchor_left = 0.0
	root.anchor_top = 0.0
	root.anchor_right = 1.0
	root.anchor_bottom = 1.0
	root.offset_left = 0.0
	root.offset_top = 0.0
	root.offset_right = 0.0
	root.offset_bottom = 0.0
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(root)
	var v := ColorRect.new()
	v.name = "CrosshairV"
	v.color = crosshair_color
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.anchor_left = 0.5
	v.anchor_top = 0.5
	v.anchor_right = 0.5
	v.anchor_bottom = 0.5
	v.offset_left = -crosshair_thickness * 0.5
	v.offset_right = crosshair_thickness * 0.5
	v.offset_top = -crosshair_size
	v.offset_bottom = crosshair_size
	root.add_child(v)
	var h := ColorRect.new()
	h.name = "CrosshairH"
	h.color = crosshair_color
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.anchor_left = 0.5
	h.anchor_top = 0.5
	h.anchor_right = 0.5
	h.anchor_bottom = 0.5
	h.offset_left = -crosshair_size
	h.offset_right = crosshair_size
	h.offset_top = -crosshair_thickness * 0.5
	h.offset_bottom = crosshair_thickness * 0.5
	root.add_child(h)

func _setup_mobile_controls() -> void:
	if not mobile_controls_enabled:
		return
	var is_mobile := mobile_controls_force_show or OS.has_feature("mobile") or DisplayServer.is_touchscreen_available()
	if not is_mobile:
		return
	var scene := load("res://ui/mobile_controls.tscn")
	if not scene:
		return
	var ui := (scene as PackedScene).instantiate() as CanvasLayer
	if not ui:
		return
	_mobile_ui = ui
	add_child(ui)
	ui.world = self
	_set_camera_rotating(false)
