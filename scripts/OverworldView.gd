extends Control

signal location_clicked(location_id: String)
signal map_clicked(map_position: Vector2)

const VIEW_RADIUS := 155.0

var map_texture: Texture2D
var locations: Array[Dictionary] = []
var route_links: Array[Array] = []
var player_pos := Vector2.ZERO
var discovered: Dictionary = {}
var explored: Array[Dictionary] = []
var current_location_id := ""

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

func configure(texture: Texture2D, location_data: Array[Dictionary], routes: Array[Array]) -> void:
	map_texture = texture
	locations = location_data
	route_links = routes
	queue_redraw()

func set_world_state(pos: Vector2, known: Dictionary, explored_spots: Array[Dictionary], active_location_id: String) -> void:
	player_pos = pos
	discovered = known
	explored = explored_spots
	current_location_id = active_location_id
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var map_point := screen_to_map(event.position)
		for location in locations:
			if not discovered.has(location.id):
				continue
			var location_point: Vector2 = Vector2(float(location.x), float(location.y))
			if map_point.distance_to(location_point) < 0.026:
				location_clicked.emit(location.id)
				return
		map_clicked.emit(map_point)

func _draw() -> void:
	if map_texture == null:
		return

	var rect := get_map_rect()
	draw_texture_rect(map_texture, rect, false)
	draw_routes(rect)
	draw_fog(rect)
	draw_locations(rect)
	draw_player(rect)

func draw_routes(rect: Rect2) -> void:
	for link in route_links:
		if not discovered.has(link[0]) or not discovered.has(link[1]):
			continue
		var from_location: Dictionary = get_location(str(link[0]))
		var to_location: Dictionary = get_location(str(link[1]))
		if from_location.is_empty() or to_location.is_empty():
			continue
		draw_route_line(
			map_to_screen(Vector2(from_location.x, from_location.y), rect),
			map_to_screen(Vector2(to_location.x, to_location.y), rect),
			Color(0.96, 0.9, 0.72, 0.55),
			4.0,
			14.0
		)

func draw_fog(rect: Rect2) -> void:
	var cell := 28.0
	var columns := int(ceil(rect.size.x / cell))
	var rows := int(ceil(rect.size.y / cell))
	for x_index in columns:
		for y_index in rows:
			var cell_rect := Rect2(rect.position + Vector2(x_index * cell, y_index * cell), Vector2(cell + 1.0, cell + 1.0))
			if is_screen_point_revealed(cell_rect.get_center(), rect):
				continue
			draw_rect(cell_rect, Color.BLACK, true)

func is_screen_point_revealed(point: Vector2, rect: Rect2) -> bool:
	for spot in explored:
		var center: Vector2 = map_to_screen(spot.pos, rect)
		var radius: float = float(spot.radius) * rect.size.x / 2048.0
		if point.distance_to(center) <= radius:
			return true
	return false

func draw_locations(rect: Rect2) -> void:
	for location in locations:
		if not discovered.has(location.id):
			continue
		var pos: Vector2 = map_to_screen(Vector2(float(location.x), float(location.y)), rect)
		var active: bool = str(location.id) == current_location_id
		draw_circle(pos, 18.0 if active else 14.0, Color(0.84, 0.68, 0.25, 0.92))
		draw_arc(pos, 21.0 if active else 17.0, 0.0, TAU, 36, Color(0.97, 0.95, 0.85, 0.95), 3.0)
		draw_string(ThemeDB.fallback_font, pos + Vector2(-28, -25), location.name, HORIZONTAL_ALIGNMENT_LEFT, 90, 18, Color(0.97, 0.95, 0.85))

func draw_player(rect: Rect2) -> void:
	var pos := map_to_screen(player_pos, rect)
	var points := PackedVector2Array([
		pos + Vector2(0, -24),
		pos + Vector2(18, 16),
		pos + Vector2(0, 8),
		pos + Vector2(-18, 16)
	])
	draw_colored_polygon(points, Color(0.36, 0.62, 0.70))
	var outline := PackedVector2Array(points)
	outline.append(points[0])
	draw_polyline(outline, Color(0.97, 0.95, 0.85), 3.0)

func get_map_rect() -> Rect2:
	var texture_size := map_texture.get_size()
	var scale: float = minf(size.x / texture_size.x, size.y / texture_size.y)
	var draw_size := texture_size * scale
	return Rect2((size - draw_size) * 0.5, draw_size)

func map_to_screen(map_pos: Vector2, rect: Rect2) -> Vector2:
	return rect.position + Vector2(map_pos.x * rect.size.x, map_pos.y * rect.size.y)

func screen_to_map(screen_pos: Vector2) -> Vector2:
	var rect := get_map_rect()
	return Vector2(
		(screen_pos.x - rect.position.x) / rect.size.x,
		(screen_pos.y - rect.position.y) / rect.size.y
	)

func get_location(location_id: String) -> Dictionary:
	for location in locations:
		if location.id == location_id:
			return location
	return {}

func draw_route_line(from: Vector2, to: Vector2, color: Color, width: float, dash: float) -> void:
	var distance := from.distance_to(to)
	if distance <= 0.0:
		return
	var direction := (to - from).normalized()
	var cursor := 0.0
	while cursor < distance:
		var start := from + direction * cursor
		var end: Vector2 = from + direction * minf(cursor + dash, distance)
		draw_line(start, end, color, width)
		cursor += dash * 2.0
