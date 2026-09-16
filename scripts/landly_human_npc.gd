extends CharacterBody3D
class_name LandlyHumanNPC

## Runtime human civilian controller for Landly City.
## The controller is intentionally asset-agnostic so imported human models can
## replace the procedural presentation later without changing navigation,
## roles, destinations, or population management.

var navigation_agent: NavigationAgent3D
var role := "CITIZEN"
var variant := 0
var movement_speed := 1.55
var destinations: Array[Vector3] = []
var waiting := false
var wait_remaining := 0.0
var walk_clock := 0.0
var target_index := -1
var arm_l: Node3D
var arm_r: Node3D
var leg_l: Node3D
var leg_r: Node3D
var torso: Node3D
var head: Node3D
var hair: Node3D

const SKIN_TONES := [
    Color(0.25, 0.14, 0.09), Color(0.36, 0.22, 0.14),
    Color(0.47, 0.31, 0.20), Color(0.58, 0.40, 0.27),
    Color(0.31, 0.18, 0.11), Color(0.64, 0.46, 0.32)
]

const HAIR_TONES := [
    Color(0.025, 0.022, 0.02), Color(0.07, 0.045, 0.03),
    Color(0.12, 0.08, 0.05), Color(0.17, 0.12, 0.08),
    Color(0.055, 0.055, 0.065)
]

const CLOTHING := [
    Color(0.08, 0.10, 0.14), Color(0.12, 0.20, 0.28),
    Color(0.20, 0.17, 0.20), Color(0.24, 0.26, 0.28),
    Color(0.31, 0.20, 0.13), Color(0.10, 0.25, 0.22),
    Color(0.34, 0.15, 0.16), Color(0.22, 0.29, 0.38)
]

func _ready() -> void:
    role = String(get_meta("npc_role", "CITIZEN"))
    variant = int(get_meta("npc_variant", 0))
    movement_speed = float(get_meta("npc_speed", 1.55))
    var raw_destinations = get_meta("npc_destinations", [])
    for destination in raw_destinations:
        if destination is Vector3:
            destinations.append(destination)

    _build_navigation_agent()
    _build_human_body()
    Callable(_begin_navigation).call_deferred()

func _build_navigation_agent() -> void:
    navigation_agent = NavigationAgent3D.new()
    navigation_agent.name = "NavigationAgent3D"
    navigation_agent.path_desired_distance = 0.75
    navigation_agent.target_desired_distance = 1.0
    navigation_agent.radius = 0.32
    navigation_agent.height = 1.75
    navigation_agent.max_speed = movement_speed
    navigation_agent.path_max_distance = 8.0
    navigation_agent.navigation_layers = 1
    # Avoidance is intentionally limited by population manager to keep Android
    # CPU cost controlled when many citizens are active.
    navigation_agent.avoidance_enabled = bool(get_meta("npc_avoidance", false))
    navigation_agent.max_neighbors = 8
    navigation_agent.neighbor_distance = 3.5
    navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))
    add_child(navigation_agent)

func _begin_navigation() -> void:
    await get_tree().physics_frame
    if not is_instance_valid(navigation_agent):
        return
    if destinations.is_empty():
        waiting = true
        wait_remaining = 1.0
        return
    _choose_next_destination()

func _physics_process(delta: float) -> void:
    if navigation_agent == null:
        return

    walk_clock += delta

    if waiting:
        velocity = Vector3.ZERO
        _animate_body(false, delta)
        wait_remaining -= delta
        if wait_remaining <= 0.0:
            waiting = false
            _choose_next_destination()
        return

    if NavigationServer3D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
        velocity = Vector3.ZERO
        _animate_body(false, delta)
        return

    if navigation_agent.is_navigation_finished():
        velocity = Vector3.ZERO
        waiting = true
        wait_remaining = 1.2 + float((variant * 17) % 30) / 10.0
        _animate_body(false, delta)
        return

    var next_path_position := navigation_agent.get_next_path_position()
    var direction := global_position.direction_to(next_path_position)
    direction.y = 0.0

    if direction.length_squared() < 0.0025:
        velocity = Vector3.ZERO
        _animate_body(false, delta)
        return

    direction = direction.normalized()
    var desired_velocity := direction * movement_speed
    desired_velocity.y = 0.0

    if navigation_agent.avoidance_enabled:
        navigation_agent.velocity = desired_velocity
    else:
        velocity = desired_velocity
        move_and_slide()

    _face_direction(direction, delta)
    _animate_body(true, delta)

func _on_velocity_computed(safe_velocity: Vector3) -> void:
    velocity.x = safe_velocity.x
    velocity.z = safe_velocity.z
    velocity.y = 0.0
    move_and_slide()

func _choose_next_destination() -> void:
    if destinations.is_empty():
        return
    var next := variant % destinations.size()
    if destinations.size() > 1 and next == target_index:
        next = (next + 1) % destinations.size()
    target_index = next
    navigation_agent.target_position = destinations[target_index]

func _face_direction(direction: Vector3, delta: float) -> void:
    if direction.length_squared() < 0.01:
        return
    var desired := atan2(direction.x, direction.z)
    rotation.y = lerp_angle(rotation.y, desired, min(delta * 8.0, 1.0))

func _animate_body(is_walking: bool, _delta: float) -> void:
    if arm_l == null:
        return
    if is_walking:
        var swing := sin(walk_clock * 8.0) * 0.34
        arm_l.rotation.x = swing
        arm_r.rotation.x = -swing
        leg_l.rotation.x = -swing * 0.72
        leg_r.rotation.x = swing * 0.72
        torso.position.y = 1.10 + abs(sin(walk_clock * 8.0)) * 0.018
        head.position.y = 1.87 + abs(sin(walk_clock * 8.0)) * 0.012
    else:
        arm_l.rotation.x = lerp(arm_l.rotation.x, 0.0, 0.18)
        arm_r.rotation.x = lerp(arm_r.rotation.x, 0.0, 0.18)
        leg_l.rotation.x = lerp(leg_l.rotation.x, 0.0, 0.18)
        leg_r.rotation.x = lerp(leg_r.rotation.x, 0.0, 0.18)
        torso.position.y = lerp(torso.position.y, 1.10, 0.18)
        head.position.y = lerp(head.position.y, 1.87, 0.18)

func _build_human_body() -> void:
    var skin := SKIN_TONES[variant % SKIN_TONES.size()]
    var hair_color := HAIR_TONES[(variant * 3) % HAIR_TONES.size()]
    var outfit := CLOTHING[(variant * 5 + 1) % CLOTHING.size()]
    var trouser := CLOTHING[(variant * 3 + 3) % CLOTHING.size()]
    var height_scale := 0.92 + float(variant % 7) * 0.025
    var shoulder_scale := 0.90 + float((variant * 2) % 6) * 0.035

    scale = Vector3(height_scale, height_scale, height_scale)

    var collision := CollisionShape3D.new()
    collision.name = "HumanCollision"
    var capsule := CapsuleShape3D.new()
    capsule.radius = 0.30
    capsule.height = 1.78
    collision.shape = capsule
    collision.position.y = 0.90
    add_child(collision)

    var hips := _box(Vector3(0, 0.56, 0), Vector3(0.43, 0.28, 0.26), trouser, "Hips")
    hips.scale.x = shoulder_scale

    torso = _capsule(Vector3(0, 1.10, 0), 0.30 * shoulder_scale, 0.92, outfit, "Torso")
    torso.scale.x = shoulder_scale

    _capsule(Vector3(0, 1.47, 0), 0.27 * shoulder_scale, 0.25, skin, "Neck")
    head = _sphere(Vector3(0, 1.87, 0), 0.255, skin, "Head")
    hair = _sphere(Vector3(0, 2.00, 0), 0.265, hair_color, "Hair")
    hair.scale = Vector3(1.0, 0.72, 1.0)

    arm_l = _capsule(Vector3(-0.40 * shoulder_scale, 1.12, 0), 0.095, 0.78, outfit.lightened(0.06), "ArmL")
    arm_r = _capsule(Vector3(0.40 * shoulder_scale, 1.12, 0), 0.095, 0.78, outfit.lightened(0.06), "ArmR")
    leg_l = _capsule(Vector3(-0.14, 0.30, 0), 0.115, 0.72, trouser, "LegL")
    leg_r = _capsule(Vector3(0.14, 0.30, 0), 0.115, 0.72, trouser, "LegR")
    _box(Vector3(-0.14, 0.05, -0.07), Vector3(0.24, 0.10, 0.42), Color(0.035, 0.04, 0.05), "ShoeL")
    _box(Vector3(0.14, 0.05, -0.07), Vector3(0.24, 0.10, 0.42), Color(0.035, 0.04, 0.05), "ShoeR")

    match role:
        "STUDENT":
            _box(Vector3(0, 1.08, 0.28), Vector3(0.40, 0.46, 0.12), Color(0.07, 0.12, 0.19), "Backpack")
        "TEACHER":
            _box(Vector3(0, 1.22, -0.31), Vector3(0.34, 0.14, 0.05), Color(0.70, 0.72, 0.75), "StaffBadge")
        "MEDICAL":
            _box(Vector3(0, 1.18, -0.31), Vector3(0.36, 0.48, 0.04), Color(0.86, 0.90, 0.92), "MedicalCoat")
            _box(Vector3(0, 1.18, -0.335), Vector3(0.05, 0.28, 0.02), Color(0.15, 0.55, 0.75), "MedicalMark")
        "OFFICER":
            _box(Vector3(0, 1.18, -0.32), Vector3(0.38, 0.52, 0.05), Color(0.08, 0.12, 0.17), "PoliceVest")
            _box(Vector3(0, 1.36, -0.35), Vector3(0.10, 0.07, 0.025), Color(0.75, 0.78, 0.82), "PoliceBadge")
        "WORKER":
            _box(Vector3(0, 1.28, -0.32), Vector3(0.40, 0.10, 0.05), Color(0.88, 0.60, 0.12), "WorkMark")
        "SERVICE":
            _box(Vector3(0, 1.16, -0.32), Vector3(0.34, 0.38, 0.05), Color(0.16, 0.34, 0.40), "ServiceUniform")

func _material(color: Color) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = 0.72
    return material

func _capsule(position_value: Vector3, radius: float, height: float, color: Color, label: String) -> Node3D:
    var mesh := MeshInstance3D.new()
    var shape := CapsuleMesh.new()
    shape.radius = radius
    shape.height = height
    shape.radial_segments = 8
    shape.rings = 4
    mesh.mesh = shape
    mesh.position = position_value
    mesh.material_override = _material(color)
    mesh.name = label
    add_child(mesh)
    return mesh

func _sphere(position_value: Vector3, radius: float, color: Color, label: String) -> Node3D:
    var mesh := MeshInstance3D.new()
    var shape := SphereMesh.new()
    shape.radius = radius
    shape.height = radius * 2.0
    shape.radial_segments = 12
    shape.rings = 8
    mesh.mesh = shape
    mesh.position = position_value
    mesh.material_override = _material(color)
    mesh.name = label
    add_child(mesh)
    return mesh

func _box(position_value: Vector3, size: Vector3, color: Color, label: String) -> Node3D:
    var mesh := MeshInstance3D.new()
    var shape := BoxMesh.new()
    shape.size = size
    mesh.mesh = shape
    mesh.position = position_value
    mesh.material_override = _material(color)
    mesh.name = label
    add_child(mesh)
    return mesh
