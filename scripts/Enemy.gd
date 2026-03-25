extends StaticBody3D
class_name Enemy

enum IntentType { ATTACK, DEFEND, BUFF }

@export var max_health: float = 50.0
@export var enemy_name: String = "Caballero Espacial"

var health: float = 0.0
var block: float = 0.0
var current_intent: IntentType = IntentType.ATTACK
var intent_value: int = 10

func _ready():
	health = max_health
	add_to_group("enemies")
	# Initial intent
	choose_next_intent()

func choose_next_intent():
	# Simple AI logic: 70% attack, 30% defend
	if randf() > 0.3:
		current_intent = IntentType.ATTACK
		intent_value = randi_range(10, 20)
	else:
		current_intent = IntentType.DEFEND
		intent_value = randi_range(5, 15)
	
	# In a real game, you would emit a signal to update UI icons above the enemy
	print(enemy_name + " prepara: " + IntentType.keys()[current_intent] + " por " + str(intent_value))

func take_damage(amount: float):
	# Adjust for block
	var remaining_damage = amount - block
	block = max(0, block - amount)
	
	if remaining_damage > 0:
		health -= remaining_damage
		print(enemy_name + " recibe " + str(remaining_damage) + " daño | Salud: " + str(health))
		if health <= 0:
			die()

func execute_turn():
	match current_intent:
		IntentType.ATTACK:
			_attack_player(intent_value)
		IntentType.DEFEND:
			_add_block(intent_value)
	
	# Prepare for next turn
	choose_next_intent()

func _attack_player(amount: int):
	var gm = get_tree().get_first_node_in_group("game_manager")
	if gm:
		print(enemy_name + " ATACA por " + str(amount))
		gm.take_damage(amount)

func _add_block(amount: int):
	block += amount
	print(enemy_name + " se PROTEGE por " + str(amount))

func die():
	print(enemy_name + " ELIMINADO!")
	queue_free()

# To handle physical collisions (if the projectile hits the StaticBody)
# Note: You need to connect the 'body_entered' from the PROJECTILE to the enemy's take_damage.
