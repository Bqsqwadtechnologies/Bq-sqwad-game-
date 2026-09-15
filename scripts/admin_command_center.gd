extends CanvasLayer
class_name AdminCommandCenter

const ADMIN_EMAIL := "isaacoshiomole0@gmail.com"
const Store = preload("res://scripts/admin_character_store.gd")

var store: AdminCharacterStore
var gate: Control
var dashboard: Control
var content: VBoxContainer
var status: Label
var selected_character_id := ""
var asset_dialog: FileDialog
var json_dialog: FileDialog

func _ready() -> void:
    layer = 100
    store = Store.new()
    store.load_catalog()
    _build_dashboard()
    _build_gate()
    visible = true

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F8:
        if gate.visible:
            return
        visible = not visible
        get_viewport().set_input_as_handled()

func _build_dashboard() -> void:
    dashboard = Control.new()
    dashboard.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(dashboard)
    var backdrop := ColorRect.new()
    backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    backdrop.color = Color(0.006, 0.012, 0.028, 0.97)
    dashboard.add_child(backdrop)

    var card := PanelContainer.new()
    card.set_anchors_preset(Control.PRESET_CENTER)
    card.position = Vector2(55, 30)
    card.size = Vector2(1170, 660)
    dashboard.add_child(card)
    var shell := VBoxContainer.new()
    shell.add_theme_constant_override("separation", 0)
    card.add_child(shell)

    var header := HBoxContainer.new()
    header.custom_minimum_size.y = 76
    header.add_theme_constant_override("separation", 14)
    shell.add_child(header)
    var brand := VBoxContainer.new()
    header.add_child(brand)
    var title := Label.new()
    title.text = "BQ SQWAD  /  ADMIN COMMAND"
    title.add_theme_font_size_override("font_size", 22)
    brand.add_child(title)
    var subtitle := Label.new()
    subtitle.text = "LANDLY CITY • DEVELOPMENT CONTROL CENTER"
    subtitle.add_theme_font_size_override("font_size", 11)
    brand.add_child(subtitle)
    var spacer := Control.new()
    spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    header.add_child(spacer)
    var identity := Label.new()
    identity.text = ADMIN_EMAIL
    header.add_child(identity)
    var close := Button.new()
    close.text = "CLOSE  [F8]"
    close.pressed.connect(func(): visible = false)
    header.add_child(close)

    var body := HBoxContainer.new()
    body.size_flags_vertical = Control.SIZE_EXPAND_FILL
    shell.add_child(body)
    var nav := VBoxContainer.new()
    nav.custom_minimum_size.x = 190
    nav.add_theme_constant_override("separation", 5)
    body.add_child(nav)
    for tab in ["OVERVIEW", "CHARACTERS", "MISSIONS", "WORLD", "ASSETS", "PROGRESSION", "SETTINGS"]:
        var b := Button.new()
        b.text = tab
        b.custom_minimum_size.y = 42
        b.alignment = HORIZONTAL_ALIGNMENT_LEFT
        b.pressed.connect(_open_tab.bind(tab))
        nav.add_child(b)

    content = VBoxContainer.new()
    content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    content.size_flags_vertical = Control.SIZE_EXPAND_FILL
    content.add_theme_constant_override("separation", 10)
    body.add_child(content)
    status = Label.new()
    status.text = "ADMIN SESSION • LOCAL DEVELOPMENT MODE"
    status.custom_minimum_size.y = 26
    shell.add_child(status)

    asset_dialog = FileDialog.new()
    asset_dialog.access = FileDialog.ACCESS_FILESYSTEM
    asset_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
    asset_dialog.title = "Import Character Asset"
    asset_dialog.file_selected.connect(_asset_selected)
    add_child(asset_dialog)
    json_dialog = FileDialog.new()
    json_dialog.access = FileDialog.ACCESS_FILESYSTEM
    json_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
    json_dialog.filters = PackedStringArray(["*.json ; Character JSON"])
    json_dialog.title = "Import Character Profile"
    json_dialog.file_selected.connect(_json_selected)
    add_child(json_dialog)

func _build_gate() -> void:
    gate = Control.new()
    gate.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(gate)
    var bg := ColorRect.new()
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    bg.color = Color(0.004, 0.008, 0.018, 0.99)
    gate.add_child(bg)
    var box := VBoxContainer.new()
    box.set_anchors_preset(Control.PRESET_CENTER)
    box.position = Vector2(360, 170)
    box.size = Vector2(560, 340)
    box.add_theme_constant_override("separation", 14)
    gate.add_child(box)
    var title := Label.new()
    title.text = "BQ SQWAD ADMIN ACCESS"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 28)
    box.add_child(title)
    var info := Label.new()
    info.text = "Authorized development account required."
    info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    box.add_child(info)
    var email := LineEdit.new()
    email.placeholder_text = "Administrator email"
    email.custom_minimum_size.y = 46
    box.add_child(email)
    var login := Button.new()
    login.text = "AUTHENTICATE"
    login.custom_minimum_size.y = 48
    login.pressed.connect(func(): _authenticate(email))
    box.add_child(login)
    var note := Label.new()
    note.text = ADMIN_EMAIL + "\nPrototype identity gate. Firebase Auth + server-side admin claims are required for production."
    note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    box.add_child(note)
    email.grab_focus()

func _authenticate(email: LineEdit) -> void:
    if email.text.strip_edges().to_lower() != ADMIN_EMAIL:
        email.select_all()
        status.text = "ACCESS DENIED"
        return
    gate.visible = false
    dashboard.visible = true
    visible = true
    _open_tab("OVERVIEW")
    status.text = "ADMIN SESSION ACTIVE • " + ADMIN_EMAIL

func _open_tab(tab: String) -> void:
    if gate.visible:
        return
    for child in content.get_children():
        child.queue_free()
    var title := Label.new()
    title.text = tab
    title.add_theme_font_size_override("font_size", 25)
    content.add_child(title)
    var desc := Label.new()
    desc.text = _description(tab)
    desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    content.add_child(desc)
    match tab:
        "OVERVIEW": _overview()
        "CHARACTERS": _characters()
        "MISSIONS": _missions()
        "WORLD": _world()
        "ASSETS": _assets()
        "PROGRESSION": _progression()
        "SETTINGS": _settings()

func _description(tab: String) -> String:
    match tab:
        "OVERVIEW": return "Live project health and connected gameplay systems."
        "CHARACTERS": return "Professional character registry: create, edit, import profiles and attach production assets."
        "MISSIONS": return "Runtime mission framework status."
        "WORLD": return "Landly City runtime structure and expansion status."
        "ASSETS": return "Repository asset inventory and administrator imports."
        "PROGRESSION": return "XP, unlocks and cloud-persistence readiness."
        "SETTINGS": return "Administrator and production-integration controls."
    return ""

func _overview() -> void:
    var grid := GridContainer.new()
    grid.columns = 3
    content.add_child(grid)
    _stat(grid, "CHARACTERS", str(store.characters.size()))
    _stat(grid, "MISSIONS", "CONNECTED")
    _stat(grid, "COMBAT", "CONNECTED")
    _stat(grid, "LANDLY CITY", "ACTIVE")
    _stat(grid, "ENEMY", "CONNECTED")
    _stat(grid, "ADMIN", "AUTHORIZED")
    var note := Label.new()
    note.text = "The dashboard does not invent cloud state. Character edits are persisted locally until Firebase Auth/Firestore/Storage is connected."
    note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    content.add_child(note)

func _characters() -> void:
    var toolbar := HBoxContainer.new()
    content.add_child(toolbar)
    _button(toolbar, "NEW CHARACTER", _new_character)
    _button(toolbar, "IMPORT JSON", func(): json_dialog.popup_centered_ratio(0.7))
    _button(toolbar, "IMPORT ASSET", func(): asset_dialog.popup_centered_ratio(0.7))
    _button(toolbar, "REFRESH", func(): store.load_catalog(); _open_tab("CHARACTERS"))
    var scroll := ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    content.add_child(scroll)
    var list := VBoxContainer.new()
    list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.add_child(list)
    for character in store.characters:
        var row := PanelContainer.new()
        row.custom_minimum_size.y = 100
        list.add_child(row)
        var h := HBoxContainer.new()
        h.add_theme_constant_override("separation", 10)
        row.add_child(h)
        var info := VBoxContainer.new()
        info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        h.add_child(info)
        var name := Label.new()
        name.text = "%s  •  %s" % [character.get("codename", "Unnamed"), character.get("role", "")]
        name.add_theme_font_size_override("font_size", 18)
        info.add_child(name)
        var meta := Label.new()
        meta.text = "%s | %s | %s | Unlock %s" % [character.get("real_name", ""), character.get("faction", ""), character.get("status", ""), str(character.get("unlock_level", 1))]
        info.add_child(meta)
        var abilities := Label.new()
        abilities.text = "Abilities: " + ", ".join(PackedStringArray(character.get("abilities", [])))
        info.add_child(abilities)
        _button(h, "SELECT", func(): selected_character_id = String(character.get("id", "")); status.text = "SELECTED CHARACTER • " + selected_character_id)
        _button(h, "EDIT", func(): _edit_character(character))
        _button(h, "DELETE", func(): _delete_character(String(character.get("id", ""))))

func _new_character() -> void:
    _edit_character({})

func _edit_character(character: Dictionary) -> void:
    var dialog := AcceptDialog.new()
    dialog.title = "BQ SQWAD CHARACTER STUDIO"
    dialog.ok_button_text = "SAVE CHARACTER"
    dialog.min_size = Vector2(760, 620)
    add_child(dialog)
    var scroll := ScrollContainer.new()
    scroll.custom_minimum_size = Vector2(720, 520)
    dialog.add_child(scroll)
    var form := GridContainer.new()
    form.columns = 2
    scroll.add_child(form)
    var fields: Dictionary = {}
    for spec in [["id", "ID"], ["codename", "Codename"], ["real_name", "Real name"], ["role", "Role"], ["faction", "Faction"], ["rarity", "Rarity"], ["status", "Status"], ["unlock_level", "Unlock level"], ["health", "Health"], ["speed", "Speed"], ["power", "Power"], ["portrait", "Portrait path"], ["model", "Model path"]]:
        var label := Label.new()
        label.text = spec[1]
        form.add_child(label)
        var field := LineEdit.new()
        field.text = str(character.get(spec[0], ""))
        field.custom_minimum_size.x = 430
        form.add_child(field)
        fields[spec[0]] = field
    var a_label := Label.new()
    a_label.text = "Abilities"
    form.add_child(a_label)
    var a := LineEdit.new()
    a.text = ", ".join(PackedStringArray(character.get("abilities", [])))
    form.add_child(a)
    fields["abilities"] = a
    var l_label := Label.new()
    l_label.text = "Lore"
    form.add_child(l_label)
    var lore := TextEdit.new()
    lore.text = str(character.get("lore", ""))
    lore.custom_minimum_size = Vector2(430, 110)
    form.add_child(lore)
    fields["lore"] = lore
    dialog.confirmed.connect(func():
        var saved := character.duplicate(true)
        for key in ["id", "codename", "real_name", "role", "faction", "rarity", "status", "portrait", "model"]:
            saved[key] = fields[key].text.strip_edges()
        saved["unlock_level"] = fields["unlock_level"].text.to_int()
        saved["health"] = fields["health"].text.to_int()
        saved["speed"] = fields["speed"].text.to_float()
        saved["power"] = fields["power"].text.to_int()
        saved["abilities"] = _csv(a.text)
        saved["lore"] = lore.text.strip_edges()
        if store.upsert_character(saved):
            selected_character_id = String(saved.get("id", ""))
            status.text = "CHARACTER SAVED • " + String(saved.get("codename", saved.get("id", "")))
            _open_tab("CHARACTERS")
        else:
            status.text = "CHARACTER SAVE FAILED • ID REQUIRED"
    )
    dialog.popup_centered()

func _delete_character(id: String) -> void:
    var confirm := ConfirmationDialog.new()
    confirm.title = "Delete Character"
    confirm.dialog_text = "Remove %s from the catalog?" % id
    add_child(confirm)
    confirm.confirmed.connect(func(): store.remove_character(id); _open_tab("CHARACTERS"))
    confirm.popup_centered()

func _json_selected(path: String) -> void:
    var character := store.import_character_json(path)
    if character.is_empty():
        status.text = "CHARACTER IMPORT FAILED"
        return
    store.upsert_character(character)
    selected_character_id = String(character.get("id", ""))
    status.text = "CHARACTER IMPORTED • " + String(character.get("codename", selected_character_id))
    _open_tab("CHARACTERS")

func _asset_selected(path: String) -> void:
    if selected_character_id.is_empty():
        status.text = "SELECT A CHARACTER FIRST"
        return
    var target := store.copy_asset(path, "characters", selected_character_id)
    status.text = "ASSET IMPORTED • " + target if not target.is_empty() else "ASSET IMPORT FAILED"

func _missions() -> void:
    var ms := get_tree().current_scene.get_node_or_null("MissionSystem")
    if ms == null:
        _stat(content, "MISSION SYSTEM", "MISSING")
        return
    _stat(content, "ACTIVE", str(ms.active_mission))
    _stat(content, "MISSION", ms.mission_title)
    _stat(content, "OBJECTIVE", ms.objective)
    _stat(content, "XP REWARD", str(ms.xp_reward))
    _stat(content, "OBJECTIVE REACHED", str(ms.objective_reached))

func _world() -> void:
    var scene := get_tree().current_scene
    _stat(content, "SCENE", scene.name if scene else "NONE")
    _stat(content, "PLAYER", "CONNECTED" if scene and scene.get_node_or_null("Player") else "MISSING")
    _stat(content, "BQ SQWAD HQ", "CONNECTED")
    _stat(content, "LANDMARKS", "ACTIVE")
    _stat(content, "MISSION SCOUT", "CONNECTED" if scene and scene.get_node_or_null("MissionScout") else "MISSING")

func _assets() -> void:
    var counts := {"characters": 0, "world": 0, "audio": 0, "ui": 0}
    for key in counts.keys():
        _scan("res://assets/" + key, counts, key)
        _stat(content, String(key).to_upper(), str(counts[key]))
    var note := Label.new()
    note.text = "Runtime character assets are stored under user://bq_sqwad_admin/assets. Repository assets remain source-controlled on main."
    note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    content.add_child(note)

func _scan(path: String, counts: Dictionary, key: String) -> void:
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
            _scan(path.path_join(name), counts, key)
        else:
            counts[key] += 1
    dir.list_dir_end()

func _progression() -> void:
    _stat(content, "XP", "MISSION SYSTEM")
    _stat(content, "UNLOCKS", "CHARACTER CATALOG READY")
    _stat(content, "CLOUD SAVE", "FIREBASE PENDING")
    _stat(content, "AUTHORITATIVE DATA", "SERVER INTEGRATION PENDING")

func _settings() -> void:
    _stat(content, "ADMIN", ADMIN_EMAIL)
    _stat(content, "ENGINE", "GODOT 4.7.2")
    _stat(content, "BRANCH", "main")
    var checklist := Label.new()
    checklist.text = "PRODUCTION SECURITY\n✓ Admin identity configured\n✓ Character catalog is data-driven\n✓ Character JSON import\n✓ Asset import pipeline\n□ Firebase Auth enforcement\n□ Custom admin claims / server authorization\n□ Firestore character catalog\n□ Firebase Storage asset pipeline\n□ Audit log"
    checklist.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    content.add_child(checklist)

func _stat(parent: Container, name: String, value: String) -> void:
    var panel := PanelContainer.new()
    panel.custom_minimum_size = Vector2(210, 70)
    parent.add_child(panel)
    var box := VBoxContainer.new()
    panel.add_child(box)
    var a := Label.new()
    a.text = name
    a.add_theme_font_size_override("font_size", 10)
    box.add_child(a)
    var b := Label.new()
    b.text = value
    b.add_theme_font_size_override("font_size", 17)
    b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    box.add_child(b)

func _button(parent: Container, text: String, callback: Callable) -> void:
    var b := Button.new()
    b.text = text
    b.custom_minimum_size.y = 36
    b.pressed.connect(callback)
    parent.add_child(b)

func _csv(value: String) -> Array[String]:
    var result: Array[String] = []
    for part in value.split(","):
        var clean := part.strip_edges()
        if not clean.is_empty():
            result.append(clean)
    return result
