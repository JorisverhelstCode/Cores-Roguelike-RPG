extends Control

signal hex_clicked(hex: Vector2i)

var units: Dictionary = {}
var hexes: Array[Vector2i] = []
var highlighted_moves: Array[Vector2i] = []
var highlighted_targets: Array[Vector2i] = []

func set_combat_state(unit_data: Dictionary, hex_data: Array[Vector2i], move_hexes: Array[Vector2i] = [], target_hexes: Array[Vector2i] = []) -> void:
	units = unit_data
	hexes = hex_data
	highlighted_moves = move_hexes
	highlighted_targets = target_hexes
	queue_redraw()

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var local_position: Vector2 = event.position
		var clicked_hex: Vector2i = screen_to_hex(local_position)
		if hexes.has(clicked_hex):
			hex_clicked.emit(clicked_hex)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.07, 0.11, 0.08), true)
	for hex in hexes:
		var center := hex_to_screen(hex)
		var fill: Color = Color(0.95, 0.90, 0.72, 0.08)
		var stroke: Color = Color(0.95, 0.90, 0.72, 0.22)
		if highlighted_moves.has(hex):
			fill = Color(0.30, 0.66, 0.92, 0.42)
			stroke = Color(0.54, 0.84, 1.0, 0.92)
		if highlighted_targets.has(hex):
			fill = Color(0.95, 0.20, 0.14, 0.45)
			stroke = Color(1.0, 0.42, 0.34, 0.94)
		draw_hex(center, 28.0, fill, stroke)
	for unit_id in units:
		var unit: Dictionary = units[unit_id]
		var center: Vector2 = hex_to_screen(Vector2i(int(unit.q), int(unit.r)))
		var fill: Color = Color(0.36, 0.62, 0.70) if unit.team == "player" else Color(0.84, 0.36, 0.22)
		draw_hex(center, 20.0, fill, Color(0.97, 0.95, 0.85))
		draw_string(ThemeDB.fallback_font, center + Vector2(-16, 5), "You" if unit.team == "player" else "Foe", HORIZONTAL_ALIGNMENT_CENTER, 32, 12, Color(0.97, 0.95, 0.85))

func draw_hex(center: Vector2, radius: float, fill: Color, stroke: Color) -> void:
	var points := PackedVector2Array()
	for side in 6:
		var angle := deg_to_rad(60.0 * side - 30.0)
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	draw_colored_polygon(points, fill)
	if stroke.a > 0.0:
		var outline := PackedVector2Array(points)
		outline.append(points[0])
		draw_polyline(outline, stroke, 2.0)

func hex_to_screen(hex: Vector2i) -> Vector2:
	var radius := 28.0
	return size * 0.5 + Vector2(
		radius * sqrt(3.0) * (float(hex.x) + float(hex.y) / 2.0),
		radius * 1.5 * float(hex.y)
	)

func screen_to_hex(point: Vector2) -> Vector2i:
	var radius := 28.0
	var centered := point - size * 0.5
	var q := ((sqrt(3.0) / 3.0) * centered.x - (1.0 / 3.0) * centered.y) / radius
	var r := ((2.0 / 3.0) * centered.y) / radius
	return round_hex(q, r)

func round_hex(q: float, r: float) -> Vector2i:
	var x := q
	var z := r
	var y := -x - z
	var rx := roundi(x)
	var ry := roundi(y)
	var rz := roundi(z)
	var x_diff := absf(float(rx) - x)
	var y_diff := absf(float(ry) - y)
	var z_diff := absf(float(rz) - z)
	if x_diff > y_diff and x_diff > z_diff:
		rx = -ry - rz
	elif y_diff > z_diff:
		ry = -rx - rz
	else:
		rz = -rx - ry
	return Vector2i(rx, rz)
