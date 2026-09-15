extends CharacterBody3D

@export var move_speed := 7.0
@export var acceleration := 22.0
@export var gravity := 20.0
@export var jump_velocity := 7.0

func _physics_process(delta: float) -> void:
    var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var direction := Vector3(input_vector.x, 0.0, input_vector.y)

    if direction.length() > 1.0:
        direction = direction.normalized()

    var target := direction * move_speed
    velocity.x = move_toward(velocity.x, target.x, acceleration * delta)
    velocity.z = move_toward(velocity.z, target.z, acceleration * delta)

    if not is_on_floor():
        velocity.y -= gravity * delta
    elif Input.is_action_just_pressed("jump"):
        velocity.y = jump_velocity

    move_and_slide()
