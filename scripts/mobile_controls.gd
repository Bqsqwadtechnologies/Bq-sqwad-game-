extends CanvasLayer
class_name BQMobileControls

func _ready() -> void:
    layer = 50
    if not OS.has_feature("mobile"):
        visible = false
        return
    _build_controls()

func _exit_tree() -> void:
    _release_all()

func _build_controls() -> void:
    var root := Control.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(root)
    _button(root, "◀", Vector2(32, 535), Vector2(82, 82), "move_left")
    _button(root, "▶", Vector2(208, 535), Vector2(82, 82), "move_right")
    _button(root, "▲", Vector2(120, 450), Vector2(82, 82), "move_forward")
    _button(root, "▼", Vector2(120, 625), Vector2(82, 70), "move_back")
    _button(root, "ATTACK", Vector2(1060, 520), Vector2(170, 82), "attack")
    _button(root, "POWER", Vector2(880, 520), Vector2(150, 82), "ability_primary")
    _button(root, "SPECIAL", Vector2(880, 620), Vector2(150, 70), "ability_secondary")
    _button(root, "JUMP", Vector2(1040, 620), Vector2(125, 70), "jump")
    _button(root, "ACTION", Vector2(1170, 620), Vector2(100, 70), "interact")

func _button(parent: Control, caption: String, position: Vector2, size: Vector2, action: String) -> void:
    var button := Button.new()
    button.text = caption
    button.position = position
    button.size = size
    button.mouse_filter = Control.MOUSE_FILTER_STOP
    button.add_theme_font_size_override("font_size", 20 if caption.length() <= 2 else 14)
    button.add_theme_color_override("font_color", Color(0.86, 0.95, 1.0, 0.95))
    parent.add_child(button)
    button.button_down.connect(func(): Input.action_press(action))
    button.button_up.connect(func(): Input.action_release(action))

func _release_all() -> void:
    for action in ["move_left", "move_right", "move_forward", "move_back", "jump", "attack", "interact", "ability_primary", "ability_secondary"]:
        Input.action_release(action)
