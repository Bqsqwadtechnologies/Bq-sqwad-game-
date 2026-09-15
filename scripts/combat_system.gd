extends Node

signal target_locked(target: Node3D)
signal attack_started
signal attack_hit(target: Node3D, damage: int)

@export var attack_range := 4.0
@export var attack_damage := 25
@export var attack_cooldown := 0.55

var can_attack := true
var locked_target: Node3D

func _physics_process(_delta: float) -> void:
    if Input.is_action_just_pressed("attack") and can_attack:
        _attack()

func _attack() -> void:
    can_attack = false
    attack_started.emit()

    var player := get_parent() as Node3D
    if player == null:
        await get_tree().create_timer(attack_cooldown).timeout
        can_attack = true
        return

    var space_state := player.get_world_3d().direct_space_state
    var forward := -player.global_transform.basis.z
    var from := player.global_position + Vector3.UP * 1.1
    var to := from + forward * attack_range
    var query := PhysicsRayQueryParameters3D.create(from, to)
    query.exclude = [player]
    var result := space_state.intersect_ray(query)

    if not result.is_empty():
        var target := result.get("collider") as Node3D
        if target != null and target.has_method("take_damage"):
            locked_target = target
            target_locked.emit(target)
            target.take_damage(attack_damage)
            attack_hit.emit(target, attack_damage)

    await get_tree().create_timer(attack_cooldown).timeout
    can_attack = true
