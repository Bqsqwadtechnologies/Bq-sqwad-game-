extends CanvasLayer
class_name BQCharacterSelect

var panel: PanelContainer
var preview: TextureRect
var name_label: Label
var detail_label: Label
var selected_id := "ziking"
var opened := false

func _ready() -> void:
    layer = 60
    _build_ui()
    _set_open(false)
    set_process_input(true)

func _build_ui() -> void:
    var backdrop := ColorRect.new()
    backdrop.color = Color(0.005, 0.012, 0.025, 0.94)
    backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
    add_child(backdrop)

    panel = PanelContainer.new()
    panel.set_anchors_preset(Control.PRESET_CENTER)
    panel.size = Vector2(1050, 620)
    panel.position = Vector2(-525, -310)
    backdrop.add_child(panel)

    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 24)
    margin.add_theme_constant_override("margin_right", 24)
    margin.add_theme_constant_override("margin_top", 20)
    margin.add_theme_constant_override("margin_bottom", 20)
    panel.add_child(margin)

    var column := VBoxContainer.new()
    column.add_theme_constant_override("separation", 10)
    margin.add_child(column)

    var title := Label.new()
    title.text = "BQ SQWAD  /  CHARACTER SELECT"
    title.add_theme_font_size_override("font_size", 28)
    column.add_child(title)

    var body := HBoxContainer.new()
    body.size_flags_vertical = Control.SIZE_EXPAND_FILL
    body.add_theme_constant_override("separation", 18)
    column.add_child(body)

    var roster_column := VBoxContainer.new()
    roster_column.custom_minimum_size = Vector2(260, 0)
    body.add_child(roster_column)
    for character in BQCharacterSystem.ROSTER:
        var button := Button.new()
        button.text = "%s  •  %s" % [String(character["codename"]), String(character["role"])]
        button.custom_minimum_size = Vector2(250, 54)
        var id := String(character["id"])
        button.pressed.connect(func(): _select(id))
        roster_column.add_child(button)

    preview = TextureRect.new()
    preview.custom_minimum_size = Vector2(360, 440)
    preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    body.add_child(preview)

    var details := VBoxContainer.new()
    details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    body.add_child(details)

    name_label = Label.new()
    name_label.add_theme_font_size_override("font_size", 32)
    details.add_child(name_label)
    detail_label = Label.new()
    detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    detail_label.add_theme_font_size_override("font_size", 17)
    detail_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
    details.add_child(detail_label)

    var actions := HBoxContainer.new()
    actions.alignment = BoxContainer.ALIGNMENT_END
    actions.add_theme_constant_override("separation", 10)
    column.add_child(actions)

    var confirm := Button.new()
    confirm.text = "CONFIRM CHARACTER"
    confirm.custom_minimum_size = Vector2(220, 48)
    confirm.pressed.connect(_confirm)
    actions.add_child(confirm)

    var close := Button.new()
    close.text = "BACK"
    close.custom_minimum_size = Vector2(120, 48)
    close.pressed.connect(func(): _set_open(false))
    actions.add_child(close)

    _select("ziking")

func _select(id: String) -> void:
    selected_id = id
    var character := _get_character(id)
    if character.is_empty():
        return
    name_label.text = String(character["codename"]).to_upper()
    detail_label.text = "ROLE  %s\n\nHEALTH  %d    SPEED  %.1f    POWER  %d\n\nSUPERPOWERS\n%s\n\nABILITIES\n%s\n\nEQUIPMENT\n%s" % [character["role"], int(character["health"]), float(character["speed"]), int(character["power"]), ", ".join(character["superpowers"]), ", ".join(character["abilities"]), ", ".join(character["weapon_types"])]
    var texture := load(String(character["reference_image"])) as Texture2D
    preview.texture = texture

func _confirm() -> void:
    var player := get_node_or_null("../Player")
    if player == null:
        return
    var system := player.get_node_or_null("CharacterSystem") as BQCharacterSystem
    if system != null and system.select_character(selected_id):
        _set_open(false)

func _get_character(id: String) -> Dictionary:
    for character in BQCharacterSystem.ROSTER:
        if String(character["id"]) == id:
            return character
    return {}

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("character_select"):
        _set_open(not opened)
    elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE and opened:
        _set_open(false)

func _set_open(value: bool) -> void:
    opened = value
    if panel != null:
        panel.get_parent().visible = value
