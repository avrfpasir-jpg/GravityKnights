extends Node
class_name GameManager

signal energy_updated(new_energy: int)
signal block_updated(new_block: int)
signal health_updated(new_health: int)
signal turn_ended()

signal deck_updated(count: int)
signal hand_updated(hand: Array[CardData])
signal discard_updated(count: int)

@export var max_energy: int = 3
@export var max_health: int = 100
@export var cards_per_turn: int = 4

@export var starting_deck: Array[CardData] = []

var current_energy: int = 0
var current_health: int = 100
var current_block: int = 0

var draw_pile: Array[CardData] = []
var hand: Array[CardData] = []
var discard_pile: Array[CardData] = []

func _ready():
	current_energy = max_energy
	current_health = max_health
	
	add_to_group("game_manager")
	
	initialize_deck()
	draw_cards(cards_per_turn)
	emit_signals()

func emit_signals():
	emit_signal("energy_updated", current_energy)
	emit_signal("health_updated", current_health)
	emit_signal("block_updated", current_block)
	emit_signal("deck_updated", draw_pile.size())
	emit_signal("hand_updated", hand)
	emit_signal("discard_updated", discard_pile.size())

func initialize_deck():
	draw_pile = starting_deck.duplicate()
	draw_pile.shuffle()
	discard_pile = []
	hand = []

func draw_cards(count: int):
	for i in range(count):
		if draw_pile.is_empty():
			reshuffle_discard_into_draw()
		
		if not draw_pile.is_empty():
			var card = draw_pile.pop_back()
			hand.append(card)
	
	emit_signal("hand_updated", hand)
	emit_signal("deck_updated", draw_pile.size())

func reshuffle_discard_into_draw():
	draw_pile = discard_pile.duplicate()
	draw_pile.shuffle()
	discard_pile = []
	emit_signal("discard_updated", 0)
	emit_signal("deck_updated", draw_pile.size())

func discard_hand():
	discard_pile.append_array(hand)
	hand = []
	emit_signal("hand_updated", hand)
	emit_signal("discard_updated", discard_pile.size())

func use_card(card: CardData):
	if hand.has(card):
		hand.erase(card)
		discard_pile.append(card)
		emit_signal("hand_updated", hand)
		emit_signal("discard_updated", discard_pile.size())
		return true
	return false

func add_block(amount: int):
	current_block += amount
	emit_signal("block_updated", current_block)

func take_damage(amount: int):
	print("El jugador recibe: " + str(amount) + " de daño.")
	var remaining_damage = amount - current_block
	current_block = max(0, current_block - amount)
	emit_signal("block_updated", current_block)
	
	if remaining_damage > 0:
		current_health = max(0, current_health - remaining_damage)
		emit_signal("health_updated", current_health)
		if current_health <= 0:
			print("GAME OVER")

func use_energy(amount: int) -> bool:
	if current_energy >= amount:
		current_energy -= amount
		emit_signal("energy_updated", current_energy)
		return true
	return false

func end_turn():
	emit_signal("turn_ended")
	
	# Clear hand
	discard_hand()
	
	# Execute Enemy Turns
	print("--- Turno de Enemigos ---")
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.has_method("execute_turn"):
			enemy.execute_turn()
			# Delay between enemy actions
			await get_tree().create_timer(0.6).timeout
	
	# Start next player turn
	print("--- Tu Turno ---")
	await get_tree().create_timer(1.0).timeout
	reset_turn()

func reset_turn():
	current_energy = max_energy
	# Block resets each player turn by default
	current_block = 0
	
	draw_cards(cards_per_turn)
	
	emit_signal("energy_updated", current_energy)
	emit_signal("block_updated", current_block)

func force_end_turn():
	end_turn()
