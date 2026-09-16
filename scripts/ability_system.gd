extends Node
class_name BQAbilitySystem

signal ability_used(ability_name: String)
signal power_state_changed(state_name: String, enabled: bool)

@export var primary_cooldown := 1.0
@export var secondary_cooldown := 2.5

var primary_ready := true
var secondary_ready := true
var invulnerable := false
var hidden := false
var flying := false

func _physics_process(_delta: float) -> void:
    if Input.is_action_just_pressed("ability_primary") and primary_ready:
        use_primary()
    if Input.is_action_just_pressed("ability_secondary") and secondary_ready:
        use_secondary()

func get_character_system() -> BQCharacterSystem:
    return get_parent().get_node_or_null("CharacterSystem") as BQCharacterSystem

func get_player() -> CharacterBody3D:
    return get_parent() as CharacterBody3D

func use_primary() -> void:
    var system := get_character_system()
    var player := get_player()
    if system == null or player == null:
        return
    var character := system.get_active_character()
    var id := String(character.get("id", "ziking"))

    match id:
        "ziking":
            _control_target(player, 4.5)
        "goodshina":
            _electric_strike(player, 45)
        "star":
            _energy_burst(player, 48)
        "ella":
            _tech_construct(player, 42)
        "ep":
            _blade_shot(player, 50)

    _start_cooldown("primary")

func use_secondary() -> void:
    var system := get_character_system()
    var player := get_player()
    if system == null or player == null:
        return
    var character := system.get_active_character()
    var id := String(character.get("id", "ziking"))

    match id:
        "ziking":
            _control_guard()
        "goodshina":
            _vanish_blink(player)
        "star":
            _toggle_flight()
        "ella":
            _ring_teleport(player)
        "ep":
            _speed_burst(player)

    _start_cooldown("secondary")

func _control_target(player: CharacterBody3D, distance: float) -> void:
    var target := _ray_target(player, distance)
    if target != null and target.has_method("apply_control"):
        target.apply_control(3.0)
        ability_used.emit("Control")
    else:
        ability_used.emit("Control — no target")

func _control_guard() -> void:
    invulnerable = true
    power_state_changed.emit("Control Guard", true)
    await get_tree().create_timer(3.0).timeout
    invulnerable = false
    power_state_changed.emit("Control Guard", false)
    ability_used.emit("Control Guard")

func _electric_strike(player: CharacterBody3D, damage: int) -> void:
    _ray_damage(player, damage, 6.0)
    ability_used.emit("Yellow Electric Strike")

func _energy_burst(player: CharacterBody3D, damage: int) -> void:
    _ray_damage(player, damage, 12.0)
    ability_used.emit("Laser Burst")

func _tech_construct(player: CharacterBody3D, damage: int) -> void:
    _ray_damage(player, damage, 8.0)
    ability_used.emit("Tech Construct")

func _blade_shot(player: CharacterBody3D, damage: int) -> void:
    _ray_damage(player, damage, 14.0)
    ability_used.emit("Blade Shot")

func _vanish_blink(player: CharacterBody3D) -> void:
    hidden = true
    if player.has_method("set_character_visibility"):
        player.set_character_visibility(false)
    power_state_changed.emit("Disappearance", true)

    var forward := -player.global_transform.basis.z
    player.global_position += forward * 6.0
    ability_used.emit("Disappear + Teleport")

    await get_tree().create_timer(2.0).timeout
    hidden = false
    if is_instance_valid(player) and player.has_method("set_character_visibility"):
        player.set_character_visibility(true)
    power_state_changed.emit("Disappearance", false)

func _toggle_flight() -> void:
    flying = not flying
    power_state_changed.emit("Flight", flying)
    ability_used.emit("Flight")

func _ring_teleport(player: CharacterBody3D) -> void:
    var forward := -player.global_transform.basis.z
    player.global_position += forward * 8.0
    ability_used.emit("Ring Teleport")

func _speed_burst(player: CharacterBody3D) -> void:
    var forward := -player.global_transform.basis.z
    player.velocity += forward * 16.0
    ability_used.emit("Speed Burst")

func _ray_target(player: CharacterBody3D, distance: float) -> Node3D:
    var space_state := player.get_world_3d().direct_space_state
    var forward := -player.global_transform.basis.z
    var from := player.global_position + Vector3.UP * 1.1
    var to := from + forward * distance
    var query := PhysicsRayQueryParameters3D.create(from, to)
    query.exclude = [player]
    var result := space_state.intersect_ray(query)
    return result.get("collider") as Node3D if not result.is_empty() else null

func _ray_damage(player: CharacterBody3D, damage: int, distance: float) -> void:
    var target := _ray_target(player, distance)
    if target != null and target.has_method("take_damage"):
        target.take_damage(damage)

func _start_cooldown(kind: String) -> void:
    if kind == "primary":
        primary_ready = false
        await get_tree().create_timer(primary_cooldown).timeout
        primary_ready = true
    else:
        secondary_ready = false
        await get_tree().create_timer(secondary_cooldown).timeout
        secondary_ready = true
