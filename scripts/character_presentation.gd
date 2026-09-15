extends Node
class_name BQCharacterPresentation

const CHARACTER_STYLES := {
    "ziking": {"primary": Color(0.04, 0.10, 0.20), "accent": Color(0.12, 0.55, 0.95), "silhouette": Color(0.16, 0.22, 0.30)},
    "star": {"primary": Color(0.28, 0.05, 0.16), "accent": Color(1.0, 0.20, 0.55), "silhouette": Color(0.36, 0.12, 0.26)},
    "ella": {"primary": Color(0.04, 0.20, 0.28), "accent": Color(0.20, 0.78, 1.0), "silhouette": Color(0.10, 0.28, 0.34)},
    "ep": {"primary": Color(0.05, 0.10, 0.24), "accent": Color(0.20, 0.55, 1.0), "silhouette": Color(0.12, 0.18, 0.34)},
    "goodshina": {"primary": Color(0.16, 0.14, 0.03), "accent": Color(1.0, 0.78, 0.08), "silhouette": Color(0.24, 0.22, 0.06)}
}

@onready var character_system: BQCharacterSystem = get_parent().get_node_or_null("CharacterSystem") as BQCharacterSystem
@onready var body: MeshInstance3D = get_parent().get_node_or_null("Body") as MeshInstance3D
@onready var head: MeshInstance3D = get_parent().get_node_or_null("Head") as MeshInstance3D

func _ready() -> void:
    if character_system == null:
        return
    character_system.character_changed.connect(_on_character_changed)
    _on_character_changed(character_system.get_active_character())

func _on_character_changed(character: Dictionary) -> void:
    var id := String(character.get("id", "ziking"))
    var style: Dictionary = CHARACTER_STYLES.get(id, CHARACTER_STYLES["ziking"])
    _apply_material(body, style["primary"])
    _apply_material(head, style["silhouette"])

func _apply_material(mesh: MeshInstance3D, color: Color) -> void:
    if mesh == null:
        return
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = 0.58
    mesh.material_override = material
