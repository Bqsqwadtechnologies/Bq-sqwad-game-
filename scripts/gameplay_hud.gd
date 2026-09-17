extends CanvasLayer
class_name BQGameplayHUD

var health_bar: ProgressBar
var health_label: Label
var character_label: Label
var ability_primary: Button
var ability_secondary: Button
var message_label: Label
var player: BQPlayer
var message_time := 0.0

func _ready() -> void:
    layer = 30
    _build_ui()
    call_deferred("_bind_player")

func _process(delta: float) -> void:
    if message_time > 0.0:
        message_time -= delta
        if message_time <= 0.0 and is_instance_valid(message_label):
            message_label.visible = false
    if is_instance_valid(player):
        var system := player.get_node_or_null("CharacterSystem") as BQCharacterSystem
        if system != null:
            character_label.text = String(system.get_active_character().get("codename", "Ziking")).to_upper()

func _build_ui() -> void:
    var root := Control.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(root)

    var info := PanelContainer.new()
    info.position = Vector2(22, 18)
    info.size = Vector2(270, 100)
    info.mouse_filter = Control.MOUSE_FILTER_IGNORE
    root.add_child(info)
    var column := VBoxContainer.new()
    info.add_child(column)
    character_label = Label.new()
    character_label.text = "ZIKING"
    character_label.add_theme_font_size_override("font_size", 21)
    column.add_child(character_label)
    health_label = Label.new()
    health_label.text = "HEALTH"
    column.add_child(health_label)
    health_bar = ProgressBar.new()
    health_bar.max_value = 100
    health_bar.value = 100
    health_bar.show_percentage = false
    health_bar.custom_minimum_size = Vector2(240, 18)
    column.add_child(health_bar)

    ability_primary = _ability_button(root, "Q  POWER", Vector2(-300, -104), Vector2(130, 52))
    ability_secondary = _ability_button(root, "R  SPECIAL", Vector2(-160, -104), Vector2(130, 52))
    ability_primary.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
    ability_secondary.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)

    var select_button := Button.new()
    select_button.text = "C  CHARACTER"
    select_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
    select_button.position = Vector2(-350, 18)
    select_button.size = Vector2(135, 42)
    select_button.pressed.connect(func(): Input.action_press("character_select"); Input.action_release("character_select"))
    root.add_child(select_button)

    message_label = Label.new()
    message_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
    message_label.position = Vector2(-260, -115)
    message_label.size = Vector2(520, 70)
    message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    message_label.add_theme_font_size_override("font_size", 20)
    message_label.visible = false
    root.add_child(message_label)

func _ability_button(root: Control, caption: String, position: Vector2, size: Vector2) -> Button:
    var button := Button.new()
    button.text = caption
    button.position = position
    button.size = size
    button.mouse_filter = Control.MOUSE_FILTER_IGNORE
    root.add_child(button)
    return button

func _bind_player() -> void:
    player = get_node_or_null("../Player") as BQPlayer
    if player == null:
        return
    player.health_changed.connect(_on_health_changed)
    var ability := player.get_node_or_null("AbilitySystem") as BQAbilitySystem
    if ability != null:
        ability.ability_used.connect(_on_ability_used)
        ability.cooldown_changed.connect(_on_cooldown_changed)
    _on_health_changed(player.health, player.max_health)

func _on_health_changed(current: int, maximum: int) -> void:
    if not is_instance_valid(health_bar):
        return
    health_bar.max_value = maximum
    health_bar.value = current
    health_label.text = "HEALTH  %d / %d" % [current, maximum]

func _on_ability_used(name: String) -> void:
    if not is_instance_valid(message_label):
        return
    message_label.text = name
    message_label.visible = true
    message_time = 1.6

func _on_cooldown_changed(slot: String, remaining: float, duration: float) -> void:
    var button := ability_primary if slot == "primary" else ability_secondary
    if not is_instance_valid(button):
        return
    if remaining > 0.0:
        button.text = "%s  %.1fs" % ["Q  POWER" if slot == "primary" else "R  SPECIAL", remaining]
    else:
        button.text = "Q  POWER" if slot == "primary" else "R  SPECIAL"
