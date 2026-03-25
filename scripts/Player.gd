extends CharacterBody3D
class_name PlayerEntity

@export var speed: float = 8.0

func _ready():
	add_to_group("player")

func _physics_process(delta):
	# Movement relative to the camera (Isometric 3D)
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Transform input to 3D orientation: (X, 0, Z)
	var move_dir = Vector3(input_dir.x, 0, input_dir.y).normalized()
	
	if move_dir:
		velocity.x = move_dir.x * speed
		velocity.z = move_dir.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
