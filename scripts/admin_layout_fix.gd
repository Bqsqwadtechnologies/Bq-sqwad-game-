extends Node

func _ready() -> void:
    await get_tree().process_frame
    var admin := get_parent()
    if admin == null or admin.get_child_count() < 2:
        return
    var dashboard := admin.get_child(0) as Control
    var gate := admin.get_child(1) as Control
    if dashboard != null and dashboard.get_child_count() > 1:
        var card := dashboard.get_child(1) as Control
        if card != null:
            card.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE, 0)
    if gate != null and gate.get_child_count() > 1:
        var box := gate.get_child(1) as Control
        if box != null:
            box.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE, 0)
