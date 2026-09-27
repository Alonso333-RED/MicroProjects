extends CharacterBody2D


@export var speed := 300.0

@onready var camera: Camera2D = $Camera2D
@onready var joystick = $VirtualJoystick


func _enter_tree():
	var peer_id := int(name)

	set_multiplayer_authority(peer_id)

	var config := SceneReplicationConfig.new()
	config.add_property(":position")

	$MultiplayerSynchronizer.replication_config = config


func _ready():
	var local_player := is_multiplayer_authority()

	camera.enabled = local_player
	joystick.visible = local_player
	
func _physics_process(_delta):
	if not is_multiplayer_authority():
		return

	var direction := Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
		"ui_down"
	)

	velocity = direction * speed
	move_and_slide()

	print(name, " authority=", get_multiplayer_authority(), " position=", position)
