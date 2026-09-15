extends RefCounted

const WORLD_MATERIALS := preload("res://scripts/world_materials.gd")

func build(parent: Node3D) -> void:
    _add_bollards(parent, Vector3(15, 0, 14), Vector3(1, 0, 0))
    _add_bollards(parent, Vector3(-15, 0, -14), Vector3(-1, 0, 0))
    _add_benches(parent, Vector3(-16, 0, 16), Vector3(0, 0, 1))
    _add_benches(parent, Vector3(16, 0, -16), Vector3(0, 0, -1))
    _add_sign(parent, Vector3(14, 0, 28), "HQ")
    _add_sign(parent, Vector3(-14, 0, 28), "TRAINING")
    _add_sign(parent, Vector3(30, 0, 28), "SIGNAL")
    _add_planters(parent, Vector3(-18, 0, 2))
    _add_planters(parent, Vector3(18, 0, -2))

func _add_bollards(parent: Node3D, origin: Vector3, direction: Vector3) -> void:
    for i in range(5):
        var root := Node3D.new()
        root.name = "StreetBollard"
        root.position = origin + direction * float(i * 2)
        parent.add_child(root)
        _box(root, Vector3(0, 0.55, 0), Vector3(0.35, 1.1, 0.35), Color(0.22, 0.25, 0.3), "Bollard")
        _box(root, Vector3(0, 1.08, 0), Vector3(0.4, 0.08, 0.4), Color(0.08, 0.42, 0.7), "BollardLight")

func _add_benches(parent: Node3D, origin: Vector3, direction: Vector3) -> void:
    for i in range(2):
        var root := Node3D.new()
        root.name = "CityBench"
        root.position = origin + direction * float(i * 5)
        parent.add_child(root)
        _box(root, Vector3(0, 0.8, 0), Vector3(3.2, 0.18, 0.75), Color(0.16, 0.2, 0.27), "BenchSeat")
        _box(root, Vector3(0, 1.45, 0.25), Vector3(3.2, 1.1, 0.15), Color(0.1, 0.14, 0.2), "BenchBack")
        for x in [-1.15, 1.15]:
            _box(root, Vector3(x, 0.4, 0), Vector3(0.16, 0.8, 0.16), Color(0.25, 0.28, 0.33), "BenchLeg")

func _add_sign(parent: Node3D, position: Vector3, text: String) -> void:
    var root := Node3D.new()
    root.name = "DistrictSign"
    root.position = position
    parent.add_child(root)
    _box(root, Vector3(0, 1.4, 0), Vector3(0.14, 2.8, 0.14), Color(0.25, 0.28, 0.33), "SignPole")
    _box(root, Vector3(0, 2.8, 0), Vector3(2.4, 0.75, 0.12), Color(0.05, 0.16, 0.25), "SignBoard")
    var label := Label3D.new()
    label.text = text
    label.font_size = 48
    label.outline_size = 8
    label.modulate = Color(0.3, 0.8, 1.0)
    label.position = Vector3(0, 2.8, -0.08)
    label.rotation_degrees = Vector3(0, 180, 0)
    root.add_child(label)

func _add_planters(parent: Node3D, position: Vector3) -> void:
    var root := Node3D.new()
    root.name = "CityPlanter"
    root.position = position
    parent.add_child(root)
    _box(root, Vector3(0, 0.45, 0), Vector3(1.6, 0.9, 1.6), Color(0.13, 0.16, 0.2), "Planter")
    for i in range(5):
        var angle := float(i) * 1.256
        var p := Vector3(cos(angle) * 0.45, 1.15, sin(angle) * 0.45)
        _box(root, p, Vector3(0.25, 1.0, 0.25), Color(0.12, 0.3, 0.18), "Plant")

func _box(parent: Node3D, position: Vector3, size: Vector3, color: Color, node_name: String) -> void:
    var mesh := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = size
    mesh.mesh = box
    mesh.position = position
    mesh.material_override = WORLD_MATERIALS.make(color)
    mesh.name = node_name
    parent.add_child(mesh)
