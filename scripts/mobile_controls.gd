extends CanvasLayer
class_name BQMobileControls

const JOYSTICK := preload("res://scripts/touch_joystick.gd")

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

    var joystick := JOYSTICK.new()
    joystick.position = Vector2(28, -190)
    joystick.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
    root.add_child(joystick)

    _button(root, "ATTACK", Vector2(-190, -190), Vector2(160, 76), "attack", true)
    _button(root, "POWER", Vector2(-355, -190), Vector2(145, 70), "ability_primary", true)
    _button(root, "SPECIAL", Vector2(-355, -108), Vector2(145, 70), "ability_secondary", true)
    _button(root, "JUMP", Vector2(-190, -108), Vector2(110, 65), "jump", true)
    _button(root, "ACTION", Vector2(-75, -108), Vector2(105, 65), "interact", true)
    _button(root, "CHAR", Vector2(-215, 18), Vector2(110, 50), "character_select", false)

func _button(parent: Control, caption: String, position: Vector2, size: Vector2, action: String, bottom_right := false) -> void:
    var button := Button.new()
    button.text = caption
    if bottom_right:
        button.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
    button.position = position
    button.size = size
    button.mouse_filter = Control.MOUSE_FILTER_STOP
    button.add_theme_font_size_override("font_size", 16)
    button.add_theme_color_override("font_color", Color(0.88, 0.96, 1.0, 0.96))
    parent.add_child(button)
    button.button_down.connect(func(): Input.action_press(action))
    button.button_up.connect(func(): Input.action_release(action))

func _release_all() -> void:
    for action in ["move_left", "move_right", "move_forward", "move_back", "jump", "attack", "interact", "ability_primary", "ability_secondary", "character_select"]:
        Input.action_release(action)
