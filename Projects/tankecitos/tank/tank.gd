extends CharacterBody2D

var max_hp = 4
var hp = max_hp
var speed = 250

var had_input := false
var can_shoot := true

var dead := false

@export var player: PlayerMetadata
@export var bullet_scene: PackedScene

func _ready():
	$chasis.modulate = player.color
	$turret.modulate = player.color
	$hp_bar.value = hp

@warning_ignore("unused_parameter")
func _physics_process(delta):
	if dead:
		return
		
	var direction = InputUtils.get_direction(player.prefix)
		
	if direction != Vector2.ZERO:
		$chasis.rotation = direction.angle() + deg_to_rad(90)
		$hitbox.rotation = direction.angle() + deg_to_rad(90)
		
	velocity = direction * speed
	move_and_slide()
	
	$turret.rotation += deg_to_rad(45) * delta
	
	var has_input = direction != Vector2.ZERO
	
	if had_input and not has_input:
		shoot()
		
	had_input = has_input
		
	
func shoot():
	if not can_shoot:
		return
		
	can_shoot = false
	
	var bullet = bullet_scene.instantiate()
	bullet.player = player
	bullet.global_position = $turret/Muzzle.global_position
	bullet.global_rotation = $turret.global_rotation

	get_parent().add_child(bullet)

	await get_tree().create_timer(1.0).timeout

	can_shoot = true
	
func take_damage(value):
	if dead:
		return

	hp -= value
	$hp_bar.value = hp

	if hp <= 0:
		die()
	
func die():
	dead = true

	$turret.visible = false
	$hp_bar.visible = false

	velocity = Vector2.ZERO
	get_tree().current_scene.update_alives()
