extends Button

var response
@onready var response_field = $"../response"
@onready var feedback = $"../feedback"
@onready var root = get_tree().current_scene

func _pressed() -> void:
	response = response_field.text
	
	response = int(response)
	if response == 0:
		feedback.text = "Invalid Answer."
	else:
		evaluate()
		
func evaluate():
	if response == root.correct:
		feedback.text = "Correct!"
	elif response < root.correct:
		feedback.text = "Is bigger"
	elif response > root.correct:
		feedback.text = "Is smaller"
