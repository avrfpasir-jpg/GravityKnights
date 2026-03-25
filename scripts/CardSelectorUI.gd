extends Control
class_name CardSelectorUI

# Basic UI script to manage selection and energy display
@onready var energy_label: Label = $EnergyLabel

func _on_card_type_button_pressed(type: int):
	var launcher = get_tree().get_first_node_in_group("launcher")
	if launcher:
		launcher.selected_card_type = type

func _on_energy_updated(new_energy: int):
	energy_label.text = "Energy: %d" % new_energy
