extends Node3D

const WORLD_MATERIALS := preload("res://scripts/world_materials.gd")
const CITY_LANDMARKS := preload("res://scripts/city_landmarks.gd")
const CITY_PROPS := preload("res://scripts/city_props.gd")
const MISSION_INTERACTION := preload("res://scripts/mission_interaction.gd")
const CITY_EXPANSION := preload("res://scripts/city_expansion.gd")
const CITY_LIFE := preload("res://scripts/city_life.gd")

var city: Node3D
var landmarks: Node3D
var night_mode := false

func _ready() -> void:
    _build_landly_city()
    set_process(true)

func _process(_delta: float) -> void:
    var mission_system := get_node_or_null("MissionSystem")
    var player := get_node_or_null("Player")
    if mission_system != null and player != null:
        mission_system.update_player_position(player.global_position)

func toggle_night_mode() -> void:
    night_mode = not night_mode
    _apply_time_of_day()

func set_night_mode(enabled: bool) -> void:
    night_mode = enabled
    _apply_time_of_day()

func is_night_mode() -> bool:
    return night_mode

func _apply_time_of_day() -> void:
    var environment_node := get_node_or_null("Environment") as WorldEnvironment
    var sun := get_node_or_null("Sun") as DirectionalLight3D
    if environment_node == null or sun == null:
        return
    if night_mode:
        environment_node.environment.background_color = Color(0.006, 0.012, 0.03)
        environment_node.environment.ambient_light_color = Color(0.10, 0.15, 0.30)
        environment_node.environment.ambient_light_energy = 0.38
        sun.rotation_degrees = Vector3(-18, -135, 0)
        sun.light_energy = 0.25
    else:
        # Default presentation is a bright late-afternoon Landly City.
        environment_node.environment.background_color = Color(0.18, 0.27, 0.40)
        environment_node.environment.ambient_light_color = Color(0.72, 0.78, 0.88)
        environment_node.environment.ambient_light_energy = 1.0
        sun.rotation_degrees = Vector3(-48, -32, 0)
        sun.light_energy = 1.65

func _build_landly_city() -> void:
    city = Node3D.new()
    city.name = "LandlyCity"
    add_child(city)

    _add_ground(city)
    _add_road(city, Vector3(0, 0.02, 0), Vector3(120, 0.1, 14))
    _add_road(city, Vector3(0, 0.03, 0), Vector3(14, 0.1, 120))
    _add_secondary_roads(city)
    _add_sidewalks(city)
    _add_street_lights(city)

    # city_props now owns the primary 3D architecture and uses the supplied
    # Landly building/interior reference photographs. Do not add the old
    # placeholder buildings here; they previously covered the real references.
    CITY_PROPS.new().build(city)

    _add_hq(city, Vector3(0, 4, 42))
    _add_training_zone(city, Vector3(-38, 0.1, 38))
    _add_mission_zone(city, Vector3(38, 0.1, 38))
    _add_spawn_marker(city, Vector3(0, 0.1, -34))
    _add_city_districts(city)
    _add_world_markers(city)

    landmarks = Node3D.new()
    landmarks.name = "Landmarks"
    city.add_child(landmarks)
    CITY_LANDMARKS.new().build(landmarks)

    CITY_EXPANSION.new().build(city)
    CITY_LIFE.new().build(city)
    _apply_time_of_day()

func _add_secondary_roads(parent: Node3D) -> void:
    for z in [-36.0, 36.0]:
        _add_road(parent, Vector3(0, 0.025, z), Vector3(120, 0.1, 8))
    for x in [-36.0, 36.0]:
        _add_road(parent, Vector3(x, 0.025, 0), Vector3(8, 0.1, 120))

func _add_city_districts(parent: Node3D) -> void:
    _add_district_marker(parent, Vector3(-42, 0.14, -44), "NORTH DISTRICT")
    _add_district_marker(parent, Vector3(42, 0.14, -44), "EAST DISTRICT")
    _add_district_marker(parent, Vector3(-42, 0.14, 44), "TRAINING DISTRICT")
    _add_district_marker(parent, Vector3(42, 0.14, 44), "MISSION DISTRICT")

func _add_district_marker(parent: Node3D, position: Vector3, title: String) -> void:
    var root := Node3D.new()
    root.name = title.replace(" ", "")
    root.position = position
    parent.add_child(root)
    _add_box(root, Vector3(0, 1.8, 0), Vector3(0.25, 3.6, 0.25), Color(0.18, 0.24, 0.32), "DistrictPost")
    var label := Label3D.new()
    label.text = title
    label.font_size = 28
    label.outline_size = 7
    label.position = Vector3(0, 3.7, 0)
    label.modulate = Color(0.55, 0.85, 1.0)
    label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    root.add_child(label)

func _add_world_markers(parent: Node3D) -> void:
    _add_marker(parent, Vector3(0, 0.16, -34), "SPAWN")
    _add_marker(parent, Vector3(-38, 0.16, 38), "TRAINING")
    _add_marker(parent, Vector3(38, 0.16, 38), "MISSION")
    _add_marker(parent, Vector3(0, 0.16, 42), "HQ")

func _add_marker(parent: Node3D, position: Vector3, title: String) -> void:
    var root := Node3D.new()
    root.name = title + "Marker"
    root.position = position
    parent.add_child(root)
    _add_box(root, Vector3.ZERO, Vector3(4.0, 0.08, 1.0), Color(0.08, 0.3, 0.48), title + "Pad")
    var label := Label3D.new()
    label.text = title
    label.font_size = 24
    label.outline_size = 6
    label.position = Vector3(0, 0.4, 0)
    label.modulate = Color(0.65, 0.9, 1.0)
    label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    root.add_child(label)

func _add_ground(parent: Node3D) -> void:
    var body := StaticBody3D.new()
    body.name = "CityGround"
    parent.add_child(body)
    _add_box(body, Vector3(0, -0.5, 0), Vector3(120, 1, 120), Color(0.06, 0.09, 0.12), "Ground")

func _add_road(parent: Node3D, position: Vector3, size: Vector3) -> void:
    var body := StaticBody3D.new()
    body.name = "Road"
    parent.add_child(body)
    _add_box(body, position, size, Color(0.075, 0.085, 0.11), "Road")
    if size.x > size.z:
        for x in range(-55, 56, 10):
            _add_box(body, Vector3(float(x), position.y + 0.055, position.z), Vector3(4.0, 0.025, 0.12), Color(0.76, 0.76, 0.68), "RoadMark")
    else:
        for z in range(-55, 56, 10):
            _add_box(body, Vector3(position.x, position.y + 0.055, float(z)), Vector3(0.12, 0.025, 4.0), Color(0.76, 0.76, 0.68), "RoadMark")

func _add_sidewalks(parent: Node3D) -> void:
    var sidewalk_color := Color(0.18, 0.20, 0.24)
    var pieces := [
        [Vector3(0, 0.12, 10), Vector3(120, 0.18, 5)], [Vector3(0, 0.12, -10), Vector3(120, 0.18, 5)],
        [Vector3(10, 0.13, 0), Vector3(5, 0.2, 120)], [Vector3(-10, 0.13, 0), Vector3(5, 0.2, 120)]
    ]
    for piece in pieces:
        var body := StaticBody3D.new()
        body.name = "Sidewalk"
        parent.add_child(body)
        _add_box(body, piece[0], piece[1], sidewalk_color, "Sidewalk")

func _add_street_lights(parent: Node3D) -> void:
    for z in [-48.0, -32.0, -16.0, 16.0, 32.0, 48.0]:
        _add_lamp(parent, Vector3(18, 0, z))
        _add_lamp(parent, Vector3(-18, 0, z))
    for x in [-48.0, -32.0, -16.0, 16.0, 32.0, 48.0]:
        _add_lamp(parent, Vector3(x, 0, 18))
        _add_lamp(parent, Vector3(x, 0, -18))

func _add_lamp(parent: Node3D, position: Vector3) -> void:
    var root := Node3D.new()
    root.name = "StreetLamp"
    root.position = position
    parent.add_child(root)
    _add_box(root, Vector3(0, 2.2, 0), Vector3(0.18, 4.4, 0.18), Color(0.22, 0.25, 0.3), "LampPole")
    _add_box(root, Vector3(0, 4.35, 0), Vector3(0.7, 0.18, 0.7), Color(0.15, 0.35, 0.55), "LampGlow")

func _add_hq(parent: Node3D, position: Vector3) -> void:
    var body := StaticBody3D.new()
    body.name = "BQSqwadHQ"
    parent.add_child(body)
    _add_box(body, position, Vector3(28, 8, 18), Color(0.04, 0.12, 0.2), "BQ Sqwad HQ")
    _add_box(body, position + Vector3(0, 4.2, -9.3), Vector3(12, 1.0, 0.6), Color(0.15, 0.55, 0.9), "HQ Entrance")
    _add_box(body, position + Vector3(0, 0.1, -9.5), Vector3(6, 0.2, 3), Color(0.08, 0.25, 0.4), "HQ Plaza")
    var label := Label3D.new()
    label.text = "BQ SQWAD HQ"
    label.font_size = 48
    label.outline_size = 10
    label.position = position + Vector3(0, 1.8, -9.65)
    label.modulate = Color(0.65, 0.9, 1.0)
    label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    parent.add_child(label)

func _add_training_zone(parent: Node3D, position: Vector3) -> void:
    var body := StaticBody3D.new()
    body.name = "TrainingZone"
    parent.add_child(body)
    _add_box(body, position, Vector3(24, 0.2, 18), Color(0.07, 0.13, 0.18), "Training Ground")
    _add_box(body, position + Vector3(0, 1.2, -7), Vector3(18, 2.4, 0.5), Color(0.1, 0.25, 0.38), "Training Wall")
    _add_box(body, position + Vector3(-7, 1.0, 0), Vector3(0.5, 2.0, 8), Color(0.1, 0.25, 0.38), "Training Wall")

func _add_mission_zone(parent: Node3D, position: Vector3) -> void:
    var body := StaticBody3D.new()
    body.name = "MissionZone"
    parent.add_child(body)
    _add_box(body, position, Vector3(24, 0.2, 18), Color(0.12, 0.1, 0.16), "Mission Ground")
    _add_box(body, position + Vector3(-9, 2, 0), Vector3(0.5, 4, 12), Color(0.18, 0.12, 0.2), "Mission Barrier")
    _add_box(body, position + Vector3(9, 2, 0), Vector3(0.5, 4, 12), Color(0.18, 0.12, 0.2), "Mission Barrier")
    _add_box(body, position + Vector3(0, 0.3, 0), Vector3(3.0, 0.12, 3.0), Color(0.1, 0.55, 0.8), "SignalMarker")
    var interaction := Area3D.new()
    interaction.name = "SignalInteraction"
    interaction.position = position + Vector3(0, 1.2, 0)
    interaction.collision_layer = 0
    interaction.collision_mask = 1
    interaction.set_script(MISSION_INTERACTION)
    parent.add_child(interaction)
    var collision := CollisionShape3D.new()
    var shape := SphereShape3D.new()
    shape.radius = 3.5
    collision.shape = shape
    interaction.add_child(collision)

func _add_spawn_marker(parent: Node3D, position: Vector3) -> void:
    var body := StaticBody3D.new()
    body.name = "SafeSpawn"
    parent.add_child(body)
    _add_box(body, position, Vector3(8, 0.12, 8), Color(0.05, 0.2, 0.3), "Safe Spawn")

func _add_box(parent: Node3D, position: Vector3, size: Vector3, color: Color, label: String) -> void:
    var mesh := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = size
    mesh.mesh = box
    mesh.position = position
    mesh.material_override = WORLD_MATERIALS.make(color)
    mesh.name = label
    parent.add_child(mesh)
    var collision := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = size
    collision.shape = shape
    collision.position = position
    parent.add_child(collision)
