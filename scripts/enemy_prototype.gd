extends CharacterBody3D

@export var patrol_radius := 5.0
@export var patrol_speed := 2.2

var origin := Vector3.ZERO
var patrol_time := 0.0

func _ready() -> void:
    origin = global_position

func _physics_process(delta: float) -> void:
    patrol_time += delta
    var offset := Vector3(sin(patrol_time * 0.55) * patrol_radius, 0.0, cos(patrol_time * 0.4) * patrol_radius)
    var target := origin + offset
    var direction := target - global_position
    direction.y = 0.0

    if direction.length_squared() > 0.25:
        direction = direction.normalized()
        velocity.x = direction.x * patrol_speed
        velocity.z = direction.z * patrol_speed
        rotation.y = lerp_angle(rotation.y, atan2(direction.x, direction.z), delta * 5.0)
    else:
        velocity.x = move_toward(velocity.x, 0.0, patrol_speed * delta * 2.0)
        velocity.z = move_toward(velocity.z, 0.0, patrol_speed * delta * 2.0)

    if not is_on_floor():
        velocity.y -= 18.0 * delta
    else:
        velocity.y = 0.0

    move_and_slide()
