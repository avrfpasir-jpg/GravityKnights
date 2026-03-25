extends StaticBody3D
class_name Enemy

@export var health: float = 50.0

func _on_body_entered(body: Node3D):
	if body is Projectile:
		var impact_force = body.linear_velocity.length() * body.mass
		take_damage(impact_force)

func take_damage(amount: float):
	health -= amount
	print("Enemigo golpeado por: ", amount, " | Salud restante: ", health)
	if health <= 0:
		_on_death()

func _on_death():
	print("Enemigo destruido!")
	# Maybe add a explosion effect or just queue_free
	queue_free()
