extends Node3D

@onready var game_manager: GameManager = $GameManager
@onready var player: PlayerEntity = $Player
@onready var launcher: LauncherUI = $Launcher

var room_count: int = 0

func _ready():
	# Register GameManager in a group for easy access
	game_manager.add_to_group("game_manager")
	game_manager.turn_ended.connect(_on_turn_ended)
	game_manager.state_changed.connect(_on_state_changed)

func _process(delta):
	# Door Detection (Simple version for MVP)
	if game_manager.current_state == GameManager.GameState.HUB:
		_check_door_transitions()

func _check_door_transitions():
	var pos = player.global_position
	# Board is 20x20. Walls at 10.
	# Door trigger at abs > 9.5
	if abs(pos.x) > 9.5 or abs(pos.z) > 9.5:
		print("Entrando en nueva habitación...")
		_transition_to_new_room()

func _transition_to_new_room():
	room_count += 1
	
	# Move player to center
	player.global_position = Vector3(0, 0.5, 0)
	
	# Decide if it's a combat or another HUB? 
	# For simplicity, next is always combat
	_spawn_enemies_for_room()
	game_manager.set_state(GameManager.GameState.COMBAT)

func _spawn_enemies_for_room():
	# Clean any old enemies
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.queue_free()
	
	# Spawn 1 to 3 enemies randomly
	var num = randi_range(1, 3)
	for i in range(num):
		var enemy = game_manager.enemy_scene.instantiate()
		add_child(enemy)
		# Random position in the room
		enemy.global_position = Vector3(randf_range(-5, 5), 0.5, randf_range(-5, 5))

func _on_state_changed(state: int):
	if state == GameManager.GameState.HUB:
		# Exploration mode: Enable player movement, hide launcher
		player.speed = 8.0
		launcher.visible = false
	elif state == GameManager.GameState.COMBAT:
		# Combat mode: Disable player movement (optional), show launcher
		player.velocity = Vector3.ZERO
		player.speed = 0.0 # Freeze in place during turn-based combat?
		launcher.visible = true

func _on_turn_ended():
	# Optional: Destroy all active projectiles on turn end
	for child in get_children():
		if child is Projectile:
			child.queue_free()
