extends Area2D

var mass_value = 10

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerCell:
		body.eat_mass(mass_value)
		get_tree().current_scene.masses -= 1
		queue_free()
