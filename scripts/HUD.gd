extends Control

@onready var energy_label: Label = $StatsPanel/EnergyLabel
@onready var health_label: Label = $StatsPanel/HealthLabel
@onready var block_label: Label = $StatsPanel/BlockLabel
@onready var combat_ui: Control = $CombatUI
@onready var card_bar: HBoxContainer = $CombatUI/CardBar
@onready var end_turn_button: Button = $CombatUI/EndTurnButton

func _ready():
	var gm = get_tree().get_first_node_in_group("game_manager")
	if gm:
		gm.energy_updated.connect(_on_energy_updated)
		gm.health_updated.connect(_on_health_updated)
		gm.block_updated.connect(_on_block_updated)
		gm.hand_updated.connect(_on_hand_updated)
		gm.state_changed.connect(_on_state_changed)
		
		# Connect End Turn button
		end_turn_button.pressed.connect(gm.end_turn)
		
		# Initial state
		_on_state_changed(gm.current_state)
		_on_energy_updated(gm.current_energy)
		_on_health_updated(gm.current_health)
		_on_block_updated(gm.current_block)

func _on_state_changed(state: int):
	# Show/Hide combat specific UI
	if state == 1: # COMBAT
		combat_ui.visible = true
	else:
		combat_ui.visible = false

func _on_hand_updated(hand: Array[CardData]):
	for child in card_bar.get_children(): child.queue_free()
	
	for card in hand:
		var btn = Button.new()
		btn.text = card.name + "\n(" + str(card.energy_cost) + ")"
		btn.custom_minimum_size = Vector2(100, 40)
		btn.pressed.connect(func(): _on_card_selected(card))
		card_bar.add_child(btn)

func _on_card_selected(card: CardData):
	var launcher = get_tree().get_first_node_in_group("launcher")
	if launcher: launcher.select_card_from_hand(card)

func _on_energy_updated(val):
	energy_label.text = "ENERGÍA: %d" % val

func _on_health_updated(val):
	health_label.text = "SALUD: %d" % val

func _on_block_updated(val):
	block_label.text = "BLOQUEO: %d" % val
