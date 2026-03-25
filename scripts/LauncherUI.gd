extends Node3D
class_name LauncherUI

# References for card spawning
@export var dart_data: CardData
@export var hammer_data: CardData
@export var magnet_data: CardData
@export var shield_data: CardData

# Reference to the Projectile scene template
@export var projectile_scene: PackedScene 

# Trajectory Visualization (using MeshInstance3D with Cylinder or Tube inside child)
@onready var trajectory_line: MeshInstance3D = $TrajectoryLine

var is_dragging: bool = false
var drag_start: Vector3 = Vector3.ZERO
var drag_end: Vector3 = Vector3.ZERO
var active_data: CardData

# Simple state for which card is currently "selected"
var selected_card_type: int = CardData.Type.DART

func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_on_drag_start()
			else:
				_on_drag_end()

	if event is InputEventMouseMotion and is_dragging:
		_on_drag_motion()

func _on_drag_start():
	var mouse_pos = get_viewport().get_mouse_position()
	drag_start = _project_mouse_to_plane(mouse_pos)
	is_dragging = true
	# Select data based on card UI index (for now, default to DART or use signal)
	active_data = _get_data_by_type(selected_card_type)
	trajectory_line.visible = true

func _on_drag_motion():
	var mouse_pos = get_viewport().get_mouse_position()
	drag_end = _project_mouse_to_plane(mouse_pos)
	_update_trajectory_visual()

func _on_drag_end():
	if not is_dragging: return
	is_dragging = false
	trajectory_line.visible = false
	
	# Consume energy and launch
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager and game_manager.use_energy(active_data.energy_cost):
		_launch_projectile()

func _launch_projectile():
	# Calculate launch direction: from end to start (pulling back creates forward velocity)
	var launch_dir = (drag_start - drag_end).normalized()
	# Or keep it from start to end? Let's assume start to end for simplicity or pull-back like a bow
	# User wants "Drag & Shoot", pulling back makes more sense for a "launcher".
	
	var projectile = projectile_scene.instantiate() as Projectile
	get_parent().add_child(projectile) # Spawn into world
	projectile.global_position = drag_start
	projectile.data = active_data
	
	# Apply block if it's a defensive card
	if active_data.type == CardData.Type.SHIELD:
		var game_manager = get_tree().get_first_node_in_group("game_manager")
		if game_manager:
			game_manager.add_block(active_data.block_amount)
	
	projectile.launch(launch_dir)

func _update_trajectory_visual():
	# Setup height and rotation of a mesh to form an arrow/line
	var diff = drag_end - drag_start
	var distance = diff.length()
	if distance < 0.1: return
	
	trajectory_line.scale.z = distance
	trajectory_line.global_position = drag_start + (diff / 2.0)
	trajectory_line.look_at(drag_end, Vector3.UP)

func _project_mouse_to_plane(mouse_pos: Vector2) -> Vector3:
	var camera = get_viewport().get_camera_3d()
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_dir = camera.project_ray_normal(mouse_pos)
	
	# Horizontal plane at Y = 0.5 (where objects slide)
	var plane = Plane(Vector3.UP, 0.5)
	var pos = plane.intersects_ray(ray_origin, ray_dir)
	return pos if pos != null else Vector3.ZERO

func _get_data_by_type(type: int) -> CardData:
	match type:
		CardData.Type.DART: return dart_data
		CardData.Type.HAMMER: return hammer_data
		CardData.Type.MAGNET: return magnet_data
		CardData.Type.SHIELD: return shield_data
	return dart_data
