extends CanvasLayer
class_name AdminDashboard

const ADMIN_EMAIL := "isaacoshiomole0@gmail.com"
const AdminStore = preload("res://scripts/admin_character_store.gd")

var store: AdminCharacterStore
var authenticated := false
var overlay: ColorRect
var window: PanelContainer
var content: VBoxContainer
var status_label: Label
var character_list: VBoxContainer
var selected_character_id := ""
var upload_dialog: FileDialog
var import_dialog: FileDialog

func _ready() -> void:
    layer = 100
    store = AdminStore.new()
    store.load_catalog()
    _build_shell()
    _show_gate()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F8:
        if authenticated:
            visible = not visible
        else:
            visible = true
            _show_gate()
        get_viewport().set_input_as_handled()

func _build_shell() -> void:
    overlay = ColorRect.new()
    overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    overlay.color = Color(0.008, 0.015, 0.035, 0.96)
    add_child(overlay)

    window = PanelContainer.new()
    window.set_anchors_preset(Control.PRESET_CENTER)
    window.position = Vector2(70, 35)
    window.size = Vector2(1140, 650)
    add_child(window)

    var outer := VBoxContainer.new()
    outer.add_theme_constant_override("separation", 0)
    window.add_child(outer)

    var header := HBoxContainer.new()
    header.custom_minimum_size.y = 72
    header.add_theme_constant_override("separation", 18)
    outer.add_child(header)

    var brand := VBoxContainer.new()
    header.add_child(brand)
    var title := Label.new()
    title.text = "BQ SQWAD  /  ADMIN COMMAND"
    title.add_theme_font_size_override("font_size", 22)
    brand.add_child(title)
    var subtitle := Label.new()
    subtitle.text = "Landly City live development control center"
    subtitle.add_theme_font_size_override("font_size", 12)
    brand.add_child(subtitle)

    var spacer := Control.new()
    spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    header.add_child(spacer)
    var admin := Label.new()
    admin.text = ADMIN_EMAIL
    admin.add_theme_font_size_override("font_size", 12)
    header.add_child(admin)
    var close := Button.new()
    close.text = "CLOSE  [F8]"
    close.pressed.connect(_close_dashboard)
    header.add_child(close)

    var body := HBoxContainer.new()
    body.size_flags_vertical = Control.SIZE_EXPAND_FILL
    body.add_theme_constant_override("separation", 0)
    outer.add_child(body)

    var nav := VBoxContainer.new()
    nav.custom_minimum_size.x = 190
    nav.add_theme_constant_override("separation", 6)
    body.add_child(nav)

    for item in ["OVERVIEW", "CHARACTERS", "MISSIONS", "WORLD", "ASSETS", "PROGRESSION", "SETTINGS"]:
        var button := Button.new()
        button.text = item
        button.custom_minimum_size.y = 42
        button.alignment = HORIZONTAL_ALIGNMENT_LEFT
        button.pressed.connect(_open_tab.bind(item))
        nav.add_child(button)

    content = VBoxContainer.new()
    content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    content.size_flags_vertical = Control.SIZE_EXPAND_FILL
    content.add_theme_constant_override("separation", 10)
    body.add_child(content)

    status_label = Label.new()
    status_label.text = "READY"
    status_label.custom_minimum_size.y = 28
    outer.add_child(status_label)

    upload_dialog = FileDialog.new()
    upload_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
    upload_dialog.access = FileDialog.ACCESS_FILESYSTEM
    upload_dialog.title = "Import character asset"
    upload_dialog.file_selected.connect(_on_asset_selected)
    add_child(upload_dialog)

    import_dialog = FileDialog.new()
    import_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
    import_dialog.access = FileDialog.ACCESS_FILESYSTEM
    import_dialog.title = "Import character JSON"
    import_dialog.filters = PackedStringArray(["*.json ; Character profile JSON"])
    import_dialog.file_selected.connect(_on_character_json_selected)
    add_child(import_dialog)

    _open_tab("OVERVIEW")

func _show_gate() -> void:
    if window == null:
        return
    overlay.visible = true
    window.visible = true
    for child in window.get_children():
        child.visible = false
    var gate := VBoxContainer.new()
    gate.name = "AdminGate"
    gate.set_anchors_preset(Control.PRESET_CENTER)
    gate.position = Vector2(310, 145)
    gate.size = Vector2(520, 330)
    gate.add_theme_constant_override("separation", 14)
    window.add_child(gate)

    var title := Label.new()
    title.text = "BQ SQWAD ADMIN ACCESS"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 28)
    gate.add_child(title)
    var info := Label.new()
    info.text = "Enter the authorized development account to open the command center."
    info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    gate.add_child(info)
    var email := LineEdit.new()
    email.placeholder_text = "Admin email"
    email.custom_minimum_size.y = 44
    email.name = "Email"
    gate.add_child(email)
    var login := Button.new()
    login.text = "AUTHENTICATE"
    login.custom_minimum_size.y = 48
    login.pressed.connect(_authenticate.bind(email))
    gate.add_child(login)
    var hint := Label.new()
    hint.text = "Authorized administrator: " + ADMIN_EMAIL + "\nPrototype gate; connect to Firebase Auth before production release."
    hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    gate.add_child(hint)
    email.grab_focus()

func _authenticate(email: LineEdit) -> void:
    if email.text.strip_edges().to_lower() != ADMIN_EMAIL:
        status_label.text = "ACCESS DENIED  •  ADMIN ACCOUNT REQUIRED"
        email.select_all()
        return
    authenticated = true
    _clear_window()
    _open_tab("OVERVIEW")
    status_label.text = "ADMIN SESSION ACTIVE  •  LOCAL DEVELOPMENT CONTROL"

func _close_dashboard() -> void:
    visible = false

func _clear_window() -> void:
    for child in window.get_children():
        child.queue_free()

func _open_tab(tab: String) -> void:
    if not authenticated:
        return
    _clear_window()
    var root := VBoxContainer.new()
    root.name = "Tab"
    root.add_theme_constant_override("separation", 12)
    window.add_child(root)
    var title := Label.new()
    title.text = tab
    title.add_theme_font_size_override("font_size", 26)
    root.add_child(title)
    var subtitle := Label.new()
    subtitle.text = _tab_subtitle(tab)
    subtitle.add_theme_font_size_override("font_size", 13)
    root.add_child(subtitle)

    match tab:
        "OVERVIEW": _build_overview(root)
        "CHARACTERS": _build_characters(root)
        "MISSIONS": _build_missions(root)
        "WORLD": _build_world(root)
        "ASSETS": _build_assets(root)
        "PROGRESSION": _build_progression(root)
        "SETTINGS": _build_settings(root)

func _tab_subtitle(tab: String) -> String:
    match tab:
        "OVERVIEW": return "Live project health, content counts and development controls."
        "CHARACTERS": return "Create, edit, import and prepare BQ Sqwad characters for the data-driven roster."
        "MISSIONS": return "Mission framework status and live mission controls."
        "WORLD": return "Landly City runtime structure and expansion controls."
        "ASSETS": return "Reference, character, world and audio asset inventory."
        "PROGRESSION": return "Player progression architecture and persistence readiness."
        "SETTINGS": return "Administrator identity and production integration checklist."
    return ""

func _build_overview(root: VBoxContainer) -> void:
    var grid := GridContainer.new()
    grid.columns = 3
    grid.add_theme_constant_override("h_separation", 10)
    grid.add_theme_constant_override("v_separation", 10)
    root.add_child(grid)
    _stat_card(grid, "CHARACTERS", str(store.characters.size()))
    _stat_card(grid, "MISSION SYSTEM", "CONNECTED")
    _stat_card(grid, "COMBAT", "CONNECTED")
    _stat_card(grid, "LANDLY CITY", "ACTIVE")
    _stat_card(grid, "ADMIN", "AUTHORIZED")
    _stat_card(grid, "FIREBASE", "READY FOR INTEGRATION")
    var actions := HBoxContainer.new()
    actions.add_theme_constant_override("separation", 8)
    root.add_child(actions)
    _action(actions, "MANAGE CHARACTERS", "CHARACTERS")
    _action(actions, "MISSION CONTROL", "MISSIONS")
    _action(actions, "WORLD CONTROL", "WORLD")
    _action(actions, "ASSET LIBRARY", "ASSETS")
    var note := Label.new()
    note.text = "No fake cloud state is reported as live. Local character data is persisted under user:// until Firebase/Storage is connected."
    note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    root.add_child(note)

func _stat_card(parent: Container, name: String, value: String) -> void:
    var panel := PanelContainer.new()
    panel.custom_minimum_size = Vector2(220, 90)
    parent.add_child(panel)
    var box := VBoxContainer.new()
    panel.add_child(box)
    var a := Label.new()
    a.text = name
    a.add_theme_font_size_override("font_size", 11)
    box.add_child(a)
    var b := Label.new()
    b.text = value
    b.add_theme_font_size_override("font_size", 20)
    box.add_child(b)

func _action(parent: Container, text: String, tab: String) -> void:
    var button := Button.new()
    button.text = text
    button.custom_minimum_size = Vector2(170, 42)
    button.pressed.connect(_open_tab.bind(tab))
    parent.add_child(button)

func _build_characters(root: VBoxContainer) -> void:
    var toolbar := HBoxContainer.new()
    toolbar.add_theme_constant_override("separation", 8)
    root.add_child(toolbar)
    _button(toolbar, "NEW CHARACTER", _new_character)
    _button(toolbar, "IMPORT JSON", func(): import_dialog.popup_centered_ratio(0.7))
    _button(toolbar, "IMPORT ASSET", func(): upload_dialog.popup_centered_ratio(0.7))
    _button(toolbar, "REFRESH", func(): store.load_catalog(); _open_tab("CHARACTERS"))

    var scroll := ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    root.add_child(scroll)
    character_list = VBoxContainer.new()
    character_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.add_child(character_list)
    for character in store.characters:
        _character_row(character)

func _character_row(character: Dictionary) -> void:
    var panel := PanelContainer.new()
    panel.custom_minimum_size.y = 92
    character_list.add_child(panel)
    var row := HBoxContainer.new()
    row.add_theme_constant_override("separation", 12)
    panel.add_child(row)
    var info := VBoxContainer.new()
    info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    row.add_child(info)
    var name := Label.new()
    name.text = "%s  •  %s" % [character.get("codename", "Unnamed"), character.get("role", "")]
    name.add_theme_font_size_override("font_size", 18)
    info.add_child(name)
    var meta := Label.new()
    meta.text = "%s  |  %s  |  %s  |  Level %s" % [character.get("real_name", ""), character.get("faction", ""), character.get("status", ""), str(character.get("unlock_level", 1))]
    info.add_child(meta)
    var abilities := Label.new()
    abilities.text = "Abilities: " + ", ".join(PackedStringArray(character.get("abilities", [])))
    abilities.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    info.add_child(abilities)
    _button(row, "EDIT", func(): _edit_character(character))
    _button(row, "DELETE", func(): _delete_character(String(character.get("id", ""))))

func _new_character() -> void:
    _show_character_editor({})

func _edit_character(character: Dictionary) -> void:
    _show_character_editor(character.duplicate(true))

func _show_character_editor(character: Dictionary) -> void:
    var dialog := AcceptDialog.new()
    dialog.title = "Character Studio"
    dialog.ok_button_text = "SAVE CHARACTER"
    dialog.min_size = Vector2(720, 600)
    add_child(dialog)
    var scroll := ScrollContainer.new()
    scroll.custom_minimum_size = Vector2(680, 500)
    dialog.add_child(scroll)
    var form := GridContainer.new()
    form.columns = 2
    form.add_theme_constant_override("h_separation", 12)
    form.add_theme_constant_override("v_separation", 8)
    scroll.add_child(form)
    var fields: Dictionary = {}
    for spec in [["id", "ID"], ["codename", "Codename"], ["real_name", "Real name"], ["role", "Role"], ["faction", "Faction"], ["rarity", "Rarity"], ["status", "Status"], ["unlock_level", "Unlock level"], ["health", "Health"], ["speed", "Speed"], ["power", "Power"], ["portrait", "Portrait path"], ["model", "Model path"]]:
        var label := Label.new()
        label.text = spec[1]
        form.add_child(label)
        var field := LineEdit.new()
        field.text = str(character.get(spec[0], ""))
        field.custom_minimum_size.x = 420
        fields[spec[0]] = field
        form.add_child(field)
    var ability_label := Label.new()
    ability_label.text = "Abilities (comma separated)"
    form.add_child(ability_label)
    var ability_field := LineEdit.new()
    ability_field.text = ", ".join(PackedStringArray(character.get("abilities", [])))
    fields["abilities"] = ability_field
    form.add_child(ability_field)
    var lore_label := Label.new()
    lore_label.text = "Lore"
    form.add_child(lore_label)
    var lore_field := TextEdit.new()
    lore_field.text = str(character.get("lore", ""))
    lore_field.custom_minimum_size = Vector2(420, 100)
    fields["lore"] = lore_field
    form.add_child(lore_field)
    dialog.confirmed.connect(func():
        var saved := character.duplicate(true)
        for key in ["id", "codename", "real_name", "role", "faction", "rarity", "status", "portrait", "model"]:
            saved[key] = fields[key].text.strip_edges()
        saved["unlock_level"] = _to_int(fields["unlock_level"].text, 1)
        saved["health"] = _to_int(fields["health"].text, 100)
        saved["speed"] = _to_float(fields["speed"].text, 7.0)
        saved["power"] = _to_int(fields["power"].text, 25)
        saved["abilities"] = _split_csv(fields["abilities"].text)
        saved["lore"] = fields["lore"].text.strip_edges()
        if store.upsert_character(saved):
            status_label.text = "CHARACTER SAVED  •  " + String(saved.get("codename", ""))
            _open_tab("CHARACTERS")
        else:
            status_label.text = "CHARACTER SAVE FAILED"
    )
    dialog.popup_centered()

func _delete_character(id: String) -> void:
    if id.is_empty():
        return
    var confirm := ConfirmationDialog.new()
    confirm.title = "Delete Character"
    confirm.dialog_text = "Delete character '%s' from the admin catalog?" % id
    add_child(confirm)
    confirm.confirmed.connect(func():
        store.remove_character(id)
        _open_tab("CHARACTERS")
        status_label.text = "CHARACTER REMOVED  •  " + id
    )
    confirm.popup_centered()

func _on_character_json_selected(path: String) -> void:
    var character := store.import_character_json(path)
    if character.is_empty():
        status_label.text = "IMPORT FAILED  •  INVALID CHARACTER JSON"
        return
    if store.upsert_character(character):
        status_label.text = "CHARACTER IMPORTED  •  " + String(character.get("codename", character.get("id", "")))
        if authenticated:
            _open_tab("CHARACTERS")

func _on_asset_selected(path: String) -> void:
    if selected_character_id.is_empty():
        status_label.text = "SELECT A CHARACTER BEFORE IMPORTING AN ASSET"
        return
    var copied := store.copy_asset(path, "characters", selected_character_id)
    status_label.text = "ASSET IMPORTED  •  " + copied if not copied.is_empty() else "ASSET IMPORT FAILED"

func _build_missions(root: VBoxContainer) -> void:
    var mission_system := get_tree().current_scene.get_node_or_null("MissionSystem")
    var grid := GridContainer.new()
    grid.columns = 2
    root.add_child(grid)
    if mission_system != null:
        _stat_card(grid, "ACTIVE", str(mission_system.active_mission))
        _stat_card(grid, "MISSION", mission_system.mission_title)
        _stat_card(grid, "OBJECTIVE", mission_system.objective)
        _stat_card(grid, "XP REWARD", str(mission_system.xp_reward))
        _stat_card(grid, "OBJECTIVE REACHED", str(mission_system.objective_reached))
    var note := Label.new()
    note.text = "MissionSystem is the runtime source of truth. Future mission authoring can use the same data-driven pattern as characters."
    note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    root.add_child(note)

func _build_world(root: VBoxContainer) -> void:
    var scene := get_tree().current_scene
    var grid := GridContainer.new()
    grid.columns = 2
    root.add_child(grid)
    _stat_card(grid, "CURRENT SCENE", scene.name if scene != null else "NONE")
    _stat_card(grid, "PLAYER", "CONNECTED" if scene != null and scene.get_node_or_null("Player") != null else "MISSING")
    _stat_card(grid, "MISSION ZONE", "CONNECTED")
    _stat_card(grid, "BQ SQWAD HQ", "CONNECTED")
    _stat_card(grid, "LANDMARK LAYER", "ACTIVE")
    _stat_card(grid, "ENEMY PROTOTYPE", "CONNECTED" if scene != null and scene.get_node_or_null("MissionScout") != null else "MISSING")

func _build_assets(root: VBoxContainer) -> void:
    var counts := {"characters": 0, "world": 0, "audio": 0, "ui": 0}
    _scan_asset_counts("res://assets/characters", counts, "characters")
    _scan_asset_counts("res://assets/world", counts, "world")
    _scan_asset_counts("res://assets/audio", counts, "audio")
    _scan_asset_counts("res://assets/ui", counts, "ui")
    var grid := GridContainer.new()
    grid.columns = 2
    root.add_child(grid)
    for key in counts.keys():
        _stat_card(grid, String(key).to_upper(), str(counts[key]))
    var info := Label.new()
    info.text = "Character imports made at runtime are stored in user://bq_sqwad_admin/assets. Project assets remain in the Git repository."
    info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    root.add_child(info)

func _scan_asset_counts(path: String, counts: Dictionary, key: String) -> void:
    var dir := DirAccess.open(path)
    if dir == null:
        return
    dir.list_dir_begin()
    while true:
        var name := dir.get_next()
        if name.is_empty():
            break
        if name.begins_with("."):
            continue
        if dir.current_is_dir():
            _scan_asset_counts(path.path_join(name), counts, key)
        else:
            counts[key] += 1
    dir.list_dir_end()

func _build_progression(root: VBoxContainer) -> void:
    var grid := GridContainer.new()
    grid.columns = 2
    root.add_child(grid)
    _stat_card(grid, "PERSISTENCE", "ARCHITECTURE READY")
    _stat_card(grid, "CLOUD SAVE", "FIREBASE PENDING")
    _stat_card(grid, "XP", "MISSION SYSTEM")
    _stat_card(grid, "CHARACTER UNLOCKS", "CATALOG READY")
    var note := Label.new()
    note.text = "Progression is deliberately not faked as cloud-saved. Firebase persistence will become the authoritative player-data layer when authentication is connected."
    note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    root.add_child(note)

func _build_settings(root: VBoxContainer) -> void:
    var grid := GridContainer.new()
    grid.columns = 2
    root.add_child(grid)
    _stat_card(grid, "ADMIN ACCOUNT", ADMIN_EMAIL)
    _stat_card(grid, "ENGINE", "GODOT 4.7.2")
    _stat_card(grid, "RENDERER", "GL COMPATIBILITY")
    _stat_card(grid, "DEFAULT BRANCH", "main")
    var checklist := Label.new()
    checklist.text = "PRODUCTION CHECKLIST\n✓ Data-driven character catalog\n✓ Admin character studio\n✓ Character JSON import\n✓ Runtime asset import\n✓ Mission/world/combat visibility\n□ Firebase Auth enforcement\n□ Firebase Storage character assets\n□ Server-side admin authorization\n□ Cloud character catalog synchronization"
    checklist.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    root.add_child(checklist)

func _button(parent: Container, text: String, callback: Callable) -> Button:
    var button := Button.new()
    button.text = text
    button.custom_minimum_size.y = 38
    button.pressed.connect(callback)
    parent.add_child(button)
    return button

func _to_int(value: String, fallback: int) -> int:
    var parsed := value.to_int()
    return parsed if not value.strip_edges().is_empty() else fallback

func _to_float(value: String, fallback: float) -> float:
    var parsed := value.to_float()
    return parsed if not value.strip_edges().is_empty() else fallback

func _split_csv(value: String) -> Array[String]:
    var result: Array[String] = []
    for item in value.split(","):
        var clean := item.strip_edges()
        if not clean.is_empty():
            result.append(clean)
    return result
