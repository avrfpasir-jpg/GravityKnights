extends RigidBody3D
class_name Projectile

@export var data: CardData
@export var magnet_force: float = 100.0
@export var magnet_radius: float = 10.0

var is_active: bool = true
var is_magnet: bool = false
var is_shield: bool = false
var attract_area: Area3D

func _ready():
	if not data: return
	
	# Setup physics based on CardData
	mass = data.mass
	physics_material_override = PhysicsMaterial.new()
	physics_material_override.bounce = data.bounce
	physics_material_override.friction = data.friction
	
	# Gravity-free setup
	gravity_scale = 0.0
	
	# Type specific setup
	if data.type == CardData.Type.MAGNET:
		is_magnet = true
		_setup_magnet_area()
	elif data.type == CardData.Type.SHIELD:
		is_shield = true
		# Possible visualization change (e.g., turn blue/shield-like)

func _setup_magnet_area():
	attract_area = Area3D.new()
	var collision = CollisionShape3D.new()
	var shape = SphereShape3D.new()
	shape.radius = magnet_radius
	collision.shape = shape
	attract_area.add_child(collision)
	add_child(attract_area)

func _physics_process(delta):
	# Magnet logic
	if is_magnet and linear_velocity.length() < 0.5: 
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
		_attract_bodies(delta)
	
	# Shield logic (become static barrier)
	if is_shield and linear_velocity.length() < 0.5 and is_active:
		_anchor_shield()

func _anchor_shield():
	# Stop and freeze to become a physical wall
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	freeze = true 
	is_active = false

func _attract_bodies(delta):
	for body in attract_area.get_overlapping_bodies():
		if body is RigidBody3D and body != self:
			var direction = (global_position - body.global_position).normalized()
			# Apply attraction force towards magnet
			body.apply_central_force(direction * magnet_force)

# This would be called by the Launcher/UI script on spawn
func launch(direction: Vector3):
	apply_central_impulse(direction * data.initial_velocity)

func stop_projectile():
	is_active = false
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	if is_magnet:
		# Maybe trigger an explosion or just deactivate? 
		# For MVP, we'll just stop everything at turn end.
		pass
