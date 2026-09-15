extends Node3D

const BUILDING_MATERIAL := preload("res://scripts/world_materials.gd")

func _ready() -> void:
    _build_landly_city_prototype()

func _build_landly_city_prototype() -> void:
    # Small, testable district. Reference assets will replace these placeholders later.
    var city := Node3D.new()
    city.name = "LandlyCityPrototype"
    add_child(city)

    _add_ground(city)
    _add_road(city, Vector3(0, 0.02, 0), Vector3(120, 0.1, 14))
    _add_road(city, Vector3(0, 0.03, 0), Vector3(14, 0.1, 120))

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

func _add_building(parent: Node3D, position: Vector3, size: Vector3) -> void:
    var body := StaticBody3D.new()
    body.name = "LandlyBuilding"
    parent.add_child(body)
    _add_box(body, position, size, Color(0.12, 0.16, 0.22), "Building")

func _add_hq(parent: Node3D, position: Vector3) -> void:
    var body := StaticBody3D.new()
    body.name = "BQSqwadHQPlaceholder"
    parent.add_child(body)
    _add_box(body, position, Vector3(28, 8, 18), Color(0.04, 0.12, 0.2), "BQ Sqwad HQ")

func _add_box(parent: Node3D, position: Vector3, size: Vector3, color: Color, label: String) -> void:
    var mesh := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = size
    mesh.mesh = box
    mesh.position = position
    mesh.material_override = BUILDING_MATERIAL.make(color)
    mesh.name = label
    parent.add_child(mesh)

    var collision := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = size
    collision.shape = shape
    collision.position = position
    parent.add_child(collision)
