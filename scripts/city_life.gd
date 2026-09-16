extends Node
class_name BQCityLife

## Procedural civilian life layer for Landly City.
## Uses lightweight MeshInstance3D actors so the prototype stays mobile-friendly.

const ROLES := ["CITIZEN", "STUDENT", "WORKER", "OFFICER", "COMMUTER"]
const COLORS := [
    Color(0.16, 0.20, 0.26),
    Color(0.24, 0.28, 0.34),
    Color(0.12, 0.25, 0.32),
    Color(0.28, 0.18, 0.12),
    Color(0.18, 0.12, 0.25)
]

var population_root: Node3D
var rng := RandomNumberGenerator.new()

func build(parent: Node3D) -> void:
    population_root = Node3D.new()
    population_root.name = "LandlyCityPopulation"
    parent.add_child(population_root)
    rng.seed = 420826

    _build_citizens()
    _build_traffic()
    _build_service_zones()

func _build_citizens() -> void:
    # Keep the initial population deliberately bounded for Android performance.
    var spawn_points := [
        Vector3(-24, 0.9, -8), Vector3(-16, 0.9, 8), Vector3(18, 0.9, -8),
        Vector3(26, 0.9, 10), Vector3(-34, 0.9, 18), Vector3(34, 0.9, -18),
        Vector3(-12, 0.9, 34), Vector3(12, 0.9, 34), Vector3(-44, 0.9, -12),
        Vector3(44, 0.9, 12), Vector3(-30, 0.9, -38), Vector3(30, 0.9, -38),
        Vector3(-2, 0.9, 24), Vector3(2, 0.9, -24), Vector3(-52, 0.9, 20),
        Vector3(52, 0.9, -20)
    ]

    for i in range(spawn_points.size()):
        _add_person(spawn_points[i], ROLES[i % ROLES.size()], i)

func _add_person(position: Vector3, role: String, index: int) -> void:
    var person := Node3D.new()
    person.name = role + "_%02d" % index
    person.position = position
    population_root.add_child(person)

    var body := MeshInstance3D.new()
    var capsule := CapsuleMesh.new()
    capsule.radius = 0.28
    capsule.height = 1.35
    body.mesh = capsule
    body.position.y = 0.7
    body.material_override = _material(COLORS[index % COLORS.size()])
    person.add_child(body)

    var head := MeshInstance3D.new()
    var sphere := SphereMesh.new()
    sphere.radius = 0.2
    sphere.height = 0.4
    head.mesh = sphere
    head.position.y = 1.55
    head.material_override = _material(Color(0.32, 0.22, 0.17))
    person.add_child(head)

    var label := Label3D.new()
    label.text = role
    label.font_size = 10
    label.outline_size = 3
    label.position = Vector3(0, 2.0, 0)
    label.modulate = Color(0.7, 0.82, 0.9, 0.8)
    label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    person.add_child(label)

func _build_traffic() -> void:
    var traffic_root := Node3D.new()
    traffic_root.name = "LandlyTraffic"
    population_root.add_child(traffic_root)

    var routes := [
        [Vector3(-52, 0.55, 0), Vector3(52, 0.55, 0)],
        [Vector3(0, 0.55, -52), Vector3(0, 0.55, 52)],
        [Vector3(-52, 0.55, 36), Vector3(52, 0.55, 36)]
    ]
    var colors := [Color(0.08, 0.18, 0.28), Color(0.22, 0.22, 0.25), Color(0.12, 0.3, 0.2), Color(0.32, 0.16, 0.12)]

    for i in range(12):
        var car := MeshInstance3D.new()
        car.name = "CityVehicle_%02d" % i
        var box := BoxMesh.new()
        box.size = Vector3(1.8, 0.7, 3.2)
        car.mesh = box
        car.position = routes[i % routes.size()][0].lerp(routes[i % routes.size()][1], float(i % 6) / 6.0)
        car.material_override = _material(colors[i % colors.size()])
        traffic_root.add_child(car)

func _build_service_zones() -> void:
    _add_sign(Vector3(-44, 2.4, -44), "LANDLY POLICE")
    _add_sign(Vector3(44, 2.4, -44), "LANDLY HOSPITAL")
    _add_sign(Vector3(-44, 2.4, 44), "LANDLY COLLEGE")
    _add_sign(Vector3(44, 2.4, 44), "DEFENCE ZONE")

func _add_sign(position: Vector3, title: String) -> void:
    var sign := Label3D.new()
    sign.text = title
    sign.font_size = 20
    sign.outline_size = 5
    sign.position = position
    sign.modulate = Color(0.55, 0.82, 1.0)
    sign.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    population_root.add_child(sign)

func _material(color: Color) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = 0.72
    return material
