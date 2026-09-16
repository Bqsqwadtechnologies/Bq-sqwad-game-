extends CharacterBody3D

signal defeated

@export var enemy_type := "city_guard"
@export var patrol_radius := 7.0

var health := 100
var max_health := 100
var move_speed := 3.0
var damage := 10
var attack_range := 3.0
var detection_range := 24.0
var behavior := "melee_pursuit"
var origin := Vector3.ZERO
var patrol_time := 0.0
var attack_cooldown := 0.0
var defeated_state := false
var control_time_remaining := 0.0
var target: Node3D

func _ready() -> void:
    origin = global_position
    var definition := BQEnemySystem.get_enemy_definition(enemy_type)
    if not definition.is_empty():
        max_health = int(definition.get("health", max_health))
        move_speed = float(definition.get("speed", move_speed))
        damage = int(definition.get("damage", damage))
        attack_range = float(definition.get("attack_range", attack_range))
        detection_range = float(definition.get("detection_range", detection_range))
        behavior = String(definition.get("behavior", behavior))
    health = max_health
    BQEnemySystem.register_enemy(self)
    target = get_tree().get_first_node_in_group("player") as Node3D
    if target == null:
        target = get_tree().get_first_node_in_group("Player") as Node3D
    _update_status_label()

func _physics_process(delta: float) -> void:
    if defeated_state:
        return

    attack_cooldown = max(0.0, attack_cooldown - delta)
    if not is_instance_valid(target):
        target = get_tree().get_first_node_in_group("player") as Node3D

    if control_time_remaining > 0.0:
        control_time_remaining = max(0.0, control_time_remaining - delta)
        velocity.x = move_toward(velocity.x, 0.0, move_speed * delta * 4.0)
        velocity.z = move_toward(velocity.z, 0.0, move_speed * delta * 4.0)
        _apply_gravity(delta)
        move_and_slide()
        return

    if target != null and global_position.distance_to(target.global_position) <= detection_range:
        _pursue_target(delta)
    else:
        _patrol(delta)

func _pursue_target(delta: float) -> void:
    var direction := target.global_position - global_position
    direction.y = 0.0
    var distance := direction.length()
    if distance > 0.1:
        direction = direction.normalized()

    if distance > attack_range:
        velocity.x = direction.x * move_speed
        velocity.z = direction.z * move_speed
        rotation.y = lerp_angle(rotation.y, atan2(direction.x, direction.z), delta * 6.0)
    else:
        velocity.x = move_toward(velocity.x, 0.0, move_speed * delta * 5.0)
        velocity.z = move_toward(velocity.z, 0.0, move_speed * delta * 5.0)
        if attack_cooldown <= 0.0 and target.has_method("take_damage"):
            target.take_damage(damage)
            attack_cooldown = 1.25

    _apply_gravity(delta)
    move_and_slide()

func _patrol(delta: float) -> void:
    patrol_time += delta
    var offset := Vector3(sin(patrol_time * 0.55) * patrol_radius, 0.0, cos(patrol_time * 0.4) * patrol_radius)
    var patrol_target := origin + offset
    var direction := patrol_target - global_position
    direction.y = 0.0

    if direction.length_squared() > 0.25:
        direction = direction.normalized()
        velocity.x = direction.x * move_speed * 0.55
        velocity.z = direction.z * move_speed * 0.55
        rotation.y = lerp_angle(rotation.y, atan2(direction.x, direction.z), delta * 5.0)
    else:
        velocity.x = move_toward(velocity.x, 0.0, move_speed * delta * 2.0)
        velocity.z = move_toward(velocity.z, 0.0, move_speed * delta * 2.0)

    _apply_gravity(delta)
    move_and_slide()

func _apply_gravity(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= 18.0 * delta
    else:
        velocity.y = 0.0

func apply_control(duration: float = 3.0) -> void:
    control_time_remaining = max(control_time_remaining, duration)

func take_damage(amount: int) -> void:
    if defeated_state or amount <= 0:
        return
    health = max(0, health - amount)
    _update_status_label()
    if health == 0:
        defeated_state = true
        velocity = Vector3.ZERO
        BQEnemySystem.report_defeated(self)
        defeated.emit()
        queue_free()

func _update_status_label() -> void:
    var status := get_node_or_null("Status") as Label3D
    if status == null:
        return
    var definition := BQEnemySystem.get_enemy_definition(enemy_type)
    var title := String(definition.get("display_name", enemy_type)).to_upper()
    status.text = "%s  %d/%d" % [title, health, max_health]
