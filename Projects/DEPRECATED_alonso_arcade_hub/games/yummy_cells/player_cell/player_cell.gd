extends CharacterBody2D
class_name PlayerCell

const SPEED := 250
const BASE_MASS := 100

var base_sprite_scale: Vector2
var _current_mass := BASE_MASS

var current_mass: int:
	get:
		return _current_mass

	set(value):
		_current_mass = value

		$Label.text = str(value)
		$Label.size = Vector2(value/4.0,value/4.0)
		$Label.add_theme_font_size_override("font_size", value/10.0)
		$Label.position = Vector2(-value*0.125, -value*0.125)
		($CollisionShape2D.shape as CircleShape2D).radius = value / 2.0

		var factor := float(value) / BASE_MASS
		$Sprite2D.scale = base_sprite_scale * factor

@export var player: PlayerMetadata

func _ready() -> void:
	base_sprite_scale = $Sprite2D.scale

	$Sprite2D.modulate = player.color
	current_mass = BASE_MASS

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	var direction = InputUtils.get_direction(player.prefix)

	velocity = direction * SPEED
	move_and_slide()

func eat_mass(value: int):
	current_mass += value

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is PlayerCell:
		if current_mass > body.current_mass:
			current_mass += body.current_mass
			body.queue_free()
			get_tree().current_scene.one_left()
