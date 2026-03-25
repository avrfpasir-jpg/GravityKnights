extends Node
class_name GameManager

# States
enum GameState { HUB, COMBAT, TRANSITION }
var current_state: GameState = GameState.HUB

signal energy_updated(new_energy: int)
signal block_updated(new_block: int)
signal health_updated(new_health: int)
signal turn_ended()
signal state_changed(new_state: int)

signal deck_updated(count: int)
signal hand_updated(hand: Array[CardData])
signal discard_updated(count: int)

@export var cards_per_turn: int = 4
@export var enemy_scene: PackedScene # Reference to spawn enemies

var max_energy: int = 3
var max_health: int = 100
var current_energy: int = 0
var current_health: int = 100
var current_block: int = 0

var draw_pile: Array[CardData] = []
var hand: Array[CardData] = []
var discard_pile: Array[CardData] = []

func _ready():
	add_to_group("game_manager")
	
	# Load Player Stats from Global Autoload
	if Global.selected_player:
		max_health = Global.selected_player.max_health
		max_energy = Global.selected_player.max_energy
		draw_pile = Global.selected_player.starting_deck.duplicate()
		draw_pile.shuffle()
	
	current_health = max_health
	current_energy = max_energy
	
	# Start as HUB
	set_state(GameState.HUB)
	emit_signals()

func set_state(new_state: int):
	current_state = new_state
	emit_signal("state_changed", current_state)
	
	if current_state == GameState.HUB:
		print("--- EXPLORACIÓN: Entrando en el HUB ---")
		# Hide combat UI usually handled in HUD.gd listener
	elif current_state == GameState.COMBAT:
		print("--- COMBATE: ¡Prepárate! ---")
		reset_turn()

func emit_signals():
	emit_signal("energy_updated", current_energy)
	emit_signal("health_updated", current_health)
	emit_signal("block_updated", current_block)
	emit_signal("deck_updated", draw_pile.size())
	emit_signal("hand_updated", hand)
	emit_signal("discard_updated", discard_pile.size())

# Combate Logic
func draw_cards(count: int):
	for i in range(count):
		if draw_pile.is_empty(): _reshuffle()
		if not draw_pile.is_empty(): hand.append(draw_pile.pop_back())
	emit_signal("hand_updated", hand)
	emit_signal("deck_updated", draw_pile.size())

func _reshuffle():
	draw_pile = discard_pile.duplicate()
	draw_pile.shuffle()
	discard_pile = []
	emit_signal("discard_updated", 0)
	emit_signal("deck_updated", draw_pile.size())

func discard_hand():
	discard_pile.append_array(hand)
	hand = []
	emit_signals()

func use_energy(amount: int) -> bool:
	if current_energy >= amount:
		current_energy -= amount
		emit_signal("energy_updated", current_energy)
		return true
	return false

func end_turn():
	if current_state != GameState.COMBAT: return
	
	discard_hand()
	
	# Enemy Turns
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.has_method("execute_turn"):
			enemy.execute_turn()
			await get_tree().create_timer(0.6).timeout
	
	# If encounter is over, goto HUB
	if get_tree().get_nodes_in_group("enemies").is_empty():
		set_state(GameState.HUB)
	else:
		reset_turn()

func reset_turn():
	current_energy = max_energy
	current_block = 0
	draw_cards(cards_per_turn)
	emit_signals()

func start_combat():
	if current_state == GameState.COMBAT: return
	set_state(GameState.COMBAT)
	# Logic to spawn enemies could go here or in a separate room manager
