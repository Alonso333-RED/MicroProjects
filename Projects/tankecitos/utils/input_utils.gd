class_name InputUtils

static func get_direction(prefix: String) -> Vector2:
	return Input.get_vector(
		prefix + "_left",
		prefix + "_right",
		prefix + "_up",
		prefix + "_down"
	)
