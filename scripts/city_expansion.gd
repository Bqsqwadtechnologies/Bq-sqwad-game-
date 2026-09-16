extends Node
class_name BQCityExpansion

const PEOPLE := [
    {"name": "Citizen", "color": Color(0.32, 0.38, 0.48)},
    {"name": "Worker", "color": Color(0.12, 0.48, 0.62)},
    {"name": "Student", "color": Color(0.55, 0.28, 0.52)},
    {"name": "Officer", "color": Color(0.18, 0.22, 0.28)}
]

func build(parent: Node3D) -> void:
    _add_landly_college(parent, Vector3(-58, 5, -42))
    _add_landly_bus(parent, Vector3(0, 1.1, -18), 0.0)
    _add_landly_bus(parent, Vector3(22, 1.1, 18), 90.0)
    _add_public_square(parent, Vector3(0, 0.15, 0))
    _add_military_zone(parent, Vector3(55, 0.15, -48))
    _add_helicopter(parent, Vector3(55, 9, -48))
    _add_tower(parent, Vector3(-55, 14, 45))
    _add_stairs(parent, Vector3(-12, 0.1, 12))
    _add_people(parent)

func _add_people(parent: Node3D) -> void:
    var locations := [
        Vector3(-7, 0.9, -18), Vector3(8, 0.9, -20), Vector3(-18, 0.9, -8), Vector3(19, 0.9, -7),
        Vector3(-24, 0.9, 17), Vector3(24, 0.9, 15), Vector3(-8, 0.9, 29), Vector3(10, 0.9, 31),
        Vector3(-43, 0.9, -38), Vector3(-48, 0.9, -43), Vector3(-40, 0.9, -46), Vector3(-52, 0.9, -35),
        Vector3(43, 0.9, 38), Vector3(48, 0.9, 42), Vector3(38, 0.9, 45), Vector3(44, 0.9, 31),
        Vector3(5, 0.9, 44), Vector3(-5, 0.9, 44), Vector3(30, 0.9, 2), Vector3(-30, 0.9, 2),
        Vector3(2, 0.9, -34), Vector3(-2, 0.9, -34), Vector3(15, 0.9, -34), Vector3(-15, 0.9, -34)
    ]
    for i in range(locations.size()):
        var data: Dictionary = PEOPLE[i % PEOPLE.size()]
        _add_person(parent, locations[i], String(data["name"]), data["color"], i)

func _add_person(parent: Node3D, position: Vector3, role: String, color: Color, index: int) -> void:
    var root := Node3D.new()
    root.name = role + "_%02d" % index
    root.position = position
    parent.add_child(root)

    var body := MeshInstance3D.new()
    var body_mesh := CapsuleMesh.new()
    body_mesh.radius = 0.28
    body_mesh.height = 1.25
    body.mesh = body_mesh
    body.material_override = _material(color)
    body.position.y = 0.62
    root.add_child(body)

    var head := MeshInstance3D.new()
    var head_mesh := SphereMesh.new()
    head_mesh.radius = 0.22
    head_mesh.height = 0.44
    head.mesh = head_mesh
    head.material_override = _material(Color(0.24, 0.28, 0.34))
    head.position.y = 1.45
    root.add_child(head)

    var label := Label3D.new()
    label.text = role
    label.font_size = 12
    label.outline_size = 3
    label.modulate = Color(0.72, 0.82, 0.92)
    label.position.y = 1.85
    label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    root.add_child(label)

func _add_landly_college(parent: Node3D, position: Vector3) -> void:
    var root := Node3D.new()
    root.name = "LandlyCollege"
    root.position = position
    parent.add_child(root)
    _box(root, Vector3.ZERO, Vector3(26, 10, 20), Color(0.10, 0.18, 0.26), "CollegeBuilding")
    _box(root, Vector3(0, 5.3, -10.4), Vector3(14, 1.2, 0.5), Color(0.12, 0.55, 0.82), "CollegeSign")
    var label := Label3D.new()
    label.text = "LANDLY COLLEGE"
    label.font_size = 36
    label.outline_size = 8
    label.position = Vector3(0, 2.0, -10.7)
    label.modulate = Color(0.65, 0.9, 1.0)
    label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    root.add_child(label)
    for floor in range(3):
        _box(root, Vector3(0, -3.2 + floor * 3.1, 10.25), Vector3(20, 2.1, 0.35), Color(0.14, 0.25, 0.34), "CollegeFloor")
    _add_sign(root, Vector3(0, 0.2, -11.2), "PUBLIC SCHOOL / COLLEGE")

func _add_landly_bus(parent: Node3D, position: Vector3, yaw: float) -> void:
    var root := Node3D.new()
    root.name = "LandlyCityBus"
    root.position = position
    root.rotation_degrees.y = yaw
    parent.add_child(root)
    _box(root, Vector3(0, 1.1, 0), Vector3(9.0, 2.2, 2.7), Color(0.08, 0.24, 0.38), "BusBody")
    _box(root, Vector3(0, 1.55, -1.38), Vector3(7.5, 0.85, 0.12), Color(0.12, 0.42, 0.62), "BusWindows")
    _box(root, Vector3(0, 2.0, 0), Vector3(5.0, 0.32, 2.75), Color(0.12, 0.50, 0.76), "BusRoof")
    _add_wheel(root, Vector3(-2.8, 0.2, -1.45))
    _add_wheel(root, Vector3(2.8, 0.2, -1.45))
    _add_sign(root, Vector3(0, 1.9, -1.5), "LANDLY BUS")

func _add_wheel(parent: Node3D, position: Vector3) -> void:
    var wheel := MeshInstance3D.new()
    var mesh := CylinderMesh.new()
    mesh.top_radius = 0.55
    mesh.bottom_radius = 0.55
    mesh.height = 0.28
    wheel.mesh = mesh
    wheel.rotation_degrees = Vector3(90, 0, 0)
    wheel.position = position
    wheel.material_override = _material(Color(0.025, 0.03, 0.04))
    parent.add_child(wheel)

func _add_public_square(parent: Node3D, position: Vector3) -> void:
    var root := Node3D.new()
    root.name = "LandlyPublicSquare"
    root.position = position
    parent.add_child(root)
    _box(root, Vector3(0, 0, 0), Vector3(12, 0.18, 12), Color(0.12, 0.15, 0.19), "PublicViewPlaza")
    _add_sign(root, Vector3(0, 0.5, -5.8), "LANDLY PUBLIC VIEW")
    _box(root, Vector3(0, 1.5, 0), Vector3(0.3, 3, 0.3), Color(0.22, 0.35, 0.46), "PublicTower")

func _add_military_zone(parent: Node3D, position: Vector3) -> void:
    var root := Node3D.new()
    root.name = "LandlyMilitaryZone"
    root.position = position
    parent.add_child(root)
    _box(root, Vector3.ZERO, Vector3(24, 0.2, 24), Color(0.07, 0.10, 0.09), "MilitaryGround")
    _box(root, Vector3(0, 4, 0), Vector3(18, 8, 10), Color(0.11, 0.15, 0.13), "MilitaryHQ")
    _box(root, Vector3(0, 8.2, -5.4), Vector3(10, 1.0, 0.4), Color(0.32, 0.38, 0.34), "MilitarySign")
    _add_sign(root, Vector3(0, 5.0, -5.6), "LANDLY DEFENCE / MILITARY ZONE")
    for x in [-10.0, 10.0]:
        _box(root, Vector3(x, 1.8, 0), Vector3(0.5, 3.6, 0.5), Color(0.24, 0.28, 0.25), "GuardPost")
    _box(root, Vector3(0, 0.3, 10), Vector3(8, 0.2, 6), Color(0.12, 0.18, 0.16), "Helipad")

func _add_helicopter(parent: Node3D, position: Vector3) -> void:
    var root := Node3D.new()
    root.name = "LandlyMilitaryHelicopter"
    root.position = position
    parent.add_child(root)
    _box(root, Vector3.ZERO, Vector3(4.5, 1.2, 2.0), Color(0.10, 0.15, 0.14), "HelicopterBody")
    _box(root, Vector3(2.7, 0.2, 0), Vector3(2.5, 0.35, 0.5), Color(0.08, 0.12, 0.11), "HelicopterTail")
    _box(root, Vector3(0, 0.9, 0), Vector3(5.5, 0.12, 0.12), Color(0.24, 0.30, 0.28), "Rotor")
    _add_sign(root, Vector3(0, -0.9, -1.1), "MILITARY AIR")

func _add_tower(parent: Node3D, position: Vector3) -> void:
    var root := Node3D.new()
    root.name = "LandlyObservationTower"
    root.position = position
    parent.add_child(root)
    _box(root, Vector3(0, 14, 0), Vector3(8, 28, 8), Color(0.10, 0.15, 0.22), "ObservationTower")
    for y in [4.0, 10.0, 16.0, 22.0]:
        _box(root, Vector3(0, y, -4.1), Vector3(6, 2.0, 0.25), Color(0.12, 0.42, 0.62), "TowerWindows")
    _add_sign(root, Vector3(0, 2, -4.5), "LANDLY TOWER")

func _add_stairs(parent: Node3D, position: Vector3) -> void:
    var root := Node3D.new()
    root.name = "PublicStairs"
    root.position = position
    parent.add_child(root)
    for i in range(7):
        _box(root, Vector3(0, i * 0.18, -i * 0.45), Vector3(4.0, 0.36 + i * 0.01, 0.8), Color(0.18, 0.21, 0.25), "StreetStair")

func _add_sign(parent: Node3D, position: Vector3, text_value: String) -> void:
    var label := Label3D.new()
    label.text = text_value
    label.font_size = 18
    label.outline_size = 5
    label.position = position
    label.modulate = Color(0.62, 0.84, 1.0)
    label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    parent.add_child(label)

func _box(parent: Node3D, position: Vector3, size: Vector3, color: Color, label: String) -> void:
    var mesh := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = size
    mesh.mesh = box
    mesh.position = position
    mesh.material_override = _material(color)
    mesh.name = label
    parent.add_child(mesh)

func _material(color: Color) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = 0.62
    return material
