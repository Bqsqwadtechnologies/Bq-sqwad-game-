extends RefCounted

const WORLD_MATERIALS := preload("res://scripts/world_materials.gd")

func build(parent: Node3D) -> void:
    _add_parking(parent, Vector3(-22, 0.12, -18), Vector3(10, 0.12, 16))
    _add_parking(parent, Vector3(22, 0.12, -18), Vector3(10, 0.12, 16))
    _add_bench(parent, Vector3(-15, 0.25, 14), 0.0)
    _add_bench(parent, Vector3(15, 0.25, -14), PI)
    _add_barrier_line(parent, Vector3(-8, 0.45, 28), 6)
    _add_barrier_line(parent, Vector3(8, 0.45, 28), 6)
    _add_sign(parent, Vector3(-7, 2.0, 18), "HQ")
    _add_sign(parent, Vector3(7, 2.0, 18), "MISSION")

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
    mesh.material_override = WORLD_MATERIALS.make(color)
    mesh.name = label
    parent.add_child(mesh)
