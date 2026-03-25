extends Control

@onready var grid_container: GridContainer = $GridContainer

# Resources to pre-load for the Knight's deck
var dart = preload("res://resources/DartData.tres")
var hammer = preload("res://resources/HammerData.tres")
var magnet = preload("res://resources/MagnetData.tres")
var shield = preload("res://resources/ShieldData.tres")

func _ready():
	_setup_character_options()

func _setup_character_options():
	for i in range(4):
		var panel = _create_character_panel(i)
		grid_container.add_child(panel)

func _create_character_panel(id: int) -> ColorRect:
	var panel = ColorRect.new()
	panel.custom_minimum_size = Vector2(250, 400)
	
	var label = Label.new()
	label.anchors_preset = 8
	label.grow_horizontal = 2
	label.grow_vertical = 2
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	if id == 0:
		panel.color = Color(0.1, 0.4, 0.7) 
		label.text = "CABALLERO\nGRAVEDAD\n\n(CLICK PARA JUGAR)"
		panel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		panel.gui_input.connect(func(event): if event is InputEventMouseButton and event.pressed: _on_character_selected())
	else:
		panel.color = Color(0.1, 0.1, 0.1) 
		label.text = "COMING SOON"
		label.modulate = Color(0.5, 0.5, 0.5)
	
	panel.add_child(label)
	return panel

func _on_character_selected():
	var player = PlayerData.new()
	player.name = "Caballero Gravedad"
	player.max_health = 100
	player.max_energy = 3
	
	# THEMATIC STARTING DECK
	var deck: Array[CardData] = []
	# 3x Darts, 3x Shields, 2x Hammers, 1x Magnet
	for i in range(3): deck.append(dart)
	for i in range(3): deck.append(shield)
	for i in range(2): deck.append(hammer)
	deck.append(magnet)
	
	player.starting_deck = deck
	
	Global.selected_player = player
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
