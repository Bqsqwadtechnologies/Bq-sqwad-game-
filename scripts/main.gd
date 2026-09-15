extends Node3D

const WORLD_MATERIALS := preload("res://scripts/world_materials.gd")
const CITY_LANDMARKS := preload("res://scripts/city_landmarks.gd")
const CITY_PROPS := preload("res://scripts/city_props.gd")

var city: Node3D
var landmarks: Node3D

func _ready() -> void:
    _build_landly_city_prototype()

func _process(_delta: float) -> void:
    var mission_system := get_node_or_null("MissionSystem")
    var player := get_node_or_null("Player")
    if mission_system != null and player != null:
        mission_system.update_player_position(player.global_position)

func _build_landly_city_prototype() -> void:
    city = Node3D.new()
    city.name = "LandlyCityPrototype"
    add_child(city)

    _add_ground(city)
    _add_road(city, Vector3(0, 0.02, 0), Vector3(120, 0.1, 14))
    _add_road(city, Vector3(0, 0.03, 0), Vector3(14, 0.1, 120))
    _add_sidewalks(city)
    _add_street_lights(city)
    CITY_PROPS.new().build(city)

    var building_data := [
        [Vector3(-28, 5, -25), Vector3(16, 10, 14)],
        [Vector3(28, 7, -25), Vector3(18, 14, 14)],
        [Vector3(-28, 4, 25), Vector3(14, 8, 18)],
        [Vector3(28, 6, 25), Vector3(20, 12, 16)],
        [Vector3(-48, 3.5, 0), Vector3(10, 7, 18)],
        [Vector3(48, 4.5, 0), Vector3(12, 9, 20)]
    ]

    for item in building_data:
        _add_building(city, item[0], item[1])

    _add_hq(city, Vector3(0, 4, 42))
    _add_training_zone(city, Vector3(-38, 0.1, 38))
    _add_mission_zone(city, Vector3(38, 0.1, 38))
    _add_spawn_marker(city, Vector3(0, 0.1, -34))

    landmarks = Node3D.new()
    landmarks.name = "Landmarks"
    city.add_child(landmarks)
    CITY_LANDMARKS.new().build(landmarks)

func _add_ground(parent: Node3D) -> void:
    var body := StaticBody3D.new()
    body.name = "CityGround"
    parent.add_child(body)
    _add_box(body, Vector3(0, -0.5, 0), Vector3(120, 1, 120), Color(0.035, 0.055, 0.08), "Ground")

func _add_road(parent: Node3D, position: Vector3, size: Vector3) -> void:
    var body := StaticBody3D.new()
    body.name = "Road"
    parent.add_child(body)
    _add_box(body, position, size, Color(0.075, 0.085, 0.11), "Road")

func _add_sidewalks(parent: Node3D) -> void:
    var sidewalk_color := Color(0.16, 0.18, 0.22)
    var pieces := [
        [Vector3(0, 0.12, 10), Vector3(120, 0.18, 5)],
        [Vector3(0, 0.12, -10), Vector3(120, 0.18, 5)],
        [Vector3(10, 0.13, 0), Vector3(5, 0.2, 120)],
        [Vector3(-10, 0.13, 0), Vector3(5, 0.2, 120)]
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

func _add_building(parent: Node3D, position: Vector3, size: Vector3) -> void:
    var body := StaticBody3D.new()
    body.name = "LandlyBuilding"
    parent.add_child(body)
    _add_box(body, position, size, Color(0.12, 0.16, 0.22), "Building")

    var window_rows := int(max(1.0, floor(size.y / 3.0)))
    var window_columns := int(max(2.0, floor(size.x / 4.0)))
    for row in range(window_rows):
        for column in range(window_columns):
            var x := -size.x * 0.5 + 2.0 + float(column) * 4.0
            var y := -size.y * 0.5 + 2.0 + float(row) * 3.0
            if x < size.x * 0.5 - 0.8 and y < size.y * 0.5 - 0.8:
                _add_box(body, Vector3(x, y, -size.z * 0.505), Vector3(1.4, 1.1, 0.08), Color(0.12, 0.42, 0.62), "Window")

func _add_hq(parent: Node3D, position: Vector3) -> void:
    var body := StaticBody3D.new()
    body.name = "BQSqwadHQ"
    parent.add_child(body)
    _add_box(body, position, Vector3(28, 8, 18), Color(0.04, 0.12, 0.2), "BQ Sqwad HQ")
    _add_box(body, position + Vector3(0, 4.2, -9.3), Vector3(12, 1.0, 0.6), Color(0.15, 0.55, 0.9), "HQ Entrance")
    _add_box(body, position + Vector3(0, 0.1, -9.5), Vector3(6, 0.2, 3), Color(0.08, 0.25, 0.4), "HQ Plaza")

func _add_training_zone(parent: Node3D, position: Vector3) -> void:
    var body := StaticBody3D.new()
    body.name = "TrainingZone"
    parent.add_child(body)
    _add_box(body, position, Vector3(24, 0.2, 18), Color(0.07, 0.13, 0.18), "Training Ground")
    _add_box(body, position + Vector3(0, 1.2, -7), Vector3(18, 2.4, 0.5), Color(0.1, 0.25, 0.38), "Training Wall")

func _add_mission_zone(parent: Node3D, position: Vector3) -> void:
    var body := StaticBody3D.new()
    body.name = "MissionZone"
    parent.add_child(body)
    _add_box(body, position, Vector3(24, 0.2, 18), Color(0.12, 0.1, 0.16), "Mission Ground")
    _add_box(body, position + Vector3(-9, 2, 0), Vector3(0.5, 4, 12), Color(0.18, 0.12, 0.2), "Mission Barrier")
    _add_box(body, position + Vector3(9, 2, 0), Vector3(0.5, 4, 12), Color(0.18, 0.12, 0.2), "Mission Barrier")
    _add_box(body, position + Vector3(0, 0.3, 0), Vector3(3.0, 0.12, 3.0), Color(0.1, 0.55, 0.8), "SignalMarker")

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
