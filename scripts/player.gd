extends CharacterBody3D
class_name BQPlayer

signal movement_state_changed(moving: bool)
signal health_changed(current: int, maximum: int)
signal defeated
signal respawned

@export var move_speed := 7.0
@export var sprint_multiplier := 1.35
@export var acceleration := 24.0
@export var gravity := 20.0
@export var jump_velocity := 7.0
@export var turn_speed := 12.0
@export var max_health := 100
@export var respawn_delay := 2.5

var is_moving := false
var health := 100
var defeated_state := false
var spawn_position := Vector3.ZERO
var spawn_rotation := Vector3.ZERO

@onready var ability_system: BQAbilitySystem = $AbilitySystem

func _ready() -> void:
    spawn_position = global_position
    spawn_rotation = rotation
    health = max_health
    var character_system := get_node_or_null("CharacterSystem") as BQCharacterSystem
    if character_system != null:
        character_system.character_changed.connect(_on_character_changed)
        _on_character_changed(character_system.get_active_character())
    health_changed.emit(health, max_health)

func _physics_process(delta: float) -> void:
    if defeated_state:
        velocity = Vector3.ZERO
        return

    var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var direction := Vector3(input_vector.x, 0.0, input_vector.y)
    if direction.length_squared() > 1.0:
        direction = direction.normalized()

    var character_system := get_node_or_null("CharacterSystem") as BQCharacterSystem
    var character := character_system.get_active_character() if character_system != null else {}
    var character_speed := float(character.get("speed", move_speed))
    var sprinting := Input.is_key_pressed(KEY_SHIFT)
    var target_speed := character_speed * (sprint_multiplier if sprinting else 1.0)
    var target := direction * target_speed
    velocity.x = move_toward(velocity.x, target.x, acceleration * delta)
    velocity.z = move_toward(velocity.z, target.z, acceleration * delta)

    if ability_system != null and ability_system.flying:
        if Input.is_action_just_pressed("jump"):
            velocity.y = 7.0
        elif Input.is_action_pressed("jump"):
            velocity.y = move_toward(velocity.y, 5.0, 18.0 * delta)
        else:
            velocity.y = move_toward(velocity.y, 0.0, 12.0 * delta)
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
        rotation.y = lerp_angle(rotation.y, target_rotation, min(1.0, turn_speed * delta))

    move_and_slide()

func take_damage(amount: int) -> void:
    if defeated_state or amount <= 0:
        return
    if ability_system != null and ability_system.invulnerable:
        return
    health = max(0, health - amount)
    health_changed.emit(health, max_health)
    if health == 0:
        defeated_state = true
        velocity = Vector3.ZERO
        defeated.emit()
        _respawn_after_delay()

func heal(amount: int) -> void:
    if defeated_state or amount <= 0:
        return
    health = min(max_health, health + amount)
    health_changed.emit(health, max_health)

func reset_health() -> void:
    defeated_state = false
    health = max_health
    health_changed.emit(health, max_health)

func _respawn_after_delay() -> void:
    await get_tree().create_timer(respawn_delay).timeout
    if not is_instance_valid(self):
        return
    global_position = spawn_position
    rotation = spawn_rotation
    velocity = Vector3.ZERO
    defeated_state = false
    health = max_health
    health_changed.emit(health, max_health)
    respawned.emit()

func _on_character_changed(character: Dictionary) -> void:
    max_health = int(character.get("health", 100))
    health = max_health
    defeated_state = false
    health_changed.emit(health, max_health)

func set_character_visibility(visible_state: bool) -> void:
    for child in get_children():
        if child is MeshInstance3D or child is Node3D and child.name == "CharacterVisual":
            child.visible = visible_state
    var visual := get_node_or_null("CharacterVisual")
    if visual != null:
        visual.visible = visible_state
