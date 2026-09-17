extends Node
class_name BQCombatSystem

signal target_locked(target: Node3D)
signal attack_started
signal attack_hit(target: Node3D, damage: int)

@export var attack_range := 4.0
@export var attack_damage := 25
@export var attack_cooldown := 0.55
@export var attack_radius := 1.25

var can_attack := true
var locked_target: Node3D

func _physics_process(_delta: float) -> void:
    if Input.is_action_just_pressed("attack") and can_attack:
        _attack()

func _attack() -> void:
    can_attack = false
    attack_started.emit()
    var player := get_parent() as CharacterBody3D
    if player == null:
        await get_tree().create_timer(attack_cooldown).timeout
        can_attack = true
        return

    var target := _find_attack_target(player)
    if target != null and target.has_method("take_damage"):
        locked_target = target
        target_locked.emit(target)
        target.take_damage(attack_damage)
        var state := get_node_or_null("/root/BQGameState")
        if state != null and state.has_method("register_damage"):
            state.register_damage(attack_damage)
        attack_hit.emit(target, attack_damage)

    await get_tree().create_timer(attack_cooldown).timeout
    can_attack = true

func _find_attack_target(player: CharacterBody3D) -> Node3D:
    var space_state := player.get_world_3d().direct_space_state
    var center := player.global_position + Vector3.UP * 1.1
    var sphere := SphereShape3D.new()
    sphere.radius = attack_range
    var query := PhysicsShapeQueryParameters3D.new()
    query.shape = sphere
    query.transform = Transform3D(Basis.IDENTITY, center)
    query.exclude = [player]
    query.collide_with_bodies = true
    var hits := space_state.intersect_shape(query, 32)
    var forward := -player.global_transform.basis.z
    var best: Node3D
    var best_score := -INF
    for hit in hits:
        var candidate := hit.get("collider") as Node3D
        if candidate == null or not candidate.has_method("take_damage"):
            continue
        var offset := candidate.global_position - center
        offset.y = 0.0
        var distance := offset.length()
        if distance > attack_range or distance < 0.05:
            continue
        var facing := forward.dot(offset.normalized())
        if facing < -0.15:
            continue
        var score := facing * 3.0 - distance * 0.15
        if score > best_score:
            best_score = score
            best = candidate
    return best
