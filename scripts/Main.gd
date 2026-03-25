extends Node3D

@onready var game_manager: GameManager = $GameManager

func _ready():
	# Register GameManager in a group for easy access
	game_manager.add_to_group("game_manager")
	game_manager.turn_ended.connect(_on_turn_ended)

func _on_turn_ended():
	print("Turn Ended! Cleaning up projectiles...")
	# Optional: Destroy all active projectiles on turn end
	for child in get_children():
		if child is Projectile:
			# Smoothly fade out or just queue_free
			child.queue_free()
	
	# After cleanup, the GameManager will reset energy based on its timer
