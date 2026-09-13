extends Node2D

@export var mass_scene: PackedScene
@export var spawn_range := Vector2(1000, 500)

var masses := 0
var alives = 4

func one_left():
	alives -= 1
	if alives < 2:
		get_tree().reload_current_scene()
			
func spawn_mass():
	var mass = mass_scene.instantiate()

	mass.global_position = Vector2(
		randf_range(-spawn_range.x, spawn_range.x),
		randf_range(-spawn_range.y, spawn_range.y)
	)

	add_child(mass)
	masses += 1

func _on_timer_timeout() -> void:
	if masses <= 100:
		spawn_mass()
