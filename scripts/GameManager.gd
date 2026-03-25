extends Node
class_name GameManager

signal energy_updated(new_energy: int)
signal block_updated(new_block: int)
signal health_updated(new_health: int)
signal turn_ended()

@export var max_energy: int = 3
@export var max_health: int = 100

var current_energy: int = 0
var current_health: int = 100
var current_block: int = 0

func _ready():
	current_energy = max_energy
	current_health = max_health
	emit_signal("energy_updated", current_energy)
	emit_signal("health_updated", current_health)
	emit_signal("block_updated", current_block)

func add_block(amount: int):
	current_block += amount
	emit_signal("block_updated", current_block)

func take_damage(amount: int):
	# Damage first reduces block, then health
	var remaining_damage = amount - current_block
	current_block = max(0, current_block - amount)
	emit_signal("block_updated", current_block)
	
	if remaining_damage > 0:
		current_health = max(0, current_health - remaining_damage)
		emit_signal("health_updated", current_health)
		if current_health <= 0:
			# Handle Game Over
			pass

func use_energy(amount: int) -> bool:
	if current_energy >= amount:
		current_energy -= amount
		emit_signal("energy_updated", current_energy)
		
		if current_energy <= 0:
			end_turn()
		return true
	return false

func end_turn():
	# For turn end, stop all movement or destroy active projectiles
	emit_signal("turn_ended")
	
	# Wait a short duration before resetting
	await get_tree().create_timer(1.0).timeout
	reset_turn()

func reset_turn():
	current_energy = max_energy
	# Block usually resets each turn in deckbuilders
	current_block = 0
	emit_signal("energy_updated", current_energy)
	emit_signal("block_updated", current_block)

# Useful for "End Turn" UI button if you adds one
func force_end_turn():
	end_turn()
