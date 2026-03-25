extends Resource
class_name CardData

enum Type { DART, HAMMER, MAGNET, SHIELD }

@export var name: String = "Card"
@export var type: Type = Type.DART
@export var mass: float = 1.0
@export var initial_velocity: float = 20.0
@export var bounce: float = 0.8
@export var friction: float = 0.1
@export var energy_cost: int = 1
@export var block_amount: int = 0
