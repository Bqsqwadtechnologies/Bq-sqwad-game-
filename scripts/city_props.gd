extends RefCounted

const WORLD_MATERIALS := preload("res://scripts/world_materials.gd")

const BUILDING_REFERENCES := [
    preload("res://assets/world/landly_city/buildings/grok_1789481894997.jpg"),
    preload("res://assets/world/landly_city/buildings/grok_1789481899017.jpg"),
    preload("res://assets/world/landly_city/buildings/grok_1789481912498.jpg")
]

const INTERIOR_REFERENCES := [
    preload("res://assets/world/landly_city/interiors/IMG-20260524-WA0000.jpg"),
    preload("res://assets/world/landly_city/interiors/IMG-20260525-WA0000(1).jpg"),
    preload("res://assets/world/landly_city/interiors/IMG-20260525-WA0001.jpg"),
    preload("res://assets/world/landly_city/interiors/IMG-20260525-WA0002(1).jpg"),
    preload("res://assets/world/landly_city/interiors/IMG-20260525-WA0003(1).jpg"),
    preload("res://assets/world/landly_city/interiors/grok_1789481907180.jpg")
]

func build(parent: Node3D) -> void:
    _add_parking(parent, Vector3(-22, 0.12, -18), Vector3(10, 0.12, 16))
    _add_parking(parent, Vector3(22, 0.12, -18), Vector3(10, 0.12, 16))
    _add_bench(parent, Vector3(-15, 0.25, 14), 0.0)
    _add_bench(parent, Vector3(15, 0.25, -14), PI)
    _add_barrier_line(parent, Vector3(-8, 0.45, 28), 6)
    _add_barrier_line(parent, Vector3(8, 0.45, 28), 6)
    _add_sign(parent, Vector3(-7, 2.0, 18), "HQ")
    _add_sign(parent, Vector3(7, 2.0, 18), "MISSION")
    _build_uploaded_landly_buildings(parent)

func _build_uploaded_landly_buildings(parent: Node3D) -> void:
    var data := [
        {"p": Vector3(-28, 7.0, -25), "s": Vector3(20, 14, 16), "ref": 0, "name": "LandlyReferenceTowerA", "label": "LANDLY BUSINESS CENTER"},
        {"p": Vector3(28, 9.0, -25), "s": Vector3(22, 18, 16), "ref": 1, "name": "LandlyReferenceTowerB", "label": "LANDLY FINANCE PLAZA"},
        {"p": Vector3(-28, 6.0, 25), "s": Vector3(18, 12, 20), "ref": 2, "name": "LandlyReferenceTowerC", "label": "LANDLY RESIDENCES"},
        {"p": Vector3(28, 8.0, 25), "s": Vector3(24, 16, 18), "ref": 0, "name": "LandlyReferenceTowerD", "label": "LANDLY TECHNOLOGY HUB"},
        {"p": Vector3(-48, 5.5, 0), "s": Vector3(14, 11, 20), "ref": 1, "name": "LandlyReferenceTowerE", "label": "LANDLY CIVIC CENTER"},
        {"p": Vector3(48, 6.5, 0), "s": Vector3(16, 13, 22), "ref": 2, "name": "LandlyReferenceTowerF", "label": "LANDLY MEDICAL CENTER"}
    ]
    for index in range(data.size()):
        var item: Dictionary = data[index]
        _add_detailed_building(parent, item["p"], item["s"], int(item["ref"]), index, String(item["name"]), String(item["label"]))

func _add_detailed_building(parent: Node3D, position: Vector3, size: Vector3, reference_index: int, interior_index: int, building_name: String, title: String) -> void:
    var root := Node3D.new()
    root.name = building_name
    root.position = position
    parent.add_child(root)

    var body := StaticBody3D.new()
    body.name = "Structure"
    root.add_child(body)
    _box(body, Vector3.ZERO, size, Color(0.045, 0.075, 0.11), "Structure")

    var reference := BUILDING_REFERENCES[reference_index % BUILDING_REFERENCES.size()]
    _add_facade(root, reference, Vector3(0, 0.2, -size.z * 0.505), Vector2(size.x * 0.9, size.y * 0.88), 0.0, "ReferenceFacadeFront")
    _add_facade(root, reference, Vector3(0, 0.2, size.z * 0.505), Vector2(size.x * 0.9, size.y * 0.88), PI, "ReferenceFacadeBack")

    for x in [-size.x * 0.46, size.x * 0.46]:
        _box(root, Vector3(x, 0.2, -size.z * 0.53), Vector3(0.28, size.y * 0.94, 0.34), Color(0.16, 0.22, 0.29), "FacadeColumn")
    _box(root, Vector3(0, size.y * 0.47, -size.z * 0.53), Vector3(size.x * 0.96, 0.34, 0.36), Color(0.18, 0.28, 0.38), "RoofTrim")
    _box(root, Vector3(0, -size.y * 0.47, -size.z * 0.53), Vector3(size.x * 0.96, 0.34, 0.36), Color(0.08, 0.12, 0.18), "BaseTrim")

    var rows := max(3, int(size.y / 2.7))
    var cols := max(4, int(size.x / 3.2))
    for row in range(rows):
        for col in range(cols):
            var wx := -size.x * 0.42 + float(col) * (size.x * 0.84 / max(1, cols - 1))
            var wy := -size.y * 0.38 + float(row) * (size.y * 0.76 / max(1, rows - 1))
            _box(root, Vector3(wx, wy, -size.z * 0.545), Vector3(1.35, 1.15, 0.08), Color(0.10, 0.40, 0.62), "Window")

    _box(root, Vector3(0, -size.y * 0.31, -size.z * 0.60), Vector3(min(5.0, size.x * 0.3), size.y * 0.22, 0.18), Color(0.08, 0.22, 0.34), "EntranceCanopy")
    _box(root, Vector3(0, -size.y * 0.42, -size.z * 0.60), Vector3(2.8, 0.08, 1.6), Color(0.12, 0.35, 0.5), "EntrancePlaza")

    # Use the supplied interior photography as an entrance/lobby display.
    # It sits behind a dark frame so it reads as a glazed lobby rather than a flat label.
    _add_facade(root, INTERIOR_REFERENCES[interior_index % INTERIOR_REFERENCES.size()], Vector3(0, -size.y * 0.30, -size.z * 0.615), Vector2(min(5.4, size.x * 0.34), min(3.0, size.y * 0.25)), 0.0, "UploadedInteriorLobby")
    _box(root, Vector3(0, -size.y * 0.30, -size.z * 0.625), Vector3(min(5.8, size.x * 0.38), 0.18, 0.18), Color(0.18, 0.30, 0.40), "LobbyFrameTop")

    for x in [-size.x * 0.35, 0.0, size.x * 0.35]:
        _box(root, Vector3(x, size.y * 0.55, 0), Vector3(1.5, 0.5, 1.2), Color(0.09, 0.12, 0.16), "RoofEquipment")

    var label := Label3D.new()
    label.name = "BuildingTitle"
    label.text = title
    label.font_size = 22
    label.outline_size = 7
    label.position = Vector3(0, size.y * 0.31, -size.z * 0.62)
    label.modulate = Color(0.62, 0.88, 1.0)
    label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    root.add_child(label)

    _box(root, Vector3(0, 0, -size.z * 0.565), Vector3(0.16, size.y * 0.78, 0.12), Color(0.12, 0.45, 0.7), "VerticalLight")
    _box(root, Vector3(-size.x * 0.44, 0, -size.z * 0.565), Vector3(0.08, size.y * 0.78, 0.08), Color(0.08, 0.32, 0.52), "EdgeLight")

func _add_facade(parent: Node3D, texture: Texture2D, position: Vector3, size: Vector2, rotation_y: float, label: String) -> void:
    var mesh := MeshInstance3D.new()
    mesh.name = label
    var plane := PlaneMesh.new()
    plane.size = size
    mesh.mesh = plane
    mesh.position = position
    mesh.rotation.y = rotation_y
    var material := StandardMaterial3D.new()
    material.albedo_texture = texture
    material.roughness = 0.82
    material.cull_mode = BaseMaterial3D.CULL_DISABLED
    mesh.material_override = material
    parent.add_child(mesh)

func _add_parking(parent: Node3D, position: Vector3, size: Vector3) -> void:
    var root := Node3D.new()
    root.name = "ParkingBay"
    root.position = position
    parent.add_child(root)
    _box(root, Vector3.ZERO, size, Color(0.045, 0.06, 0.08), "ParkingSurface")
    var lane_count := int(size.x / 2.5)
    for i in range(lane_count):
        var x := -size.x * 0.5 + 1.25 + float(i) * 2.5
        _box(root, Vector3(x, 0.08, 0), Vector3(0.08, 0.02, size.z - 1.0), Color(0.55, 0.58, 0.62), "ParkingLine")

func _add_bench(parent: Node3D, position: Vector3, rotation_y: float) -> void:
    var root := Node3D.new()
    root.name = "CityBench"
    root.position = position
    root.rotation.y = rotation_y
    parent.add_child(root)
    _box(root, Vector3(0, 0.75, 0), Vector3(2.8, 0.18, 0.55), Color(0.18, 0.23, 0.3), "BenchSeat")
    _box(root, Vector3(0, 1.35, 0.2), Vector3(2.8, 1.0, 0.16), Color(0.12, 0.17, 0.23), "BenchBack")
    for x in [-1.0, 1.0]:
        _box(root, Vector3(x, 0.35, 0), Vector3(0.14, 0.7, 0.14), Color(0.3, 0.34, 0.4), "BenchLeg")

func _add_barrier_line(parent: Node3D, position: Vector3, count: int) -> void:
    var root := Node3D.new()
    root.name = "SafetyBarrierLine"
    root.position = position
    parent.add_child(root)
    for i in range(count):
        var x := (float(i) - float(count - 1) * 0.5) * 2.2
        _box(root, Vector3(x, 0.6, 0), Vector3(0.16, 1.2, 0.16), Color(0.25, 0.3, 0.36), "BarrierPost")
        if i < count - 1:
            _box(root, Vector3(x + 1.1, 0.62, 0), Vector3(2.0, 0.12, 0.12), Color(0.18, 0.42, 0.62), "BarrierRail")

func _add_sign(parent: Node3D, position: Vector3, text_value: String) -> void:
    var root := Node3D.new()
    root.name = "DistrictSign"
    root.position = position
    parent.add_child(root)
    _box(root, Vector3(0, -1.5, 0), Vector3(0.12, 3.0, 0.12), Color(0.25, 0.28, 0.34), "SignPost")
    _box(root, Vector3(0, 0.05, 0), Vector3(2.8, 1.1, 0.14), Color(0.06, 0.18, 0.28), "SignPanel")
    var label := Label3D.new()
    label.text = text_value
    label.font_size = 32
    label.outline_size = 8
    label.position = Vector3(0, 0.05, -0.09)
    label.modulate = Color(0.55, 0.85, 1.0)
    root.add_child(label)

func _box(parent: Node3D, position: Vector3, size: Vector3, color: Color, label: String) -> void:
    var mesh := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = size
    mesh.mesh = box
    mesh.position = position
    mesh.material_override = _material(color, 0.72)
    mesh.name = label
    parent.add_child(mesh)

func _material(color: Color, roughness: float) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = roughness
    return material
