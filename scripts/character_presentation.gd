extends Node
class_name BQCharacterPresentation

const CHARACTER_STYLES := {
    "ziking": {"primary": Color(0.035, 0.08, 0.16), "accent": Color(0.08, 0.55, 1.0), "silhouette": Color(0.20, 0.25, 0.32)},
    "star": {"primary": Color(0.20, 0.035, 0.12), "accent": Color(1.0, 0.16, 0.55), "silhouette": Color(0.35, 0.08, 0.22)},
    "ella": {"primary": Color(0.035, 0.15, 0.20), "accent": Color(0.12, 0.85, 0.95), "silhouette": Color(0.08, 0.25, 0.30)},
    "ep": {"primary": Color(0.035, 0.08, 0.20), "accent": Color(0.15, 0.58, 1.0), "silhouette": Color(0.10, 0.18, 0.34)},
    "goodshina": {"primary": Color(0.13, 0.11, 0.025), "accent": Color(1.0, 0.78, 0.06), "silhouette": Color(0.25, 0.22, 0.05)}
}

const MODEL_PATHS := {
    "ziking": "res://assets/characters/ziking/ziking.glb",
    "star": "res://assets/characters/star/star.glb",
    "ella": "res://assets/characters/ella/ella.glb",
    "ep": "res://assets/characters/ep/ep.glb",
    "goodshina": "res://assets/characters/goodshina/goodshina.glb"
}

@onready var character_system: BQCharacterSystem = get_parent().get_node_or_null("CharacterSystem") as BQCharacterSystem
@onready var body: MeshInstance3D = get_parent().get_node_or_null("Body") as MeshInstance3D
@onready var head: MeshInstance3D = get_parent().get_node_or_null("Head") as MeshInstance3D

var visual_root: Node3D
var imported_model: Node3D
var animation_player: AnimationPlayer
var talk_requested := false
var _last_animation := ""

func _ready() -> void:
    if character_system == null:
        return
    character_system.character_changed.connect(_on_character_changed)
    _on_character_changed(character_system.get_active_character())

func _process(_delta: float) -> void:
    if imported_model == null or not is_instance_valid(imported_model):
        return
    var actor := get_parent() as CharacterBody3D
    if actor == null:
        return

    var desired := "idle"
    if talk_requested:
        desired = "talk"
    elif not actor.is_on_floor():
        desired = "jump"
    elif Vector2(actor.velocity.x, actor.velocity.z).length() > 8.0:
        desired = "run"
    elif Vector2(actor.velocity.x, actor.velocity.z).length() > 0.15:
        desired = "walk"
    _play_best_animation(desired)

func _on_character_changed(character: Dictionary) -> void:
    var id := String(character.get("id", "ziking"))
    var style: Dictionary = CHARACTER_STYLES.get(id, CHARACTER_STYLES["ziking"])
    if visual_root != null and is_instance_valid(visual_root):
        visual_root.queue_free()
    if imported_model != null and is_instance_valid(imported_model):
        imported_model.queue_free()
    imported_model = null
    animation_player = null
    _last_animation = ""

    var path := String(MODEL_PATHS.get(id, ""))
    if not path.is_empty() and ResourceLoader.exists(path):
        var packed := load(path) as PackedScene
        if packed != null:
            imported_model = packed.instantiate() as Node3D
            if imported_model != null:
                imported_model.name = "ImportedCharacterModel"
                imported_model.position = Vector3.ZERO
                get_parent().add_child.call_deferred(imported_model)
                if body != null:
                    body.visible = false
                if head != null:
                    head.visible = false
                animation_player = _find_animation_player(imported_model)
                _play_best_animation("idle")
                return

    # Keep the existing procedural visual as a safe fallback until a real GLB is supplied.
    if body != null:
        body.visible = false
    if head != null:
        head.visible = false
    visual_root = Node3D.new()
    visual_root.name = "CharacterVisual"
    get_parent().add_child(visual_root)
    _build_humanoid(style, id)

func _find_animation_player(root: Node) -> AnimationPlayer:
    if root is AnimationPlayer:
        return root as AnimationPlayer
    for child in root.get_children():
        var found := _find_animation_player(child)
        if found != null:
            return found
    return null

func _play_best_animation(intent: String) -> void:
    if animation_player == null or not is_instance_valid(animation_player):
        return
    var animations := animation_player.get_animation_list()
    if animations.is_empty():
        return
    var candidates: Array[String] = []
    match intent:
        "idle":
            candidates = ["idle", "stand", "breath"]
        "walk":
            candidates = ["walk", "walking", "move"]
        "run":
            candidates = ["run", "running", "sprint"]
        "jump":
            candidates = ["jump", "fall", "air"]
        "talk":
            candidates = ["talk", "speaking", "gesture", "idle"]
        "attack":
            candidates = ["attack", "punch", "strike", "combat"]
        _:
            candidates = [intent]
    for candidate in candidates:
        for animation_name in animations:
            if String(animation_name).to_lower().contains(candidate):
                if _last_animation != animation_name:
                    animation_player.play(animation_name)
                    _last_animation = animation_name
                return
    # If the GLB uses unfamiliar clip names, leave its default/first clip usable.
    if _last_animation.is_empty():
        animation_player.play(animations[0])
        _last_animation = animations[0]

func set_talking(active: bool) -> void:
    talk_requested = active
    if active:
        _play_best_animation("talk")

func play_action_animation(action: String) -> void:
    # Gameplay systems can request a non-looping action by its semantic name.
    if action.to_lower() in ["attack", "hit", "hurt", "defeat", "victory", "dodge"]:
        _play_best_animation(action.to_lower())

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
            _part("EquipmentLeft", Vector3(0.78, 0.95, -0.15), Vector3(0.10, 0.48, 0.10), accent, true)
            _part("EquipmentRight", Vector3(-0.78, 1.05, -0.12), Vector3(0.12, 0.42, 0.12), silhouette)
        "star":
            _part("Mask", Vector3(0, 2.0, -0.29), Vector3(0.48, 0.25, 0.08), primary, true)
            _part("FlightCore", Vector3(0, 1.55, 0.20), Vector3(0.22, 0.55, 0.12), accent, true)
        "ella":
            _part("TechRing", Vector3(0.72, 1.1, -0.18), Vector3(0.34, 0.34, 0.08), accent, true)
            _part("TechCore", Vector3(0, 1.45, -0.26), Vector3(0.25, 0.25, 0.06), accent, true)
        "ep":
            _part("LeftGlove", Vector3(-0.7, 0.9, -0.15), Vector3(0.30, 0.25, 0.38), accent, true)
            _part("RightGlove", Vector3(0.7, 0.9, -0.15), Vector3(0.30, 0.25, 0.38), accent, true)
        "goodshina":
            _part("StealthCore", Vector3(0, 1.48, -0.26), Vector3(0.28, 0.22, 0.06), accent, true)

func _part(part_name: String, position: Vector3, size: Vector3, color: Color, emissive := false) -> void:
    var mesh := MeshInstance3D.new()
    mesh.name = part_name
    var box := BoxMesh.new()
    box.size = size
    mesh.mesh = box
    mesh.position = position
    mesh.material_override = _material(color, emissive)
    visual_root.add_child(mesh)

func _material(color: Color, emissive: bool) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = 0.52
    if emissive:
        material.emission_enabled = true
        material.emission = color
        material.emission_energy_multiplier = 1.8
    return material
