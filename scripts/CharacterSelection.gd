extends Control

@onready var grid_container: GridContainer = $GridContainer

# Define some card resources for the starting deck if we want to pre-fill it
@export var dart_data: CardData
@export var hammer_data: CardData

func _ready():
	_setup_character_options()

func _setup_character_options():
	# Loop through 4 slots
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
	
	if id == 0:
		panel.color = Color(0.2, 0.5, 0.8) # Blue-ish for available
		label.text = "CABALLERO\nGRAVEDAD\n\n(CLICK PARA JUGAR)"
		panel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		panel.gui_input.connect(func(event): if event is InputEventMouseButton and event.pressed: _on_character_selected())
	else:
		panel.color = Color(0.1, 0.1, 0.1) # Dark for locked
		label.text = "COMING SOON"
		label.modulate = Color(0.5, 0.5, 0.5)
	
	panel.add_child(label)
	return panel

func _on_character_selected():
	print("Personaje seleccionado. Cargando partida...")
	# Create a dummy PlayerData for the Knight
	var player = PlayerData.new()
	player.name = "Caballero Gravedad"
	player.max_health = 100
	player.max_energy = 3
	
	# Pass it to Global
	Global.selected_player = player
	
	# Change Scene
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
