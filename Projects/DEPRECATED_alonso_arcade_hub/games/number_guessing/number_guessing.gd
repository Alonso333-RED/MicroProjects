extends Control

var correct

func _ready() -> void:
	randomize()
	
	correct = randi_range(1, 1000)
	
func get_correct():
	return correct
