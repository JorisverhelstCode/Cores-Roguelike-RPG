extends Control

signal location_clicked(location_id: String)
signal map_clicked(map_position: Vector2)

const VIEW_RADIUS := 155.0
const MIN_ZOOM := 1.0
const MAX_ZOOM := 5.0
const ZOOM_STEP := 1.18
const START_ZOOM := 3.2
const LOCATION_CLICK_RADIUS := 12.0
const LEFT_DRAG_THRESHOLD := 6.0

var map_texture: Texture2D
var locations: Array[Dictionary] = []
var route_links: Array[Array] = []
var player_pos := Vector2.ZERO
var discovered: Dictionary = {}
var explored: Array[Dictionary] = []
var current_location_id := ""
var zoom_level := 1.0
var pan_offset := Vector2.ZERO
var is_panning := false
var last_pan_position := Vector2.ZERO
var pan_button := MOUSE_BUTTON_NONE
var pan_start_position := Vector2.ZERO
var left_dragged := false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		clamp_pan_offset()
		queue_redraw()

func configure(texture: Texture2D, location_data: Array[Dictionary], routes: Array[Array]) -> void:
	map_texture = texture
	locations = location_data
	route_links = routes
	clamp_pan_offset()
	queue_redraw()

func set_world_state(pos: Vector2, known: Dictionary, explored_spots: Array[Dictionary], active_location_id: String) -> void:
	player_pos = pos
	discovered = known
	explored = explored_spots
	current_location_id = active_location_id
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var button_event: InputEventMouseButton = event
		if button_event.pressed and button_event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_at(button_event.position, zoom_level * ZOOM_STEP)
			accept_event()
			return
		if button_event.pressed and button_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_at(button_event.position, zoom_level / ZOOM_STEP)
			accept_event()
			return
		if button_event.button_index == MOUSE_BUTTON_LEFT:
			if button_event.pressed:
				is_panning = true
				pan_button = MOUSE_BUTTON_LEFT
				pan_start_position = button_event.position
				last_pan_position = button_event.position
				left_dragged = false
			else:
				var was_click := is_panning and pan_button == MOUSE_BUTTON_LEFT and not left_dragged
				is_panning = false
				pan_button = MOUSE_BUTTON_NONE
				if was_click:
					handle_left_click(button_event.position)
			accept_event()
			return
		if button_event.button_index == MOUSE_BUTTON_MIDDLE or button_event.button_index == MOUSE_BUTTON_RIGHT:
			is_panning = button_event.pressed
			pan_button = button_event.button_index if button_event.pressed else MOUSE_BUTTON_NONE
			last_pan_position = button_event.position
			accept_event()
			return
		accept_event()
	if event is InputEventMouseMotion and is_panning:
		var motion_event: InputEventMouseMotion = event
		if pan_button == MOUSE_BUTTON_LEFT and motion_event.position.distance_to(pan_start_position) > LEFT_DRAG_THRESHOLD:
			left_dragged = true
		pan_offset += motion_event.position - last_pan_position
		last_pan_position = motion_event.position
		clamp_pan_offset()
		queue_redraw()
		accept_event()

func handle_left_click(screen_position: Vector2) -> void:
	for location in locations:
		if not discovered.has(location.id):
			continue
		var rect := get_map_rect()
		var location_screen: Vector2 = map_to_screen(Vector2(float(location.x), float(location.y)), rect)
		if screen_position.distance_to(location_screen) <= LOCATION_CLICK_RADIUS:
			location_clicked.emit(location.id)
			return

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
		var zoom_t := clampf((zoom_level - MIN_ZOOM) / (MAX_ZOOM - MIN_ZOOM), 0.0, 1.0)
		var radius := lerpf(5.0, 16.0 if active else 13.0, zoom_t)
		draw_circle(pos, radius, Color(0.84, 0.68, 0.25, 0.88))
		draw_arc(pos, radius + 3.0, 0.0, TAU, 36, Color(0.97, 0.95, 0.85, 0.92), maxf(1.0, radius * 0.16))
		if zoom_level >= 1.65:
			var font_size := int(round(lerpf(11.0, 19.0, zoom_t)))
			draw_string(ThemeDB.fallback_font, pos + Vector2(-26, -radius - 7), location.name, HORIZONTAL_ALIGNMENT_LEFT, 90, font_size, Color(0.97, 0.95, 0.85))

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
	var base_rect := get_base_map_rect()
	var draw_size := base_rect.size * zoom_level
	return Rect2(base_rect.get_center() - draw_size * 0.5 + pan_offset, draw_size)

func get_base_map_rect() -> Rect2:
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

func zoom_in() -> void:
	zoom_at(size * 0.5, zoom_level * ZOOM_STEP)

func zoom_out() -> void:
	zoom_at(size * 0.5, zoom_level / ZOOM_STEP)

func reset_zoom() -> void:
	zoom_level = MIN_ZOOM
	pan_offset = Vector2.ZERO
	queue_redraw()

func focus_on_map_position(map_pos: Vector2, next_zoom: float = START_ZOOM) -> void:
	if map_texture == null:
		return
	zoom_level = clampf(next_zoom, MIN_ZOOM, MAX_ZOOM)
	var base_rect := get_base_map_rect()
	var draw_size := base_rect.size * zoom_level
	var screen_center := size * 0.5
	var desired_position := screen_center - Vector2(map_pos.x * draw_size.x, map_pos.y * draw_size.y)
	pan_offset = desired_position - (base_rect.get_center() - draw_size * 0.5)
	clamp_pan_offset()
	queue_redraw()

func zoom_at(screen_pos: Vector2, next_zoom: float) -> void:
	if map_texture == null:
		return
	var previous_rect := get_map_rect()
	var map_anchor := Vector2(
		(screen_pos.x - previous_rect.position.x) / previous_rect.size.x,
		(screen_pos.y - previous_rect.position.y) / previous_rect.size.y
	)
	zoom_level = clampf(next_zoom, MIN_ZOOM, MAX_ZOOM)
	if is_equal_approx(zoom_level, MIN_ZOOM):
		pan_offset = Vector2.ZERO
	else:
		var base_rect := get_base_map_rect()
		var draw_size := base_rect.size * zoom_level
		var desired_position := screen_pos - Vector2(map_anchor.x * draw_size.x, map_anchor.y * draw_size.y)
		pan_offset = desired_position - (base_rect.get_center() - draw_size * 0.5)
		clamp_pan_offset()
	queue_redraw()

func clamp_pan_offset() -> void:
	if map_texture == null or zoom_level <= MIN_ZOOM:
		pan_offset = Vector2.ZERO
		return
	var base_rect := get_base_map_rect()
	var draw_size := base_rect.size * zoom_level
	var extra := (draw_size - base_rect.size) * 0.5
	pan_offset.x = clampf(pan_offset.x, -extra.x, extra.x)
	pan_offset.y = clampf(pan_offset.y, -extra.y, extra.y)

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
