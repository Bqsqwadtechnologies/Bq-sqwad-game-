extends Node
class_name BQAbilitySystem

signal ability_used(ability_name: String)
signal power_state_changed(state_name: String, enabled: bool)
signal cooldown_changed(slot: String, remaining: float, duration: float)

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
    if not primary_ready:
        return
    var system := get_character_system()
    var player := get_player()
    if system == null or player == null:
        return
    var character := system.get_active_character()
    var id := String(character.get("id", "ziking"))
    match id:
        "ziking": _control_target(player, 5.5)
        "goodshina": _electric_strike(player, 45)
        "star": _energy_burst(player, 48)
        "ella": _tech_construct(player, 42)
        "ep": _blade_shot(player, 50)
    _start_cooldown("primary", primary_cooldown)

func use_secondary() -> void:
    if not secondary_ready:
        return
    var system := get_character_system()
    var player := get_player()
    if system == null or player == null:
        return
    var character := system.get_active_character()
    var id := String(character.get("id", "ziking"))
    match id:
        "ziking": _control_guard()
        "goodshina": _vanish_blink(player)
        "star": _toggle_flight()
        "ella": _ring_teleport(player)
        "ep": _speed_burst(player)
    _start_cooldown("secondary", secondary_cooldown)

func _control_target(player: CharacterBody3D, distance: float) -> void:
    var target := _find_target(player, distance)
    if target != null and target.has_method("apply_control"):
        target.apply_control(3.0)
        _spawn_power_fx(player, Color(0.15, 0.55, 1.0), 1.3)
        ability_used.emit("Control")
    else:
        ability_used.emit("Control — no target")

func _control_guard() -> void:
    invulnerable = true
    power_state_changed.emit("Control Guard", true)
    await get_tree().create_timer(3.0).timeout
    if is_instance_valid(self):
        invulnerable = false
        power_state_changed.emit("Control Guard", false)
        ability_used.emit("Control Guard")

func _electric_strike(player: CharacterBody3D, damage: int) -> void:
    _area_damage(player, damage, 6.0)
    _spawn_power_fx(player, Color(1.0, 0.82, 0.08), 1.5)
    ability_used.emit("Yellow Electric Strike")

func _energy_burst(player: CharacterBody3D, damage: int) -> void:
    _area_damage(player, damage, 8.0)
    _spawn_power_fx(player, Color(1.0, 0.25, 0.65), 1.7)
    ability_used.emit("Energy Burst")

func _tech_construct(player: CharacterBody3D, damage: int) -> void:
    _area_damage(player, damage, 7.0)
    _spawn_power_fx(player, Color(0.2, 0.8, 1.0), 1.4)
    ability_used.emit("Tech Construct")

func _blade_shot(player: CharacterBody3D, damage: int) -> void:
    _area_damage(player, damage, 12.0)
    _spawn_power_fx(player, Color(0.2, 0.55, 1.0), 1.8)
    ability_used.emit("Blade Shot")

func _vanish_blink(player: CharacterBody3D) -> void:
    hidden = true
    player.set_character_visibility(false)
    power_state_changed.emit("Disappearance", true)
    var forward := -player.global_transform.basis.z
    player.global_position += forward * 6.0
    _spawn_power_fx(player, Color(1.0, 0.78, 0.08), 1.0)
    ability_used.emit("Disappear + Teleport")
    await get_tree().create_timer(2.0).timeout
    if is_instance_valid(player):
        hidden = false
        player.set_character_visibility(true)
        power_state_changed.emit("Disappearance", false)

func _toggle_flight() -> void:
    flying = not flying
    power_state_changed.emit("Flight", flying)
    ability_used.emit("Flight %s" % ("ON" if flying else "OFF"))

func _ring_teleport(player: CharacterBody3D) -> void:
    var forward := -player.global_transform.basis.z
    player.global_position += forward * 8.0
    _spawn_power_fx(player, Color(0.2, 0.9, 1.0), 1.2)
    ability_used.emit("Ring Teleport")

func _speed_burst(player: CharacterBody3D) -> void:
    var forward := -player.global_transform.basis.z
    player.velocity += forward * 16.0
    _spawn_power_fx(player, Color(0.2, 0.55, 1.0), 1.1)
    ability_used.emit("Speed Burst")

func _find_target(player: CharacterBody3D, distance: float) -> Node3D:
    var space_state := player.get_world_3d().direct_space_state
    var sphere := SphereShape3D.new()
    sphere.radius = distance
    var query := PhysicsShapeQueryParameters3D.new()
    query.shape = sphere
    query.transform = Transform3D(Basis.IDENTITY, player.global_position + Vector3.UP)
    query.exclude = [player]
    var hits := space_state.intersect_shape(query, 32)
    var forward := -player.global_transform.basis.z
    var best: Node3D
    var best_score := -INF
    for hit in hits:
        var candidate := hit.get("collider") as Node3D
        if candidate == null or not candidate.has_method("take_damage"):
            continue
        var offset := candidate.global_position - player.global_position
        offset.y = 0.0
        if offset.length() < 0.1:
            continue
        var score := forward.dot(offset.normalized()) * 3.0 - offset.length() * 0.1
        if score > best_score:
            best_score = score
            best = candidate
    return best

func _area_damage(player: CharacterBody3D, damage: int, radius: float) -> void:
    var space_state := player.get_world_3d().direct_space_state
    var sphere := SphereShape3D.new()
    sphere.radius = radius
    var query := PhysicsShapeQueryParameters3D.new()
    query.shape = sphere
    query.transform = Transform3D(Basis.IDENTITY, player.global_position + Vector3.UP)
    query.exclude = [player]
    var hits := space_state.intersect_shape(query, 48)
    var state := get_node_or_null("/root/BQGameState")
    for hit in hits:
        var target := hit.get("collider") as Node3D
        if target != null and target.has_method("take_damage"):
            target.take_damage(damage)
            if state != null and state.has_method("register_damage"):
                state.register_damage(damage)

func _spawn_power_fx(player: CharacterBody3D, color: Color, scale_amount: float) -> void:
    var fx := MeshInstance3D.new()
    var mesh := SphereMesh.new()
    mesh.radius = 0.35
    mesh.height = 0.7
    fx.mesh = mesh
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.emission_enabled = true
    material.emission = color
    material.emission_energy_multiplier = 3.0
    fx.material_override = material
    fx.scale = Vector3.ONE * scale_amount
    fx.global_position = player.global_position + Vector3.UP * 1.2
    get_tree().current_scene.add_child(fx)
    var tween := fx.create_tween()
    tween.set_parallel(true)
    tween.tween_property(fx, "scale", Vector3.ONE * (scale_amount * 2.4), 0.28)
    tween.tween_property(fx, "transparency", 1.0, 0.32)
    tween.chain().tween_callback(fx.queue_free)

func _start_cooldown(kind: String, duration: float) -> void:
    if kind == "primary":
        primary_ready = false
    else:
        secondary_ready = false
    var remaining := duration
    while remaining > 0.0:
        cooldown_changed.emit(kind, remaining, duration)
        await get_tree().create_timer(0.1).timeout
        remaining -= 0.1
    cooldown_changed.emit(kind, 0.0, duration)
    if kind == "primary":
        primary_ready = true
    else:
        secondary_ready = true
