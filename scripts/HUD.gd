extends Control

@onready var energy_label: Label = $EnergyLabel
@onready var health_label: Label = $HealthLabel
@onready var block_label: Label = $BlockLabel
@onready var card_bar: HBoxContainer = $CardBar

# We'll use a scene or button template for the cards
# For MVP, we'll just use the existing buttons if they match or create them

func _ready():
	var gm = get_tree().get_first_node_in_group("game_manager")
	if gm:
		gm.energy_updated.connect(_on_energy_updated)
		gm.health_updated.connect(_on_health_updated)
		gm.block_updated.connect(_on_block_updated)
		gm.hand_updated.connect(_on_hand_updated)
		
		# Initial state
		_on_energy_updated(gm.current_energy)
		_on_health_updated(gm.current_health)
		_on_block_updated(gm.current_block)
		_on_hand_updated(gm.hand)

func _on_hand_updated(hand: Array[CardData]):
	# Clear existing card buttons
	for child in card_bar.get_children():
		child.queue_free()
	
	# Create new buttons for each card in hand
	for card in hand:
		var btn = Button.new()
		btn.text = card.name + " (" + str(card.energy_cost) + ")"
		btn.custom_minimum_size = Vector2(100, 40)
		btn.pressed.connect(func(): _on_card_selected(card))
		card_bar.add_child(btn)

func _on_card_selected(card: CardData):
	var launcher = get_tree().get_first_node_in_group("launcher")
	if launcher:
		launcher.select_card_from_hand(card)
		print("Carta seleccionada: ", card.name)

func _on_energy_updated(val):
	energy_label.text = "ENERGÍA: %d" % val

func _on_health_updated(val):
	health_label.text = "SALUD: %d" % val

func _on_block_updated(val):
	block_label.text = "BLOQUEO: %d" % val
