extends Node
class_name BQCharacterPresentation

const CHARACTER_STYLES := {
    "ziking": {"primary": Color(0.035, 0.08, 0.16), "accent": Color(0.08, 0.55, 1.0), "silhouette": Color(0.20, 0.25, 0.32)},
    "star": {"primary": Color(0.20, 0.035, 0.12), "accent": Color(1.0, 0.16, 0.55), "silhouette": Color(0.35, 0.08, 0.22)},
    "ella": {"primary": Color(0.035, 0.15, 0.20), "accent": Color(0.12, 0.85, 0.95), "silhouette": Color(0.08, 0.25, 0.30)},
    "ep": {"primary": Color(0.035, 0.08, 0.20), "accent": Color(0.15, 0.58, 1.0), "silhouette": Color(0.10, 0.18, 0.34)},
    "goodshina": {"primary": Color(0.13, 0.11, 0.025), "accent": Color(1.0, 0.78, 0.06), "silhouette": Color(0.25, 0.22, 0.05)}
}

@onready var character_system: BQCharacterSystem = get_parent().get_node_or_null("CharacterSystem") as BQCharacterSystem
@onready var body: MeshInstance3D = get_parent().get_node_or_null("Body") as MeshInstance3D
@onready var head: MeshInstance3D = get_parent().get_node_or_null("Head") as MeshInstance3D

var visual_root: Node3D

func _ready() -> void:
    if character_system == null:
        return
    character_system.character_changed.connect(_on_character_changed)
    _on_character_changed(character_system.get_active_character())

func _on_character_changed(character: Dictionary) -> void:
    var id := String(character.get("id", "ziking"))
    var style: Dictionary = CHARACTER_STYLES.get(id, CHARACTER_STYLES["ziking"])
    if body != null:
        body.visible = false
    if head != null:
        head.visible = false
    if visual_root != null and is_instance_valid(visual_root):
        visual_root.queue_free()
    visual_root = Node3D.new()
    visual_root.name = "CharacterVisual"
    get_parent().add_child(visual_root)
    _build_humanoid(style, id)

func _build_humanoid(style: Dictionary, id: String) -> void:
    var primary: Color = style["primary"]
    var accent: Color = style["accent"]
    var silhouette: Color = style["silhouette"]

    _part("Torso", Vector3(0, 1.15, 0), Vector3(0.82, 1.05, 0.42), primary)
    _part("Head", Vector3(0, 2.0, 0), Vector3(0.52, 0.58, 0.52), silhouette)
    _part("LeftArm", Vector3(-0.57, 1.2, 0), Vector3(0.22, 0.9, 0.24), primary)
    _part("RightArm", Vector3(0.57, 1.2, 0), Vector3(0.22, 0.9, 0.24), primary)
    _part("LeftLeg", Vector3(-0.23, 0.43, 0), Vector3(0.28, 0.82, 0.30), silhouette)
    _part("RightLeg", Vector3(0.23, 0.43, 0), Vector3(0.28, 0.82, 0.30), silhouette)
    _part("ChestCore", Vector3(0, 1.25, -0.24), Vector3(0.38, 0.32, 0.06), accent, true)

    match id:
        "ziking":
            _weapon(Vector3(0.78, 0.95, -0.15), Vector3(0.10, 0.48, 0.10), accent)
            _weapon(Vector3(-0.78, 1.05, -0.12), Vector3(0.12, 0.42, 0.12), silhouette)
        "star":
            # The established mask is preserved as a distinct gameplay element.
            _part("Mask", Vector3(0, 2.0, -0.29), Vector3(0.48, 0.25, 0.08), primary, true)
            _weapon(Vector3(-0.75, 1.0, -0.12), Vector3(0.08, 0.62, 0.08), accent)
            _weapon(Vector3(0.75, 1.0, -0.12), Vector3(0.08, 0.62, 0.08), accent)
            _part("FlightCore", Vector3(0, 1.55, 0.20), Vector3(0.22, 0.55, 0.12), accent, true)
        "ella":
            _part("TechRing", Vector3(0.72, 1.1, -0.18), Vector3(0.34, 0.34, 0.08), accent, true)
            _part("TechCore", Vector3(0, 1.45, -0.26), Vector3(0.25, 0.25, 0.06), accent, true)
            _weapon(Vector3(-0.76, 1.05, -0.12), Vector3(0.12, 0.36, 0.12), accent)
        "ep":
            _part("LeftGlove", Vector3(-0.7, 0.9, -0.15), Vector3(0.30, 0.25, 0.38), accent, true)
            _part("RightGlove", Vector3(0.7, 0.9, -0.15), Vector3(0.30, 0.25, 0.38), accent, true)
            _weapon(Vector3(-0.76, 1.02, -0.34), Vector3(0.06, 0.46, 0.06), accent)
            _weapon(Vector3(0.76, 1.02, -0.34), Vector3(0.06, 0.46, 0.06), accent)
        "goodshina":
            _part("StealthCore", Vector3(0, 1.48, -0.26), Vector3(0.28, 0.22, 0.06), accent, true)
            _weapon(Vector3(0.78, 1.0, -0.12), Vector3(0.10, 0.44, 0.10), accent)

func _part(part_name: String, position: Vector3, size: Vector3, color: Color, emissive := false) -> void:
    var mesh := MeshInstance3D.new()
    mesh.name = part_name
    var box := BoxMesh.new()
    box.size = size
    mesh.mesh = box
    mesh.position = position
    mesh.material_override = _material(color, emissive)
    visual_root.add_child(mesh)

func _weapon(position: Vector3, size: Vector3, color: Color) -> void:
    _part("Equipment", position, size, color, true)

func _material(color: Color, emissive: bool) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = 0.52
    if emissive:
        material.emission_enabled = true
        material.emission = color
        material.emission_energy_multiplier = 1.8
    return material
