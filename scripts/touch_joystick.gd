extends Control
class_name BQTouchJoystick

@export var radius := 78.0
var active_touch := -1
var center := Vector2.ZERO

func _ready() -> void:
    custom_minimum_size = Vector2(radius * 2.0, radius * 2.0)
    mouse_filter = Control.MOUSE_FILTER_STOP
    queue_redraw()

func _draw() -> void:
    center = size * 0.5
    draw_circle(center, radius, Color(0.02, 0.08, 0.14, 0.72))
    draw_arc(center, radius, 0.0, TAU, 64, Color(0.25, 0.7, 1.0, 0.7), 3.0)
    var knob := center
    if active_touch >= 0:
        knob = get_local_mouse_position()
        knob = center + (knob - center).limit_length(radius * 0.55)
    draw_circle(knob, radius * 0.32, Color(0.15, 0.55, 0.85, 0.85))

func _gui_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed:
            active_touch = event.index
            _update_actions(event.position)
        elif event.index == active_touch:
            active_touch = -1
            _release_actions()
            queue_redraw()
    elif event is InputEventScreenDrag and event.index == active_touch:
        _update_actions(event.position)

func _update_actions(local_position: Vector2) -> void:
    var delta := local_position - size * 0.5
    var normalized := delta.limit_length(radius) / radius
    Input.action_release("move_left")
    Input.action_release("move_right")
    Input.action_release("move_forward")
    Input.action_release("move_back")
    if normalized.x < -0.22:
        Input.action_press("move_left", clamp(-normalized.x, 0.0, 1.0))
    elif normalized.x > 0.22:
        Input.action_press("move_right", clamp(normalized.x, 0.0, 1.0))
    if normalized.y < -0.22:
        Input.action_press("move_forward", clamp(-normalized.y, 0.0, 1.0))
    elif normalized.y > 0.22:
        Input.action_press("move_back", clamp(normalized.y, 0.0, 1.0))
    queue_redraw()

func _release_actions() -> void:
    for action in ["move_left", "move_right", "move_forward", "move_back"]:
        Input.action_release(action)
