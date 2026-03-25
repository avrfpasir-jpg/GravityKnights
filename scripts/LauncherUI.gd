extends Node3D
class_name LauncherUI

# Now we get the data from the hand instead of a static export
@export var projectile_scene: PackedScene 

@onready var trajectory_line: MeshInstance3D = $TrajectoryLine

var is_dragging: bool = false
var drag_start: Vector3 = Vector3.ZERO
var drag_end: Vector3 = Vector3.ZERO
var active_data: CardData

func _ready():
	add_to_group("launcher")

func select_card_from_hand(card: CardData):
	# Set this as the active card to launch
	active_data = card

func _input(event: InputEvent):
	# Only allow launching if we have a card selected and it's our turn/energy
	if not active_data: return 
	
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
		# Notify deck to discard used card
		game_manager.use_card(active_data)
		# Clear selection after use
		active_data = null

func _launch_projectile():
	var launch_dir = (drag_start - drag_end).normalized()
	var projectile = projectile_scene.instantiate() as Projectile
	get_parent().add_child(projectile) 
	projectile.global_position = drag_start
	projectile.data = active_data
	
	# Apply block if it's a defensive card
	if active_data.block_amount > 0:
		var game_manager = get_tree().get_first_node_in_group("game_manager")
		if game_manager:
			game_manager.add_block(active_data.block_amount)
	
	projectile.launch(launch_dir)

func _update_trajectory_visual():
	var diff = drag_end - drag_start
	var distance = diff.length()
	if distance < 0.1: return
	
	trajectory_line.scale.z = distance
	trajectory_line.global_position = drag_start + (diff / 2.0)
	trajectory_line.look_at(drag_end, Vector3.UP)

func _project_mouse_to_plane(mouse_pos: Vector2) -> Vector3:
	var camera = get_viewport().get_camera_3d()
	if not camera: return Vector3.ZERO
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_dir = camera.project_ray_normal(mouse_pos)
	
	var plane = Plane(Vector3.UP, 0.5)
	var pos = plane.intersects_ray(ray_origin, ray_dir)
	return pos if pos != null else Vector3.ZERO
