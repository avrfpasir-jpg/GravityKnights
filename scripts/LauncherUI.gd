extends Node3D
class_name LauncherUI

@export var projectile_scene: PackedScene 

@onready var trajectory_line: MeshInstance3D = $TrajectoryLine

var is_dragging: bool = false
var drag_start: Vector3 = Vector3.ZERO
var drag_end: Vector3 = Vector3.ZERO
var active_data: CardData

func _ready():
	add_to_group("launcher")

func _process(delta):
	# Follow the player position if they are moving in HUB
	var player = get_tree().get_first_node_in_group("player")
	if player:
		global_position = player.global_position + Vector3(0, 0.5, 0)

func select_card_from_hand(card: CardData):
	active_data = card

func _input(event: InputEvent):
	# Disable combat launcher if not in COMBAT state or no card selected
	var gm = get_tree().get_first_node_in_group("game_manager")
	if gm and gm.current_state != GameManager.GameState.COMBAT:
		return
		
	if not active_data: return 
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed: _on_drag_start()
			else: _on_drag_end()

	if event is InputEventMouseMotion and is_dragging:
		_on_drag_motion()

	if event.is_action_pressed("ui_accept"): # Space to end turn
		gm.end_turn()

func _on_drag_start():
	var mouse_pos = get_viewport().get_mouse_position()
	drag_start = _project_mouse_to_plane(mouse_pos)
	is_dragging = true
	trajectory_line.visible = true

func _on_drag_motion():
	var mouse_pos = get_viewport().get_mouse_position()
	drag_end = _project_mouse_to_plane(mouse_pos)
	_update_trajectory_visual()

func _on_drag_end():
	if not is_dragging: return
	is_dragging = false
	trajectory_line.visible = false
	
	var gm = get_tree().get_first_node_in_group("game_manager")
	if gm and gm.use_energy(active_data.energy_cost):
		_launch_projectile()
		gm.use_card(active_data)
		active_data = null

func _launch_projectile():
	var launch_dir = (drag_start - drag_end).normalized()
	var projectile = projectile_scene.instantiate() as Projectile
	get_parent().add_child(projectile) 
	projectile.global_position = drag_start
	projectile.data = active_data
	
	if active_data.block_amount > 0:
		var gm = get_tree().get_first_node_in_group("game_manager")
		if gm: gm.add_block(active_data.block_amount)
	
	projectile.launch(launch_dir)

func _update_trajectory_visual():
	var diff = drag_end - drag_start
	var distance = diff.length()
	if distance < 0.1: return
	
	trajectory_line.scale.z = distance
	# Point towards where we ARE looking (pull-back is opposite)
	trajectory_line.look_at(global_position + (drag_start - drag_end), Vector3.UP)

func _project_mouse_to_plane(mouse_pos: Vector2) -> Vector3:
	var camera = get_viewport().get_camera_3d()
	if not camera: return Vector3.ZERO
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_dir = camera.project_ray_normal(mouse_pos)
	var plane = Plane(Vector3.UP, 0.5)
	var pos = plane.intersects_ray(ray_origin, ray_dir)
	return pos if pos != null else Vector3.ZERO
