extends Node3D

const WORLD_MATERIALS := preload("res://scripts/world_materials.gd")

func build(parent: Node3D) -> void:
    _add_landmark(parent, Vector3(-42, 3.5, -38), Vector3(12, 7, 12), "North Tower")
    _add_landmark(parent, Vector3(42, 5.0, -38), Vector3(16, 10, 12), "East Tower")
    _add_landmark(parent, Vector3(-42, 4.0, 22), Vector3(14, 8, 14), "Market Block")
    _add_landmark(parent, Vector3(42, 4.5, 22), Vector3(16, 9, 14), "Transit Block")
    _add_plaza(parent, Vector3(0, 0.12, 0))

func _add_landmark(parent: Node3D, position: Vector3, size: Vector3, label: String) -> void:
    var root := Node3D.new()
    root.name = label
    root.position = position
    parent.add_child(root)

    _add_box(root, Vector3.ZERO, size, Color(0.10, 0.14, 0.20), label)
    _add_box(root, Vector3(0, size.y * 0.5 + 0.15, 0), Vector3(size.x * 0.72, 0.25, size.z * 0.72), Color(0.08, 0.30, 0.48), "Roof")

    var strips := int(max(2.0, floor(size.y / 2.5)))
    for row in range(strips):
        var y := -size.y * 0.5 + 1.5 + float(row) * 2.5
        _add_box(root, Vector3(0, y, -size.z * 0.51), Vector3(size.x * 0.68, 0.7, 0.08), Color(0.12, 0.38, 0.58), "FacadeLight")

func _add_plaza(parent: Node3D, position: Vector3) -> void:
    _add_box(parent, position, Vector3(22, 0.16, 22), Color(0.07, 0.10, 0.15), "Central Plaza")
    _add_box(parent, position + Vector3(0, 0.18, 0), Vector3(8, 0.08, 8), Color(0.10, 0.28, 0.40), "Plaza Core")

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
