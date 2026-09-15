extends CharacterBody3D
class_name BQPlayer

signal movement_state_changed(moving: bool)

@export var move_speed := 7.0
@export var acceleration := 22.0
@export var gravity := 20.0
@export var jump_velocity := 7.0
@export var turn_speed := 10.0

var is_moving := false

@onready var ability_system: BQAbilitySystem = $AbilitySystem
@onready var body_mesh: MeshInstance3D = $Body
@onready var head_mesh: MeshInstance3D = $Head

func _physics_process(delta: float) -> void:
    var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var direction := Vector3(input_vector.x, 0.0, input_vector.y)
    if direction.length_squared() > 1.0:
        direction = direction.normalized()

    var character_system := $CharacterSystem as BQCharacterSystem
    var character := character_system.get_active_character() if character_system != null else {}
    var character_speed := float(character.get("speed", move_speed))
    var target := direction * character_speed
    velocity.x = move_toward(velocity.x, target.x, acceleration * delta)
    velocity.z = move_toward(velocity.z, target.z, acceleration * delta)

    if ability_system != null and ability_system.flying:
        velocity.y = move_toward(velocity.y, 0.0, gravity * delta)
    elif not is_on_floor():
        velocity.y -= gravity * delta
    elif Input.is_action_just_pressed("jump"):
        velocity.y = jump_velocity
    else:
        velocity.y = 0.0

    var moving_now := direction.length_squared() > 0.01
    if moving_now != is_moving:
        is_moving = moving_now
        movement_state_changed.emit(is_moving)

    if moving_now:
        var target_rotation := atan2(direction.x, direction.z)
        rotation.y = lerp_angle(rotation.y, target_rotation, turn_speed * delta)

    move_and_slide()

func set_character_visibility(visible_state: bool) -> void:
    body_mesh.visible = visible_state
    head_mesh.visible = visible_state
