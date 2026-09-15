extends Node

func _ready() -> void:
    await get_tree().process_frame
    var admin := get_parent()
    if admin == null:
        return
    var dashboard: Control = admin.get_node_or_null("Dashboard")
    var gate: Control = admin.get_node_or_null("Gate")
    if dashboard != null and dashboard.get_child_count() > 1:
        var card := dashboard.get_child(1) as Control
        if card != null:
            card.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE, 0)
    if gate != null and gate.get_child_count() > 1:
        var box := gate.get_child(1) as Control
        if box != null:
            box.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE, 0)
