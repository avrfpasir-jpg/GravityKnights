extends Control

@onready var energy_label: Label = $EnergyLabel
@onready var health_label: Label = $HealthLabel
@onready var block_label: Label = $BlockLabel

func _ready():
	var gm = get_tree().get_first_node_in_group("game_manager")
	if gm:
		gm.energy_updated.connect(_on_energy_updated)
		gm.health_updated.connect(_on_health_updated)
		gm.block_updated.connect(_on_block_updated)
		
		# Initial state
		_on_energy_updated(gm.current_energy)
		_on_health_updated(gm.current_health)
		_on_block_updated(gm.current_block)
	
	# Connect buttons dynamically if they exist in a HBox or similar
	_setup_card_buttons()

func _setup_card_buttons():
	# Assuming buttons are named ButtonDart, ButtonHammer, etc.
	# Or just look for specific meta/names
	for btn in find_children("*", "Button"):
		if btn.name.contains("Dart"):
			btn.pressed.connect(func(): _on_card_selected(0))
		elif btn.name.contains("Hammer"):
			btn.pressed.connect(func(): _on_card_selected(1))
		elif btn.name.contains("Magnet"):
			btn.pressed.connect(func(): _on_card_selected(2))
		elif btn.name.contains("Shield"):
			btn.pressed.connect(func(): _on_card_selected(3))

func _on_card_selected(type: int):
	var launcher = get_tree().get_first_node_in_group("launcher")
	if launcher:
		launcher.selected_card_type = type
		print("Carta seleccionada: ", type)

func _on_energy_updated(val):
	energy_label.text = "ENERGÍA: %d" % val

func _on_health_updated(val):
	health_label.text = "SALUD: %d" % val

func _on_block_updated(val):
	block_label.text = "BLOQUEO: %d" % val
